//
//  SettingCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

class UserProfileCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .userProfile
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showUserProfileViewFlow()
    }
    
    private func showUserProfileViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(UserProfileViewModel.self) else { return }
        
        let vc = UserProfileViewController(viewModel: vm)
        
        vm.setActions(
            actions: UserProfileViewModelActions(
                showMeloPlaceDetailView: self.showMeloPlaceDetailView,
                showSearchUserView: self.showSearchUserView,
                showFollowingUserView: self.showFollowingUserView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void = { [weak self] meloPlaces, indexPath in
        guard let self = self else { return }
        let coordinator = MeloPlaceDetailCoordinator(navigation: self.navigation)
        
        coordinator.meloPlaces.accept(meloPlaces)
        coordinator.indexPath.accept(indexPath)
//        coordinator.indexPath = indexPath
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showSearchUserView: () -> Void = { [weak self] in
        guard let self = self else { return }
        let coordinator = SearchUserCoordinator(navigation: self.navigation)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showFollowingUserView: (_ id: String, _ tabState: Int) -> Void = { [weak self] id, tabState in
        guard let self = self else { return }
        let coordinator = FollowingUserListCoordinator(navigation: self.navigation)
        coordinator.userID = id
        coordinator.tabState = tabState
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
}

extension UserProfileCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
