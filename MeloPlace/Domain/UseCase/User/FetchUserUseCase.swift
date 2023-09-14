//
//  FetchUserUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol FetchUserUseCaseProtocol: AnyObject {
    func fetch() -> Observable<User>
}

class FetchUserUseCase: FetchUserUseCaseProtocol {
    var userRepository: UserRepositoryProtocol
    let disposeBag = DisposeBag()
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func fetch() -> Observable<User> {
        return self.userRepository.fetchUserInfo()
    }
    
}
