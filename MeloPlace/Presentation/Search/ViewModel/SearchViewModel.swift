//
//  SearchViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation
import RxSwift
import RxRelay

protocol SearchViewModelDelegate {
    func searchSpaceDidSelect(space: Space)
}

struct SearchViewModelActions {
    let closeSearchView: () -> Void
}

class SearchViewModel {
    let locationManager = LocationManager.shared
    let disposeBag = DisposeBag()
    
    var actions: SearchViewModelActions?
    var delegate: SearchViewModelDelegate?
    
    let searchSpaces = BehaviorRelay<[Space]>(value: [])
    
    struct Input {
        var didEditSearchText: Observable<String>
        var didTapSearchTableCell: Observable<IndexPath>
    }
    
    struct Output {
        let searchSpaces = PublishRelay<[Space]>()
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didEditSearchText
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .subscribe { owner, query in
                owner.locationManager.setSearchText(with: query)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapSearchTableCell
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                var space = self.searchSpaces.value[indexPath.row]
                self.delegate?.searchSpaceDidSelect(space: space)
                self.actions?.closeSearchView()
            })
            .disposed(by: self.disposeBag)
        
        self.locationManager.results
            .withUnretained(self)
            .subscribe(onNext: { owner, spaces in
                owner.searchSpaces.accept(spaces)
                output.searchSpaces.accept(spaces)
            })
            .disposed(by: self.disposeBag)
        
        return output
    }
}

extension SearchViewModel {
    func setActions(actions: SearchViewModelActions) {
        self.actions = actions
    }
    
}
