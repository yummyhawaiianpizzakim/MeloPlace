//
//  MainViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay


struct MainViewModelActions {
    let showAddMeloPlaceView: () -> Void
    let showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
}

class MainViewModel {
    let disposeBag = DisposeBag()
    let fireBaseService = FireBaseNetworkService.shared
    let spotifyService = SpotifyService.shared
    
    var actions: MainViewModelActions?
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    func setActions(actions: MainViewModelActions) {
        self.actions = actions
    }
    
    struct Input {
        var viewWillAppear: Observable<Void>
        var didSelectItem: Observable<IndexPath>
        var didTapAddButton: Observable<Void>
        var didTapPlayPauseButton: Observable<Void>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<[MeloPlace]>(value: [])
        let music = PublishRelay<Music?>()
        let isPaused = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppear
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.fetchMeloPlace()
            })
            .disposed(by: self.disposeBag)
        
        input.didSelectItem
            .withUnretained(self)
            .subscribe { owner, indexPath in
                let meloPlaces = owner.meloPlaces.value
                owner.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapAddButton
            .withUnretained(self)
            .subscribe { owner , _ in
                print("tap")
                owner.actions?.showAddMeloPlaceView()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapPlayPauseButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.spotifyService.didTapPauseOrPlay()
            }
            .disposed(by: self.disposeBag)
        
        self.meloPlaces
            .bind(to: output.dataSource)
            .disposed(by: self.disposeBag)
        
        self.spotifyService.isPaused
            .bind(to: output.isPaused)
            .disposed(by: self.disposeBag)
        
//        self.mock.bind(to: output.dataSource).disposed(by: self.disposeBag)
        
        return output
    }
}

extension MainViewModel {
//    func fetchMeloPlace() {
//        var array: [MeloPlace] = []
//        self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
//            .map({ dto in
//                let melo = dto.toDomain()
//                array.append(melo)
//            })
//            .subscribe { _ in
//                self.meloPlaces.accept(array)
//            }
//            .disposed(by: self.disposeBag)
//     
//    }
    
    func fetchMeloPlace() {
        self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
            .map { dto in
                dto.toDomain()
            }
            .toArray()
            .catchAndReturn([])
            .subscribe(onSuccess: { meloPlaces in
                self.meloPlaces.accept(meloPlaces)
            }, onFailure: { error in
                print(error)
            })
            .disposed(by: self.disposeBag)
    }
    
    func playMusic(uri: String) {
        self.spotifyService.playMusic(uri: uri)
    }
    
}
