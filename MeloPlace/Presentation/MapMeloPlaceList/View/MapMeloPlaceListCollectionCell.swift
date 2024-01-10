//
//  MapMeloPlaceListCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/31.
//

import Foundation
import SnapKit
import UIKit
import Kingfisher

final class MapMeloPlaceListCollectionCell: UICollectionViewCell {
    static var id: String {
        return "MapMeloPlaceListCollectionCell"
    }
    var uuid: String?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 75.0 / 2
        imageView.layer.borderColor = UIColor.themeColor300?.cgColor
        imageView.layer.borderWidth = 1.5
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15.0)
        label.numberOfLines = 1
        label.textColor = .black
        label.textAlignment = .left
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12.0)
        label.numberOfLines = 1
        label.textColor = .themeGray300
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

    }

    func addSubviews() {
        [self.imageView, self.addressLabel,
         self.musicLabel, self.artistLabel].forEach {
            self.contentView.addSubview($0)
        }
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(75.0)
            $0.height.equalTo(75.0)
        }

        self.addressLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.top)
            $0.leading.equalTo(self.imageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(25.0)
        }
        
        self.musicLabel.snp.makeConstraints {
            $0.top.equalTo(self.addressLabel.snp.bottom).offset(5)
            $0.leading.equalTo(self.addressLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(20.0)
        }
        
        self.artistLabel.snp.makeConstraints {
            $0.top.equalTo(self.musicLabel.snp.bottom).offset(5)
            $0.leading.equalTo(self.musicLabel.snp.leading)
            $0.trailing.equalToSuperview().offset(-10)
            $0.height.equalTo(20.0)
        }
        
    }

    func configureCell(item: MeloPlace) {
        guard let imageURLString = item.images.first else { return }
        self.addressLabel.text = item.spaceName.replaceString(where: "대한민국", of: "대한민국 ", with: "")
        self.musicLabel.text = item.musicName
        self.artistLabel.text = item.musicArtist
        self.setImage(imageURLString: imageURLString)

    }
}

extension MapMeloPlaceListCollectionCell {
    private func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
    
}
