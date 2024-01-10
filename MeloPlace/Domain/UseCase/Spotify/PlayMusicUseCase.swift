//
//  PlayMusicUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation

protocol PlayMusicUseCaseProtocol: AnyObject {
    func play(uri: String)
    func stop() 
}

final class PlayMusicUseCase: PlayMusicUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func play(uri: String) {
        self.spotifyRepository.playMusic(uri: uri)
    }
    
    func stop() {
        self.spotifyRepository.stopPlayingMusic()
    }
}
