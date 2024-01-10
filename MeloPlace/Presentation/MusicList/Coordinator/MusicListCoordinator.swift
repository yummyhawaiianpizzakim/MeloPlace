//
//  MusicListCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import UIKit

final class MusicListCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .musicList
    
    var navigation: UINavigationController
    
    init(navigation : UINavigationController
    ) {
        self.navigation = navigation
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
        
        let vc = MusicListViewController(viewModel: vm)
        
        vm.setActions(
            actions: MusicListViewModelActions(
                closeMusicListView: self.closeMusicListView,
                submitSelectedMusic: self.submitSelectedMusic
            )
        )
        
        self.navigation.present(vc, animated: true)
    }
    
    lazy var closeMusicListView: () -> Void = { [weak self] in
        self?.finish()
    }
    
    lazy var submitSelectedMusic: (_ music: Music) -> Void = { [weak self] music in
        guard let viewController = self?.navigation.viewControllers.last as? AddMeloPlaceViewController else { return }
        
        self?.finish()
        viewController.viewModel?.selectedMusic.accept(music)
    }
}

extension MusicListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
