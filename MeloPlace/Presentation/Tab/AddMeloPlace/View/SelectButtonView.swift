//
//  SelectButtonView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/26.
//

import Foundation
import UIKit
import SnapKit

final class SelectButtonView: UIView {
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .gray

        return imageView
    }()

    init(text: String) {
        super.init(frame: .zero)
        label.text = text
        backgroundColor = .white

        layer.borderColor = CGColor(gray: 10, alpha: 1)
        addSubViews()
        makeConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(_ text: String) {
        label.text = text
    }

    func addSubViews() {
        [label, icon].forEach {
            addSubview($0)
        }
    }

    func makeConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(40.0)
        }

        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        icon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(label).offset(10)
        }
    }
    
}

extension SelectButtonView {
   
}
