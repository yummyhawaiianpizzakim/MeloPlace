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

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 240.0 / 2
        imageView.clipsToBounds = true
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.themeColor300?.cgColor
        imageView.layer.borderWidth = 2
        return imageView
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
        self.contentView.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
            $0.width.equalTo(240.0)
            $0.height.equalTo(240.0)
        }
    }

    func configureCell(item: MeloPlace) {
        guard let imageURLString = item.images.first else { return }
        self.setImage(imageURLString: imageURLString)

    }
}

extension MainCell {
    private func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxImageSize = CGSize(width: 480, height: 480)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
    
}
