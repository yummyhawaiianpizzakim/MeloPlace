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
    let indexPath = BehaviorRelay<IndexPath>(value: [0, 0])
//    var indexPath: IndexPath?
    
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
        
        self.indexPath
            .bind(to: vm.indexPath)
            .disposed(by: self.disposeBag)
//        vm.indexPath = self.indexPath
        
        let vc = MeloPlaceDetailViewController(viewModel: vm)
        
        vc.hidesBottomBarWhenPushed = true
        
        vm.setActions(
            actions: MeloPlaceDetailViewModelActions(
                showCommentsView: self.showCommentsView,
                closeCommentsView: self.closeCommentsView
            )
        )
//        vc.modalPresentationStyle = .overFullScreen
//        self.navigation.present(vc, animated: true)
        self.navigation.pushViewController(vc, animated: true)
        
    }
    
    lazy var showCommentsView: (_ meloPlace: MeloPlace) -> Void = { [weak self] meloPlace in
        guard let self = self else { return }
        let commentCoordinator = CommentCoordinator(navigation: self.navigation)
        commentCoordinator.meloPlace.accept(meloPlace)
        commentCoordinator.finishDelegate = self
        self.childCoordinators.append(commentCoordinator)
        commentCoordinator.start()
    }
    
    lazy var closeCommentsView: () -> Void = { [weak self] in
        self?.navigation.popViewController(animated: false)
        self?.finish()
    }
}

extension MeloPlaceDetailCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
