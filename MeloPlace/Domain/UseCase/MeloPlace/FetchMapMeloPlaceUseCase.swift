//
//  FetchMapMeloPlaceUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/14.
//

import Foundation
import RxSwift

protocol FetchMapMeloPlaceUseCaseProtocol: AnyObject {
    func fetch(region: Region, tapState: Int) -> Observable<[MeloPlace]> 
}

final class FetchMapMeloPlaceUseCase: FetchMapMeloPlaceUseCaseProtocol {
    var userRepository: UserRepositoryProtocol
    var meloPlaceRepository: MeloPlaceRepositoryProtocol
    var mapRepository: MapRepositoryProtocol
    let disposeBag = DisposeBag()
    
    init(userRepository: UserRepositoryProtocol,
         meloPlaceRepository: MeloPlaceRepositoryProtocol,
         mapRepository: MapRepositoryProtocol) {
        self.userRepository = userRepository
        self.meloPlaceRepository = meloPlaceRepository
        self.mapRepository = mapRepository
    }
    
    func fetch(region: Region, tapState: Int) -> Observable<[MeloPlace]> {
        let user = self.userRepository.fetchUserInfo().share()
        let userID = user.map { $0.id }
        let following = user.map { $0.following }
        let value = Observable.combineLatest(userID, following)
        
        return fetch(region: region, tapState: tapState, value: value)
        
    }
    
}

private extension FetchMapMeloPlaceUseCase {
    func fetch(region: Region, tapState: Int, value: Observable<(String, [String])>) -> Observable<[MeloPlace]> {
        return value
            .flatMap {[weak self] val -> Observable<[MeloPlace]> in
                guard let self
                else { return Observable.error(NetworkServiceError.noDataError)}
                let (id, following) = val
                switch tapState {
                case 0:
                    return self.meloPlaceRepository.fetchMapMeloPlaces(region: region, userID: [id]).asObservable()
                case 1:
                    
                    return self.meloPlaceRepository.fetchMapMeloPlaces(region: region, userID: following).asObservable()
                default:
                    return Observable.just([])
                }
            }
        
    }
    
    func matchGeoPoint(geoPoint: GeoPoint) -> GeoPoint {
        let geoPoint = self.mapRepository.fetchCurrentLocation()
            switch geoPoint {
            case .success(let geo):
                return geo
            case .failure:
                return GeoPoint.seoulCoordinate
            }
        }
    
}
