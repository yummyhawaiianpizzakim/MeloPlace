//
//  MusicListCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/15.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher

final class MusicListCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "MusicListCollectionCell"
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "title"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = "artist"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .themeGray300
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            print("isSelected::: \(isSelected)")
            self.updateSelectionAttributes(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension MusicListCollectionCell {
    func configureUI() {
        [self.imageView, self.titleLabel,
         self.artistLabel].forEach {
            self.contentView.addSubview($0)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(self.imageView.snp.trailing).offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-5)
            make.height.equalTo(15)
        }
    }
    
    func bindUI() {
        
    }
    
    func setImage(urlString: String) {
        guard let url = URL(string: urlString) else { return }
        self.imageView.kf.indicatorType = .activity
        let maxProfileImageSize = CGSize(width: 50, height: 50)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none,options: [.processor(downsamplingProcessor)])
    }
    
    func updateSelectionAttributes(_ isSelected: Bool) {
        if isSelected {
            self.contentView.backgroundColor = .themeColor300
            self.titleLabel.textColor = .themeWhite300
            self.artistLabel.textColor = .themeWhite300
        } else {
            self.contentView.backgroundColor = .themeBackground
            self.titleLabel.textColor = .black
            self.artistLabel.textColor = .themeGray300
        }
    }
}

extension MusicListCollectionCell {
    func bindCell(item: Music) {
        self.titleLabel.text = item.name
        self.artistLabel.text = item.artist
        self.setImage(urlString: item.imageURL)
    }
    
}
