//
//  SignUpCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import UIKit

final class SignUpCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .signUp
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showSignUpViewFlow()
    }
    
    private func showSignUpViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SignUpViewModel.self) else { return }
        
        let vc = SignUpViewController(viewModel: vm)
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
}

extension SignUpCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
}
