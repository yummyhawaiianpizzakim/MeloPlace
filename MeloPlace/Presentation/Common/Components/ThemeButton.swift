//
//  ThemeButton.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import UIKit

final class ThemeButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            backgroundColor = isEnabled ? .themeColor300 : .themeGray300
        }
    }

    convenience init(title: String = " ") {
        self.init()

        setTitle(title, for: .normal)
        setTitleColor(.white, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 10)
        backgroundColor = .themeColor300
        layer.cornerRadius = 10
    }
}
