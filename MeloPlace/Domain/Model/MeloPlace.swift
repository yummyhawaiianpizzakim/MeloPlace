//
//  MeloPlace.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation

struct MeloPlace: Hashable {
    var uuid: String
    var userId: String
    
    var images: [String]
    var title: String
    var description: String
    
    var address: String
    var simpleAddress: String
    
    var latitude: Double
    var longitude: Double
    var memoryDate: Date
}
