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

class PostCommentUseCase: PostCommentUseCaseProtocol {
    var commentRepository: CommentRepositoryProtocol
    
    init(commentRepository: CommentRepositoryProtocol) {
        self.commentRepository = commentRepository
    }
    
    func post(meloPlaceID: String, contents: String, createdDate: Date) -> Observable<Comment> {
        return self.commentRepository.postComment(meloPlaceID: meloPlaceID, contents: contents, createdDate: createdDate)
    }
}
