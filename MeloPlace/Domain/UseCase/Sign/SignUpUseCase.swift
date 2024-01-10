//
//  SignUpUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/29.
//

import Foundation
import RxSwift

protocol SignUpUseCaseProtocol: AnyObject {
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool>
}

final class SignUpUseCase: SignUpUseCaseProtocol {
    private let signRepository: SignRepositoryProtocol
    
    init(signRepository: SignRepositoryProtocol) {
        self.signRepository = signRepository
    }
    
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool> {
        self.signRepository.signUp(email: email, pw: pw, profile: profile)
    }
}
