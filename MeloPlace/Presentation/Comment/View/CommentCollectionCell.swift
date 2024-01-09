//
//  CommentCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import Kingfisher

class CommentCollectionCell: UICollectionViewCell {
    static var id: String {
        return "CommentCollectionCell"
    }
    
    var disposeBag = DisposeBag()
    
    let userID = BehaviorRelay<String>(value: "")
    
    private lazy var profileImageView = ProfileImageView()
    
    private lazy var contentTextView: UITextView = {
        let label = UITextView()
        label.font = .systemFont(ofSize: 20)
        label.backgroundColor = .clear
        label.textColor = .black
        label.isSelectable = false
        label.isScrollEnabled = false
        label.sizeToFit()
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.layoutIfNeeded()
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
        self.profileImageView.image = nil
        self.contentTextView.attributedText = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}

private extension CommentCollectionCell {
    func configureUI() {
        [self.profileImageView,
         self.contentTextView
        ]
            .forEach { self.contentView.addSubview($0) }
        
        self.profileImageView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(8)
            make.width.height.equalTo(30).priority(1000)
//            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.contentTextView.snp.remakeConstraints { make in
            make.bottom.equalToSuperview().offset(-5)
            make.top.equalToSuperview()
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
            make.trailing.lessThanOrEqualToSuperview().offset(-10)
            make.height.equalTo(self.contentTextView.contentSize.height) // 콘텐츠 크기에 맞춤

        }
    }
    
    func bindUI() {
        
    }
    
    func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.profileImageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
    func setTitleLabel(comment: Comment, user: User) {
        let text = NSMutableAttributedString()
        // user.name을 bold체로 설정하여 추가
        let boldText = NSAttributedString(string: user.name, attributes: [.font: UIFont.boldSystemFont(ofSize: 15)])
        text.append(boldText)
        // comment.contents를 일반체로 설정하여 추가
        let spaceText = NSAttributedString(string: "  ", attributes: [.font: UIFont.systemFont(ofSize: 15)])
        text.append(spaceText)
        let normalText = NSAttributedString(string: comment.contents, attributes: [.font: UIFont.systemFont(ofSize: 15)])
        text.append(normalText)
        self.contentTextView.attributedText = text
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = self.contentTextView.sizeThatFits(size)
        self.contentTextView.constraints.forEach { constraint in
            if estimatedSize.height >= 50 {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        self.contentTextView.reloadInputViews()
        self.setNeedsUpdateConstraints()
        
    }
}

extension CommentCollectionCell {
    func configureCell(by comment: Comment) {
        guard let user = comment.user else { return }
        self.userID.accept(user.id)
        self.setTitleLabel(comment: comment, user: user)
        self.setImage(imageURLString: user.imageURL)
    }
    
    var didTapUserProfile: Observable<String> {
        self.profileImageView.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(self.userID)
    }
    
}
