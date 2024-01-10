//
//  MeloPlaceRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import CoreLocation
import MapKit
import RxSwift

protocol MeloPlaceRepositoryProtocol: AnyObject {
    func createMeloPlace(meloPlace: MeloPlace) -> Observable<MeloPlace> 
    func fetchUserMeloPlace(id: String?) -> Observable<[MeloPlace]>
    func fetchTagedMeloPlace(id: String?) -> Observable<[MeloPlace]> 
    func fetchMapMeloPlaces(region: Region, userID: [String]) -> Observable<[MeloPlace]>
    func fetchBrowseMeloPlace(limit: Int, isInit: Bool) -> Observable<[MeloPlace]>
}

final class MeloPlaceRepository: MeloPlaceRepositoryProtocol {
    let disposeBag = DisposeBag()
    private let fireBaseService: FireBaseNetworkServiceProtocol
    
    init(fireBaseService: FireBaseNetworkServiceProtocol) {
        self.fireBaseService = fireBaseService
    }
    
    func createMeloPlace(meloPlace: MeloPlace) -> Observable<MeloPlace> {
        let dto = meloPlace.toDTO()
        
        return self.fireBaseService.create(dto: dto, access: .meloPlace)
            .map { $0.toDomain() }
            .asObservable()
    }
    
    func fetchUserMeloPlace(id: String?) -> Observable<[MeloPlace]> {
        guard let id = try? self.fireBaseService.determineUserID(id: id)
        else { return Observable.just([])}
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "userID", value: id)
        ]
        return self.fireBaseService.read(type: MeloPlaceDTO.self, access: .meloPlace, firebaseFilter: .isEqualTo(queryList))
            .map({ dto in
                dto.toDomain()
            })
            .toArray()
            .asObservable()
            .catchAndReturn([])
    }
    
    func fetchTagedMeloPlace(id: String?) -> Observable<[MeloPlace]> {
        guard let id = try? self.fireBaseService.determineUserID(id: id)
        else { return Observable.just([]) }
        
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "tagedUsers", value: id )
        ]
        
        return self.fireBaseService
            .read(type: MeloPlaceDTO.self,
                  access: .meloPlace,
                  firebaseFilter: .taged(queryList)
            )
            .map { $0.toDomain() }
            .toArray()
            .debug("fetchTagedMeloPlace")
            .catchAndReturn([])
            .asObservable()
    }
    
    func fetchMapMeloPlaces(region: Region, userID: [String]) -> Observable<[MeloPlace]> {
        let centerGeoPoint = region.center
        let southWest = centerGeoPoint.shiftGeoPoint(latitudeDelta: -(region.spanLatitude / 2), longitudeDelta: -(region.spanLongitude / 2))
        let northEast = centerGeoPoint.shiftGeoPoint(latitudeDelta: (region.spanLatitude / 2), longitudeDelta: (region.spanLongitude / 2))
        
        if userID.isEmpty {
            return Observable.just([])
        }
        
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "latitude", value: southWest.latitude),
            .init(key: "latitude", value: northEast.latitude),
            .init(key: "userID", value: userID)
        ]
        
        let latitudeFilteredMeloPlaces = self.fireBaseService.read(type: MeloPlaceDTO.self, access: .meloPlace, firebaseFilter: .coordinate(queryList))
            .map({ $0.toDomain() })
            .toArray()
            .map { meloPlaces in
                meloPlaces.filter {
                    let meloPlaceLongitude = $0.longitude
                    
                    return southWest.longitude..<northEast.longitude ~= meloPlaceLongitude
                }
            }
            .asObservable()
        
        return latitudeFilteredMeloPlaces
    }
    
    func fetchBrowseMeloPlace(limit: Int, isInit: Bool) -> Observable<[MeloPlace]> {
        if isInit {
            self.fireBaseService.initMeloPlaceLastSnapshot()
        }
        let queryList: [FirebaseQueryDTO] = [.init(key: "memoryDate", value: true)]
        
        let currentUserID = try? self.fireBaseService.determineUserID(id: nil)
        
        return self.fireBaseService.readForPagination(type: MeloPlaceDTO.self, access: .meloPlace, firebaseFilter: .date(queryList))
            .filter({ $0.userID != currentUserID })
            .map { $0.toDomain() }
            .toArray()
            .catchAndReturn([])
            .asObservable()
    }
}

