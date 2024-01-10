//
//  SearchBarView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/03.
//

import Foundation
import UIKit
import SnapKit

final class SearchBarView: UIView {
    // MARK: UI
    private lazy var searchImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .themeGray100
        view.image = UIImage(systemName: "magnifyingglass")
        return view
    }()
    
    lazy var searchLabel: UILabel = {
        let label = UILabel()
        label.text = "검색"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .themeColor300
        return label
    }()
    
    // MARK: Properties
    override var intrinsicContentSize: CGSize {
        return UIView.layoutFittingExpandedSize
    }
    
    // MARK: Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.configureAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension SearchBarView {
    func configureUI() {
        [self.searchImageView, self.searchLabel].forEach {
            self.addSubview($0)
        }
        
        self.searchImageView.snp.makeConstraints { make in
            make.height.width.equalTo(24)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        
        self.searchLabel.snp.makeConstraints { make in
            make.leading.equalTo(searchImageView.snp.trailing).offset(5)
            make.centerY.equalToSuperview()
        }
    }
    
    func configureAttributes() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.themeColor300?.cgColor
        self.layer.borderWidth = 1
    }
}

extension SearchBarView {
    func configure(searchText: String) {
        self.searchLabel.text = searchText
    }
}
