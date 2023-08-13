//
//  GeoPoint.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import CoreLocation

struct GeoPoint: Codable {
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var dictData: [String: Any] {
        [
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
}
