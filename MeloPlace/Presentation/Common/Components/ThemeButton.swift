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
    
    override var isSelected: Bool {
        didSet {
            self.configureIsSelected(self.isSelected)
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

private extension ThemeButton {
    func configureIsSelected(_ isSelected: Bool) {
        if isSelected {
            self.backgroundColor = .white
            self.layer.borderColor = UIColor.themeColor300?.cgColor
            self.layer.borderWidth = 1.5
            self.setTitleColor(.themeColor300, for: .selected)
        } else {
            self.backgroundColor = UIColor.themeColor300
            self.layer.borderColor = UIColor.white.cgColor
            self.layer.borderWidth = 1.5
            self.setTitleColor(.white, for: .normal)
        }
    }
}
