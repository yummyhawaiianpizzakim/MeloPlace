//
//  CommentCoordinator.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/24.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

final class CommentCoordinator: CoordinatorProtocol {
    var finishDelegate: CoordinatorFinishDelegate?
    
    var childCoordinators: [CoordinatorProtocol] = []
    
    var type: CoordinatorType = .comment
    
    var navigation: UINavigationController
    
    let disposeBag = DisposeBag()
    
    let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
    
    init(navigation : UINavigationController) {
        self.navigation = navigation
    }
    
    func start() {
        self.showCommentViewFlow()
    }
    
    private func showCommentViewFlow() {
        let container = DIContainer.shared.container
        guard let vm = container.resolve(CommentViewModel.self)
        else { return }
        
        self.meloPlace
            .bind(to: vm.meloPlace)
            .disposed(by: self.disposeBag)
        
        let vc = CommentViewController(viewModel: vm)
        
        vm.setActions(
            actions: CommentViewModelActions(
                showAnotherUserProfileView: self.showAnotherUserProfileView
            )
        )
        
        if let sheet = vc.sheetPresentationController {
            
            //지원할 크기 지정
            sheet.detents = [.medium(), .large()]
            //크기 변하는거 감지
//            sheet.delegate = self
            
            //시트 상단에 그래버 표시 (기본 값은 false)
            sheet.prefersGrabberVisible = true
            
            //처음 크기 지정 (기본 값은 가장 작은 크기)
            //sheet.selectedDetentIdentifier = .large
            
            //뒤 배경 흐리게 제거 (기본 값은 모든 크기에서 배경 흐리게 됨)
            //sheet.largestUndimmedDetentIdentifier = .medium
            
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.preferredCornerRadius = 30.0
        }
        
        self.navigation.present(vc, animated: true)
    }
    
    lazy var showAnotherUserProfileView: (_ id: String) -> Void = { [weak self] userID in
        guard let self else { return }
        let coordinator = AnotherUserProfileCoordinator(navigation: self.navigation)
        coordinator.userID = userID
        self.childCoordinators.append(coordinator)
        coordinator.finishDelegate = self
        coordinator.start()
    }
}

extension CommentCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
