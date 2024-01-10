//
//  SearchUserViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/09.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay

struct SearchUserViewModelActions {
    let showUserProfileView: (_ userID: String) -> Void
    let closeSearchView: (_ user: User) -> Void
}

final class SearchUserViewModel {
    let disposeBag = DisposeBag()
    private let fetchUserUseCase: FetchUserUseCaseProtocol
    
    var actions: SearchUserViewModelActions?

    let childByUserProfile = BehaviorRelay<Bool>(value: false)
    let searchedUsers = BehaviorRelay<[User]>(value: [])
    
    init(fetchUserUseCase: FetchUserUseCaseProtocol) {
        self.fetchUserUseCase = fetchUserUseCase
    }
    
    struct Input {
        var didEditSearchText: Observable<String>
        var didTapSearchTableCell: Observable<IndexPath>
    }
    
    struct Output {
        let searchedUser: Driver<[User]>
    }
    
    func transform(input: Input) -> Output {
        
        input.didEditSearchText
            .debounce(.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap({ owner, query -> Observable<[User]> in
                let user = query.isEmpty ?
                Observable.just([]) : owner.fetchUserUseCase.fetch(userNickName: query)
                return user
            })
            .bind(to: self.searchedUsers)
            .disposed(by: self.disposeBag)
        
        input.didTapSearchTableCell
            .withUnretained(self)
            .map({ owner, indexPath in
                return owner.searchedUsers.value[indexPath.row]
            })
            .withUnretained(self)
            .subscribe(onNext: { owner, user in
                let isChildByUserProfile = owner.childByUserProfile.value
                
                if isChildByUserProfile {
                    owner.actions?.showUserProfileView(user.id)
                } else {
                    owner.actions?.closeSearchView(user)
                }
            })
            .disposed(by: self.disposeBag)
        
        return Output(searchedUser: self.searchedUsers.asDriver())
    }
}

extension SearchUserViewModel {
    func setActions(actions: SearchUserViewModelActions) {
        self.actions = actions
    }
    
}
