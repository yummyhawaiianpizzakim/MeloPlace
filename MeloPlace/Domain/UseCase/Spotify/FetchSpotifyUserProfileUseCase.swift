//
//  FetchSpotifyUserProfileUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol FetchSpotifyUserProfileUseCaseProtocol: AnyObject {
    func fetch() -> Observable<SpotifyUserProfile>
}

class FetchSpotifyUserProfileUseCase: FetchSpotifyUserProfileUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func fetch() -> Observable<SpotifyUserProfile> {
        return self.spotifyRepository.fetchSpotifyUserProfile()
    }
}
