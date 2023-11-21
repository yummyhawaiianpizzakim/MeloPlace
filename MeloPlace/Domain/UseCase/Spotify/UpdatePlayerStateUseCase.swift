//
//  UpdatePlayerStateUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol UpdatePlayerStateUseCaseProtocol: AnyObject {
    func update()
}

class UpdatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func update() {
        return self.spotifyRepository.updatePlayerState()
    }
}
