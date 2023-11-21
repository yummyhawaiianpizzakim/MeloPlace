//
//  MeloPlaceDTO.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/22.
//

import Foundation

struct MeloPlaceDTO: DTOProtocol {
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
}

extension MeloPlaceDTO {
    func toDomain() -> MeloPlace {
        return MeloPlace(
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
