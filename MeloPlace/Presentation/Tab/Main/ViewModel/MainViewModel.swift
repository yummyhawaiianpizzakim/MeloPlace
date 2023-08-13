//
//  MainViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay


struct MainViewModelActions {
    let showAddMeloPlaceView: () -> Void
}

class MainViewModel {
    let disposeBag = DisposeBag()
    
    var actions: MainViewModelActions?
    
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
    
    func setActions(actions: MainViewModelActions) {
        self.actions = actions
    }
    
    struct Input {
        var didTapAddButton: Observable<Void>
    }
    
    struct Output {
        let dataSource = BehaviorRelay<[MeloPlace]>(value: [])
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        input.didTapAddButton
            .withUnretained(self)
            .subscribe { owner , _ in
                print("tap")
                owner.actions?.showAddMeloPlaceView()
            }
            .disposed(by: self.disposeBag)
        
        self.mock.bind(to: output.dataSource).disposed(by: self.disposeBag)
        
        return output
    }
}
