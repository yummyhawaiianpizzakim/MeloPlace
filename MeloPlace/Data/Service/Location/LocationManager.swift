//
//  LocationManager.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import CoreLocation
import Foundation
import MapKit
import RxSwift
import RxRelay

protocol LocationManagerProtocol: AnyObject {
    var core: CLLocationManager { get }
    func reverseGeocode(point: GeoPoint, completion: @escaping (Address?) -> Void)
    func observeAuthorizationStatus() -> Observable<CLAuthorizationStatus> 
    func checkAuthorization(status: CLAuthorizationStatus) -> Bool
    func location(_ coordinate: CLLocationCoordinate2D) -> CLLocation
    func distance(capsuleCoordinate: CLLocationCoordinate2D) -> Double
    func checkLocationAuthorization(completion: @escaping (Bool) -> Void)
    func setSearchText(with searchText: String) -> Observable<[Space]> 
    func fetchCurrentLocation() -> Result<GeoPoint, Error>
    func fetchLocationName(using geoPoint: GeoPoint) -> Observable<Address> 
}

final class LocationManager: NSObject, LocationManagerProtocol {
    let disposeBag = DisposeBag()
    
    private var searchCompleter = MKLocalSearchCompleter()
    
    var results = BehaviorRelay<[Space]>(value: [])

    override init() {
        super.init()
        searchCompleter.delegate = self
    }

    let core: CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5
        manager.requestWhenInUseAuthorization()

        return manager
    }()

    var coordinate: CLLocationCoordinate2D? {
        core.location?.coordinate
    }

    private let geocoder = CLGeocoder()
    private let locale = Locale(identifier: "ko_KR")
    
    func observeAuthorizationStatus() -> Observable<CLAuthorizationStatus> {
        return self.core.rx.didChangeAuthorization
    }

    // 좌표 -> 주소
    func reverseGeocode(point: GeoPoint, completion: @escaping (Address?) -> Void) {
        let location = CLLocation(latitude: point.latitude, longitude: point.longitude)

        geocoder.reverseGeocodeLocation(location, preferredLocale: locale) { placemarks, error in
            guard let placemark = placemarks?.first,
                  error == nil else {
                completion(nil)
                return
            }

            let rawValues = placemark
                .description
                .split(separator: ", ")
                .map { String($0) }

            guard let rawAddress = rawValues.last(where: { $0.hasPrefix("대한민국") }),
//                  let validInfo = rawAddress.components(separatedBy: "@")
                  let validInfo = rawAddress.components(separatedBy: "@")[safe: 0]
            else { // @ 아래로 불필요한 정보
                completion(nil)
                return
            }
            
            var separated = validInfo.components(separatedBy: " ")
            separated.removeFirst()

            let fullAddress = separated.joined(separator: " ")
            let simpleAddress = "\(separated[safe: 0] ?? "") \(separated[safe: 1] ?? "")"

            completion(Address(full: fullAddress, simple: simpleAddress))
        }
    }

    // 위치 권한 상태 확인
    @discardableResult
    func checkAuthorization(status: CLAuthorizationStatus) -> Bool {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            core.startUpdatingLocation()
            return true

        case .restricted, .notDetermined:
            core.requestWhenInUseAuthorization()

        case .denied:
            core.requestWhenInUseAuthorization()

        @unknown default:
            return false
        }

        return false
    }

    func location(_ coordinate: CLLocationCoordinate2D) -> CLLocation {
        return CLLocation(latitude: coordinate.latitude,
                          longitude: coordinate.longitude)
    }

    func distance(capsuleCoordinate: CLLocationCoordinate2D) -> Double {
        guard let currentCoordinate = coordinate else {
            return 0.0
        }
        
        let currentLocation = location(currentCoordinate)
        let capsuleLocation = location(capsuleCoordinate)
        
        return currentLocation.distance(from: capsuleLocation)
    }

    func checkLocationAuthorization(completion: @escaping (Bool) -> Void) {
        switch self.core.authorizationStatus {
        case .denied:
            completion(false)
        case .notDetermined, .restricted:
            self.core.requestWhenInUseAuthorization()
        default:
            completion(true)
            return
        }
    }
    
    func setSearchText(with searchText: String) -> Observable<[Space]> {
        self.searchCompleter.queryFragment = searchText
        return self.results.asObservable()
    }
    
    private func fetchSelectedLocationInfo(with selectedResult: MKLocalSearchCompletion) -> Single<Space?> {
        
        return Single.create { single in
            let searchRequest = MKLocalSearch.Request(completion: selectedResult)
            let search = MKLocalSearch(request: searchRequest)
            search.start { response, error in
                guard error == nil else {
                    return single(.success(nil))
                }
                
                guard let placeMark = response?.mapItems[0].placemark else {
                    return single(.success(nil))
                }
                
                let coordinate = placeMark.coordinate
                return single(
                    .success(
                        Space(
                            name: selectedResult.title,
                            address: selectedResult.subtitle,
                            lat: coordinate.latitude,
                            lng: coordinate.longitude
                        )))
            }
            return Disposables.create()
        }
    }
    
    func fetchCurrentLocation() -> Result<GeoPoint, Error> {
        guard let lat = self.core.location?.coordinate.latitude,
              let lng = self.core.location?.coordinate.longitude
        else { return  .failure(LocalError.locationAuthError) }
        
        return .success(GeoPoint(latitude: lat, longitude: lng))
    }
    
    func fetchLocationName(using geoPoint: GeoPoint) -> Observable<Address> {
        
        return Observable.create { [weak self] observer in
            self?.reverseGeocode(point: geoPoint, completion: { address in
                observer.onNext(address!)
            })
            
            return Disposables.create()
        }
    }
    
}

extension LocationManager: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Observable.zip(completer.results.compactMap {
            self.fetchSelectedLocationInfo(with: $0).asObservable()
        })
        .map { locations -> [Space] in
            let filtered = locations.filter { $0 != nil }
            return filtered.compactMap { $0 }
        }
        .bind(to: results)
        .disposed(by: self.disposeBag)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print(error)
    }
}
