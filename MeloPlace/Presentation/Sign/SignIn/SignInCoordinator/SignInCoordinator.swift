//
//  SignInCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import UIKit

final class SignInCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .signIn
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showSignInViewFlow()
    }
    
    private func showSignInViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SignInViewModel.self) else { return }
        
        let vc = SignInViewController(viewModel: vm)
        
        vm.setActions(
            actions: SignInViewModelActions(
                showSignUpView: self.showSignUpView,
                closeSinInView: self.closeSinInView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showSignUpView: (_ profile: SpotifyUserProfile) -> Void = { [weak self] profile in
        let container = DIContainer.shared.container
        guard let self = self, let vm = container.resolve(SignUpViewModel.self) else { return }
        vm.profile.accept(profile)
        
        vm.setActions(
            actions: SignUpViewModelActions(
                closeSignUpView: self.closeSinUpView
            )
        )
        
        let vc = SignUpViewController(viewModel: vm)
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var closeSinInView: () -> Void = { [weak self] in
        self?.finish()
        self?.navigation.popViewController(animated: true)
    }
    
    lazy var closeSinUpView: () -> Void = { [weak self] in
        self?.finish()
        self?.navigation.popViewController(animated: true)
    }
}

extension SignInCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
