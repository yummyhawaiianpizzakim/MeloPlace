//
//  FilterCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import UIKit
import SnapKit

class FilterCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "FilterCollectionCell"
    }
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.lineBreakMode = .byWordWrapping
        label.textColor = .white
        label.text = "test"
        label.textAlignment = .center
        return label
    }()
    
    override var isSelected: Bool {
        didSet { self.selectedUpdate() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FilterCollectionCell {
    private func configureUI() {
        self.contentView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    private func selectedUpdate() {
        let textColor = self.isSelected ? UIColor.themeColor300 : UIColor.gray
        let font = self.isSelected ? UIFont.boldSystemFont(ofSize: 16) : UIFont.systemFont(ofSize: 16)
        
        self.titleLabel.textColor = textColor
        self.titleLabel.font = font
        
    }
    
    func bind(title: String) {
            self.titleLabel.text = title
        }
    
    func sizeFittingWith(cellWidth: CGFloat, cellHeight: CGFloat, text: String) -> CGSize {
        self.titleLabel.text = text
        
        //            let targetSize = CGSize(width: UIView.layoutFittingCompressedSize.width, height: cellHeight)
        let targetSize = CGSize(width: cellWidth, height: cellHeight)
        
        return self.contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .fittingSizeLevel,
            verticalFittingPriority: .required
        )
    }
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct FilterCollectionViewCellPreview: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let cell = FilterCollectionCell(frame: .zero)
            /** Cell setup code */
            return cell
        }
        .previewLayout(.sizeThatFits)
    }
}

#endif
