//
//  CommentInputView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/09/25.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CommentInputView: UIView {
    
    let disposeBag = DisposeBag()
    
    lazy var commentTextField: UITextField = {
        let textField = UITextField()
        
        textField.borderStyle = .none
        textField.font = .systemFont(ofSize: 14)
        return textField
    }()
        
    lazy var postCommentButton: UIButton = {
        let button = UIButton()
        let size = CGSize(width: 25, height: 25)
        
        button.setImage(UIImage(systemName: "arrow.up.circle")?.resize(size: size) , for: .normal)
        button.setImage(UIImage(systemName: "arrow.up.circle")?.resize(size: size), for: .disabled)
        return button
    }()
    
    lazy var commentInputContainerView: UIView = {
        let view = UIView()
        
        view.backgroundColor = .white
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
        self.bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let postCommentCornerRadius = self.postCommentButton.frame.height / 2
        let inputContainerViewCornerRadius = self.commentInputContainerView.frame.height / 2
        
        self.postCommentButton.layer.cornerRadius = postCommentCornerRadius
        self.commentInputContainerView.layer.cornerRadius = inputContainerViewCornerRadius
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderWidth = 1
    }
}

extension CommentInputView {
    func configureUI() {
        self.addSubview(self.commentInputContainerView)
        
        [self.commentTextField, self.postCommentButton]
            .forEach { self.commentInputContainerView.addSubview($0) }
        
        self.commentInputContainerView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(8)
            make.bottom.equalToSuperview().offset(-8)
        }
        
        self.commentTextField.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
            make.leading.equalToSuperview().offset(16)
        }
        
        self.postCommentButton.snp.makeConstraints { make in
            make.trailing.top.bottom.equalToSuperview()
            make.width.equalTo(self.postCommentButton.snp.height)
        }
        
    }
    
    func bindUI() {
        self.commentTextField.rx.text
            .orEmpty
            .map(\.isEmpty)
            .map { !$0 }
            .bind(to: postCommentButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
    }
}

extension CommentInputView {
    var textObservable: Observable<String> {
        return self.commentTextField.rx.text.orEmpty.asObservable()
    }
    
    var didTapPostWithText: Observable<String> {
        return self.postCommentButton.rx.tap
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .withUnretained(self) { owner, _ in
                let text = owner.commentTextField.text ?? ""
                
                owner.commentTextField.text = ""
                owner.postCommentButton.isEnabled = false
                return text
            }
            .asObservable()
    }
}
