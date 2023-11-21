//
//  SpotifyRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/03.
//

import Foundation
import RxSwift

protocol SpotifyRepositoryProtocol: AnyObject {
    func tryConnect() -> Observable<Bool>
    func playMusic(uri: String)
    func stopPlayingMusic()
    func searchMusic(query: String, type: String) -> Observable<[Music]>
    func fetchSpotifyUserProfile() -> Observable<SpotifyUserProfile>
    func updatePlayerState()
    func observePlayerState() -> Observable<Bool> 
}

class SpotifyRepository: SpotifyRepositoryProtocol {
    private let spotifyService: SpotifyServiceProtocol
    
    init(spotifyService: SpotifyServiceProtocol) {
        self.spotifyService = spotifyService
    }
    
    func tryConnect() -> Observable<Bool> {
        self.spotifyService.tryConnect()
        return self.spotifyService.isToken.asObservable()
    }
    
    func playMusic(uri: String) {
        self.spotifyService.playMusic(uri: uri)
    }
    
    func stopPlayingMusic() {
        self.spotifyService.stopPlayingMusic()
    }
    
    func searchMusic(query: String, type: String) -> Observable<[Music]> {
        return self.spotifyService.searchMusic(query: query, type: type)
            .map { $0.toDomain() }
            .catchAndReturn([])
    }
    
    func fetchSpotifyUserProfile() -> Observable<SpotifyUserProfile> {
        return self.spotifyService.fetchSpotifyUserProfile()
            .map { $0.toDomain() }
    }
    
    func updatePlayerState() {
        self.spotifyService.didTapPauseOrPlay()
    }
    
    func observePlayerState() -> Observable<Bool> {
        return self.spotifyService.isPaused.asObservable()
    }
    
}
