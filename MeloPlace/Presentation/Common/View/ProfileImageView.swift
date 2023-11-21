//
//  ProfileImageView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/25.
//

import Foundation
import UIKit

import RxSwift
import Kingfisher

final class ProfileImageView: UIImageView {
    init() {
        super.init(frame: .zero)
        
        self.clipsToBounds = true
        self.contentMode = .scaleAspectFill
        self.backgroundColor = .themeGray100
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let cornerRadius = self.frame.height / 2
        self.layer.cornerRadius = cornerRadius
        self.layer.borderWidth = 1.5
        self.layer.borderColor = UIColor.themeColor300?.cgColor
    }
    
    func setImage(at profileImageURL: URL?) {
        let maxProfileImageSize = CGSize(width: 80, height: 80)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.kf.setImage(with: profileImageURL, options: [.processor(downsamplingProcessor)])
    }
}

extension Reactive where Base: ProfileImageView {
    var setImage: Binder<URL?> {
        return Binder(self.base) { imageView, url in
            let downsamplingProcessor = DownsamplingImageProcessor(size: imageView.frame.size)
            imageView.kf.setImage(with: url, options: [.processor(downsamplingProcessor)])
        }
    }
}
