//
//  FetchCommentUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/26.
//

import Foundation
import RxSwift

protocol FetchCommentUseCaseProtocol: AnyObject {
    func fetchComment(meloPlaceID: String, limit: Int, isInit: Bool) -> Observable<[Comment]>
}

class FetchCommentUseCase: FetchCommentUseCaseProtocol {
    var commentRepository: CommentRepositoryProtocol
    var userRepository: UserRepositoryProtocol
    
//    init(commentRepository: CommentRepositoryProtocol) {
//        self.commentRepository = commentRepository
//    }
    init(commentRepository: CommentRepositoryProtocol,
         userRepository: UserRepositoryProtocol) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }
    
    func fetchComment(meloPlaceID: String, limit: Int, isInit: Bool) -> Observable<[Comment]> {
        return self.commentRepository
            .fetchComment(limit: limit, meloPlaceID: meloPlaceID, isInit: isInit)
            .withUnretained(self)
            .flatMap { owner, comments -> Observable<[Comment]> in
            let userIDs = comments.map { $0.creatorUserID }
            return self.userRepository.fetchUserWithComments(userID: userIDs)
                    .map { users in
                        self.mapCommentWithUser(comments: comments, users: users)
                    }.asObservable()
            }
    }
    
    private func mapCommentWithUser(comments: [Comment], users: [User]) -> [Comment] {
        var mappedCommnets: [Comment] = []
        
        comments.forEach { comment in
            users.forEach { user in
                if comment.creatorUserID == user.id {
                    var mutableCommnet = comment
                    mutableCommnet.user = user
                    mappedCommnets.append(mutableCommnet)
                }
            }
        }
        return mappedCommnets
    }
}
