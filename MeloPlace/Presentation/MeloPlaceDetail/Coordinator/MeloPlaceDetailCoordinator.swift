//
//  MeloPlaceDetailCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

class MeloPlaceDetailCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .detail
    
    var navigation: UINavigationController
    
    let disposeBag = DisposeBag()
    
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
//    let indexPath = PublishRelay<IndexPath>()
//    let indexPath = BehaviorRelay<IndexPath>(value: [0, 0])
    var indexPath: IndexPath?
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showMeloPlaceDetailViewFlow()
    }
    
    private func showMeloPlaceDetailViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(MeloPlaceDetailViewModel.self)
        else { return }
        
        self.meloPlaces
            .bind(to: vm.meloPlaces)
            .disposed(by: self.disposeBag)
        
//        self.indexPath
//            .bind(to: vm.indexPath)
//            .disposed(by: self.disposeBag)
        vm.indexPath = self.indexPath
        
        let vc = MeloPlaceDetailViewController(viewModel: vm)
        
//        vm.setActions(
//            actions: PhotoListViewModelActions(
//                showPhotoDetail: self.showPhotoDetail
//            )
//        )
//        vc.modalPresentationStyle = .fullScreen
        self.navigation.present(vc, animated: true)
//        self.navigation.pushViewController(vc, animated: true)
        
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
