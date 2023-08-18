//
//  SignInViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import RxSwift
import RxRelay

struct SignInViewModelActions {
    let showSignUpView: (_ profile: SpotifyUserProfile) -> Void
    let closeSinInView: () -> Void
}

class SignInViewModel {
    
    struct Input {
        var didTapSignInButton: Observable<Void>
    }
    
    struct Output {
        
    }
    
    let spotifyService = SpotifyService.shared
    let fireBaseService = FireBaseNetworkService.shared
    var actions: SignInViewModelActions?
    let disposeBag = DisposeBag()
    
    let userProfile = PublishRelay<SpotifyUserProfile>()
    
    func setActions(actions: SignInViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didTapSignInButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.spotifyService.tryConnect()
            }
            .disposed(by: self.disposeBag)
        
        self.spotifyService.isToken
            .withUnretained(self)
            .subscribe { owner , isToken in
                print("isToken: \(isToken)")
                if isToken {
                    owner.spotifyService.fetchSpotifyUserProfile()
                        .map { dto in dto.toDomain() }
                        .subscribe {[weak self] userProfile in
                            print("userProfile: \(userProfile)")
                            self?.fetchUserInfor(profile: userProfile)
                            self?.userProfile.accept(userProfile)
                        }
                        .disposed(by: owner.disposeBag)
                }
            }
            .disposed(by: self.disposeBag)
        
        return output
    }
}

extension SignInViewModel {
    func fetchUserInfor(profile: SpotifyUserProfile) {
        self.fireBaseService.fetchUserInforWithSpotifyID(spotifyID: profile.id)
            .subscribe(with: self,onNext: { owner, dto in
                if let user = dto?.toDomain() {
                    // 이미 Firestore에 있는 사용자입니다. 로그인 처리를 진행합니다.
                    owner.fireBaseService.signIn(email: user.email, password: user.password)
                        .subscribe(onSuccess: { isSuccess in
                            if isSuccess {
                                owner.actions?.closeSinInView()
                            } else {
                                print("sign IN FAIL")
                            }
                        }, onFailure: { error in
                            print(error)
                        }).disposed(by: owner.disposeBag)
                } else {
                    // Firestore에 사용자가 없으므로 회원 가입 페이지로 이동합니다.
                    owner.actions?.showSignUpView(profile)
                }
            }, onError: { owner, error in
                print("Error occurred:", error)
            })
            .disposed(by: disposeBag)
    }
    
}
