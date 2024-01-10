//
//  FollowingUserListCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/09.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import RxSwift

final class FollowingUserListCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "FollowingUserListCollectionCell"
    }
    
    let disposeBag = DisposeBag()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        let cornerRadius = appOffset * 6 / 2
        view.layer.cornerRadius = cornerRadius
        view.layer.borderWidth = 1.5
        view.layer.borderColor = UIColor.themeColor300?.cgColor
        view.tintColor = .black
        return view
    }()
    
    lazy var label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension FollowingUserListCollectionCell {
    private func configureUI() {
        [self.profileImageView, self.label].forEach {
            self.contentView.addSubview($0)
        }
        
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(appOffset * 6)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(appOffset)
        }
        
        self.label.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(appOffset * 2)
        }
    }
    
    func configureCell(user: User) {
        self.label.text = user.name
        self.setImage(at: user.imageURL)
    }
    
    private func setImage(at profileImageURL: String) {
        let url = URL(string: profileImageURL)
        let size = appOffset * 10
        let maxProfileImageSize = CGSize(width: size, height: size)
        let placeholderImage = UIImage(systemName: "person")?.withTintColor(.black, renderingMode: .alwaysTemplate)
        self.profileImageView.kf.setImage(with: url, placeholder: placeholderImage, options: [] )
    }
    
}
