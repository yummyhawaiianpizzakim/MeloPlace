//
//  AddMeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

struct AddMeloPlaceViewModelActions {
    let showMeloLocationView: () -> Void
    let showSearchView: () -> Void
    let showMusicListView: () -> Void
    let showSelectDateView: () -> Void
    let showSearchUserView: () -> Void
    let closeAddMeloPlaceView: () -> Void
}

final class AddMeloPlaceViewModel {
    let disposeBag = DisposeBag()
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    private let createMeloPlaceUseCase: CreateMeloPlaceUseCaseProtocol
    private let uploadImageUseCase: UploadImageUseCaseProtocol
    
    init(fetchUserUseCase: FetchUserUseCaseProtocol,
         createMeloPlaceUseCase: CreateMeloPlaceUseCaseProtocol,
         uploadImageUseCase: UploadImageUseCaseProtocol) {
        self.fetchUserUseCase = fetchUserUseCase
        self.createMeloPlaceUseCase = createMeloPlaceUseCase
        self.uploadImageUseCase = uploadImageUseCase
    }
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var meloPlaceTitle: Observable<String>
        var meloPlaceContent: Observable<String>
        var didTapPlaceButton: Observable<Void>
        var didTapMusicButton: Observable<Void>
        var didTapDateButton: Observable<Void>
        var didTapTagUserButton: Observable<Void>
        var didTapTagUserDeleteButton: Observable<String>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let selectedSpace: Driver<Space?>
        let selectedDate: Driver<Date?>
        let selectedMusic: Driver<Music?>
        let selectedUserNames: Driver<[String]>
        let deletedUserName: Driver<String>
        let isEnableDoneButton: Driver<Bool>
        let isIndicatorActived: Driver<Bool>
    }
    
    let userInfo = PublishRelay<User>()
    let pickedImage = BehaviorRelay<Data?>(value: nil)
    let pickedImageURL = BehaviorRelay<String>(value: "")
    let selectedSpace = BehaviorRelay<Space?>(value: nil)
    let selectedDate = BehaviorRelay<Date?>(value: nil)
    let selectedMusic = BehaviorRelay<Music?>(value: nil)
    let tagedFollowings = BehaviorRelay<[User]>(value: [])
    let deletedName = BehaviorRelay<String>(value: "")
    let isIndicatorActived = BehaviorRelay<Bool>(value: false)
    
    var actions: AddMeloPlaceViewModelActions?
    
    func setActions(actions: AddMeloPlaceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        self.fetchUserUseCase.fetch(userID: nil)
            .bind(to: self.userInfo)
            .disposed(by: self.disposeBag)
        
        let meloPlace = Observable.combineLatest(
            input.meloPlaceTitle, input.meloPlaceContent,
            self.selectedMusic, self.selectedSpace,
            self.selectedDate, self.pickedImageURL,
            self.userInfo, self.tagedFollowings)
            .map { value in
                return self.generateMeloPlace(value: value)
            }
            .share()
        
        input.didTapMusicButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("music tap!")
                owner.actions?.showMusicListView()
            })
            .disposed(by: self.disposeBag)
        
        input.didTapPlaceButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showSearchView()
            })
            .disposed(by: self.disposeBag)
        
        input.didTapDateButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showSelectDateView()
            })
            .disposed(by: self.disposeBag)
        
        input.didTapTagUserButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.actions?.showSearchUserView()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapTagUserDeleteButton
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .debug("deletetap")
            .do(onNext: { owner, name in
                owner.deletedName.accept(name)
            })
            .map({ owner, name in
                owner.tagedFollowings.value.filter { $0.name != name }
            })
            .bind(to: self.tagedFollowings)
            .disposed(by: self.disposeBag)
        
        input.didTapDoneButton
            .withLatestFrom(self.pickedImage)
            .withUnretained(self)
            .flatMapFirst { owner, data -> Observable<String> in
                guard let data else { return Observable.empty() }
                owner.isIndicatorActived.accept(true)
                return owner.uploadImageUseCase.upload(data: data)
                    .do { owner.pickedImageURL.accept($0) }
            }
            .withLatestFrom(meloPlace)
            .withUnretained(self)
            .flatMapLatest { owner, meloPlace in
                 owner.createMeloPlaceUseCase.create(meloPlace: meloPlace)
            }
            .subscribe { [weak self] meloPlace in
                self?.isIndicatorActived.accept(false)
                self?.actions?.closeAddMeloPlaceView()
            } onError: { error in
                print(error)
            }
            .disposed(by: self.disposeBag)
        
        let tagedFollowingIDs = self.tagedFollowings
            .debug("tagedFollowingIDs")
            .map { $0.map { $0.name} }
            .share()

        let isEnableDoneButton = Observable.combineLatest(
            input.meloPlaceTitle, input.meloPlaceContent,
            self.selectedMusic, self.selectedSpace,
            self.selectedDate, self.pickedImage,
            self.userInfo)
            .map { value in
            let isEnable = self.checkEnableButton(value: value)
            
            return isEnable
            }.share()
        
        return Output(
            selectedSpace: self.selectedSpace.asDriver(onErrorJustReturn: nil),
            selectedDate: self.selectedDate.asDriver(onErrorJustReturn: nil),
            selectedMusic: self.selectedMusic.asDriver(onErrorJustReturn: nil),
            selectedUserNames: tagedFollowingIDs.asDriver(onErrorJustReturn: []),
            deletedUserName: self.deletedName.asDriver(),
            isEnableDoneButton: isEnableDoneButton.asDriver(onErrorJustReturn: false),
            isIndicatorActived: self.isIndicatorActived.asDriver()
        )
    }
}

extension AddMeloPlaceViewModel {
    func addImage(data: Data) {
        self.pickedImage.accept(data)
    }
    
}

private extension AddMeloPlaceViewModel {
    func checkEnableButton(value: (String, String, Music?, Space?, Date?, Data?, User)) -> Bool {
        let (title, content, music, space, date, imageData, user) = value
        guard let music,
              let space,
              let date,
              let imageData
        else { return false }
        let isEnable = (!title.isEmpty && !content.isEmpty && content != "내용을 남겨주세요" && !music.name.isEmpty &&
        !space.name.isEmpty && !space.lat.isNaN && !date.toString().isEmpty &&
        !imageData.isEmpty && !user.id.isEmpty) ? true : false
        
        return isEnable
    }
    
    func generateMeloPlace(value: (String, String, Music?, Space?, Date?, String, User, [User])) -> MeloPlace {
        let (title, content, music, space, date, imageURL, user, tagedUsers) = value
        guard let music,
              let space,
              let date
        else { return MeloPlace() }
        
        var tagedUserIDs: [String] = []
        
        tagedUsers.forEach { tagedUserIDs.append($0.id) }
        
        return MeloPlace(id: UUID().uuidString,
                         userID: user.id,
                         tagedUsers: tagedUserIDs,
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
                         address: space.address,
                         spaceName: space.name,
                         latitude: space.lat,
                         longitude: space.lng,
                         memoryDate: date
        )
    }
}
