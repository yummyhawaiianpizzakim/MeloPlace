//
//  FollowingUserListViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/09.
//

import Foundation
import RxCocoa
import RxSwift
import RxRelay

enum FollowingListSection: Int, Hashable {
    case follower = 0
    case following
    
    enum Item: Hashable {
        case follower(User)
        case following(User)
    }
}

struct FollowingUserListViewModelActions {
    var showAnotherUserProfileView: (_ id: String) -> Void
}

typealias FollowingListDataSource = [FollowingListSection: [FollowingListSection.Item]]

final class FollowingUserListViewModel {
    private let disposeBag = DisposeBag()
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    
    var actions: FollowingUserListViewModelActions?
    
    var userID: String?
    let followerUsers = BehaviorRelay<[User]>(value: [])
    let followingUsers = BehaviorRelay<[User]>(value: [])
    
    init(fetchUserUseCase: FetchUserUseCaseProtocol) {
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    struct Input {
        let tabstate: Observable<Int>
    }
    
    struct Output {
        let dataSources: Driver<[FollowingListDataSource]>
    }
    
    func transform(input: Input) -> Output {
        let user = self.fetchUserUseCase.fetch(userID: self.userID).share()
        
        user.withUnretained(self)
            .flatMap { owner, user -> Observable<([User], [User])> in
                let followers = user.follower
                let followings = user.following
                
                return owner.fetchUserUseCase.fetchFollowersAndFollowingsUser(followers: followers, followings: followings)
            }
            .withUnretained(self)
            .subscribe { owner, val in
                let (followers, followings) = val
                owner.followerUsers.accept(followers)
                owner.followingUsers.accept(followings)
            }
            .disposed(by: self.disposeBag)
        
        let dataSources = Observable.combineLatest(input.tabstate, self.followerUsers, self.followingUsers)
            .withUnretained(self)
//            .debug("viewMOdel dataSource")
            .map { owner, val -> [FollowingListDataSource] in
                let (tabstate, followers, followings) = val
                return owner.mappingDataSource(state: tabstate, followers: followers, followings: followings)
            }.asDriver(onErrorJustReturn: [])
            
        return Output(dataSources: dataSources)
    }
    
    func setActions(actions: FollowingUserListViewModelActions) {
        self.actions = actions
    }
}

private extension FollowingUserListViewModel {
    
    private func mappingDataSource(state: Int, followers: [User], followings: [User]) -> [FollowingListDataSource] {
        switch state {
        case 0:
            return [mappingFollowerDataSurce(followers: followers)]
        case 1:
            return [mappingFollowingDataSurce(followings: followings)]
        default:
            return []
        }
    }
    
    private func mappingFollowerDataSurce(followers: [User]) -> FollowingListDataSource {
        if followers.isEmpty {
            return [FollowingListSection.follower: []]
        }
        
        return [FollowingListSection.follower:
                    followers.map({ FollowingListSection.Item.follower($0)
        })]
    }
    
    private func mappingFollowingDataSurce(followings: [User]) -> FollowingListDataSource {
        if followings.isEmpty {
            return [FollowingListSection.following: []]
        }
        
        return [FollowingListSection.following:
                    followings.map({ FollowingListSection.Item.following($0)
        })]
    }
    
}

extension FollowingUserListViewModel {
    func showAnotherUserProfileView(state: Int, indexPath: IndexPath) {
        switch state {
        case 0:
            guard let user = self.followerUsers.value[safe: indexPath.row] else { return }
            self.actions?.showAnotherUserProfileView(user.id)
            
            return
        case 1:
            guard let user = self.followingUsers.value[safe: indexPath.row] else { return }
            self.actions?.showAnotherUserProfileView(user.id)
            
            return
        default:
            return
        }
    }
}
