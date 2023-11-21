//
//  TagedUserCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/10/26.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay

class TagedUserCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "TagedUserCollectionCell"
    }
    
    private let disposeBag = DisposeBag()
    
    var userName = BehaviorRelay<String>(value: "")
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.font = .systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "x.circle"), for: .normal)
        button.tintColor = .black
        button.backgroundColor = .white
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.configureUI()
        self.configureAttributes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.userNameLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        self.clipsToBounds = true
    }
    
}

extension TagedUserCollectionCell {
    private func configureUI() {
        [self.userNameLabel,
         self.deleteButton
        ].forEach {
            self.contentView.addSubview($0)
        }
        
        self.userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(5)
        }
        
        self.deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.userNameLabel.snp.trailing).offset(5)
            make.height.width.equalTo(18)
        }
    }
    
    private func configureAttributes() {
        self.layer.masksToBounds = true
        self.isUserInteractionEnabled = true
    }
    
    func configureCell(item: String) {
        self.userName.accept(item)
        self.userNameLabel.text = item
    }
    
    var didTapDeleteButton: Observable<String> {
        self.deleteButton.rx.tap
            .withLatestFrom(self.userName)
    }
}

final class TagedUserCollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    
    private let offset: CGFloat
    
    init(offset: CGFloat, direction: UICollectionView.ScrollDirection) {
        self.offset = offset
        super.init()
        
        self.scrollDirection = direction
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        let attributes = super.layoutAttributesForElements(in: rect)
        
        self.minimumLineSpacing = self.offset
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + offset
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
