//
//  SelectDateViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/16.
//

import Foundation
import RxSwift
import RxRelay

//protocol SelectDateViewModelDelegate {
//    func dateDidSelect(date: Date)
//}

struct SelectDateViewModelActions {
    let closeSelectDateView: () -> Void
    let closeSelectDateViewWith: (_ date: Date) -> Void
}

class SelectDateViewModel {
    
    struct Input {
        var selectedDate: Observable<Date>
        var didTapDoneButton: Observable<Void>
        
    }
    
    struct Output {
        let isDone = BehaviorRelay<Bool>(value: false)
    }
    
    let disposeBag = DisposeBag()
    
    var actions: SelectDateViewModelActions?
//    var delegate: SelectDateViewModelDelegate?
    
    func setActions(actions: SelectDateViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
//        input.selectedDate
//            .withUnretained(self)
//            .subscribe { owner, date in
//                owner.delegate?.dateDidSelect(date: date)
//                print(date)
//            }
//            .disposed(by: self.disposeBag)
        
        input.didTapDoneButton
            .withLatestFrom(input.selectedDate)
            .map({[weak self] date in
//                self?.delegate?.dateDidSelect(date: date)
                self?.actions?.closeSelectDateViewWith(date)
                return true
            })
            .bind(to: output.isDone)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
