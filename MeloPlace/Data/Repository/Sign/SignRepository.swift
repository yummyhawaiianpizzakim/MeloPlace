//
//  SignRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/05.
//

import Foundation
import RxSwift

protocol SignRepositoryProtocol: AnyObject {
    func signIn(email: String, password: String) -> Single<Bool>
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool>
    func fetchUserInfor(withSpotifyID id: String) -> Observable<User?>
}

class SignRepository: SignRepositoryProtocol {
    private let firebaseService: FireBaseNetworkServiceProtocol
    
    init(firebaseService: FireBaseNetworkServiceProtocol) {
        self.firebaseService = firebaseService
    }
    
    func fetchUserInfor(withSpotifyID id: String) -> Observable<User?> {
        return self.firebaseService.fetchUserInfor(withSpotifyID: id)
            .map { $0?.toDomain() }
    }
    
    func signIn(email: String, password: String) -> Single<Bool> {
        return self.firebaseService.signIn(email: email, password: password)
        
    }
    
    func signUp(email: String, pw: String, profile: SpotifyUserProfile) -> Observable<Bool> {
        guard let imageData = profile.imageURL.data(using: .utf8)
        else { return Observable.just(false) }
        return self.firebaseService
            .uploadDataStorage(data: imageData, path: .profileImages)
            .asObservable()
            .flatMap { [weak self] url -> Observable<Bool> in
                guard let self else { return Observable.just(false) }
                let userDTO = UserDTO(
                    id: "",
                    spotifyID: profile.id,
                    name: profile.name,
                    email: email,
                    password: pw,
                    imageURL: url,
                    imageWidth: profile.imageWidth,
                    imageHeight: profile.imageHeight,
                    follower: [],
                    following: []
                )
                
                return self.firebaseService.signUp(userDTO: userDTO).asObservable()
            }
    }
    
    func signOut() {
        
    }
    
    
}
