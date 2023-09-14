//
//  FetchMeloPlaceUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import RxSwift

protocol FetchMeloPlaceUseCaseProtocol: AnyObject {
    func fetch() -> Observable<[MeloPlace]> 
}

class FetchMeloPlaceUseCase: FetchMeloPlaceUseCaseProtocol {
    var meloPlaceRepository: MeloPlaceRepositoryProtocol
    
    init(meloPlaceRepository: MeloPlaceRepositoryProtocol) {
        self.meloPlaceRepository = meloPlaceRepository
    }
    
    func fetch() -> Observable<[MeloPlace]> {
        return self.meloPlaceRepository.fetchUserMeloPlace().asObservable()
    }
    
}
