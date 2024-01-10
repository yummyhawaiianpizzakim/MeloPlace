//
//  SearchMusicUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol SearchMusicUseCaseProtocol: AnyObject {
    func search(query: String, type: String) -> Observable<[Music]> 
}

final class SearchMusicUseCase: SearchMusicUseCaseProtocol {
    private let spotifyRepository: SpotifyRepositoryProtocol
    
    init(spotifyRepository: SpotifyRepositoryProtocol) {
        self.spotifyRepository = spotifyRepository
    }
    
    func search(query: String, type: String) -> Observable<[Music]> {
        self.spotifyRepository.searchMusic(query: query, type: type)
    }
}
