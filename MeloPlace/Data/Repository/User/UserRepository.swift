//
//  UserRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol UserRepositoryProtocol: AnyObject {
//    func fetchUserInfo() -> Single<User>
    func fetchUserInfo() -> Observable<User> 
}

class UserRepository: UserRepositoryProtocol {
//    var userStorage: UserStorageProtocol
//    var fireStoreService: FireStoreServiceProtocol
    var fireBaseService = FireBaseNetworkService.shared
    let disposeBag = DisposeBag()
    
    init(fireBaseService: FireBaseNetworkService) {
        self.fireBaseService = fireBaseService
    }
    
//    func fetchUserInfo() -> Single<User> {
//        return Single.create {[weak self] single in
//            guard let self = self else { return Disposables.create() }
//            self.fireBaseService.read(type: UserDTO.self, userCase: .currentUser, access: .user)
//                .map { dto in
//                    dto.toDomain()
//                }
//                .subscribe(onNext: { user in
//                    single(.success(user))
//                }, onError: { error in
//                    single(.failure(error))
//                })
//                .disposed(by: self.disposeBag)
//
//            return Disposables.create()
//        }
//    }
    
    func fetchUserInfo() -> Observable<User> {
        return self.fireBaseService
            .read(type: UserDTO.self, userCase: .currentUser, access: .user)
            .map { dto in
                dto.toDomain()
            }
            .catchAndReturn(User())
    }
}
