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
    
//    var addViewModel: AddMeloPlaceViewModel
    
    init(navigation : UINavigationController
//         addViewModel: AddMeloPlaceViewModel
    ) {
        self.navigation = navigation
//        self.addViewModel = addViewModel
    }
    
    func start() {
        self.showBrowseViewFlow()
    }
    
    private func showBrowseViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(SelectDateViewModel.self) else { return }
//        vm.delegate = self.addViewModel
        let vc = SelectDateViewController(viewModel: vm)
        
        vm.setActions(
            actions: SelectDateViewModelActions(
                closeSelectDateView: self.closeSelectDateView,
                closeSelectDateViewWith: self.closeSelectDateViewWith
            )
        )
        
//        self.navigation.pushViewController(vc, animated: true)
        self.navigation.present(vc, animated: true)
    }
    
    lazy var closeSelectDateView: () -> Void = { [weak self] in
        
        self?.finish()
        
    }
    
    lazy var closeSelectDateViewWith: (_ date: Date) -> Void = { [weak self] date in
        guard
            let addMeloPlaceViewController = self?.navigation.viewControllers.last as? AddMeloPlaceViewController
        else { return }
        self?.finish()
        
        addMeloPlaceViewController.viewModel?.selectedDate.accept(date)
    }
    
}

extension SelectDateCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
