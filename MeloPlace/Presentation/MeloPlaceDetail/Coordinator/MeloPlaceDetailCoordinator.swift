//
//  MeloPlaceDetailCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import UIKit
import RxRelay

class MeloPlaceDetailCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .detail
    
    var navigation: UINavigationController
    
    let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showMeloPlaceDetailViewFlow()
    }
    
    private func showMeloPlaceDetailViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MeloPlaceDetailViewModel.self),
        let meloPlace = self.meloPlace.value else { return }
        
        vm.meloPlace.accept(meloPlace)
        let vc = MeloPlaceDetailViewController(viewModel: vm)
        
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

extension MeloPlaceDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
