//
//  SignUpViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import RxSwift
import RxRelay

struct SignUpViewModelActions {
    let closeSignUpView: () -> Void
}

class SignUpViewModel {
    
    struct Input {
        var emailText: Observable<String>
        var passwordText: Observable<String>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let profile = BehaviorRelay<SpotifyUserProfile?>(value: nil)
        let isDonButotnEnable = BehaviorRelay<Bool>(value: false)
    }
    
    let fireBaseService = FireBaseNetworkService.shared
    var actions: SignUpViewModelActions?
    let disposeBag = DisposeBag()
    
    let profile = BehaviorRelay<SpotifyUserProfile?>(value: nil)
    
    func setActions(actions: SignUpViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        let loginText = Observable.combineLatest(input.emailText, input.passwordText)
        
        loginText
            .bind(onNext: { email, pw in
                if !email.isEmpty && !pw.isEmpty {
                    output.isDonButotnEnable.accept(true)
                } else {
                    output.isDonButotnEnable.accept(false)
                }
            })
            .disposed(by: self.disposeBag)
        
        input.didTapDoneButton
            .withLatestFrom( loginText )
            .subscribe { [weak self] email, pw in
                guard let self = self, let profile = self.profile.value else { return }
                
                self.fireBaseService.signUp(email: email, password: pw, spotifyID: profile.id, userDTO: UserDTO())
                    .subscribe(onSuccess: { isSuccess in
                        if isSuccess {
                            self.actions?.closeSignUpView()
                        } else {
                            print("SIGN UP FAIL")
                        }
                    }, onFailure: { error in
                        print(error)
                    }).disposed(by: self.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        self.profile
            .bind(to: output.profile)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
