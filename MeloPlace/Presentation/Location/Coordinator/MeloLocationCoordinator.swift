//
//  LocationCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import UIKit

final class MeloLocationCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .location
    
    var navigation: UINavigationController
    
    var viewController: MeloLocationViewController?
    
    init(navigation : UINavigationController
    ) {
        self.navigation = navigation
    }
    
    init() {
        self.navigation = UINavigationController()
    }
    
    func start() {
        self.showMeloLocationViewFlow()
    }
    
    private func showMeloLocationViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MeloLocationViewModel.self) else { return }
        
        let vc = MeloLocationViewController(viewModel: vm)
        
        vm.setActions(
            actions: MeloLocationViewModelActions(
                closeMeloLocationView: self.closeMeloLocationView
            )
        )
        
        self.viewController = vc
        self.navigation.present(vc, animated: true)
    }
    
    lazy var closeMeloLocationView: (_ space: Space?) -> Void = { [weak self] space in
        guard let self else { return }
        self.finish()
        
        if self.navigation.viewControllers.last is SearchViewController {
            let vc = self.navigation.viewControllers.last as? SearchViewController
            vc?.viewModel?.currentSpace.accept(space)
        }
    }
}

extension MeloLocationCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
