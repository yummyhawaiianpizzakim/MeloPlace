//
//  MapMeloPlaceListViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/31.
//

import Foundation
import RxSwift
import RxRelay

class MapMeloPlaceListViewModel {
    let disposeBag = DisposeBag()
    
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    struct Input {
        
    }
    
    struct Output {
        let dataSource = BehaviorRelay<[MeloPlace]>(value: [])
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        self.meloPlaces
            .bind(to: output.dataSource)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
