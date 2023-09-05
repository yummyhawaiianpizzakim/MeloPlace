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
        [self.label].forEach {
            self.contentView.addSubview($0)
        }
        
        self.label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
        }
    }
    
}

extension SearchTableCell {
    func configureCell(item: Space) {
        self.label.text = item.address
    }
    
}
