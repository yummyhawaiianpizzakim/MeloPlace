//
//  MainCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

class MainCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .main
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showMainViewFlow()
    }
    
    private func showMainViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MainViewModel.self) else { return }
        
        let vc = MainViewController(viewModel: vm)
        
        vm.setActions(
            actions: MainViewModelActions(
                showAddMeloPlaceView: self.showAddMeloPlaceView, showMeloPlaceDetailView: self.showMeloPlaceDetailView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showAddMeloPlaceView: () -> Void = { [weak self]  in
        guard let navigation = self?.navigation else { return }
        let addMeloPlaceCoordinator = AddMeloPlaceCoordinator(navigation: navigation)
        addMeloPlaceCoordinator.finishDelegate = self
        self?.childCoordinators.append(addMeloPlaceCoordinator)
        addMeloPlaceCoordinator.start()
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
}

extension MainCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
