//
//  MockReverseGeoCodeUseCase.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/06.
//

import Foundation
import RxSwift
@testable import MeloPlace

final class MockReverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol {
    func reverse(point: GeoPoint) -> Observable<Space> {
        let space = Space.stub()
        return Observable.just(space)
    }
    
}
