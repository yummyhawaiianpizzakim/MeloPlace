//
//  MusicListCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import UIKit

class MusicListCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .musicList
    
    var navigation: UINavigationController
    
    var addViewModel: AddMeloPlaceViewModel?
    
    init(navigation : UINavigationController, addViewModel: AddMeloPlaceViewModel) {
        self.navigation = navigation
        self.addViewModel = addViewModel
    }
    
    init() {
        self.navigation = UINavigationController()
    }
    
    func start() {
        self.showMusicListViewFlow()
    }
    
    private func showMusicListViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MusicListViewModel.self) else { return }
        
//        vm.delegate = self.musicListViewModel
        let vc = MusicListViewController(viewModel: vm)
        
        vm.setActions(
            actions: MusicListViewModelActions(
//                closeMeloLocationView: self.closeMeloLocationView
                showMusicPlayerView: self.showMusicPlayerView)
        )
        
        self.navigation.present(vc, animated: true)
//        self.navigation.pushViewController(vc, animated: true)
    }
    
    lazy var closeMeloLocationView: () -> Void = { [weak self] in
        self?.finish()
//        self?.viewController?.dismiss(animated: true)
    }
    
    lazy var showMusicPlayerView: (_ music: Music) -> Void = { [weak self] music in
//        let container = DIContainer.shared.container
//        guard let vm = container.resolve(PhotoDetailViewModel.self) else { return }
//        vm.indexpath = indexPath
//        let vc = PhotoDetailViewController(viewModel: vm)
////        self?.navigation.present(vc, animated: true)
//        self?.navigation.pushViewController(vc, animated: true)
    }
}

extension MusicListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}