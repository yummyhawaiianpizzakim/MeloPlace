//
//  selectDateCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/16.
//

import Foundation

import UIKit

class SelectDateCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .selectDate
    
    var navigation: UINavigationController
    
    var addViewModel: AddMeloPlaceViewModel
    
    init(navigation : UINavigationController, addViewModel: AddMeloPlaceViewModel) {
        self.navigation = navigation
        self.addViewModel = addViewModel
    }
    
    func start() {
        self.showBrowseViewFlow()
    }
    
    private func showBrowseViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SelectDateViewModel.self) else { return }
        vm.delegate = self.addViewModel
        let vc = SelectDateViewController(viewModel: vm)
        
        vm.setActions(
            actions: SelectDateViewModelActions(
                closeSelectDateView: self.closeSelectDateView
            )
        )
        
//        self.navigation.pushViewController(vc, animated: true)
        self.navigation.present(vc, animated: true)
    }
    
    lazy var closeSelectDateView: () -> Void = { [weak self] in
        self?.finish()
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

extension SelectDateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
