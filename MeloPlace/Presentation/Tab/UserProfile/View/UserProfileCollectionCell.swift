//
//  UserProfileCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/08.
//

import Foundation
import UIKit
import SnapKit
import Kingfisher
import RxSwift

protocol UserProfileCollectionCellDelegate: AnyObject {
    func didTapSignInButton(sender: UserProfileCollectionCell)
}

class UserProfileCollectionCell: UICollectionViewCell {
    static var identifier: String {
        return "UserProfileCollectionCell"
    }
    
    weak var delegate: UserProfileCollectionCellDelegate?
    let disposeBag = DisposeBag()
    
    lazy var profileImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
//        let cornerRadius = view.frame.height / 2
//        view.layer.cornerRadius = cornerRadius
        
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "name"
        label.textColor = .white
        label.font = .systemFont(ofSize: appOffset * 2)
        label.textAlignment = .center
        return label
    }()
    
//    private lazy var signInButton: UIButton = {
//        let button = UIButton()
//        button.setTitle("Sign In", for: .normal)
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = .systemFont(ofSize: 12)
//        return button
//    }()
    
    lazy var filterView: UICollectionView = {
        let view = FilterCollectionView(filterMode: .userPage)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.bindCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UserProfileCollectionCell {
    private func configureUI() {
        self.contentView.addSubview(self.profileImageView)
        self.profileImageView.snp.makeConstraints { make in
            make.width.height.equalTo(appOffset * 8)
//            make.leading.equalToSuperview().inset(appOffset * 2)
            make.top.equalToSuperview().inset(appOffset * 3)
            make.centerX.equalToSuperview()
        }
        
        self.contentView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints { make in
//            make.left.right.equalToSuperview().offset(appOffset * 2)
            make.centerX.equalToSuperview()
            make.height.equalTo(8)
            make.top.equalTo(self.profileImageView.snp.bottom).offset(appOffset / 2)
        }
        
//        self.contentView.addSubview(self.signInButton)
//        self.signInButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(self.nameLabel.snp.bottom).offset(appOffset)
//            make.width.equalTo(appOffset * 8)
//            make.height.equalTo(appOffset * 3)
//        }
        
        self.contentView.addSubview(self.filterView)
        self.filterView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
//            make.top.equalTo(self.signInButton.snp.bottom).offset(appOffset)
            make.top.equalTo(self.nameLabel.snp.bottom).offset(appOffset)
            make.height.equalTo(appOffset * 6)
        }
        
//        self.contentView.addSubview(self.filterView)
//        self.filterView.snp.makeConstraints { make in
//            make.left.right.equalToSuperview()
//            make.top.equalTo(self.nameLabel.snp.bottom).offset(appOffset)
//            make.height.equalTo(appOffset * 6)
//        }
        
    }
    
    private func bindCell() {
//        self.signInButton.rx.tap
//            .throttle(.seconds(1), scheduler: MainScheduler.instance)
//            .bind { [weak self] _ in
//                guard let self = self else { return }
//                self.delegate?.didTapSignInButton(sender: self)
//            }
//            .disposed(by: self.disposeBag)
        
    }
    
    func configureCell(user: User) {
        self.nameLabel.text = user.name
        self.setImage(at: user.imageURL)
    }
    
    private func setImage(at profileImageURL: String) {
//        let url = try? profileImageURL.asURL()
        let url = URL(string: profileImageURL)
        let maxProfileImageSize = CGSize(width: 80, height: 80)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
//        let url = URL(string: profileImageURL!)
        self.profileImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "person"), options: [.processor(downsamplingProcessor)] )
    }
    
}

//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct UserProfileCollectionViewCellPreview: PreviewProvider{
//    static var previews: some View {
//        UIViewPreview {
//            let cell = UserProfileCollectionViewCell(frame: .zero)
//            /** Cell setup code */
//            return cell
//        }
//        .previewLayout(.sizeThatFits)
//    }
//}
//
//#endif
