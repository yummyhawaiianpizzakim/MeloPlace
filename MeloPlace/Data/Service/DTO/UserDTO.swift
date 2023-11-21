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
    var follower: [String]
    var following: [String]
    
    init(id: String, spotifyID: String, name: String, email: String, password: String, imageURL: String, imageWidth: Int, imageHeight: Int, follower: [String], following: [String]) {
        self.id = id
        self.spotifyID = spotifyID
        self.name = name
        self.email = email
        self.password = password
        self.imageURL = imageURL
        self.imageWidth = imageWidth
        self.imageHeight = imageHeight
        self.follower = follower
        self.following = following
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
        self.follower = []
        self.following = []
    }
    
}

extension UserDTO {
    func toDomain() -> User {
        let user = User(id: self.id,
                        spotifyID: self.spotifyID,
                        name: self.name,
                        email: self.email,
                        password: self.password,
                        imageURL: self.imageURL,
                        imageWidth: self.imageWidth,
                        imageHeight: self.imageHeight,
                        follower: self.follower,
                        following: self.following
            )
        
        return user
    }
}
