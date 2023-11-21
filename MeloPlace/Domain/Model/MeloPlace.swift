//
//  MeloPlace.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation

struct MeloPlace: Hashable {
    var id: String
    var userID: String
    var tagedUsers: [String]
    
    var musicURI: String
    var musicName: String
    var musicDuration: Int
    var musicArtist: String
    var musicAlbum: String
    var musicImageURL: String
    var musicImgaeWidth: Int
    var musicImgaeHeight: Int
    
    var images: [String]
    var title: String
    var description: String
    
    var address: String
    var spaceName: String
    
    var latitude: Double
    var longitude: Double
    var memoryDate: Date
    
    init(id: String, userID: String, tagedUsers: [String], musicURI: String, musicName: String, musicDuration: Int, musicArtist: String, musicAlbum: String, musicImageURL: String, musicImgaeWidth: Int, musicImgaeHeight: Int, images: [String], title: String, description: String, address: String, spaceName: String, latitude: Double, longitude: Double, memoryDate: Date) {
        self.id = id
        self.userID = userID
        self.tagedUsers = tagedUsers
        self.musicURI = musicURI
        self.musicName = musicName
        self.musicDuration = musicDuration
        self.musicArtist = musicArtist
        self.musicAlbum = musicAlbum
        self.musicImageURL = musicImageURL
        self.musicImgaeWidth = musicImgaeWidth
        self.musicImgaeHeight = musicImgaeHeight
        self.images = images
        self.title = title
        self.description = description
        self.address = address
        self.spaceName = spaceName
        self.latitude = latitude
        self.longitude = longitude
        self.memoryDate = memoryDate
    }
    
    init() {
        self.id = ""
        self.userID = ""
        self.tagedUsers = []
        self.musicURI = ""
        self.musicName = ""
        self.musicDuration = 0
        self.musicArtist = ""
        self.musicAlbum = ""
        self.musicImageURL = ""
        self.musicImgaeWidth = 0
        self.musicImgaeHeight = 0
        self.images = []
        self.title = ""
        self.description = ""
        self.address = ""
        self.spaceName = ""
        self.latitude = 0.00
        self.longitude = 0.00
        self.memoryDate = Date()
    }
}

extension MeloPlace {
    func toDTO() -> MeloPlaceDTO {
        return MeloPlaceDTO(
            id: self.id,
            userID: self.userID,
            tagedUsers: self.tagedUsers,
            musicURI: self.musicURI,
            musicName: self.musicName,
            musicDuration: self.musicDuration,
            musicArtist: self.musicArtist,
            musicAlbum: self.musicAlbum,
            musicImageURL: self.musicImageURL,
            musicImgaeWidth: self.musicImgaeWidth,
            musicImgaeHeight: self.musicImgaeHeight,
            images: self.images,
            title: self.title,
            description: self.description,
            address: self.address,
            spaceName: self.spaceName,
            latitude: self.latitude,
            longitude: self.longitude,
            memoryDate: self.memoryDate
        )
    }
}
