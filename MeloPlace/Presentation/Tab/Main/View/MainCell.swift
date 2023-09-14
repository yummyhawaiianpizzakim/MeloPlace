//
//  MainCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import SnapKit
import UIKit
import Kingfisher

final class MainCell: UICollectionViewCell {
    static var id: String {
        return "MainCell"
    }
    var uuid: String?

//    var thumbnailImageView = ThumbnailImageView(frame: .zero, width: FrameResource.homeCapsuleCellWidth)
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 216.0 / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 24.0)
        label.textColor = .black
        label.numberOfLines = 1
        label.textAlignment = .center
        return label
    }()

    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    lazy var addressLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20.0)
        label.textColor = .gray
        label.numberOfLines = 3
        label.textAlignment = .center
        return label
    }()
    
//    lazy var playPauseButton = UIButton(type: .system)

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
        [self.addressLabel, self.imageView, self.titleLabel, self.descriptionLabel, self.musicLabel].forEach {
            self.contentView.addSubview($0)
        }
    }

    func makeConstraints() {
        self.addressLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(self.addressLabel.snp.bottom).offset(20)
            $0.width.equalTo(216.0)
            $0.height.equalTo(216.0)
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.imageView.snp.bottom).offset(10.0 * 2)
            $0.centerX.equalToSuperview()
        }

        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(10.0)
            $0.centerX.equalToSuperview()
        }
        
        self.musicLabel.snp.makeConstraints { make in
            make.top.equalTo(self.descriptionLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
//        self.playPauseButton.snp.makeConstraints { make in
//            make.top.equalTo(self.musicLabel.snp.bottom).offset(10)
//            make.centerX.equalToSuperview()
//        }
    }

    func configureCell(item: MeloPlace) {
        guard let imageURLString = item.images.first else { return }
        self.titleLabel.text = item.title
        self.descriptionLabel.text = item.description
        self.addressLabel.text = item.simpleAddress
        self.musicLabel.text = item.musicName
        self.setImage(imageURLString: imageURLString)

    }
}

extension MainCell {
    private func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
    
}
