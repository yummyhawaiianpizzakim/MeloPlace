//
//  MusicListViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

struct MusicListViewModelActions {
    let closeMusicListView: () -> Void
    let submitSelectedMusic: (_ music: Music) -> Void
}

final class MusicListViewModel {
    let disposeBag = DisposeBag()
    private let searchMusicUseCase: SearchMusicUseCaseProtocol
    private let playMusicUseCase: PlayMusicUseCaseProtocol
    
    let musics = BehaviorRelay<[Music]>(value: [])
    let selectedMusic = BehaviorRelay<Music?>(value: nil)

    var actions: MusicListViewModelActions?
    
    init(searchMusicUseCase: SearchMusicUseCaseProtocol, playMusicUseCase: PlayMusicUseCaseProtocol) {
        self.searchMusicUseCase = searchMusicUseCase
        self.playMusicUseCase = playMusicUseCase
    }
    
    struct Input {
        var searchText: Observable<String>
        var didSelectItem: Observable<IndexPath>
        var didDeselectItem: Observable<IndexPath>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let dataSource: Driver<[Music]>
        let isDoneButtonEnable: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.searchText
            .skip(1)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap({ owner, query in
                owner.searchMusicUseCase.search(query: query, type: "track")
            })
            .bind(to: self.musics)
            .disposed(by: self.disposeBag)
        
        input.didSelectItem
            .withUnretained(self)
            .map { owner, indexPath in
                return owner.musics.value[indexPath.row]
            }
            .do { [weak self] music in
                self?.playMusicUseCase.play(uri: music.URI)
            }
            .bind(to: self.selectedMusic)
            .disposed(by: self.disposeBag)
        
        input.didDeselectItem
            .withUnretained(self)
            .subscribe { owner, indexPath in
                owner.selectedMusic.accept(nil)
            }
            .disposed(by: self.disposeBag)
        
        let isEnable = self.selectedMusic
            .compactMap { music in
                if let music {
                    return true
                } else {
                    return false
                }
            }
            .asDriver(onErrorJustReturn: false)
         
        input.didTapDoneButton
            .withLatestFrom(self.selectedMusic)
            .subscribe {[weak self] music in
                guard let music = music else { return }
                self?.actions?.submitSelectedMusic(music)
            }
            .disposed(by: self.disposeBag)
        
        return Output(dataSource: self.musics.asDriver(),
                      isDoneButtonEnable: isEnable)
    }
    
    func setActions(actions: MusicListViewModelActions) {
        self.actions = actions
    }
    
}
