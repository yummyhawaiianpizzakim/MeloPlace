//
//  MeloPlaceDetailCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/09.
//

import Foundation
import SnapKit
import UIKit
import Kingfisher

final class MeloPlaceDetailCollectionCell: UICollectionViewCell {
    static var id: String {
        return "MeloPlaceDetailCollectionCell"
    }
    var uuid: String?
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
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
        [self.imageView].forEach {
            self.contentView.addSubview($0)
        }
    }

    func makeConstraints() {
        self.imageView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.trailing.equalToSuperview().offset(-20)
        }
    }

    func configureCell(item: MeloPlace) {
        guard let imageURLString = item.images.first else { return }
        self.setImage(imageURLString: imageURLString)

    }
}

extension MeloPlaceDetailCollectionCell {
    private func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        self.imageView.kf.setImage(
            with: url,
            placeholder: .none
        )
    }
    
    
}
