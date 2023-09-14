//
//  MeloPlaceDTO.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/22.
//

import Foundation

struct MeloPlaceDTO: DTOProtocol {
    var id: String
    var userId: String
    
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
    var simpleAddress: String
    
    var latitude: Double
    var longitude: Double
    var memoryDate: Date
}

extension MeloPlaceDTO {
    func toDomain() -> MeloPlace {
        return MeloPlace(
            id: self.id,
            userId: self.userId,
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
            simpleAddress: self.simpleAddress,
            latitude: self.latitude,
            longitude: self.longitude,
            memoryDate: self.memoryDate
        )
    }
}
