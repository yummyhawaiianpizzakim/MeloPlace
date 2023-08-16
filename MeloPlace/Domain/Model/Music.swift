//
//  Music.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation

struct Music: Hashable {
    var id: String
    var name: String
    var URI: String
    var duration: Int
    var artist: String
    var album: String
    var imageURL: String
    var imageWidth: Int
    var imageHeightL: Int
}
