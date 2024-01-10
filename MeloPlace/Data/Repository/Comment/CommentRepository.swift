//
//  CommentRepository.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/24.
//

import Foundation
import RxSwift

protocol CommentRepositoryProtocol {
    func postComment(meloPlaceID: String, contents: String, createdDate: Date) -> Observable<Comment>
    func fetchComment(limit: Int, meloPlaceID: String, isInit: Bool) -> Observable<[Comment]> 
}

final class CommentRepository: CommentRepositoryProtocol {
    private let fireBaseService: FireBaseNetworkServiceProtocol
    
    init(fireBaseService: FireBaseNetworkServiceProtocol) {
        self.fireBaseService = fireBaseService
    }
    
    func postComment(meloPlaceID: String, contents: String, createdDate: Date) -> Observable<Comment> {
        guard
            let userID = try? self.fireBaseService.determineUserID(id: nil)
        else { return Observable.empty() }
        
        let dto = CommentDTO(id: UUID().uuidString,
                          creatorUserID: userID,
                          meloPlaceID: meloPlaceID,
                          contents: contents,
                          createdDate: createdDate)
        
        let result = self.fireBaseService.create(dto: dto, access: .comment(meloPlaceID: meloPlaceID)).map { $0.toDomain() }
            .asObservable()
        
        return result
    }
    
    func fetchComment(limit: Int, meloPlaceID: String, isInit: Bool) -> Observable<[Comment]> {
        if isInit {
            self.fireBaseService.initCommentLastSnapshot()
        }
        
        let queryList: [FirebaseQueryDTO] = [
            .init(key: "createdDate", value: true)
        ]
        
        let comments = self.fireBaseService.readForPagination(type: CommentDTO.self, access: .comment(meloPlaceID: meloPlaceID), firebaseFilter: .date(queryList))
            .map({ $0.toDomain() })
            .toArray()
            .catchAndReturn([])
            .asObservable()
        
        return comments
    }
}
