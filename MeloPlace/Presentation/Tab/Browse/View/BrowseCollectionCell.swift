//
//  BrowseCollectionCell.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/11/05.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxRelay
import Kingfisher

final class BrowseCollectionCell: UICollectionViewCell {
    static var id: String {
        return "BrowseCollectionCell"
    }
    var uuid: String?
    let Browse = BehaviorRelay<Browse?>(value: nil)
    
    var isPlayPauseButtonPaused = false {
        didSet {
            self.playPauseButton.isSelected = self.isPlayPauseButtonPaused
        }
    }
    
    let userID = BehaviorRelay<String>(value: "")
    let meloPlaceID = BehaviorRelay<String>(value: "")
    
    lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 30 / 2
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.themeColor300?.cgColor
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .black
        return imageView
    }()
    
    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        
        return imageView
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.text = "음악"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var artistLabel: UILabel = {
        let label = UILabel()
        label.text = "아티스트"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .themeGray300
        return label
    }()
    
    lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        button.setImage(UIImage(systemName: "play.fill", withConfiguration: configuration), for: .selected)
        button.setImage(UIImage(systemName: "pause.fill", withConfiguration: configuration), for: .normal)
        button.imageView?.tintColor = .black
        return button
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    lazy var contentTextView: UITextView = {
        let view = UITextView()
        view.font = .systemFont(ofSize: 15)
        view.textColor = .black
        view.contentInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        view.textContainerInset = .init(top: 0, left: 0, bottom: 0, right: 0)
//        view.scrollIndicatorInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        view.isEditable = false
        view.isScrollEnabled = false
        return view
    }()
    
    lazy var commentsLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글 달기..."
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureAttribute()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
    }
    
    func configureAttribute() {
        self.layer.borderColor = UIColor.themeGray100?.cgColor
        self.layer.borderWidth = 0.5
    }

    func addSubviews() {
        [self.topView, self.imageView, self.middleView, self.bottomView].forEach {
            self.contentView.addSubview($0)
        }
        
        [self.profileImageView, self.userNameLabel]
            .forEach { self.topView.addSubview($0) }
        
        [self.playPauseButton,
         self.musicLabel, self.artistLabel]
            .forEach { self.middleView.addSubview($0) }
        
        [self.dateLabel, self.placeLabel,
         self.contentTextView, self.commentsLabel]
            .forEach { self.bottomView.addSubview($0) }
    }

    func makeConstraints() {
        self.topView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.middleView.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(45)
        }
        
        self.bottomView.snp.makeConstraints { make in
            make.top.equalTo(self.middleView.snp.bottom).offset(5)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(160)
            make.bottom.equalTo(self.safeAreaLayoutGuide)
        }
        
        self.profileImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(30)
        }
        
        self.userNameLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(self.profileImageView.snp.trailing).offset(10)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
        
        self.playPauseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
            make.height.width.equalTo(20)
        }
        
        self.musicLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.leading.equalTo(self.playPauseButton.snp.trailing).offset(10)
        }
        
        self.artistLabel.snp.makeConstraints { make in
            make.top.equalTo(self.musicLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.musicLabel.snp.leading)
        }
        
        self.placeLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(15)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.top.equalTo(self.placeLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(15)
        }

        self.contentTextView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(10)
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(self.contentTextView.contentSize.height)
        }
        
        self.commentsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentTextView.snp.bottom).offset(10)
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(15)
        }
        
    }

    func configureCell(item: Browse) {
        self.Browse.accept(item)
        let meloPlace = item.meloPlace
        let user = item.user
        self.userID.accept(user.id)
        self.meloPlaceID.accept(meloPlace.id)
        guard let imageURLString = meloPlace.images.first else { return }
        let userProfileImageURL = user.imageURL
        self.dateLabel.text = meloPlace.memoryDate.toString()
        self.placeLabel.text = meloPlace.spaceName
        self.userNameLabel.text = user.name
        self.contentTextView.text = meloPlace.description
        let size = CGSize(width: self.frame.width, height: .infinity)
        let estimatedSize = self.contentTextView.sizeThatFits(size)
        self.contentTextView.constraints.forEach { constraint in
            if estimatedSize.height >= 15 {
                if constraint.firstAttribute == .height {
                    constraint.constant = estimatedSize.height
                }
            }
        }
        self.contentTextView.reloadInputViews()
        self.musicLabel.text = meloPlace.musicName
        self.artistLabel.text = meloPlace.musicArtist
        self.setImage(imageURLString: imageURLString, isProfile: false)
        self.setImage(imageURLString: userProfileImageURL, isProfile: true)
    }
}

extension BrowseCollectionCell {
    private func setImage(imageURLString: String, isProfile: Bool) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        
        if isProfile {
            self.profileImageView.kf.indicatorType = .activity
            let placeHolder = UIImage(systemName: "person")
            
            self.profileImageView.kf.setImage(
                with: url,
                placeholder: placeHolder,
                options: [.processor(downsamplingProcessor)]
            )
        } else {
            self.imageView.kf.indicatorType = .activity
            self.imageView.kf.setImage(
                with: url,
                placeholder: .none
            )
        }
    }
    
    var didTapUserNameLabel: Observable<String> {
        self.userNameLabel.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(self.userID)
    }
    
    var didTapImageView: Observable<String> {
        self.imageView.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(self.meloPlaceID)
    }
    
    var didTapProfileImageL: Observable<String> {
        self.profileImageView.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(self.userID)
    }
    
    var didTapCommentLabel: Observable<String> {
        self.commentsLabel.rx.tapGesture()
            .when(.recognized)
            .withLatestFrom(self.meloPlaceID)
    }
    
    var didTapPlayButton: Observable<String?> {
        self.playPauseButton.rx.tap
            .withLatestFrom(self.Browse)
            .map { browse in
                browse?.meloPlace.musicURI
            }
    }
}
