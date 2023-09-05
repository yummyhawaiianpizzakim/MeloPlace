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
    
    var mapViewModel: MapViewModel
    
    init(navigation : UINavigationController,
         mapViewModel: MapViewModel) {
        self.navigation = navigation
        self.mapViewModel = mapViewModel
    }
    
    func start() {
        self.showSearchViewFlow()
    }
    
    private func showSearchViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SearchViewModel.self) else { return }
        vm.delegate = self.mapViewModel
        let vc = SearchViewController(viewModel: vm)
        
        vm.setActions(
            actions: SearchViewModelActions(
                closeSearchView: self.closeSearchView
            )
        )
        
        self.navigation.pushViewController(vc, animated: false)
    }
    
    lazy var closeSearchView: () -> Void = { [weak self] in
        self?.navigation.popViewController(animated: false)
        self?.finish()
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

extension SearchCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
