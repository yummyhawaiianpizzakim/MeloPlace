//
//  AppCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

class AppCoordinator: CoordinatorProtocol {
    
    

    weak var finishDelegate: CoordinatorFinishDelegate?

    var childCoordinators: [CoordinatorProtocol] = []

    var type: CoordinatorType = .app

    let container = DIContainer.shared.container
    
    var navigation: UINavigationController
    
    init(navigation: UINavigationController) {
        self.navigation = navigation
    }

    func start() {
//        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
//          if error != nil || user == nil {
//            // Show the app's signed-out state.
//              self.showSignInFlow()
//          } else {
//            // Show the app's signed-in state.
//              self.showTabBarFlow()
//          }
//        }
//        self.showSignInFlow()
        self.showTabBarFlow()
    }

}

extension AppCoordinator {
    func showTabBarFlow() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: self.navigation)
        tabBarCoordinator.finishDelegate = self
        tabBarCoordinator.start()
        childCoordinators.append(tabBarCoordinator)
        
    }
    
//    func showSignInFlow() {
//        let signInCoordinator = SignInCoordinator(navigation: self.navigation)
//        signInCoordinator.finishDelegate = self
//        signInCoordinator.start()
//        childCoordinators.append(signInCoordinator)
//
//    }
}

extension AppCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        self.childCoordinators = childCoordinators.filter({ coordinator in
            coordinator.type != childCoordinator.type
        })
        
//        self.navigation.view.backgroundColor = .systemBackground
//        self.navigation.viewControllers.removeAll()
        
//        switch childCoordinator.type {
//        case .tab:
//            self.showSignInFlow()
//        case .signIn:
//            self.showTabBarFlow()
//        default:
//            break
//        }
        
    }
    
}
