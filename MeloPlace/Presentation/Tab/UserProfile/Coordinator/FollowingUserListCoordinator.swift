//
//  FollowingUserListCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/09.
//

import Foundation
import UIKit

class FollowingUserListCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .followingUserList
    
    var navigation: UINavigationController
    
    var userID: String?
    
    var tabState: Int?
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showFollowingUserListViewFlow()
    }
    
    private func showFollowingUserListViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(FollowingUserListViewModel.self) else { return }
        
        let vc = FollowingUserListViewController(viewModel: vm)
        vc.tabstate.accept(self.tabState ?? 0)
        vc.hidesBottomBarWhenPushed = true
        vm.userID = self.userID
        vm.setActions(
            actions:
                FollowingUserListViewModelActions(
                    showAnotherUserProfileView: self.showAnotherUserProfileView)
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showAnotherUserProfileView: (_ id: String) -> Void = { [weak self] id in
        guard let self = self else { return }
        let coordinator = AnotherUserProfileCoordinator(navigation: self.navigation)
        coordinator.userID = id
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
}

extension FollowingUserListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
