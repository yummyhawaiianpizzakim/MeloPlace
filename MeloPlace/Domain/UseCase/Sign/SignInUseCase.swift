//
//  SignInUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol SignInUseCaseProtocol: AnyObject {
    func signIn(with profile: SpotifyUserProfile) -> Observable<Bool>
}

final class SignInUseCase: SignInUseCaseProtocol {
    private let signRepository: SignRepositoryProtocol
    
    init(signRepository: SignRepositoryProtocol) {
        self.signRepository = signRepository
    }
    
    func signIn(with profile: SpotifyUserProfile) -> Observable<Bool> {
        self.signRepository.fetchUserInfor(withSpotifyID: profile.id)
            .withUnretained(self)
            .flatMap { owner, user in
                guard let user else { return Observable.just(false) }
                return owner.signRepository.signIn(email: user.email, password: user.password).asObservable()
            }
    }
}

private extension SignInUseCase {
}
