//
//  MeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
//import UIKit
import MapKit
import RxSwift
import RxCocoa
import RxRelay

struct MeloPlaceDetailViewModelActions {
    let showCommentsView: (_ meloPlace: MeloPlace) -> Void
    let closeCommentsView: () -> Void
}

class MeloPlaceDetailViewModel {
    let disposeBag = DisposeBag()
    private let playMusicUseCase: PlayMusicUseCaseProtocol
    private let updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol
    private let observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol

    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    let indexPath = BehaviorRelay<IndexPath>(value: [0, 0])
    
    var actions: MeloPlaceDetailViewModelActions?
    
    init(playMusicUseCase: PlayMusicUseCaseProtocol, updatePlayerStateUseCase: UpdatePlayerStateUseCaseProtocol, observePlayerStateUseCase: ObservePlayerStateUseCaseProtocol) {
        self.playMusicUseCase = playMusicUseCase
        self.updatePlayerStateUseCase = updatePlayerStateUseCase
        self.observePlayerStateUseCase = observePlayerStateUseCase
    }
    
    struct Input {
        var didTapPlayPauseButton: Observable<Void>
        var didTapCommentsView: Observable<Int>
        var didTapBackButton: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<(meloPlaces: [MeloPlace], indexPath: IndexPath)>
        let isPaused: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.didTapPlayPauseButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.updatePlayerStateUseCase.update()
            }
            .disposed(by: self.disposeBag)
        
        let isPaused = self.observePlayerStateUseCase
            .observe()
            .asDriver(onErrorJustReturn: false)
            
        input.didTapCommentsView
            .withUnretained(self)
            .subscribe { owner, index in
                let meloPlace = self.meloPlaces.value[index]
                owner.actions?.showCommentsView(meloPlace)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapBackButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.actions?.closeCommentsView()
            }
            .disposed(by: self.disposeBag)
        
        let dataSources = Observable.combineLatest(self.meloPlaces, self.indexPath)
            .withUnretained(self)
            .flatMap { owner, values -> Observable<(meloPlaces: [MeloPlace], indexPath: IndexPath)> in
                let (meloPlaces, indexPath) = values
                return Observable.just((meloPlaces: meloPlaces, indexPath: indexPath))
            }
            .asDriver(onErrorJustReturn: ([MeloPlace](), IndexPath()))
        
        return Output(dataSource: dataSources, isPaused: isPaused)
    }
    
    func setActions(actions: MeloPlaceDetailViewModelActions) {
        self.actions = actions
    }
}

private extension MeloPlaceDetailViewModel {

}

extension MeloPlaceDetailViewModel {
    func playMusic(uri: String) {
        self.playMusicUseCase.play(uri: uri)
    }
    
}
