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
import RxSwift
import RxCocoa

final class AddMeloPlaceView: UIView {
    let disposeBag = DisposeBag()
    
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
        label.text = "새 게시물"
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
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
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "제목"
        textField.leftView = UIView(frame: .init(x: 0, y: 0, width: 5, height: textField.frame.height))
        textField.leftViewMode = .always
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.layer.borderColor = UIColor.white.cgColor
        return textField
    }()
    
    lazy var titleTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = "0/20"
        label.textColor = .themeGray300
        return label
    }()
    
    lazy var contentTextCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = "0/200"
        label.textColor = .themeGray300
        return label
    }()
    
    lazy var musicButton = SelectButtonView(text: "음악")
    
    lazy var placeButton = SelectButtonView(text: "장소")
    
    lazy var dateButton = SelectButtonView(text: "날짜")
    
    lazy var tagUserButton = SelectTagUserButtonView(text: "태그 유저")
    
    lazy var contentTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .white
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 20)
        textView.text = "내용을 남겨주세요"
        textView.textColor = .themeGray100
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.white.cgColor
        return textView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.configureAttribute()
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension AddMeloPlaceView {
    func configureAttribute() {
        self.titleTextField.delegate = self
        self.contentTextView.delegate = self
    }
    
    func configureUI() {
        [self.topView, self.imageView, self.inputStackView,
         self.titleTextCountLabel, self.contentTextCountLabel
        ]
            .forEach { self.addSubview($0) }
        
        [self.backButton, self.topViewTitleLabel]
            .forEach { self.topView.addSubview($0) }
        
        [self.titleTextField,
         self.contentTextView,
         self.musicButton,
         self.placeButton,
         self.dateButton,
         self.tagUserButton
        ].forEach { view in
            self.inputStackView.addArrangedSubview(view)
        }
        
        self.topView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.inputStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.top.equalTo(self.imageView.snp.bottom).offset(10)
            make.bottom.equalToSuperview()
        }
        
        self.topViewTitleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.backButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(10)
            make.height.width.equalTo(20)
        }
        
        self.imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.topView.snp.bottom).offset(10)
            make.width.height.equalTo(200)
        }
        
        self.titleTextField.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(30)
        }
        
        self.titleTextCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.titleTextField.snp.trailing).offset(-5)
            make.bottom.equalTo(self.titleTextField.snp.bottom).offset(-5)
        }

        self.contentTextView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.height.equalTo(90)
        }
        
        self.contentTextCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(self.contentTextView.snp.trailing).offset(-5)
            make.bottom.equalTo(self.contentTextView.snp.bottom).offset(-5)
        }
        
        [self.titleTextField, self.musicButton, self.placeButton,
         self.dateButton, self.tagUserButton, self.contentTextView
        ].forEach { view in self.inputStackView.setCustomSpacing(8, after: view) }
    }
    
    func bindUI() {
        self.contentTextView.rx.didBeginEditing
            .bind { [weak self] _ in
                if self?.contentTextView.text == "내용을 남겨주세요" {
                    self?.contentTextView.text = ""
                    self?.contentTextView.textColor = .black
                    self?.contentTextView.layer.borderColor = UIColor.themeColor300?.cgColor
                }
            }
            .disposed(by: self.disposeBag)
            
        self.contentTextView.rx.didEndEditing
            .bind { [weak self] _ in
                if self?.contentTextView.text == "" || self?.contentTextView.text == nil {
                    self?.contentTextView.text = "내용을 남겨주세요"
                    self?.contentTextView.textColor = .themeGray100
                    self?.contentTextView.layer.borderColor = UIColor.white.cgColor
                }
            }
            .disposed(by: self.disposeBag)
        
        self.titleTextField.rx.text.orEmpty
            .bind { [weak self] text in
                self?.titleTextCountLabel.text = "\(text.count)/20"
            }
            .disposed(by: self.disposeBag)
        
        self.contentTextView.rx.text.orEmpty
            .bind { [weak self] text in
                if text == "내용을 남겨주세요" {
                    self?.contentTextCountLabel.text = "0/200"
                } else {
                    self?.contentTextCountLabel.text = "\(text.count)/200"
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    func setImage(at profileImageURL: URL?) {
        let maxProfileImageSize = CGSize(width: 100, height: 100)
        let downsamplingProcessor = DownsamplingImageProcessor(size: maxProfileImageSize)
        self.imageView.kf.setImage(with: profileImageURL, options: [.processor(downsamplingProcessor)])
    }
}
extension AddMeloPlaceView: UITextFieldDelegate, UITextViewDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.themeColor300?.cgColor
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.layer.borderColor = UIColor.white.cgColor
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {return false}
        let maxLength = 20
        
        // 최대 글자수 이상을 입력한 이후에는 중간에 다른 글자를 추가할 수 없게 작동
        if text.count >= maxLength && range.length == 0 && range.location >= maxLength {
            textField.endEditing(true)
            self.titleTextCountLabel.textColor = .red
            return false
        }
        self.titleTextCountLabel.textColor = .themeGray300
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let text = textView.text else {return false}
        let maxLength = 200
        
        // 최대 글자수 이상을 입력한 이후에는 중간에 다른 글자를 추가할 수 없게 작동
        if text.count >= maxLength && range.length == 0 && range.location >= maxLength {
            textView.endEditing(true)
            self.contentTextCountLabel.textColor = .red
            return false
        }
        self.contentTextCountLabel.textColor = .themeGray300
        return true
    }
}
