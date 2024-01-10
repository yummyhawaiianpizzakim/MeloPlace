//
//  SelectDateViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/16.
//

import Foundation
import RxSwift
import RxRelay

struct SelectDateViewModelActions {
    let closeSelectDateView: () -> Void
    let closeSelectDateViewWith: (_ date: Date) -> Void
}

final class SelectDateViewModel {
    
    struct Input {
        var selectedDate: Observable<Date>
        var didTapDoneButton: Observable<Void>
        
    }
    
    struct Output {
        let isDone = BehaviorRelay<Bool>(value: false)
    }
    
    let disposeBag = DisposeBag()
    
    var actions: SelectDateViewModelActions?
    
    func setActions(actions: SelectDateViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didTapDoneButton
            .withLatestFrom(input.selectedDate)
            .map({[weak self] date in
                self?.actions?.closeSelectDateViewWith(date)
                return true
            })
            .bind(to: output.isDone)
            .disposed(by: self.disposeBag)
        
        return output
    }
}
