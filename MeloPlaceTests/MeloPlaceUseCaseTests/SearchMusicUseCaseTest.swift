//
//  SearchMusicUseCaseTest.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2023/12/16.
//

import XCTest
import RxSwift
import RxTest
@testable import MeloPlace

final class SearchMusicUseCaseTest: XCTestCase {
    private var searchMusicUseCase: SearchMusicUseCaseProtocol!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    
    override func setUpWithError() throws {
        self.searchMusicUseCase = SearchMusicUseCase(spotifyRepository: MockSpotifyRepository())
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        self.searchMusicUseCase = nil
        self.scheduler = nil
        self.disposeBag = nil
    }
    
    func test_search() {
        let musics = self.scheduler.createObserver(Bool.self)
        
        self.scheduler?.createHotObservable([
            .next(200, ("", "track")),
            .next(300, ("BTS", "track"))
        ])
        .withUnretained(self)
        .flatMap({ owner, val in
            let (query, type) = val
            return owner.searchMusicUseCase.search(query: query, type: type)
                .map({ _ in
                    return true
                })
                .catchAndReturn(false)
        })
        .bind(to: musics)
        .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(musics.events, [
            .next(200, false),
            .next(300, true)
        ])
    }
}
