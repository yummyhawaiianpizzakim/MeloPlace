//
//  Region.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/18.
//

import Foundation

struct Region {
    var center: GeoPoint
    var spanLatitude: Double
    var spanLongitude: Double
}

extension Region {
    static func stub(center: GeoPoint = .init(latitude: 0,
                                              longitude: 0),
                     spanLatitude: Double = 1,
                     spanLongitude: Double = 1) -> Self {
        return .init(center: center,
                     spanLatitude: spanLatitude,
                     spanLongitude: spanLongitude)
    }
}
