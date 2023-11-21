//
//  GeoPoint.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import CoreLocation

struct GeoPoint: Codable, Hashable {
    let latitude: Double
    let longitude: Double
    
    static var seoulCoordinate = GeoPoint(latitude: 37.553836, longitude: 126.969652)

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var dictData: [String: Any] {
        [
            "latitude": latitude,
            "longitude": longitude,
        ]
    }
    
    func shiftGeoPoint(latitudeDelta: Double, longitudeDelta: Double) -> GeoPoint {
        return GeoPoint(latitude: self.latitude + latitudeDelta,
                        longitude: self.longitude + longitudeDelta)
    }
}
