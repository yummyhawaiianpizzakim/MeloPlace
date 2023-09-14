//
//  AddMeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import RxSwift
import RxRelay

struct AddMeloPlaceViewModelActions {
    let showMeloLocationView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
    let showMusicListView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
    let showSelectDateView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
    let closeAddMeloPlaceView: () -> Void
}

class AddMeloPlaceViewModel {
    let disposeBag = DisposeBag()
    let fireBaseService = FireBaseNetworkService.shared
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var meloPlaceTitle: Observable<String>
        var meloPlaceContent: Observable<String>
        var didTapPlaceButton: Observable<Void>
        var didTapMusicButton: Observable<Void>
        var didTapDateButton: Observable<Void>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let selectedAddress = PublishRelay<Address>()
        let selectedGeoPoint = PublishRelay<GeoPoint>()
        let selectedDate = PublishRelay<Date>()
        let selectedMusic = PublishRelay<Music?>()
        let isEnableDoneButton = BehaviorRelay<Bool>(value: false)
    }
    
    let userInfo = PublishRelay<User>()
    let pickedImage = PublishRelay<Data>()
    let pickedImageURL = PublishRelay<String>()
    let selectedAddress = PublishRelay<Address>()
    let selectedGeoPoint = PublishRelay<GeoPoint>()
    let selectedDate = PublishRelay<Date>()
    let selectedMusic = PublishRelay<Music>()
    
    var actions: AddMeloPlaceViewModelActions?
    
    func setActions(actions: AddMeloPlaceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewDidLoad
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.fetchUser()
                    .subscribe(onSuccess: { user in
                        owner.userInfo.accept(user)
                    }, onFailure: { error in
                        print("user: \(error)")
                    })
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: disposeBag)
        
        input.didTapMusicButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("music tap!")
                owner.actions?.showMusicListView( self )
            })
            .disposed(by: self.disposeBag)
        
        input.didTapPlaceButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showMeloLocationView( self )
            })
            .disposed(by: self.disposeBag)
        
        input.didTapDateButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showSelectDateView( self )
            })
            .disposed(by: self.disposeBag)
        
        let meloPlace = Observable.combineLatest(
            input.meloPlaceTitle, input.meloPlaceContent,
            self.selectedMusic, self.selectedAddress,
            self.selectedGeoPoint, self.selectedDate,
            self.pickedImageURL, self.userInfo
        ).map { (title, content, music, address, geoPoint, date, imageURL, user) in
            
            MeloPlace(id: UUID().uuidString,
                      userId: user.id,
                      musicURI: music.URI,
                      musicName: music.name,
                      musicDuration: music.duration,
                      musicArtist: music.artist,
                      musicAlbum: music.album,
                      musicImageURL: music.imageURL,
                      musicImgaeWidth: music.imageWidth,
                      musicImgaeHeight: music.imageHeightL,
                      images: [imageURL],
                      title: title,
                      description: content,
                      address: address.full,
                      simpleAddress: address.simple,
                      latitude: geoPoint.latitude,
                      longitude: geoPoint.longitude,
                      memoryDate: date
            )
        }
        
//        input.didTapDoneButton
//            .withLatestFrom(self.pickedImage)
//            .map { [weak self] data in
//                guard let self = self else { return }
//                self.fireBaseService.uploadDataStorage(data: data, path: .meloPlaceImages)
//                    .subscribe(onSuccess: { url in
//                        self.pickedImageURL.accept(url)
//                    }, onFailure: { error in
//
//                    })
//                    .disposed(by: disposeBag)
//            }
//            .withLatestFrom(meloPlace)
//            .withUnretained(self)
//            .subscribe(onNext: { owner, meloPlace in
//                owner.addMeloPlace(meloPlace: meloPlace)
//                    .subscribe(onSuccess: { isSuccess in
//                        print("isSuccess: \(isSuccess)")
//                        if isSuccess {
//                            owner.actions?.closeAddMeloPlaceView()
//                        }
//                    }, onFailure: { error in
//                        print(error)
//                    })
//                    .disposed(by: owner.disposeBag)
//            })
//            .disposed(by: self.disposeBag)
        
        input.didTapDoneButton
            .withLatestFrom(self.pickedImage)
            .flatMapLatest { [weak self] data -> Observable<String> in
                guard let self = self else { return .empty() }
                return self.fireBaseService.uploadDataStorage(data: data, path: .meloPlaceImages)
                    .asObservable()
                    .observe(on: MainScheduler.instance) // UI 작업을 위해 메인 스레드에서 실행되도록 설정합니다.
                    .do(onNext: { url in
                        self.pickedImageURL.accept(url)
                    }, onError: { error in
                        print(error)
                    })
            }
            .withLatestFrom(meloPlace)
            .flatMapLatest { [weak self] meloPlace -> Observable<Bool> in
                guard let self = self else { return .empty() }
                return self.addMeloPlace(meloPlace: meloPlace)
                    .asObservable()
            }
            .subscribe(onNext: { [weak self] isSuccess in
                guard let self = self else { return }
                print("isSuccess: \(isSuccess)")
                if isSuccess {
                    self.actions?.closeAddMeloPlaceView()
                }
            }, onError: { error in
                print(error)
            })
            .disposed(by: self.disposeBag)

        
        self.selectedAddress
            .bind(to: output.selectedAddress)
            .disposed(by: self.disposeBag)
        
        self.selectedGeoPoint
            .bind(to: output.selectedGeoPoint)
            .disposed(by: self.disposeBag)
        
        self.selectedDate
            .bind(to: output.selectedDate)
            .disposed(by: self.disposeBag)
        
        self.selectedMusic
            .bind(to: output.selectedMusic)
            .disposed(by: self.disposeBag)
        
        Observable.combineLatest(
            input.meloPlaceTitle, input.meloPlaceContent,
            self.selectedMusic, self.selectedAddress,
            self.selectedGeoPoint, self.selectedDate,
            self.pickedImage, self.userInfo
        ).map { (title, content, music, address, geoPoint, date, iamgeData, user) in
            var isEnable = !title.isEmpty && !content.isEmpty && !music.name.isEmpty &&
            !address.full.isEmpty && !geoPoint.latitude.isNaN && !date.toString().isEmpty &&
            !iamgeData.isEmpty && !user.id.isEmpty ? true : false
            return isEnable
        }
        .bind(to: output.isEnableDoneButton)
        .disposed(by: self.disposeBag)
        
        return output
    }
}

extension AddMeloPlaceViewModel {
    func addImage(data: Data) {
        self.pickedImage.accept(data)
    }
    
    private func fetchUser() -> Single<User> {
        return Single.create {[weak self] single in
            guard let self = self else { return Disposables.create() }
            self.fireBaseService.read(type: UserDTO.self, userCase: .currentUser, access: .user)
                .subscribe { UserDTO in
//                    print("usrdototototo: \(UserDTO)")
                    let user = UserDTO.toDomain()
//                    print("tqtqtqtqt: \(user)")
                    single(.success(user))
                } onError: { error in
                    print("tqtqtqtqt: \(error)")
                    single(.failure(error))
                }
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        

    }
    
    private func addMeloPlace(meloPlace: MeloPlace) -> Single<Bool> {
        return Single.create {[weak self] single in
            guard let self = self else { return Disposables.create() }
            let meloPlaceDTO = meloPlace.toDTO()
            self.fireBaseService.create(dto: meloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
                .subscribe(onSuccess: { dto in
//                    print("meloDTO: \(dto)")
                    single(.success(true))
                }, onFailure: { error in
                    print("meloDTO: \(error)")
                    single(.failure(error))
                })
                .disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
        
        

    }
}

extension AddMeloPlaceViewModel: MeloLocationViewModelDelegate {
    func locationSelected(address: Address, geopoint: GeoPoint) {
        self.selectedAddress.accept(address)
        self.selectedGeoPoint.accept(geopoint)
        print(address, geopoint)
    }
    
}

extension AddMeloPlaceViewModel: SelectDateViewModelDelegate {
    func dateDidSelect(date: Date) {
        self.selectedDate.accept(date)
    }
    
}

extension AddMeloPlaceViewModel: MusicListViewModelDelegate {
    func musicDidSelect(music: Music) {
        self.selectedMusic.accept(music)
    }
}
