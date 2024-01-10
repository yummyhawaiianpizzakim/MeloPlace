//
//  BrowseCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

final class BrowseCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .browse
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showBrowseViewFlow()
    }
    
    private func showBrowseViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(BrowseViewModel.self) else { return }
        
        let vc = BrowseViewController(viewModel: vm)
        
        vm.setActions(
            actions: BrowseViewModelActions(
                showSearchUserView: self.showSearchUserView,
                showMeloPlaceDetailView: self.showMeloPlaceDetailView,
                showAnotherUserProfileView: self.showAnotherUserProfileView,
                showCommentsView: self.showCommentsView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showSearchUserView: () -> Void = { [weak self] in
        guard let self else { return }
        let coordinator = SearchUserCoordinator(navigation: self.navigation)
        
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void = { [weak self] meloPlaces, indexPath in
        guard let self = self else { return }
        let coordinator = MeloPlaceDetailCoordinator(navigation: self.navigation)
        
        coordinator.meloPlaces.accept(meloPlaces)
        coordinator.indexPath.accept(indexPath)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showAnotherUserProfileView: (_ id: String) -> Void = { [weak self] id in
        guard let self = self else { return }
        let coordinator = AnotherUserProfileCoordinator(navigation: self.navigation)
        coordinator.userID = id
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showCommentsView: (_ meloPlace: MeloPlace) -> Void = { [weak self] meloPlace in
        guard let self = self else { return }
        let commentCoordinator = CommentCoordinator(navigation: self.navigation)
        commentCoordinator.meloPlace.accept(meloPlace)
        commentCoordinator.finishDelegate = self
        self.childCoordinators.append(commentCoordinator)
        commentCoordinator.start()
    }
    
    lazy var closeCommentsView: () -> Void = { [weak self] in
        self?.navigation.popViewController(animated: false)
        self?.finish()
    }
}

extension BrowseCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
