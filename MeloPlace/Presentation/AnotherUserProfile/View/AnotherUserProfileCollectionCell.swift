//
//  AnotherUserProfileCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/01.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import RxSwift

final class AnotherUserProfileCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "AnotherUserProfileCollectionCell"
    }
    let disposeBag = DisposeBag()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        let cornerRadius = appOffset * 10 / 2
        view.layer.cornerRadius = cornerRadius
        view.layer.borderColor = UIColor.themeColor300?.cgColor
        view.layer.borderWidth = 1.5
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var contentsCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 3)
        label.textAlignment = .center
        return label
    }()
    
    lazy var contentsLabel: UILabel = {
        let label = UILabel()
        label.text = "게시물"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var followerCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 3)
        label.textAlignment = .center
        return label
    }()
    
    lazy var followerLabel: UILabel = {
        let label = UILabel()
        label.text = "팔로워"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var followingCountLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 3)
        label.textAlignment = .center
        return label
    }()
    
    lazy var followingLabel: UILabel = {
        let label = UILabel()
        label.text = "팔로잉"
        label.textColor = .black
        label.font = .systemFont(ofSize: appOffset * 2)
        label.textAlignment = .center
        return label
    }()
    
    lazy var followingButton = ThemeButton(title: "팔로잉")
    
    lazy var searchUserButton = ThemeButton(title: "친구 찾기")
    
    lazy var filterView: UICollectionView = {
        let view = FilterCollectionView(filterMode: .userPage)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureAttribute()
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension AnotherUserProfileCollectionCell {
    private func configureUI() {
        [self.profileImageView, self.nameLabel,
         self.contentsCountLabel, self.contentsLabel,
         self.followerLabel, self.followerCountLabel,
         self.followingLabel, self.followingCountLabel,
         self.filterView,
         self.followingButton,
         self.searchUserButton]
            .forEach { self.contentView.addSubview($0) }
        
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(appOffset * 10)
            make.top.equalToSuperview().offset(appOffset * 4)
            make.leading.equalToSuperview().offset(appOffset * 4)
        }
        
        self.contentsCountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.top).offset(appOffset * 2)
            make.trailing.equalTo(self.followerCountLabel.snp.leading).offset( -(appOffset * 4) )
            make.width.equalTo(appOffset * 6)
        }
        
        self.contentsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentsCountLabel.snp.bottom).offset(appOffset)
            make.trailing.equalTo(self.contentsCountLabel)
            make.width.equalTo(self.contentsCountLabel)
        }
        
        self.followerCountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.top).offset(appOffset * 2)
            make.trailing.equalTo(self.followingCountLabel.snp.leading).offset( -(appOffset * 4) )
            make.width.equalTo(appOffset * 6)
        }
        
        self.followerLabel.snp.makeConstraints { make in
            make.top.equalTo(self.followerCountLabel.snp.bottom).offset(appOffset)
            make.trailing.equalTo(self.followerCountLabel)
            make.width.equalTo(self.followerCountLabel)
        }
        
        self.followingCountLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.top).offset(appOffset * 2)
            make.trailing.equalToSuperview().offset( -(appOffset * 4) )
            make.width.equalTo(appOffset * 6)
        }
        
        self.followingLabel.snp.makeConstraints { make in
            make.top.equalTo(self.followingCountLabel.snp.bottom).offset(appOffset)
            make.trailing.equalTo(self.followingCountLabel)
            make.width.equalTo(self.followingCountLabel)
        }
        
        self.nameLabel.snp.makeConstraints { make in
            make.top.equalTo(self.profileImageView.snp.bottom).offset(appOffset)
            make.leading.equalTo(self.profileImageView.snp.leading)
            make.height.equalTo(appOffset * 2)
        }
        
        self.followingButton.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(appOffset)
            make.leading.equalToSuperview().offset(appOffset * 4)
            make.height.equalTo(appOffset * 4)
            make.width.equalTo(appOffset * 20)
        }
        
        self.searchUserButton.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(appOffset)
            make.trailing.equalToSuperview().offset(-(appOffset * 4))
            make.height.equalTo(appOffset * 4)
            make.width.equalTo(appOffset * 20)
        }
        
        self.filterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.searchUserButton.snp.bottom).offset(appOffset)
            make.height.equalTo(appOffset * 6)
        }
     
    }
    
    func configureAttribute() {
        self.profileImageView.tintColor = .black
    }
    
    func configureCell(user: User, meloPlaceCount: Int) {
        let following = user.following.filter { $0 != "" }
        let follower = user.follower.filter { $0 != "" }
        self.nameLabel.text = user.name
        self.contentsCountLabel.text = "\(meloPlaceCount)"
        self.followingCountLabel.text = "\(following.count)"
        self.followerCountLabel.text = "\(follower.count)"
        self.setImage(at: user.imageURL)
    }
    
    private func setImage(at profileImageURL: String) {
        let url = URL(string: profileImageURL)
        let size = appOffset * 10
        let maxProfileImageSize = CGSize(width: size, height: size)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person"), options: [.processor(downsamplingProcessor)] )
    }
    
    func configureFollowButton(_ isFollowed: Bool) {
        self.followingButton.isSelected = isFollowed
        isFollowed ?
        self.followingButton.setTitle("팔로잉", for: .selected)
        :
        self.followingButton.setTitle("팔로우", for: .normal)
    }
}
