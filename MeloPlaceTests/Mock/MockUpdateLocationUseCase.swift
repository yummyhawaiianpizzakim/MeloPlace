//
//  MockUpdateLocationUseCase.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/06.
//

import Foundation
import RxSwift
@testable import MeloPlace

class MockUpdateLocationUseCase: UpdateLocationUseCaseProtocol {
    func executeLocationTracker() {
        
    }
    
    func terminateLocationTracker() {
        
    }
    
    func observeAuthorizationStatus() -> Observable<Bool> {
        return Observable.just(true)
    }
    
    
}
