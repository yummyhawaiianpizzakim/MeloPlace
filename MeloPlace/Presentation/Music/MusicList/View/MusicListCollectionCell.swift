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

class MusicListCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "MusicListCollectionCell"
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
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
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var arrowImageView: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(systemName: "chevron.right")
        image.image?.withTintColor(.black)
        image.backgroundColor = .white
        return image
    }()
    
    override var isSelected: Bool {
        didSet {
            self.updateSelectionAttributes(isSelected)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .white
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
         self.artistLabel, self.arrowImageView].forEach {
            self.contentView.addSubview($0)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalTo(50)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(self.imageView.snp.trailing).offset(20)
            make.height.equalTo(20)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.height.equalTo(20)
        }
        
        self.arrowImageView.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.width.height.equalTo(50)
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
            self.titleLabel.font = .boldSystemFont(ofSize: 20)
            self.artistLabel.font = .boldSystemFont(ofSize: 20)
        } else {
            self.contentView.backgroundColor = .themeBackground
            self.titleLabel.textColor = .black
            self.artistLabel.textColor = .black
            self.titleLabel.font = .systemFont(ofSize: 20)
            self.artistLabel.font = .systemFont(ofSize: 20)
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
