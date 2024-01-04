//
//  SettingViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

struct UserProfileViewModelActions {
//    var showSignIn: () -> Void
    var showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
    var showSearchUserView: () -> Void
    var showFollowingUserView: (_ id: String, _ tabState: Int) -> Void
}

typealias UserDataSource = [UserProfileSection: [UserProfileSection.Item]]

class UserProfileViewModel {
    private let disposeBag = DisposeBag()
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    private let fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol
    private let updateUserUseCase: UpdateUserUseCaseProtocol
    
    let myMeloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    let tagedMeloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    let userName = BehaviorRelay<String>(value: "")
    var userID: String?
    
    var actions: UserProfileViewModelActions?

    init(fetchUserUseCase: FetchUserUseCaseProtocol,
         fetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol,
         updateUserUseCase: UpdateUserUseCaseProtocol) {
        self.fetchUserUseCase = fetchUserUseCase
        self.fetchMeloPlaceUseCase = fetchMeloPlaceUseCase
        self.updateUserUseCase = updateUserUseCase
    }
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let tabstate: Observable<Int>
        let refresh: Observable<Void>
    }
    
    struct Output {
        let dataSources: Driver<[UserDataSource]>
    }
    
    func transform(input: Input) -> Output {
        let dataLoadTrigger = Observable.combineLatest(
            input.viewDidLoad.startWith(()),
            input.refresh.startWith(())
        )
        
        let user = self.fetchUserUseCase
            .fetch(userID: nil)
            .do(onNext: { [weak self] user in
                self?.userName.accept(user.name)
                self?.userID = user.id
            })
            .share()
               
        let meloPlaces = dataLoadTrigger.flatMap { [weak self] _ in
            guard let self else { return Observable<[MeloPlace]>.just([]) }
            return self.fetchMeloPlaceUseCase
                .fetch(id: nil)
        }.share()
                
        let tagedMeloPlaces = dataLoadTrigger.flatMap { [weak self] _ in
            guard let self else { return Observable<[MeloPlace]>.just([]) }
            return self.fetchMeloPlaceUseCase
                .fetchTagedMeloPLace(id: nil)
        }.share()
        
        let dataSources = Observable.combineLatest(input.tabstate, user, meloPlaces, tagedMeloPlaces)
            .do(onNext: { [weak self] val in
                let (_, _, meloPlaces, tagedMeloPlaces) = val
                self?.myMeloPlaces.accept(meloPlaces)
                self?.tagedMeloPlaces.accept(tagedMeloPlaces)
            })
            .map {[weak self] val -> [UserDataSource] in
                let (int, user, meloPlaces, tagedMeloPlaces) = val
                guard let self = self else { return [] }
                
                return self.mappingDataSource(state: int, user: user, meloPlaces: meloPlaces, tagedMeloPlace: tagedMeloPlaces)
            }
            .asDriver(onErrorJustReturn: [])
        
        return Output(dataSources: dataSources)
    }
    
    func setActions(actions: UserProfileViewModelActions) {
        self.actions = actions
    }
}

private extension UserProfileViewModel {
    
    func mappingDataSource(state: Int, user: User, meloPlaces: [MeloPlace], tagedMeloPlace: [MeloPlace]) -> [UserDataSource] {
        switch state {
        case 0:
            return [mappingProfileDataSource(user: user)] + [mappingMyContentsDataSurce(meloPlaces: meloPlaces)]
        case 1:
            return [mappingProfileDataSource(user: user)] + [mappingTagedContentsDataSurce(meloPlaces: tagedMeloPlace)]
        default:
            return []
        }
    }
    
    func mappingProfileDataSource(user: User) -> UserDataSource {
        return [UserProfileSection.profile: [UserProfileSection.Item.profile(user)]]
    }
    
    func mappingMyContentsDataSurce(meloPlaces: [MeloPlace]) -> UserDataSource {
        if meloPlaces.isEmpty {
            return [UserProfileSection.myContents: []]
        }
        return [ UserProfileSection.myContents: meloPlaces.map({ meloPlace in UserProfileSection.Item.myContents(meloPlace) }) ]
    }
    
    func mappingTagedContentsDataSurce(meloPlaces: [MeloPlace]) -> UserDataSource {
        if meloPlaces.isEmpty {
            return [UserProfileSection.tagedContents: []]
        }
        return [ UserProfileSection.tagedContents: meloPlaces.map({ meloPlace in UserProfileSection.Item.tagedContents(meloPlace) }) ]
    }
}

extension UserProfileViewModel {
    func showSearchUserFlow() {
        self.actions?.showSearchUserView()
    }
    
    func showMeloPlaceDetailView(state: Int, indexPath: IndexPath) {
        switch state {
        case 0:
            let meloPlaces = self.myMeloPlaces.value
            self.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            
            return
        case 1:
            let meloPlaces = self.tagedMeloPlaces.value
            self.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            
            return
        default:
            return
        }
    }
    
    func showFollowingUserView(tabState: Int) {
        guard let userID = self.userID else { return }
        self.actions?.showFollowingUserView(userID, tabState)
    }
    
}
