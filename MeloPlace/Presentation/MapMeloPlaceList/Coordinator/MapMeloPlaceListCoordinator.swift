//
//  MapMeloPlaceListCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/31.
//

import Foundation
import UIKit
import FloatingPanel
import RxSwift
import RxRelay

class MapMeloPlaceListCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .mapMeloPlaceList
    
    var navigation: UINavigationController
    
    let disposeBag = DisposeBag()
    
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showMapMeloPlaceListViewFlow()
    }
    
    private func showMapMeloPlaceListViewFlow() {
//        let container = DIContainer.shared.container
//        guard let vm = container.resolve(MapMeloPlaceListViewModel.self) else { return }
//        let floatingPanelController = FloatingPanelController()
//        let vc = MapMeloPlaceListViewController(viewModel: vm)
//        self.meloPlaces
//            .bind(to: vm.meloPlaces)
//            .disposed(by: self.disposeBag)
        
//        vm.setActions(
//            actions: PhotoListViewModelActions(
//                showPhotoDetail: self.showPhotoDetail
//            )
//        )
        
//        floatingPanelController.set(contentViewController: vc)
//        floatingPanelController.addPanel(toParent: self.navigation)
//        floatingPanelController.track(scrollView: vc.meloPlaceCollectionView)
//        floatingPanelController.changePanelStyle()
//        floatingPanelController.layout = CustomFloatingPanelLayout()
//
//        vc.loadViewIfNeeded()
//        self.navigation.present(floatingPanelController, animated: true)
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

extension MapMeloPlaceListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
