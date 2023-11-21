//
//  UploadImageUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/03.
//

import Foundation
import RxSwift

protocol UploadImageUseCaseProtocol: AnyObject {
    func upload(data: Data) -> Observable<String>
}

class UploadImageUseCase: UploadImageUseCaseProtocol {
    private let imageRepository: ImageRepositoryProtocol
    
    init(imageRepository: ImageRepositoryProtocol) {
        self.imageRepository = imageRepository
    }
    
    func upload(data: Data) -> Observable<String> {
        return self.imageRepository.upload(data: data)
    }
}
