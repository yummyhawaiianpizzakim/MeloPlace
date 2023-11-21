//
//  SearchTableCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/04.
//

import Foundation
import UIKit
import SnapKit

class SearchTableCell: UITableViewCell {
    
    static var id: String {
        return "SearchTableCell"
    }
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .themeGray100
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

private extension SearchTableCell {
    func configureUI() {
        [self.label, self.addressLabel].forEach {
            self.contentView.addSubview($0)
        }
        
        self.label.snp.makeConstraints { make in
//            make.centerY.equalToSuperview()
            make.top.equalToSuperview().offset(15)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
        }
        
        self.addressLabel.snp.makeConstraints { make in
            make.top.equalTo(self.label.snp.bottom).offset(5)
            make.leading.equalTo(self.label.snp.leading)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
    
}

extension SearchTableCell {
    func configureCell(item: Space) {
        self.label.text = item.name
        self.addressLabel.text = item.address
    }
    
}
