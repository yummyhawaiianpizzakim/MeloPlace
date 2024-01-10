//
//  MapCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

final class MapCoordinator: CoordinatorProtocol {
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
                showMeloPlaceDetailView: self.showMeloPlaceDetailView,
                showSearchView:
                    self.showSearchView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showSearchView: () -> Void = { [weak self] in
        guard let self = self else { return }
        let coordinator = SearchCoordinator(navigation: self.navigation)
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
}

extension MapCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
