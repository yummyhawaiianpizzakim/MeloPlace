//
//  MockFetchMapMeloPlaceUseCase.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/06.
//

import Foundation
import RxSwift
@testable import MeloPlace

enum MockUseCaseError: Error {
    case fetchMapMeloPlacse
}

final class MockFetchMapMeloPlaceUseCase: FetchMapMeloPlaceUseCaseProtocol {
    func fetch(region: Region, tapState: Int) -> Observable<[MeloPlace]> {
        
        return Observable.just([])
    }
    
}
