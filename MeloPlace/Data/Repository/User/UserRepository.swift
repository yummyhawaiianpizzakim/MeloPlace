//
//  UserRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol UserRepositoryProtocol: AnyObject {
    func fetchUserInfo(userID: String) -> Observable<User>
    func fetchUserInfo() -> Observable<User>
    func fetchUsersInfor(query: String, currentUserName: String) -> Observable<[User]>
    func fetchUserWithComments(userID: [String]) -> Single<[User]>
    func fetchFollowingUser(followings: [String]) -> Observable<[User]>
    func fetchFollowerUser(followers: [String]) -> Observable<[User]>
    func fetchUserInfor(with userIDs: [String]) -> Observable<[User]>
    func updateFollowedUser(id: String) -> Observable<Bool>
    func deleteFollowingUser(id: String) -> Observable<Bool>
}

class UserRepository: UserRepositoryProtocol {
    let disposeBag = DisposeBag()
    private let fireBaseService: FireBaseNetworkServiceProtocol
    
    init(fireBaseService: FireBaseNetworkServiceProtocol) {
        self.fireBaseService = fireBaseService
    }
    
    func fetchUserInfo(userID: String) -> Observable<User> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: userID)]
        let user = self.fireBaseService.read(type: UserDTO.self, access: .user, firebaseFilter: .isEqualTo(queryList))
            .map { $0.toDomain() }
        
        return user
    }
    
    func fetchUserInfo() -> Observable<User> {
        guard
            let uid = try? self.fireBaseService.determineUserID(id: nil)
        else { return Observable.empty() }
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: uid)]
        
        let user = self.fireBaseService.read(type: UserDTO.self, access: .user, firebaseFilter: .isEqualTo(queryList))
            .map { $0.toDomain() }
        
        return user
    }
    
    func fetchUsersInfor(query: String, currentUserName: String) -> Observable<[User]> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "name", value: query)]
        
        return self.fireBaseService
            .read(type: UserDTO.self,
                  access: .user,
                  firebaseFilter: .anotherUser(queryList)
            )
            .map({ $0.toDomain() })
            .filter({
                return $0.name != currentUserName
            })
            .toArray()
            .catchAndReturn([])
            .asObservable()
    }
    
    func fetchUserInfor(with userIDs: [String]) -> Observable<[User]> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: userIDs)]
        
        return self.fireBaseService.read(type: UserDTO.self, access: .user, firebaseFilter: .in(queryList))
            .map { $0.toDomain() }
            .toArray()
            .catchAndReturn([])
            .asObservable()
    }
    
    func fetchFollowingUser(followings: [String]) -> Observable<[User]> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: followings)]
        
        return self.fireBaseService.read(type: UserDTO.self, access: .user, firebaseFilter: .in(queryList))
            .map { $0.toDomain() }
            .toArray()
            .catchAndReturn([])
            .asObservable()
    }
    
    func fetchFollowerUser(followers: [String]) -> Observable<[User]> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: followers)]
        
        return self.fireBaseService.read(type: UserDTO.self, access: .user, firebaseFilter: .in(queryList))
            .map { $0.toDomain() }
            .toArray()
            .catchAndReturn([])
            .asObservable()
    }
    
    func fetchUserWithComments(userID: [String]) -> Single<[User]> {
        let queryList: [FirebaseQueryDTO] = [.init(key: "id", value: userID)]
        
        return self.fireBaseService.read(type: UserDTO.self, access: .user,firebaseFilter: .in(queryList))
            .map { $0.toDomain() }.toArray().catchAndReturn([])
    }
    
    func updateFollowedUser(id: String) -> Observable<Bool> {
        return self.fetchUserInfo().flatMap {[weak self] user -> Observable<Bool> in
            guard let self else { throw NetworkServiceError.noNetworkService }
            var currentUser = user
            currentUser.following.append(id)
            let userDTO = currentUser.toDTO()
            return self.fireBaseService.update(dto: userDTO, access: .user)
                .do(onSuccess: { userDTO in
                    self.updateFollowerUser(currentUserID: userDTO.id, anotherUserID: id)
                })
                .map { _ in
                    return true
                }
                .catchAndReturn(false)
                .asObservable()
            }
    }
    
    func deleteFollowingUser(id: String) -> Observable<Bool> {
        return self.fetchUserInfo()
            .flatMap {[weak self] user -> Observable<Bool> in
                guard let self else { throw NetworkServiceError.noNetworkService }
                var currentUser = user
                currentUser.following = currentUser.following.filter({ $0 != id })
                let userDTO = currentUser.toDTO()
                return self.fireBaseService
                    .update(dto: userDTO, access: .user)
                    .do(onSuccess: { _ in
                        self.deleteFollowerUser(currentUserID: currentUser.id, anotherUserID: id)
                    })
                    .map { _ in return true }
                    .catchAndReturn(false)
                    .asObservable()
            }
    }
    
}

extension UserRepository {
    func updateFollowerUser(currentUserID: String, anotherUserID: String) {
        self.fetchUserInfo(userID: anotherUserID)
            .flatMap { [weak self] user -> Observable<UserDTO> in
                guard let self else { throw NetworkServiceError.noNetworkService }
                var user = user
                user.follower.append(currentUserID)
                let userDTO = user.toDTO()
                return self.fireBaseService.update(dto: userDTO, access: .user)
                    .asObservable()
            }
            .subscribe()
            .disposed(by: self.disposeBag)
    }
    
    func deleteFollowerUser(currentUserID: String, anotherUserID: String) {
        self.fetchUserInfo(userID: anotherUserID)
            .flatMap { [weak self] user -> Observable<UserDTO> in
                guard let self else { throw NetworkServiceError.noNetworkService }
                var user = user
                user.follower = user.follower.filter({ $0 != currentUserID })
                let userDTO = user.toDTO()
                return self.fireBaseService.update(dto: userDTO, access: .user)
                    .asObservable()
            }
            .subscribe()
            .disposed(by: self.disposeBag)
    }
}
