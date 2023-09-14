//
//  MeloPlaceRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol MeloPlaceRepositoryProtocol: AnyObject {
    func fetchUserMeloPlace() -> Single<[MeloPlace]> 
}

class MeloPlaceRepository: MeloPlaceRepositoryProtocol {
    var fireBaseService = FireBaseNetworkService.shared
    
    init(fireBaseService: FireBaseNetworkService) {
        self.fireBaseService = fireBaseService
    }
    
    func fetchUserMeloPlace() -> Single<[MeloPlace]> {
        return self.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
            .map({ dto in
                dto.toDomain()
            })
            .toArray()
            .catchAndReturn([])
    }
}
