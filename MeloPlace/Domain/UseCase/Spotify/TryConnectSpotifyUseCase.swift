//
//  TryConnectSpotifyUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol TryConnectSpotifyUseCaseProtocol: AnyObject {
    func tryConnect() -> Observable<SpotifyUserProfile> 
}

final class TryConnectSpotifyUseCase: TryConnectSpotifyUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func tryConnect() -> Observable<SpotifyUserProfile> {
        self.spotifyRepository.tryConnect()
            .withUnretained(self)
            .flatMap { owner, isToken in
                print(isToken)
                return isToken ?
                owner.spotifyRepository.fetchSpotifyUserProfile() : Observable.error(NetworkServiceError.noAuthError)
            }
    }
    
    
}
