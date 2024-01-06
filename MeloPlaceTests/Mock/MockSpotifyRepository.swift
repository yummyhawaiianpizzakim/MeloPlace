//
//  MockSpotifyRepository.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/05.
//

import Foundation
import RxSwift
@testable import MeloPlace

enum MockURLSessionError: Error {
    case emptyQuery
}

class MockSpotifyRepository: SpotifyRepositoryProtocol {
    func tryConnect() -> Observable<Bool> {
        return Observable.just(true)
    }
    
    func playMusic(uri: String) {
        
    }
    
    func stopPlayingMusic() {
        
    }
    
    func searchMusic(query: String, type: String) -> Observable<[Music]> {
        if query.isEmpty {
            return Observable.error(MockURLSessionError.emptyQuery)
        }
        
        return Observable.just([])
    }
    
    func fetchSpotifyUserProfile() -> Observable<SpotifyUserProfile> {
        let profile = SpotifyUserProfile(id: "", name: "", email: "", imageURL: "", imageWidth: 0, imageHeight: 0)
        return Observable.just(profile)
    }
    
    func updatePlayerState() {
        
    }
    
    func observePlayerState() -> Observable<Bool> {
        return Observable.just(true)
    }
    
    
}
