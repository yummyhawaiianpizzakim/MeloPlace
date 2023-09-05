//
//  MapCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

class MapCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .map
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showMapViewFlow()
    }
    
    private func showMapViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MapViewModel.self) else { return }
        
        let vc = MapViewController(viewModel: vm)
        
        vm.setActions(
            actions: MapViewModelActions(
                showMapMeloPlaceListView:
                    self.showMapMeloPlaceListView,
                showSearchView:
                    self.showSearchView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showMapMeloPlaceListView: (_ meloPlaces: [MeloPlace]) -> Void = { [weak self] meloPlaces in
        guard let self = self else { return }
        let coordinator = MapMeloPlaceListCoordinator(navigation: self.navigation)
        coordinator.meloPlaces.accept(meloPlaces)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showSearchView: (_ sender: MapViewModel) -> Void = { [weak self] viewModel in
        guard let self = self else { return }
        let coordinator = SearchCoordinator(navigation: self.navigation, mapViewModel: viewModel)
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
}

extension MapCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
