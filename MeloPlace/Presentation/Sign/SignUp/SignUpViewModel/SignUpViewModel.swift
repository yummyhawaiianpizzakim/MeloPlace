//
//  SignUpViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct SignUpViewModelActions {
    let closeSignUpView: () -> Void
}

class SignUpViewModel {
    let disposeBag = DisposeBag()
    private let signUpUseCase: SignUpUseCaseProtocol
    var actions: SignUpViewModelActions?
    
    let profile = BehaviorRelay<SpotifyUserProfile?>(value: nil)
    
    init(signUpUseCase: SignUpUseCaseProtocol) {
        self.signUpUseCase = signUpUseCase
    }
    
    struct Input {
        var emailText: Observable<String>
        var passwordText: Observable<String>
        var didTapDoneButton: Observable<Void>
    }
    
    struct Output {
        let profile: Driver<SpotifyUserProfile?>
        let isDoneButotnEnable: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        let loginText = Observable.combineLatest(input.emailText, input.passwordText).share()
        
        let isDoneButotnEnable = loginText
            .map({ email, pw in
                let isDone = !email.isEmpty && !pw.isEmpty ?
                true : false
                
                return isDone
            })
        
        input.didTapDoneButton
            .withLatestFrom( Observable.combineLatest(loginText, self.profile) )
            .flatMap({ [weak self] values -> Observable<Bool> in
                let ((email, pw), profile) = values
                guard let self, let profile else { return Observable.just(false) }
                
                return self.signUpUseCase.signUp(email: email, pw: pw, profile: profile)
            })
            .withUnretained(self)
            .subscribe(onNext: { owner, isSuccess in
                if isSuccess {
                    owner.actions?.closeSignUpView()
                } else {
                    print("signUP fail")
                }
            })
            .disposed(by: self.disposeBag)
        
        return Output(profile: self.profile.asDriver(),
                      isDoneButotnEnable: isDoneButotnEnable.asDriver(onErrorJustReturn: false))
    }
    
    func setActions(actions: SignUpViewModelActions) {
        self.actions = actions
    }
    
}
