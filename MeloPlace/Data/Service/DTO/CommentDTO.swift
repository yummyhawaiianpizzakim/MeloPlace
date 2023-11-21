//
//  CommentDTO.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/24.
//

import Foundation

struct CommentDTO: DTOProtocol {
    var id: String
    var creatorUserID: String
    var meloPlaceID: String
    var contents: String
    let createdDate: Date
        
    func toDomain() -> Comment {
        return Comment(
            id: self.id,
            creatorUserID: self.creatorUserID,
            meloPlaceID: self.meloPlaceID,
            contents: self.contents,
            createdDate: self.createdDate
        )
    }
}

struct Comment: Hashable {
    var id: String
    var creatorUserID: String
    var meloPlaceID: String
    var contents: String
    let createdDate: Date
    
    var user: User?
    
    func toDTO() -> CommentDTO {
        return CommentDTO(
            id: self.id,
            creatorUserID: self.creatorUserID,
            meloPlaceID: self.meloPlaceID,
            contents: self.contents,
            createdDate: self.createdDate
        )
    }
}
