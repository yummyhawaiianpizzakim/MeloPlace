//
//  UserDTO.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation

struct UserDTO: DTOProtocol {
    var id: String
    var spotifyID: String
    var name: String
    var email: String
    var password: String
    var imageURL: String
    var imageWidth: Int
    var imageHeight: Int
    
    init(id: String, spotifyID: String, name: String, email: String, password: String, imageURL: String, imageWidth: Int, imageHeight: Int) {
        self.id = id
        self.spotifyID = spotifyID
        self.name = name
        self.email = email
        self.password = password
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
    }
    
    init() {
        self.id = ""
        self.spotifyID = ""
        self.name = ""
        self.email = ""
        self.password = ""
        self.imageURL = ""
        self.imageWidth = 0
        self.imageHeight = 0
    }
    
//    init(userDTO: UserDTO) {
//        self.id = ""
//        self.spotifyID = userDTO.spotifyID
//        self.name = userDTO.name
//        self.email = userDTO.email
//        self.password = userDTO.password
//        self.imageURL = userDTO.imageURL
//        self.imageWidth = userDTO.imageWidth
//        self.imageHeight = userDTO.imageHeight
//    }
//    
}

extension UserDTO {
    func toDomain() -> User {
//        print("Inside toDomain function")
        let user = User(id: self.id,
                        spotifyID: self.spotifyID,
                        name: self.name,
                        email: self.email,
                        password: self.password,
                        imageURL: self.imageURL,
                        imageWidth: self.imageWidth,
                        imageHeight: self.imageHeight
            )
        
//        print("todomain: \(user)")
        return user
    }
}
