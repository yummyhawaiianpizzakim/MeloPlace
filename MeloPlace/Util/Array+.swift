//
//  Array+.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}
