//
//  AddMeloPlaceView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import SnapKit
import UIKit
import Kingfisher

class AddMeloPlaceView: UIView {
    
    
    lazy var inputStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.isUserInteractionEnabled = true
        return stackView
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
    
//    private var editIconView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.image = UIImage(systemName: "camera.fill")
//        imageView.backgroundColor = .lightGray
//        imageView.contentMode = .scaleAspectFill
//        imageView.frame.size = CGSize(width: 20.0, height: 20.0)
//        let cornerRadius = imageView.frame.size.width / 2
//        imageView.layer.cornerRadius = cornerRadius
//        imageView.clipsToBounds = true
//        return imageView
//    }()
    
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
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "멜로플레이스"
        return textField
    }()
    
    lazy var musicButton = SelectButton(text: "음악")
    
    lazy var placeButton = SelectButton(text: "장소")
    
    lazy var dateButton = SelectButton(text: "날짜")
    
    lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .gray
//        textView.layer.borderColor = UIColor.themeGray300?.cgColor
//        textView.layer.borderWidth = FrameResource.commonBorderWidth
//        textView.layer.cornerRadius = FrameResource.commonCornerRadius
        textView.font = .systemFont(ofSize: 20)
        textView.text = "내용을 남겨주세요"
        textView.textColor = .orange
        textView.textContainerInset = UIEdgeInsets(
            top: 15,
            left: 15,
            bottom: 15,
            right: 15
        )
        
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddMeloPlaceView {
    func configureUI() {
        self.addSubview(self.imageView)
//        self.addSubview(self.editIconView)
        self.addSubview(self.inputStackView)
        [self.titleLabel, self.titleTextField,
         self.musicLabel, self.musicButton,
         self.placeLabel, self.placeButton,
         self.DateLabel, self.dateButton,
         self.contentLabel, self.contentTextView
        ].forEach { view in
            self.inputStackView.addArrangedSubview(view)
        }
        self.inputStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.height.equalTo(200)
        }
        
//        self.editIconView.snp.makeConstraints { make in
//            make.bottom.equalTo(self.imageView.snp.bottom).offset(-10)
//            make.right.equalTo(self.imageView.snp.right).offset(-10)
//            make.width.height.equalTo(20)
//        }
        
        self.titleTextField.snp.makeConstraints { make in
            make.height.equalTo(30)
        }
//        self.musicButton.snp.makeConstraints { make in
//            make.height.equalTo(30)
//        }
//        self.placeButton.snp.makeConstraints { make in
//            make.height.equalTo(30)
//        }
//
//        self.dateButton.snp.makeConstraints { make in
//            make.height.equalTo(30)
//            make.horizontalEdges.equalToSuperview()
//            make.width.equalToSuperview()
//        }
        
        self.contentTextView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        [self.titleLabel, self.musicLabel, self.placeLabel, self.DateLabel, self.contentLabel].forEach { label in self.inputStackView.setCustomSpacing(10, after: label) }
        
        [self.titleTextField, self.musicButton, self.placeButton, self.dateButton, self.contentTextView].forEach { view in self.inputStackView.setCustomSpacing(8, after: view) }
    }
    
    func bindUI() {
        
    }
    
    func setImage(at profileImageURL: URL?) {
        let maxProfileImageSize = CGSize(width: 80, height: 80)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: profileImageURL, options: [.processor(downsamplingProcessor)])
    }
    
}

class SelectButton: UIView {
//    private let label = ThemeLabel(size: FrameResource.fontSize100, color: .themeGray400)
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20)
        label.textColor = .gray
        return label
    }()
    private lazy var icon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.down")
        imageView.tintColor = .gray

        return imageView
    }()

//    var eventHandler: (() -> Void)?

    convenience init(text: String) {
        self.init()
        label.text = text
        backgroundColor = .blue

        layer.borderColor = CGColor(gray: 10, alpha: 1)
//        layer.borderWidth = FrameResource.commonBorderWidth
//        layer.cornerRadius = FrameResource.commonCornerRadius

//        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGestureEvent(_:))))
        addSubViews()
        makeConstraints()
    }

//    @objc private func tapGestureEvent(_ sender: UITapGestureRecognizer) {
//        eventHandler?()
//    }
    
    func setText(_ text: String) {
        label.text = text
    }

    private func addSubViews() {
        [label, icon].forEach {
            addSubview($0)
        }
    }

    private func makeConstraints() {
        snp.makeConstraints {
            $0.height.equalTo(40.0)
        }

        label.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(10)
        }

        icon.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-10)
            $0.leading.greaterThanOrEqualTo(label).offset(10)
        }
    }
}
