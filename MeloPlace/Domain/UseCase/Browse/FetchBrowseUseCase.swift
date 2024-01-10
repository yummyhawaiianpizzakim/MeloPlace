//
//  FetchBrowseUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/04.
//

import Foundation
import RxSwift

protocol FetchBrowseUseCaseProtocol: AnyObject {
    func fetch(limit: Int, isInit: Bool) -> Observable<[Browse]>
}

final class FetchBrowseUseCase: FetchBrowseUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    private let meloPlaceRepository: MeloPlaceRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol, meloPlaceRepository: MeloPlaceRepositoryProtocol) {
        self.userRepository = userRepository
        self.meloPlaceRepository = meloPlaceRepository
    }
    
    func fetch(limit: Int, isInit: Bool) -> Observable<[Browse]> {
        return self.meloPlaceRepository
            .fetchBrowseMeloPlace(limit: limit, isInit: isInit)
            .withUnretained(self)
            .flatMap { owner, meloPlaces -> Observable<[Browse]> in
                let userIDs = meloPlaces.map { $0.userID }
                return owner.userRepository
                    .fetchUserInfor(with: userIDs)
                    .map { owner.mapMeloPlaceWithUser(meloPlaces: meloPlaces, users: $0) }
            }
    }
}

private extension FetchBrowseUseCase {
    func mapMeloPlaceWithUser(meloPlaces: [MeloPlace], users: [User]) -> [Browse] {
        var mappedBrowses: [Browse] = []
        
        meloPlaces.forEach { meloPlace in
            users.forEach { user in
                if meloPlace.userID == user.id {
                    let browse = Browse(user: user, meloPlace: meloPlace)
                    mappedBrowses.append(browse)
                }
            }
        }
        
        return mappedBrowses
    }
}
