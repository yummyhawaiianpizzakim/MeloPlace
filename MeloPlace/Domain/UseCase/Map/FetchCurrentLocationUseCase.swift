//
//  FetchCurrentLocationUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/15.
//

import Foundation
import RxSwift

protocol FetchCurrentLocationUseCaseProtocol {
    func fetchCurrentLocation() -> Observable<(GeoPoint, Address)>
}

class FetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol {
    
    // MARK: Properties
    private let mapRepository: MapRepositoryProtocol
    
    // MARK: Initializers
    init(mapRepository: MapRepositoryProtocol) {
        self.mapRepository = mapRepository
    }
    
    // MARK: Methods
    func fetchCurrentLocation() -> Observable<(GeoPoint, Address)> {
        let result = mapRepository.fetchCurrentLocation()
        var coor = GeoPoint.seoulCoordinate
        
        if case let .success(success) = result {
            coor = success
        }
        
        return mapRepository.fetchLocationName(using: coor)
            .map { (coor, $0) }
    }
}
