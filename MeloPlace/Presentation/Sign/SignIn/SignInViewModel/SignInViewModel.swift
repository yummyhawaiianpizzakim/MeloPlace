//
//  SignInViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

struct SignInViewModelActions {
    let showSignUpView: (_ profile: SpotifyUserProfile) -> Void
    let closeSinInView: () -> Void
}

class SignInViewModel {
    private let disposeBag = DisposeBag()
    private let tryConnectSpotifyUseCase: TryConnectSpotifyUseCaseProtocol
    private let signInUseCase: SignInUseCaseProtocol
    
    var actions: SignInViewModelActions?
    
    let isIndicatorActived = BehaviorRelay<Bool>(value: false)
    let userProfile = BehaviorRelay<SpotifyUserProfile?>(value: nil)
    
    init(tryConnectSpotifyUseCase: TryConnectSpotifyUseCaseProtocol, 
         signInUseCase: SignInUseCaseProtocol) {
        self.tryConnectSpotifyUseCase = tryConnectSpotifyUseCase
        self.signInUseCase = signInUseCase
    }
    
    struct Input {
        let didTapSignInButton: Observable<Void>
    }
    
    struct Output {
        let isIndicatorActived: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        input.didTapSignInButton
            .withUnretained(self)
            .flatMapLatest { owner, _ in
                owner.tryConnectSpotifyUseCase.tryConnect()
            }
            .do(onNext: { profile in
                print("spotify::: \(profile)")
                self.userProfile.accept(profile)
            })
            .flatMapLatest { [weak self] profile -> Observable<Bool> in
                self?.isIndicatorActived.accept(true)
                guard let isSuccess = self?.signInUseCase.signIn(with: profile) else { return Observable.error(NetworkServiceError.noAuthError) }
                return isSuccess
            }
            .subscribe { [weak self] isSuccess in
                self?.isIndicatorActived.accept(false)
                guard let profile = self?.userProfile.value else { return }
                isSuccess ? self?.actions?.closeSinInView() : self?.actions?.showSignUpView(profile)
            }
            .disposed(by: self.disposeBag)
        
        return Output(isIndicatorActived: self.isIndicatorActived.asDriver())
    }
    
    func setActions(actions: SignInViewModelActions) {
        self.actions = actions
    }
    
    
}

extension SignInViewModel {
}
