//
//  MainViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay


struct MainViewModelActions {
    let showAddMeloPlaceView: () -> Void
    let showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
}

final class MainViewModel {
    let disposeBag = DisposeBag()
    private let fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol
    private let playMusicUseCase: PlayMusicUseCaseProtocol
    private let updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol
    private let observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol
    
    var actions: MainViewModelActions?
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    init(fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol, playMusicUseCase: PlayMusicUseCaseProtocol, updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol, observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol) {
        self.fetchMeloPlaceUseCase = fetchMeloPlaceUseCase
        self.playMusicUseCase = playMusicUseCase
        self.updatePlayerStateUseCase = updatePlayerStateUseCase
        self.observePlayerStateUseCase = observePlayerStateUseCase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let didSelectItem: Observable<IndexPath>
        let didTapPlayPauseButton: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[MeloPlace]>
        let isPaused: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        input.viewWillAppear
            .flatMap({ _ in
                self.fetchMeloPlaceUseCase.fetch(id: nil)
            })
            .bind(to: self.meloPlaces)
            .disposed(by: self.disposeBag)
        
        input.didSelectItem
            .withUnretained(self)
            .subscribe { owner, indexPath in
                let meloPlaces = owner.meloPlaces.value
                owner.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapPlayPauseButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.updatePlayerStateUseCase.update()
            }
            .disposed(by: self.disposeBag)
        
        let isPaused = self.observePlayerStateUseCase
            .observe()
            .asDriver(onErrorJustReturn: false)
        
        return Output(dataSource: self.meloPlaces.asDriver(),
                      isPaused: isPaused)
    }
    
    func setActions(actions: MainViewModelActions) {
        self.actions = actions
    }
    
}

extension MainViewModel {
    func playMusic(uri: String) {
        self.playMusicUseCase.play(uri: uri)
    }
    
}
