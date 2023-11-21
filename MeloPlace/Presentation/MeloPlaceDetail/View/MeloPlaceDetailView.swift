//
//  MeloPlaceDetailView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/10.
//

import Foundation
import SnapKit
import Kingfisher
import UIKit
import RxSwift
import RxRelay

final class MeloPlaceDetailView: UIView {
    
    var currentIndex = BehaviorRelay<Int>(value: 0)
    
    var itemCount: Int?
    
    var isPlayPauseButtonPaused = false {
        didSet {
            self.playPauseButton.isSelected = self.isPlayPauseButtonPaused
        }
    }
    
    lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.tintColor = .black
        return button
    }()
    
    lazy var topViewTitleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)

        return button
    }()
    
    lazy var middleView: UIView = {
        let view = UIView()
        return view
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
    
//    lazy var playerView = PlayerView()
    
    lazy var imageCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        
        view.register(MeloPlaceDetailCollectionCell.self, forCellWithReuseIdentifier: MeloPlaceDetailCollectionCell.id)
        return view
    }()
    
    lazy var imageBackgroundView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var gradientBackground: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.clear.cgColor,
                           UIColor.black.cgColor]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        return gradient
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
    
//    lazy var commentInputView = CommentInputView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.configureAttributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.addSubview(self.backgroundView)
//        self.backgroundView.addSubview(self.imageBackgroundView)
//        self.backgroundView.sendSubviewToBack(self.imageBackgroundView)
        
        [self.topView,
         self.imageCollectionView,
         self.middleView,
//         self.bottomView
         self.dateLabel, self.placeLabel,
          self.contentTextView, self.commentsLabel,
          self.commentsLabel
        ].forEach {
//            self.imageBackgroundView.addSubview($0)
            self.backgroundView.addSubview($0)
        }
        
        [self.backButton, self.topViewTitleLabel]
            .forEach { self.topView.addSubview($0) }
        
        [self.playPauseButton,
         self.musicLabel,
         self.artistLabel
        ]
            .forEach { self.middleView.addSubview($0) }
        
        self.backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        self.imageBackgroundView.snp.makeConstraints { make in
//            make.edges.equalToSuperview()
//        }
        
        self.topView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.imageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom).offset(15)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
        
        self.middleView.snp.makeConstraints { make in
            make.top.equalTo(self.imageCollectionView.snp.bottom)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(50)
        }
        
        self.playPauseButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(15)
//            make.trailing.equalToSuperview().offset(-15)
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
        
        self.topViewTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(20)
        }

        self.placeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
//            make.top.equalToSuperview().offset(5)
            make.top.equalTo(self.middleView.snp.bottom).offset(5)
            make.height.equalTo(20)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.top.equalTo(self.placeLabel.snp.bottom).offset(5)
            make.height.equalTo(20)
        }

        self.contentTextView.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(5)
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.trailing.equalTo(self.placeLabel.snp.trailing)
            make.height.equalTo(self.contentTextView.contentSize.height)
        }
        
        self.commentsLabel.snp.makeConstraints { make in
            make.top.equalTo(self.contentTextView.snp.bottom).offset(10)
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.bottom.equalTo(self.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(15)
        }
        
    }
    
    func configureAttributes() {
        self.backgroundColor = .white
        self.imageCollectionView.contentInsetAdjustmentBehavior = .never
        self.imageCollectionView.alwaysBounceHorizontal = false
        self.imageCollectionView.alwaysBounceVertical = false
    }
    
}

private extension MeloPlaceDetailView {
    func configureLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(400))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.visibleItemsInvalidationHandler = { [weak self] _, offset, _ in
            let index = Int(offset.x / (self?.imageCollectionView.bounds.width ?? 1))
            
            if self?.currentIndex.value != index {
                self?.currentIndex.accept(index)
            }
//            print("asdasdasd:: \(index)")
        }

        let layout = UICollectionViewCompositionalLayout(section: section)
        
        return layout
    }
}

extension MeloPlaceDetailView {
    func bindView(meloPlaces: [MeloPlace], index: Int) {
        let meloPlace = meloPlaces[index]
        self.itemCount = meloPlaces.count
        self.dateLabel.text = meloPlace.memoryDate.toString()
        self.placeLabel.text = meloPlace.spaceName.replaceString(where: "대한민국", of: "대한민국 ", with: "")
        self.topViewTitleLabel.text = meloPlace.title
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
    }
    
    func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
//        let maxProfileImageSize = CGSize(width: 100, height: 100)
//        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        let blur = BlurImageProcessor(blurRadius: 5.0)

        self.imageBackgroundView.kf.setImage(
            with: url,
            placeholder: .none,
            options: [.processor(blur)]
        )
        
    }
    
    private func configurePlayPauseButton(_ isPaused: Bool) {
        let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        
        isPaused ?
        self.playPauseButton.setImage(UIImage(systemName: "play.fill", withConfiguration: configuration), for: .normal)
        :
        self.playPauseButton.setImage(UIImage(systemName: "pause.fill", withConfiguration: configuration), for: .selected)
    }
    
}
