//
//  MainViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay

class MainViewModel {
    let disposeBag = DisposeBag()
    
    let mock = BehaviorRelay<[MeloPlace]>(
        value:
            [MeloPlace(uuid: UUID().uuidString,
                       userId: "",
                       images: [""],
                       title: "asdasd",
                       description: "zxczxc",
                       address: "asdqwe",
                       simpleAddress: "asdasf",
                       latitude: 10.0000,
                       longitude: 10.0000,
                       memoryDate: Date()
                      ),
             MeloPlace(uuid: UUID().uuidString,
                        userId: "",
                        images: [""],
                        title: "asdasaad",
                        description: "zxczvvxc",
                        address: "asdddqwe",
                        simpleAddress: "asdaaasf",
                        latitude: 10.0000,
                        longitude: 10.0000,
                        memoryDate: Date()
                       )
            ]
    )
    
    struct Input {
        
    }
    
    struct Output {
        let dataSource = BehaviorRelay<[MeloPlace]>(value: [])
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        self.mock.bind(to: output.dataSource).disposed(by: self.disposeBag)
        
        return output
    }
}
