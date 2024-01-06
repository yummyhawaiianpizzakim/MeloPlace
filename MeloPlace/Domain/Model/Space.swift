//
//  Space.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation

struct Space {
    let id = UUID().uuidString
    let name: String
    let address: String
    let lat: Double
    let lng: Double
}

extension Space: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Space {
    static func stub(name: String = "",
              address: String = "",
              lat: Double = 0,
              lng: Double = 0) -> Self {
        return .init(name: name,
                     address: address,
                     lat: lat,
                     lng: lng)
    }
}
