//
//  BrowseViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct BrowseViewModelActions {
    let showSearchUserView: () -> Void
    let showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
    let showAnotherUserProfileView: (_ id: String) -> Void
    let showCommentsView: (_ meloPlace: MeloPlace) -> Void
}

final class BrowseViewModel {
    let disposeBag = DisposeBag()
    private let fetchBrowseUseCase: FetchBrowseUseCaseProtocol
    private let playMusicUseCase: PlayMusicUseCaseProtocol
    private let updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol
    private let observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol
    
    private var actions: BrowseViewModelActions?
    
    let browses = BehaviorRelay<[Browse]>(value: [])
    let isLastFetch = BehaviorRelay<Bool>(value: false)
    
    init(fetchBrowseUseCase: FetchBrowseUseCaseProtocol, playMusicUseCase: PlayMusicUseCaseProtocol, updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol, observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol) {
        self.fetchBrowseUseCase = fetchBrowseUseCase
        self.playMusicUseCase = playMusicUseCase
        self.updatePlayerStateUseCase = updatePlayerStateUseCase
        self.observePlayerStateUseCase = observePlayerStateUseCase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let didTapSearchBar: Observable<Void>
        let pagination: Observable<Void>
    }
    
    struct Output {
        let browses: Driver<[Browse]>
    }
    
    func transform(input: Input) -> Output {
        self.fetchBrowseUseCase
            .fetch(limit: 5, isInit: true)
            .debug("firstBrowse")
            .bind(to: self.browses)
            .disposed(by: self.disposeBag)
        
        input.viewWillAppear
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.playMusicUseCase.stop()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapSearchBar
            .withUnretained(self)
            .bind { owner, _ in
                owner.actions?.showSearchUserView()
            }
            .disposed(by: self.disposeBag)
        
        input.pagination
            .debug("pagination")
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                return owner.fetchBrowseUseCase.fetch(limit: 5, isInit: false)
            }
            .withUnretained(self)
            .do(onNext: { owner, browses in
                browses.isEmpty ?
                owner.isLastFetch.accept(true)
                :
                owner.isLastFetch.accept(false)
            })
            .map { owner, browses in
                var oldBrowses = owner.browses.value
                return oldBrowses + browses
            }
            .bind(to: self.browses)
            .disposed(by: self.disposeBag)
        
            
        return Output(browses: self.browses.asDriver())
    }
    
    func setActions(actions: BrowseViewModelActions) {
        self.actions = actions
    }
}

extension BrowseViewModel {
    func showDetailView(meloPlaceID: String) {
        let meloPlaces = self.browses.value.map { $0.meloPlace }
        meloPlaces.enumerated().forEach { val in
            let (index, meloPlace) = val
            if meloPlace.id == meloPlaceID {
                let indexPath = IndexPath(row: index, section: 0)
                self.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            }
        }
        
    }
    
    func showAnotherUserProfileView(userID: String) {
        self.actions?.showAnotherUserProfileView(userID)
    }
    
    func showCommentsView(meloPlaceID: String) {
        let meloPlaces = self.browses.value.map { $0.meloPlace }
        meloPlaces.forEach { meloPlace in
            if meloPlace.id == meloPlaceID {
                self.actions?.showCommentsView(meloPlace)
            }
        }
        
    }
    
    func playMusic(with uri: String?) -> Observable<Bool> {
        guard let uri else { return Observable.just(false) }
        self.playMusicUseCase.play(uri: uri)
        self.updatePlayerStateUseCase.update()
        let isPaused = self.observePlayerStateUseCase.observe()
        return isPaused
    }
}
