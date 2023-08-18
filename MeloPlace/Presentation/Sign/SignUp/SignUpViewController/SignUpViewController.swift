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


class SignUpViewController: UIViewController {
    var viewModel: SignUpViewModel?
    let disposeBag = DisposeBag()
    
    lazy var textStackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        return view
    }()
    
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
        self.configureUI()
        self.bindViewModel()
    }
}

private extension SignUpViewController {
    func configureUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(self.textStackView)
        self.view.addSubview(self.doneButton)
        
        [self.emailTextLabel, self.emailTextField,
         self.passwordTextLabel, self.passwordTextField
        ].forEach {
            self.textStackView.addArrangedSubview($0)
        }
        
        self.textStackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        self.emailTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        self.passwordTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        [self.emailTextLabel, self.passwordTextLabel].forEach {
            self.textStackView.setCustomSpacing(15, after: $0)
        }
        
        [self.emailTextField, self.passwordTextField].forEach {
            self.textStackView.setCustomSpacing(10, after: $0)
        }
        
        self.doneButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-40)
            make.height.equalTo(50)
        }
        
    }
    
    func bindViewModel() {
        let input = SignUpViewModel.Input(
            emailText: self.emailTextField.rx.text.orEmpty.asObservable(),
            passwordText: self.passwordTextField.rx.text.orEmpty.asObservable(),
            didTapDoneButton: self.doneButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.profile
            .asDriver()
            .drive(with: self, onNext: { owner, profile in
                guard let profile = profile else { return }
                owner.emailTextField.text = profile.email
            })
            .disposed(by: self.disposeBag)
    }
}
