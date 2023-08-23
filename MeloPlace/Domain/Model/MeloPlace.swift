//
//  MeloPlace.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation

struct MeloPlace: Hashable {
    var id: String
    var userId: String
    
    var musicURI: String
    
    var images: [String]
    var title: String
    var description: String
    
    var address: String
    var simpleAddress: String
    
    var latitude: Double
    var longitude: Double
    var memoryDate: Date
}

extension MeloPlace {
    func toDTO() -> MeloPlaceDTO {
        return MeloPlaceDTO(id: self.id,
                            userId: self.userId,
                            musicURI: self.musicURI,
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
