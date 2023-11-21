//
//  ObservePlayerStateUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol ObservePlayerStateUseCaseProtocol: AnyObject {
    func observe() -> Observable<Bool> 
}

class ObservePlayerStateUseCase: ObservePlayerStateUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func observe() -> Observable<Bool> {
        return self.spotifyRepository.observePlayerState()
    }
}
