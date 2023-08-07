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
        
//        vm.setActions(
//            actions: PhotoListViewModelActions(
//                showPhotoDetail: self.showPhotoDetail
//            )
//        )
        
        self.navigation.pushViewController(vc, animated: true)
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

extension MainCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
