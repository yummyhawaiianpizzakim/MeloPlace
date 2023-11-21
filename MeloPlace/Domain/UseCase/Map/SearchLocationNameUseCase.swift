//
//  SearchLocationNameUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/06.
//

import Foundation
import RxSwift

protocol SearchLocationNameUseCaseProtocol: AnyObject {
    func search(query: String) -> Observable<[Space]> 
}

class SearchLocationNameUseCase: SearchLocationNameUseCaseProtocol {
    private let mapRepository: MapRepositoryProtocol
    
    init(mapRepository: MapRepositoryProtocol) {
        self.mapRepository = mapRepository
    }
    
    func search(query: String) -> Observable<[Space]> {
        self.mapRepository.setSearchText(with: query)
    }
}
