//
//  CoordinatorProtocol.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation

enum CoordinatorType {
    case app
    case tab
    case main, map, browse, userProfile
    case addMelo, detail, mapMeloPlaceList, comment , anotherUserProfile
    case location, musicList, selectDate, search, searchUser, followingUserList
    case signIn, signUp
}


protocol CoordinatorProtocol: AnyObject {
    var finishDelegate: CoordinatorFinishDelegate? { get set }
    var childCoordinators: [CoordinatorProtocol] { get set }
    var type: CoordinatorType { get }
    
    func start()
    func finish()
}


extension CoordinatorProtocol {
    func finish() {
        self.childCoordinators.removeAll()
        self.finishDelegate?.coordinatorDidFinished(childCoordinator: self)
    }
}

protocol CoordinatorFinishDelegate:AnyObject {
    func coordinatorDidFinished(childCoordinator: CoordinatorProtocol)
}
