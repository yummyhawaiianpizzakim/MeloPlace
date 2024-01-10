//
//  SearchViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

struct SearchViewModelActions {
    let showLocationView: () -> Void
    let closeSearchView: (_ space: Space) -> Void
}

final class SearchViewModel {
    let disposeBag = DisposeBag()
    private let searchLocationNameUseCase: SearchLocationNameUseCaseProtocol
    
    var actions: SearchViewModelActions?
    
    let searchSpaces = BehaviorRelay<[Space]>(value: [])
    let currentSpace = BehaviorRelay<Space?>(value: nil)
    
    init(searchLocationNameUseCase: SearchLocationNameUseCaseProtocol) {
        self.searchLocationNameUseCase = searchLocationNameUseCase
    }
    
    struct Input {
        var didEditSearchText: Observable<String>
        let didTapCurrentLocationButton: Observable<Void>
        var didTapSearchTableCell: Observable<IndexPath>
    }
    
    struct Output {
        let searchSpaces: Driver<[Space]>
    }
    
    func transform(input: Input) -> Output {
        
        let spaces = input.didEditSearchText
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap({ owner, query in
                owner.searchLocationNameUseCase.search(query: query)
            })
            .do { [weak self] spaces in
                self?.searchSpaces.accept(spaces)
            }
            .asDriver(onErrorJustReturn: [])
        
        input.didTapCurrentLocationButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.actions?.showLocationView()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapSearchTableCell
            .withUnretained(self)
            .map({ owner, indexPath in
                owner.searchSpaces.value[indexPath.row]
            })
            .withUnretained(self)
            .subscribe(onNext: { owner, space in
                owner.actions?.closeSearchView(space)
            })
            .disposed(by: self.disposeBag)
        
        self.currentSpace
            .compactMap({ $0 })
            .withUnretained(self)
            .bind { owner, space in
                owner.actions?.closeSearchView(space)
            }
            .disposed(by: self.disposeBag)
        
        return Output(searchSpaces: spaces)
    }
}

extension SearchViewModel {
    func setActions(actions: SearchViewModelActions) {
        self.actions = actions
    }
    
}
