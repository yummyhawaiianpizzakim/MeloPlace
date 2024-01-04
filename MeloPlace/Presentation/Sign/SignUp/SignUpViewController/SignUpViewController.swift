//
//  SignUpViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/17.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxKeyboard

class SignUpViewController: UIViewController {
    var viewModel: SignUpViewModel?
    let disposeBag = DisposeBag()
    
    lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.bounces = true
        return view
    }()
    
    lazy var contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var marginView = UIView()
    
//    lazy var textStackView: UIStackView = {
//        let view = UIStackView()
//        view.axis = .vertical
//        return view
//    }()
    
    lazy var emailTextLabel: UILabel = {
        let label = UILabel()
        label.text = "email"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "email을 입력하세요"
        field.font = .systemFont(ofSize: 30)
        field.textColor = .black
        field.tintColor = .black
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var passwordTextLabel: UILabel = {
        let label = UILabel()
        label.text = "password"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    lazy var passwordTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "password을 입력하세요"
        field.font = .systemFont(ofSize: 30)
        field.textColor = .black
        field.tintColor = .black
        field.layer.borderColor = UIColor.black.cgColor
        return field
    }()
    
    lazy var doneButton = ThemeButton(title: "Sign UP")
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: SignUpViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.configureUI()
        self.hideKeyboardWhenTappedAround()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension SignUpViewController {
    func configureUI() {
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.contentView)
        
//        self.view.addSubview(self.textStackView)
        self.view.addSubview(self.doneButton)
        
//        [self.textStackView].forEach {
//            self.contentView.addSubview($0)
//        }
        
        [self.emailTextLabel, self.emailTextField,
         self.passwordTextLabel, self.passwordTextField,
         self.marginView
        ].forEach {
//            self.textStackView.addArrangedSubview($0)
            self.contentView.addSubview($0)
        }
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.emailTextLabel.snp.makeConstraints { make in
//            make.top.equalToSuperview().offset(100)
            make.top.equalToSuperview().inset(150)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.emailTextField.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        self.passwordTextLabel.snp.makeConstraints { make in
            make.top.equalTo(self.emailTextField.snp.bottom).offset(15)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
        }
        
        self.passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextLabel.snp.bottom).offset(10)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview().inset(20)
            make.height.equalTo(40)
        }
        
        //이거 없으니까 텍스트 필드가 클릭이 안됨;;
        self.marginView.snp.makeConstraints { make in
            make.top.equalTo(self.passwordTextField.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        self.doneButton.snp.makeConstraints { make in
//            make.top.equalTo(self.marginView.snp.bottom)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
        
    }
    
    func bindUI() {
        RxKeyboard.instance.visibleHeight
            .skip(1)
            .drive(onNext: { [weak self] keyboardVisibleHeight in
                guard let self else { return }
//                self.updateContentViewLayout(height: keyboardVisibleHeight)
                self.scrollView.contentInset.bottom = keyboardVisibleHeight
            })
            .disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        let input = SignUpViewModel.Input(
            emailText: self.emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: self.passwordTextField.rx.text.orEmpty.asObservable(),
            didTapDoneButton: self.doneButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.profile
            .drive(with: self, onNext: { owner, profile in
                guard let profile = profile else { return }
                owner.emailTextField.text = profile.email
                owner.emailTextField.becomeFirstResponder()
            })
            .disposed(by: self.disposeBag)
        
        output?.isDoneButotnEnable
            .drive(with: self, onNext: { owner, isEnable in
                owner.doneButton.isEnabled = isEnable ? true : false
            })
            .disposed(by: self.disposeBag)
    }
    
    func updateContentViewLayout(height: CGFloat) {
        let height = height == 0 ? 40 : height
        UIView.animate(withDuration: 1) { [weak self] in
            guard let self else { return }
            self.contentView.snp.remakeConstraints {
                $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
                $0.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-height)
            }
        }
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct signUpViewController: PreviewProvider {
    static var previews: some View {
        SignUpViewController().showPreview(.iPhone8)
    }
}
#endif
