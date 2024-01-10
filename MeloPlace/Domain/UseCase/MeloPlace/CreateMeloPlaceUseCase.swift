//
//  CreateMeloPlaceUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/02.
//

import Foundation
import RxSwift

protocol CreateMeloPlaceUseCaseProtocol: AnyObject {
    func create(meloPlace: MeloPlace) -> Observable<MeloPlace> 
}

final class CreateMeloPlaceUseCase: CreateMeloPlaceUseCaseProtocol {
    var meloPlaceRepository: MeloPlaceRepositoryProtocol
    
    init(meloPlaceRepository: MeloPlaceRepositoryProtocol) {
        self.meloPlaceRepository = meloPlaceRepository
    }
    
    func create(meloPlace: MeloPlace) -> Observable<MeloPlace> {
        
        return self.meloPlaceRepository.createMeloPlace(meloPlace: meloPlace)
    }
}
