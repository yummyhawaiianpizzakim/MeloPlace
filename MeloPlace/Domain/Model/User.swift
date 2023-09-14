//
//  User.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation

struct User: Hashable {
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
}
