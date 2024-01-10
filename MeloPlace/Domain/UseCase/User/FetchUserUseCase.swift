//
//  FetchUserUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol FetchUserUseCaseProtocol: AnyObject {
    func fetch(userID: String?) -> Observable<User>
    func fetch(userNickName: String) -> Observable<[User]>
    func fetchFollowersAndFollowingsUser(followers: [String], followings: [String]) -> Observable<([User], [User])>
}

final class FetchUserUseCase: FetchUserUseCaseProtocol {
    
    var userRepository: UserRepositoryProtocol
    let disposeBag = DisposeBag()
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func fetch(userID: String?) -> Observable<User> {
        guard let userID else {
            return self.userRepository.fetchUserInfo() }
        
        return self.userRepository.fetchUserInfo(userID: userID)
    }
    
    func fetch(userNickName: String) -> Observable<[User]> {
        self.userRepository.fetchUserInfo()
            .flatMap { user in
                let currentUserName = user.name
                return self.userRepository.fetchUsersInfor(query: userNickName, currentUserName: currentUserName)
            }
    }
    
    func fetchFollowersAndFollowingsUser(followers: [String], followings: [String]) -> Observable<([User], [User])> {
        self.userRepository.fetchFollowerUser(followers: followers)
            .withUnretained(self)
            .flatMap { owner, followers -> Observable<([User], [User])> in
                owner.userRepository
                    .fetchFollowingUser(followings: followings)
                    .map { following in
                        (followers, following)
                    }
            }
    }
}
