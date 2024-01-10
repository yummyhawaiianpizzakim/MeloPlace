//
//  SearchUserCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/09.
//

import Foundation
import UIKit

final class SearchUserCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .searchUser
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showSearchViewFlow()
    }
    
    private func showSearchViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SearchUserViewModel.self) else { return }
        let vc = SearchUserViewController(viewModel: vm)
        
        vc.hidesBottomBarWhenPushed = true
        switch self.navigation.viewControllers.last {
        case is AddMeloPlaceViewController:
            vm.childByUserProfile.accept(false)
        case is UserProfileViewController:
            vm.childByUserProfile.accept(true)
        case is AnotherUserProfileViewController:
            vm.childByUserProfile.accept(true)
        case is BrowseViewController:
            vm.childByUserProfile.accept(true)
        case .none:
            return
        case .some(_):
            return
        }
        
        vm.setActions(
            actions: SearchUserViewModelActions(
                showUserProfileView: self.showUserProfileView,
                closeSearchView: self.closeSearchView
            )
        )
        
        self.navigation.pushViewController(vc, animated: false)
    }
    
    lazy var showUserProfileView: (_ userID: String) -> Void = { [weak self] id in
        guard let self else { return }
        let coordinator = AnotherUserProfileCoordinator(navigation: self.navigation)
        self.childCoordinators.append(coordinator)
        coordinator.userID = id
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var closeSearchView: (_ user: User) -> Void = { [weak self] user in
        guard let self else { return }
        self.navigation.popViewController(animated: false)
        self.finish()
        
        switch self.navigation.viewControllers.last {
        case is AddMeloPlaceViewController:
            let viewController = self.navigation.viewControllers.last as? AddMeloPlaceViewController
            guard var tagedUsers = viewController?.viewModel?.tagedFollowings.value else { return }
            
            if !tagedUsers.contains(where: { $0.id == user.id }) {
                tagedUsers.append(user)
                viewController?.viewModel?.tagedFollowings.accept(tagedUsers)
            }
            self.navigation.isNavigationBarHidden = true
        case .none:
            return
        case .some(_):
            return
        }
    }
}

extension SearchUserCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
