//
//  SearchCoordintor.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation
import UIKit

class SearchCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .search
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController
    ) {
        self.navigation = navigation
    }
    
    func start() {
        self.showSearchViewFlow()
    }
    
    private func showSearchViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SearchViewModel.self) else { return }
//        vm.delegate = self.mapViewModel
        let vc = SearchViewController(viewModel: vm)
        
        vc.hidesBottomBarWhenPushed = true
        vm.setActions(
            actions: SearchViewModelActions(
                showLocationView: self.showMeloLocationView,
                closeSearchView: self.closeSearchView
            )
        )
        
        self.navigation.pushViewController(vc, animated: false)
    }
    
    lazy var showMeloLocationView: () -> Void = { [weak self] in
        let coordinator = MeloLocationCoordinator(navigation: self!.navigation)
        self?.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var closeSearchView: (_ space: Space) -> Void = { [weak self] space in
        guard let self else { return }
        self.navigation.popViewController(animated: false)
        self.finish()
        
        switch self.navigation.viewControllers.last {
        case is MapViewController:
            let viewController = self.navigation.viewControllers.last as? MapViewController
            viewController?.viewModel?.searchSpaceDidSelect(space: space)
        case is AddMeloPlaceViewController:
            let viewController = self.navigation.viewControllers.last as? AddMeloPlaceViewController
            viewController?.viewModel?.selectedSpace.accept(space)
            self.navigation.isNavigationBarHidden = true
        case .none:
            return
        case .some(_):
            return
        }
    }
    
//    lazy var closeSearchView: () -> Void = { [weak self] in
//        self?.navigation.popViewController(animated: false)
//        self?.finish()
//
//        switch self?.navigation.viewControllers.last {
//        case is MapViewController:
//            let viewController = self?.navigation.viewControllers.last as? MapViewController
//            viewController?.viewModel.
//        case is AddMeloPlaceViewController:
//            let viewController = self?.navigation.viewControllers.last as? AddMeloPlaceViewController
//            viewController?.viewModel
//
//        }
//
//        let viewController = self?.navigation.viewControllers.last as? MapViewController
//
//        viewController?.viewModel.
//
//    }
    
//    lazy var showPhotoDetail: (_ IndexPath: IndexPath) -> Void = { [weak self] indexPath in
//        let container = DIContainer.shared.container
//        guard let vm = container.resolve(PhotoDetailViewModel.self) else { return }
//        vm.indexpath = indexPath
//        let vc = PhotoDetailViewController(viewModel: vm)
////        self?.navigation.present(vc, animated: true)
//        self?.navigation.pushViewController(vc, animated: true)
//    }
}

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
