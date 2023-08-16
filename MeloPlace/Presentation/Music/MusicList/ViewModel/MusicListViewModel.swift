//
//  MusicListViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import RxSwift
import RxRelay

protocol MusicListViewModelDelegate: AnyObject {
    func musicDidSelect(music: Music)
}

struct MusicListViewModelActions {
    let showMusicPlayerView: (_ music: Music) -> Void
    let closeMusicListView: () -> Void
}

class MusicListViewModel {
    var spotifyService = SpotifyService.shared
    
    struct Input {
        var connectSpotify: Observable<Void>
        var searchText: Observable<String>
        var didTapCell: Observable<IndexPath>
//        var selectedMusic: Observable<Music>
//        var deSelectedMusic: Observable<Music>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<[Music]>(value: [])
        let isDoneButtonEnable = BehaviorRelay<Bool>(value: false)
    }
    
    let disposeBag = DisposeBag()
    
    let selectedMusic = BehaviorRelay<Music?>(value: nil)
    
    var actions: MusicListViewModelActions?
    weak var delegate: MusicListViewModelDelegate?
    
    func setActions(actions: MusicListViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        input.connectSpotify
            .withUnretained(self)
            .subscribe { owner, _ in
                
                owner.spotifyService.tryConnect()
            }
            .disposed(by: self.disposeBag)
        
        input.searchText
            .skip(1)
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { owner, query in
                owner.spotifyService.searchMusic(query: query, type: "track")
                    .subscribe(onNext: { dto in
                        let music = dto.toDomain()
                        output.dataSource.accept(music)
                    }, onError: { error in
                        print(error)
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapCell
            .withUnretained(self)
            .subscribe { owner, indexPath in
                let music = output.dataSource.value[indexPath.row]
                owner.selectedMusic.accept(music)
                print("trackName: \(music.name)")
                owner.spotifyService.playMusic(uri: music.URI)
                output.isDoneButtonEnable.accept(true)
//                owner.actions?.showMusicPlayerView(music)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapDoneButton
            .withLatestFrom(self.selectedMusic.asObservable())
            .subscribe {[weak self] music in
                guard let music = music else { return }
                self?.delegate?.musicDidSelect(music: music)
                self?.actions?.closeMusicListView()
            }
            .disposed(by: self.disposeBag)
        
        return output
    }
}
