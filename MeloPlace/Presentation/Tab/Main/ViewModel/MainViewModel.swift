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
    let showMeloPlaceDetailView: (_ meloPlace: MeloPlace) -> Void
}

class MainViewModel {
    let disposeBag = DisposeBag()
    let fireBaseService = FireBaseNetworkService.shared
    let spotifyService = SpotifyService.shared
    
    var actions: MainViewModelActions?
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    let mock = BehaviorRelay<[MeloPlace]>(
        value:
            [MeloPlace(id: UUID().uuidString,
                       userId: "",
                       musicURI: "",
                       images: [""],
                       title: "asdasd",
                       description: "zxczxc",
                       address: "asdqwe",
                       simpleAddress: "asdasf",
                       latitude: 10.0000,
                       longitude: 10.0000,
                       memoryDate: Date()
                      ),
             MeloPlace(id: UUID().uuidString,
                       userId: "",
                       musicURI: "",
                       images: [""],
                       title: "asdasaad",
                       description: "zxczvvxc",
                       address: "asdddqwe",
                       simpleAddress: "asdaaasf",
                       latitude: 10.0000,
                       longitude: 10.0000,
                       memoryDate: Date()
                      )
            ]
    )
    
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
            .subscribe { owner, index in
                let meloPlace = owner.meloPlaces.value[index.row]
                owner.actions?.showMeloPlaceDetailView(meloPlace)
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
    func fetchMeloPlace() {
        var array: [MeloPlace] = []
        self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
            .map({ dto in
                let melo = dto.toDomain()
                array.append(melo)
            })
            .subscribe { _ in
                self.meloPlaces.accept(array)
            }
            .disposed(by: self.disposeBag)
     
    }
    
    func playMusic(indexPath: IndexPath) {
        let int = indexPath.row
        var musicURI = self.meloPlaces.value[int].musicURI
        self.spotifyService.playMusic(uri: musicURI)
    }
    
//    func fetchMeloPlace1() -> Single<[MeloPlace]> {
//        return self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
//               .map { dto in
//                   dto.toDomain()
//               }
//               .scan([], accumulator: { (accumulator: [MeloPlace], current: MeloPlace) -> [MeloPlace] in
//                   return accumulator + [current]
//               })
//               .takeLast(1)
//               .asSingle()
//    }

    
//    func fetchMeloPlace() -> Single<[MeloPlace]> {
//        return self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
//            .map { dto in
//                dto.toDomain()
//            }
//            .toArray()
//            .catchAndReturn([])
//    }
}
