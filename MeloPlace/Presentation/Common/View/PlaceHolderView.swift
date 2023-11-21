//
//  PlaceHolderView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/20.
//

import Foundation
import UIKit
import SnapKit

final class PlaceHolderView: UIView {
    
    // MARK: - UI
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    // MARK: - Properties
    
    // MARK: - Initializers
    init(text: String) {
        super.init(frame: .zero)
        
        self.descriptionLabel.text = text
        self.configureHierarchy()
        self.configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    func configureHierarchy() {
        self.addSubview(descriptionLabel)
    }
    
    func configureConstraints() {
        self.descriptionLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(appOffset)
            make.center.equalToSuperview()
        }
    }
    
    func updateDescriptionText(_ text: String) {
        self.descriptionLabel.text = text
    }
}
