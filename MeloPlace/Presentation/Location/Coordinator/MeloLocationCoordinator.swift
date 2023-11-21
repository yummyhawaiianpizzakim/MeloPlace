//
//  LocationCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import UIKit

class MeloLocationCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .location
    
    var navigation: UINavigationController
    
    var viewController: MeloLocationViewController?
    
//    var addViewModel: AddMeloPlaceViewModel?
    
    init(navigation : UINavigationController
//         addViewModel: AddMeloPlaceViewModel
    ) {
        self.navigation = navigation
//        self.addViewModel = addViewModel
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
        
//        vm.delegate = self.addViewModel
        let vc = MeloLocationViewController(viewModel: vm)
        
        vm.setActions(
            actions: MeloLocationViewModelActions(
                closeMeloLocationView: self.closeMeloLocationView
            )
        )
        
        self.viewController = vc
        self.navigation.present(vc, animated: true)
//        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var closeMeloLocationView: (_ space: Space?) -> Void = { [weak self] space in
        guard let self else { return }
        self.finish()
        
        if self.navigation.viewControllers.last is SearchViewController {
            let vc = self.navigation.viewControllers.last as? SearchViewController
            vc?.viewModel?.currentSpace.accept(space)
        }
//        self?.viewController?.dismiss(animated: true)
    }
    
//    lazy var showPhotoDetail: (_ IndexPath: IndexPath) -> Void = { [weak self] indexPath in
//        let container = DIContainer.shared.container
//        guard let vm = container.resolve(PhotoDetailViewModel.self) else { return }
//        vm.indexpath = indexPath
//        let vc = PhotoDetailViewController(viewModel: vm)
////        self?.navigation.present(vc, animated: true)
//        self?.navigation.pushViewController(vc, animated: true)
//    }
}

extension MeloLocationCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
