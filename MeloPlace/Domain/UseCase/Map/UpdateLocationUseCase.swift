//
//  UpdateLocationUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/16.
//

import Foundation
import RxSwift

protocol UpdateLocationUseCaseProtocol: AnyObject {
    func executeLocationTracker()
    func terminateLocationTracker()
    func observeAuthorizationStatus() -> Observable<Bool>
}

final class UpdateLocationUseCase: UpdateLocationUseCaseProtocol {
    private let mapRepository: MapRepositoryProtocol
    
    init(mapRepository: MapRepositoryProtocol) {
        self.mapRepository = mapRepository
    }
    
    func executeLocationTracker() {
        self.mapRepository.start()
    }
    
    func terminateLocationTracker() {
        self.mapRepository.stop()
    }
    
    func observeAuthorizationStatus() -> Observable<Bool> {
        self.mapRepository.observeAuthorizationStatus()
    }
    
}
