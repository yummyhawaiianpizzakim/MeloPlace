//
//  SettingViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay

struct UserProfileViewModelActions {
//    var showSignIn: () -> Void
    var showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
}

typealias UserDataSource = [UserProfileSection: [UserProfileSection.Item]]

class UserProfileViewModel {
    var fetchUserUseCase: FetchUserUseCaseProtocol
    var fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol
    var actions: UserProfileViewModelActions?
    var disposeBag = DisposeBag()
    
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])

    init(fetchUserUseCase: FetchUserUseCaseProtocol, fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol) {
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchMeloPlaceUseCase = fetchMeloPlaceUseCase
    }
    
    func setActions(actions: UserProfileViewModelActions) {
        self.actions = actions
    }
    
    struct Input {
    let tabstate: Observable<Int>
    }
    
    struct Output {
        let userProfile = BehaviorRelay<User?>(value: nil)
//        let dataSources = BehaviorRelay<UserProfileDataSources>(value: .init())
        let dataSources = BehaviorRelay<[UserDataSource]>(value: .init())
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let user = self.fetchUserUseCase.fetch()
        let meloPlace = self.fetchMeloPlaceUseCase.fetch()
        
        Observable.combineLatest(input.tabstate, user, meloPlace)
            .map {[weak self] int, user, meloPlaces in
                print("int: \(int), user: \(user), meloPlaces: \(meloPlaces) ")
                guard let self = self else { return [] }
                
                self.meloPlaces.accept(meloPlaces)
                return self.mappingDataSource(state: int, user: user, meloPlaces: meloPlaces)
            }
            .bind(to: output.dataSources)
            .disposed(by: disposeBag)
        
        return output
    }
}

extension UserProfileViewModel {
    
    private func mappingDataSource(state: Int, user: User, meloPlaces: [MeloPlace]) -> [UserDataSource] {
        switch state {
        case 0:
            return [mappingProfileDataSource(user: user)] + [mappingLikesDataSurce(meloPlaces: meloPlaces)]
        case 1:
            return [mappingProfileDataSource(user: user)] + [mappingLikesDataSurce(meloPlaces: meloPlaces)]
        default:
            return []
        }
    }
    
    private func updatePhotosState(meloPlaces: [MeloPlace?]) -> [MeloPlace?] {
            return meloPlaces.map { meloPlace in
                guard let meloPlace = meloPlace else { return MeloPlace() }
                return MeloPlace(id: meloPlace.id,
                                 userId: meloPlace.userId,
                                 musicURI: meloPlace.musicURI,
                                 musicName: meloPlace.musicName,
                                 musicDuration: meloPlace.musicDuration,
                                 musicArtist: meloPlace.musicArtist,
                                 musicAlbum: meloPlace.musicAlbum,
                                 musicImageURL: meloPlace.musicImageURL,
                                 musicImgaeWidth: meloPlace.musicImgaeWidth,
                                 musicImgaeHeight: meloPlace.musicImgaeHeight,
                                 images: meloPlace.images,
                                 title: meloPlace.title,
                                 description: meloPlace.description,
                                 address: meloPlace.address,
                                 simpleAddress: meloPlace.simpleAddress,
                                 latitude: meloPlace.latitude,
                                 longitude: meloPlace.longitude,
                                 memoryDate: meloPlace.memoryDate
                )
                
            }
        }
    
    private func mappingProfileDataSource(user: User) -> UserDataSource {
        return [UserProfileSection.profile: [UserProfileSection.Item.profile(user)]]
    }
    
    private func mappingLikesDataSurce(meloPlaces: [MeloPlace]) -> UserDataSource {
        if meloPlaces.isEmpty {
            return [UserProfileSection.likes: []]
        }
        return [UserProfileSection.likes: updatePhotosState(meloPlaces: meloPlaces).map( { UserProfileSection.Item.likes($0) } )]
    }
}

extension UserProfileViewModel {
    func showSignInFlow() {
//        self.actions?.showSignIn()
    }
}

extension UserProfileViewModel {
    func showMeloPlaceDetailView(indexPath: IndexPath) {
        var meloPlaces = self.meloPlaces.value
        self.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
    }
}
