//
//  CommentViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/24.
//

import Foundation
import MapKit
import RxSwift
import RxCocoa
import RxRelay

struct CommentViewModelActions {
    let showAnotherUserProfileView: (_ id: String) -> Void
}

class CommentViewModel {
    let disposeBag = DisposeBag()
    
    var actions: CommentViewModelActions?
    
    var fetchCommentUseCase: FetchCommentUseCaseProtocol
    var postCommentUseCase: PostCommentUseCaseProtocol
    
    let limit = 20
    let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
    let comments = BehaviorRelay<[Comment]>(value: [])
    let isLastFetch = BehaviorRelay<Bool>(value: false)
    
    init(fetchCommentUseCase: FetchCommentUseCaseProtocol, postCommentUseCase: PostCommentUseCaseProtocol) {
        self.fetchCommentUseCase = fetchCommentUseCase
        self.postCommentUseCase = postCommentUseCase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let didTapPostWithComment: Observable<String>
        let pagination: Observable<Void>
    }
    
    struct Output {
        let meloPlace: Driver<MeloPlace?>
        let comments: Driver<[Comment]>
        let isLastFetch: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        self.meloPlace
//            .debug("loadComments")
            .compactMap({ $0 })
            .withUnretained(self)
            .flatMap { owner, meloPlace in
                owner.fetchCommentUseCase.fetchComment(meloPlaceID: meloPlace.id, limit: self.limit, isInit: true)
            }
            .bind(to: self.comments)
            .disposed(by: self.disposeBag)
        
//        input.didTapPostWithComment
//            .withLatestFrom(Observable.combineLatest(
//                self.meloPlace, input.didTapPostWithComment)
//            )
//            .flatMapFirst { [weak self] val -> Observable<Comment> in
//                let (meloPlace, contents) = val
//                let date = Date()
//                guard let self,
//                      let meloPlace
//                else { return Observable.empty() }
//                return self.postCommentUseCase.post(meloPlaceID: meloPlace.id, contents: contents, createdDate: date)
//
//            }
//            .withLatestFrom(self.meloPlace)
//            .withUnretained(self)
//            .flatMap({ owner, meloPlace -> Observable<[Comment]> in
//                guard let meloPlace else { return Observable.just([]) }
//
//                return owner.fetchCommentUseCase.fetchComment(meloPlaceID: meloPlace.id, limit: self.limit, isInit: false)
//            })
//            .bind(to: self.comments)
//            .disposed(by: self.disposeBag)
        
        input.didTapPostWithComment
            .withLatestFrom(Observable.combineLatest(
                self.meloPlace, input.didTapPostWithComment)
            )
            .flatMapFirst { [weak self] val -> Observable<Comment> in
                let (meloPlace, contents) = val
                let date = Date()
                guard let self,
                      let meloPlace
                else { return Observable.empty() }
                return self.postCommentUseCase.post(meloPlaceID: meloPlace.id, contents: contents, createdDate: date)
                    
            }
            .withUnretained(self)
            .map({ owner, comment in
                var comments = owner.comments.value
                comments.insert(comment, at: 0)
                return comments
            })
            .bind(to: self.comments)
            .disposed(by: self.disposeBag)
        
        input.pagination
            .debug("pagination")
            .withLatestFrom(self.meloPlace)
            .withUnretained(self)
            .flatMapLatest { owner, meloPlace -> Observable<[Comment]> in
                guard let meloPlace else { return Observable.just([]) }
                return owner.fetchCommentUseCase.fetchComment(meloPlaceID: meloPlace.id, limit: self.limit, isInit: false)
            }
            .withUnretained(self)
            .do(onNext: { owner, comments in
                comments.isEmpty ?
                owner.isLastFetch.accept(true)
                :
                owner.isLastFetch.accept(false)
            })
            .map { owner, comments in
                let oldComments = owner.comments.value
                return oldComments + comments
            }
            .bind(to: self.comments)
            .disposed(by: self.disposeBag)
        
        self.comments
            .asObservable()
            .debug("commentsASDSAD")
            .subscribe { comments in
                print( comments.element?.count)
            }
            .disposed(by: self.disposeBag)
        
        return Output(meloPlace: self.meloPlace.asDriver(),
                      comments: self.comments.asDriver(),
                      isLastFetch: self.isLastFetch.asDriver()
        )
    }
    
    func setActions(actions: CommentViewModelActions) {
        self.actions = actions
    }
}

private extension CommentViewModel {

}

extension CommentViewModel {
    func showUserProfileView(id: String) {
//        self.actions?.showAnotherUserProfileView(id)
    }
}
