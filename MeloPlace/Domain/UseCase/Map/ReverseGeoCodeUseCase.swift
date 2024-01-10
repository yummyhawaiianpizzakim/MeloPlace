//
//  ReverseGeoCodeUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/06.
//

import Foundation
import RxSwift

protocol ReverseGeoCodeUseCaseProtocol: AnyObject {
    func reverse(point: GeoPoint) -> Observable<Space>
}

final class ReverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol {
    private let mapRepository: MapRepositoryProtocol
    
    init(mapRepository: MapRepositoryProtocol) {
        self.mapRepository = mapRepository
    }
    
    func reverse(point: GeoPoint) -> Observable<Space> {
        self.mapRepository.reverseGeocode(point: point)
            .withUnretained(self)
            .flatMap { owner, address -> Observable<[Space]> in
                guard let address
                else { return Observable.error(LocalError.addressError)}
                return owner.mapRepository.setSearchText(with: address.full)
            }
            .compactMap { spaces in
                spaces.first
            }
            
    }
}
