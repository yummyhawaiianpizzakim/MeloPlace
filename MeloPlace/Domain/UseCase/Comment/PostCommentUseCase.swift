//
//  PostCommentUseCase.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/26.
//

import Foundation
import RxSwift

protocol PostCommentUseCaseProtocol: AnyObject {
    func post(meloPlaceID: String, contents: String, createdDate: Date) -> Observable<Comment>
}

final class PostCommentUseCase: PostCommentUseCaseProtocol {
    var commentRepository: CommentRepositoryProtocol
    var userRepository: UserRepositoryProtocol
    
    init(commentRepository: CommentRepositoryProtocol,
         userRepository: UserRepositoryProtocol) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }
    func post(meloPlaceID: String, contents: String, createdDate: Date) -> Observable<Comment> {
        return self.commentRepository.postComment(meloPlaceID: meloPlaceID, contents: contents, createdDate: createdDate)
            .withUnretained(self)
            .flatMap { owner, comment in
                return owner.userRepository.fetchUserInfo()
                    .map { user in
                        return owner.mapCommentWithUser(comment: comment, user: user)
                    }
            }
    }
    
    private func mapCommentWithUser(comment: Comment, user: User) -> Comment {
        var comment = comment
        comment.user = user
        return comment
    }
}
