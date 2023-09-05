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
        imageView.layer.cornerRadius = 50.0 / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18.0)
        label.textColor = .gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.backgroundColor = .cyan
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
        [self.imageView, self.addressLabel, self.musicLabel].forEach {
            self.contentView.addSubview($0)
        }
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
//            $0.top.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalTo(50.0)
            $0.height.equalTo(50.0)
        }

        self.addressLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.top)
//            $0.centerX.equalToSuperview()
            $0.leading.equalTo(self.imageView.snp.trailing).offset(8)
            $0.height.equalTo(24.0)
        }
        
        self.musicLabel.snp.makeConstraints {
            $0.top.equalTo(self.addressLabel.snp.bottom).offset(10)
            $0.leading.equalTo(self.addressLabel.snp.leading)
//            make.centerX.equalToSuperview()
            $0.height.equalTo(18.0)
        }
        
    }

    func configureCell(item: MeloPlace) {
        guard let imageURLString = item.images.first else { return }
        self.addressLabel.text = item.simpleAddress
        self.musicLabel.text = item.musicURI
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
