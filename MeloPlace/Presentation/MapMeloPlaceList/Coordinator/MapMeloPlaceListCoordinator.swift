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

final class MapMeloPlaceListCoordinator: CoordinatorProtocol {
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
    }
}

extension MapMeloPlaceListCoordinator: CoordinatorFinishDelegate {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol) {
        childCoordinators = childCoordinators.filter {
            $0.type != childCoordinator.type
        }
    }
    
    
}
