//
//  MapRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/14.
//

import Foundation
import MapKit
import RxSwift

enum LocalError: Error {
    case addressError
    case locationAuthError
}

protocol MapRepositoryProtocol {
    func start()
    func stop()
    func observeAuthorizationStatus() -> Observable<Bool>
    func fetchCurrentLocation() -> Result<GeoPoint, Error>
    func setSearchText(with searchText: String) -> Observable<[Space]>
    func fetchLocationName(using geoPoint: GeoPoint) -> Observable<Address>
    func reverseGeocode(point: GeoPoint) -> Observable<Address?>
}

final class MapRepository: MapRepositoryProtocol {
    private let locationManager: LocationManagerProtocol
    
    init(locationManager: LocationManagerProtocol) {
        self.locationManager = locationManager
    }
    
    func start() {
        self.locationManager.core.startUpdatingLocation()
    }
    
    func stop() {
        self.locationManager.core.stopUpdatingLocation()
    }
    
    func observeAuthorizationStatus() -> Observable<Bool> {
        return self.locationManager
            .observeAuthorizationStatus()
            .map { status -> Bool in
                self.locationManager.checkAuthorization(status: status)
            }
    }
    
    func fetchCurrentLocation() -> Result<GeoPoint, Error> {
        return self.locationManager.fetchCurrentLocation()
    }
    
    func setSearchText(with searchText: String) -> Observable<[Space]> {
        return self.locationManager.setSearchText(with: searchText)
    }
    
    func fetchLocationName(using geoPoint: GeoPoint) -> Observable<Address> {
        
        return Observable.create { [weak self] observer in
            self?.locationManager.reverseGeocode(point: geoPoint, completion: { address in
                observer.onNext(address!)
            })
            
            return Disposables.create()
        }
    }
    
    func reverseGeocode(point: GeoPoint) -> Observable<Address?> {
        return Observable.create { observer in
            self.locationManager.reverseGeocode(point: point) { address in
                observer.onNext(address)
            }
            
            return Disposables.create()
        }
    }
}

