//
//  AddMeloPlaceCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import UIKit

class AddMeloPlaceCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .addMelo
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    init() {
        self.navigation = UINavigationController()
    }
    
    func start() {
        self.showAddMeloPlaceViewFlow()
    }
    
    private func showAddMeloPlaceViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(AddMeloPlaceViewModel.self) else { return }
        
        let vc = AddMeloPlaceViewController(viewModel: vm)
        
        vm.setActions(
            actions: AddMeloPlaceViewModelActions(
                showMeloLocationView: self.showMeloLocationView,
                showMusicListView: self.showMusicListView,
                showSelectDateView: self.showSelectDateView, closeAddMeloPlaceView: self.closeAddMeloPlaceView
            )
        )
        
        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var showMeloLocationView: (_ addViewModel: AddMeloPlaceViewModel) -> Void = { [weak self] addViewModel in
        let coordinator = MeloLocationCoordinator(navigation: self!.navigation, addViewModel: addViewModel)
        self?.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showMusicListView: (_ addViewModel: AddMeloPlaceViewModel) -> Void = { [weak self] addViewModel in
        let coordinator = MusicListCoordinator(navigation: self!.navigation, addViewModel: addViewModel)
        self?.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var showSelectDateView: (_ addViewModel: AddMeloPlaceViewModel) -> Void = { [weak self] addViewModel in
        let coordinator = SelectDateCoordinator(navigation: self!.navigation, addViewModel: addViewModel)
        self?.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
    
    lazy var closeAddMeloPlaceView: () -> Void = { [weak self] in
        self?.finish()
        self?.navigation.popViewController(animated: true)
    }
    
}

extension AddMeloPlaceCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
