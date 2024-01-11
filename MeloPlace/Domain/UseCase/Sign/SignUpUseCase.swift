//
//  SignUpUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/29.
//

import Foundation
import RxSwift
import CryptoKit

protocol SignUpUseCaseProtocol: AnyObject {
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool>
}

final class SignUpUseCase: SignUpUseCaseProtocol {
    private let signRepository: SignRepositoryProtocol
    
    init(signRepository: SignRepositoryProtocol) {
        self.signRepository = signRepository
    }
    
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool> {
        let hashedPW = self.generateHashedString(with: pw)
        return self.signRepository.signUp(email: email, pw: hashedPW, profile: profile)
    }
}

private extension SignUpUseCase {
    func generateHashedString(with string: String) -> String {
        let data = string.data(using: .utf8)
        guard let data = data else { return string}
        let sha256 = SHA256.hash(data: data)
        let hashedString = sha256.map { String(format: "%02x", $0) }.joined()
        return hashedString
    }
}
