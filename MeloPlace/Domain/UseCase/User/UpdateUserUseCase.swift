//
//  UpdateUserUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/12.
//

import Foundation
import RxSwift

protocol UpdateUserUseCaseProtocol: AnyObject {
    func updateFollowingUser(isFollowing: Bool, id: String) -> Observable<Bool>
}

final class UpdateUserUseCase: UpdateUserUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func updateFollowingUser(isFollowing: Bool, id: String) -> Observable<Bool> {
        return isFollowing ? self.userRepository.updateFollowedUser(id: id) : self.userRepository.deleteFollowingUser(id: id)
    }
    
}
