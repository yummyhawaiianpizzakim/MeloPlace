//
//  AddMeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import RxSwift
import RxRelay

class AddMeloPlaceViewModel {
    
//    let image = BehaviorRelay<Data>(value: Data())
    
    struct Input {
        var imageData: Observable<Data>
        var date: Observable<Date>
    }
    
    struct Output {
        
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        return output
    }
}

extension AddMeloPlaceViewModel {
//    func addImage(data: Data) {
//        self.image.accept(data)
//    }
}
