//
//  asd.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import RxSwift
import RxCocoa
import CoreLocation

final class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, CLLocationManagerDelegate, DelegateProxyType {
    
    static func registerKnownImplementations() {
        self.register { manager -> RxCLLocationManagerDelegateProxy in
            RxCLLocationManagerDelegateProxy(parentObject: manager, delegateProxy: self)
        }
    }
    
    static func currentDelegate(for object: CLLocationManager) -> CLLocationManagerDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: CLLocationManagerDelegate?, to object: CLLocationManager) {
        object.delegate = delegate
    }
}

// MARK: location의 변화를 관찰할 observable 추가!
extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: self.base)
    }
    
    var didChangeAuthorization: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidChangeAuthorization(_:)))
            .map { param in
                return (param[0] as? CLLocationManager)?.authorizationStatus ?? CLAuthorizationStatus.notDetermined
            }
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { param in
                return param[1] as? [CLLocation] ?? []
            }
    }
    
    var willExitMonitoringRegion: Observable<CLRegion?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didExitRegion:)))
            .map { param in
                return param[1] as? CLRegion
            }
    }
}
