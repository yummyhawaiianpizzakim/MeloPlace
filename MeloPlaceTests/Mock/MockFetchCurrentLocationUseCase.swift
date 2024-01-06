//
//  MockFetchCurrentLocationUseCase.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/06.
//

import Foundation
import RxSwift
@testable import MeloPlace

class MockFetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol {
    func fetchCurrentLocation() -> Observable<(GeoPoint, Address)> {
        let geoPoint = GeoPoint.stub()
        let address = Address(full: "", simple: "")
        return Observable.just((geoPoint, address))
    }
}
