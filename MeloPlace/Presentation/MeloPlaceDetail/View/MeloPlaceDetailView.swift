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
    
//    lazy var topView: UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        return view
//    }()
//
//    lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.text = ""
//        label.font = .systemFont(ofSize: 20)
//        label.textColor = .black
//        return label
//    }()
    
    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)

        return button
    }()
    
    lazy var playerView = PlayerView()
    
    lazy var imageCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.configureLayout())
        
        view.register(MeloPlaceDetailCollectionCell.self, forCellWithReuseIdentifier: MeloPlaceDetailCollectionCell.id)
        view.backgroundColor = .white
        return view
    }()
    
//        lazy var imageBackgroundView: UIImageView = {
//            let view = UIImageView()
////            let blurEffect = UIBlurEffect(style: .light)
////            let blurEffectView = UIVisualEffectView(effect: blurEffect)
////            let bounds = self.view.bounds
////            blurEffectView.frame =  bounds
////    //        blurEffectView.tag = 129
////            view.addSubview(blurEffectView)
//            return view
//        }()
    
    lazy var imageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
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
        view.backgroundColor = .black
        return view
    }()
    
    lazy var marginView = UIView()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = .systemFont(ofSize: 20)
        label.textColor = .white
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.configureAtributes()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        self.addSubview(self.imageBackgroundView)
        
        [self.imageCollectionView,
         self.marginView,
         self.playerView,
         self.bottomView
        ].forEach {
            self.imageBackgroundView.addSubview($0)
        }
        
        [self.dateLabel, self.placeLabel,
         self.contentLabel].forEach {
            self.bottomView.addSubview($0)
        }
        
        self.imageBackgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
//        self.topView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.height.equalTo(70)
//        }
        
        self.imageCollectionView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(15)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(400)
        }
        
        self.playerView.snp.makeConstraints { make in
            make.top.equalTo(self.imageCollectionView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(15)
            make.trailing.equalToSuperview().offset(-15)
            make.height.equalTo(200)
        }

        self.bottomView.snp.makeConstraints { make in
            make.top.equalTo(self.playerView.snp.bottom).offset(10)
            //            make.bottom.equalToSuperview()
            //            make.horizontalEdges.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(100)
            make.bottom.equalToSuperview().offset(-10)
        }

        self.placeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.top.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }

        self.dateLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.top.equalTo(self.placeLabel.snp.bottom).offset(10)
            make.height.equalTo(20)
        }

        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.dateLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }

        self.marginView.snp.makeConstraints { make in
            make.top.equalTo(self.bottomView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    func configureAtributes() {
        self.imageCollectionView.backgroundColor = .clear
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
    func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
//        let maxProfileImageSize = CGSize(width: 100, height: 100)
//        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        let blur = BlurImageProcessor(blurRadius: 5.0)

//        self.imageBackgroundView.kf.setImage(
//            with: url,
//            placeholder: .none,
//            options: [.processor(blur)]
//        )
        
    }
    
}
