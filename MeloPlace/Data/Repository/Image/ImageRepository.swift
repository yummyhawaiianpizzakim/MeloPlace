//
//  ImageRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/03.
//

import Foundation
import RxSwift

protocol ImageRepositoryProtocol: AnyObject {
    func upload(data: Data) -> Observable<String>
}

final class ImageRepository: ImageRepositoryProtocol {
    private let fireBaseService: FireBaseNetworkServiceProtocol

    init(fireBaseService: FireBaseNetworkServiceProtocol) {
        self.fireBaseService = fireBaseService
    }
    
    func upload(data: Data) -> Observable<String> {
        return self.fireBaseService
            .uploadDataStorage(data: data, path: .meloPlaceImages)
            .asObservable()
    }
    
}
