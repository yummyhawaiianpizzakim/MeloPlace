//
//  MeloPlaceViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import Kingfisher


class MeloPlaceDetailViewController: UIViewController {
    var viewModel: MeloPlaceDetailViewModel?
    let disposeBag = DisposeBag()

    
    lazy var scrollView = UIScrollView()
    
    lazy var textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
    }()
    
    lazy var bottomView: UIView = {
        let view = UIView()
        
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.frame.size = CGSize(width: 200.0, height: 200.0)
        let cornerRadius = imageView.frame.size.width / 2
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "멜로플레이스"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var musicLabel: UILabel = {
        let label = UILabel()
        label.text = "음악"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.text = "장소"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var DateLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "내용"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    
    let mapView: UIImageView = {
        let mapView = UIImageView()
        mapView.contentMode = .scaleAspectFit
        mapView.layer.borderWidth = 0.5
        mapView.layer.borderColor = UIColor.themeGray300?.cgColor
        
        return mapView
    }()
    
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MeloPlaceDetailViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindViewModel()
    }
}

private extension MeloPlaceDetailViewController {
    func configureUI() {
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.bottomView)
        
        [self.imageView, self.contentLabel, self.mapView]
            .forEach { self.scrollView.addSubview($0) }
        
        [self.musicLabel].forEach { self.bottomView.addSubview($0) }
        
        [self.DateLabel, self.placeLabel].forEach { self.imageView.addSubview($0) }
        
        self.scrollView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
        }
        
        self.imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(200)
        }
        
        self.placeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(10)
            make.height.equalTo(20)
        }
        
        self.DateLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.placeLabel.snp.leading)
            make.bottom.equalTo(self.placeLabel.snp.top).offset(-5)
            make.height.equalTo(20)
        }
        
        self.contentLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(100)
        }
        
        self.mapView.snp.makeConstraints { make in
            make.top.equalTo(self.contentLabel.snp.bottom).offset(20)
            make.leading.equalTo(self.contentLabel.snp.leading)
            make.trailing.equalTo(self.contentLabel.snp.trailing)
            make.height.equalTo(200)
        }
        
        self.bottomView.snp.makeConstraints { make in
            make.top.equalTo(self.scrollView.snp.bottom)
            make.bottom.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(80)
        }
        
        self.musicLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(5)
            make.centerX.equalToSuperview()
        }
        
    }
    
    func bindViewModel() {
        let input = MeloPlaceDetailViewModel.Input()
        let output = self.viewModel?.transform(input: input)
        
        output?.meloPlace
            .asDriver()
            .drive(with: self, onNext: { owner, meloPlace in
                guard let meloPlace = meloPlace, let imageURLString = meloPlace.images.first else { return }
                owner.DateLabel.text = meloPlace.memoryDate.toString()
                owner.placeLabel.text = meloPlace.simpleAddress
                owner.titleLabel.text = meloPlace.title
                owner.contentLabel.text = meloPlace.description
                owner.musicLabel.text = meloPlace.musicURI
                owner.setUpNavigationTitle(meloPlace.title)
                owner.setImage(imageURLString: imageURLString )
            })
            .disposed(by: self.disposeBag)
    }
    
    func setImage(imageURLString: String) {
        guard let url = URL(string: imageURLString) else { return }
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: url, placeholder: .none, options: [.processor(downsamplingProcessor)])
    }
    
    func setUpNavigationTitle(_ title: String) {
        self.navigationItem.title = title
    }
}
