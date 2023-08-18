//
//  SignInViewController.swift
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


class SignInViewController: UIViewController {
    var viewModel: SignInViewModel?
    let disposeBag = DisposeBag()
    
    lazy var signInButton = ThemeButton(title: "Sign In With Spotify")
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: SignInViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindViewModel()
    }
}

private extension SignInViewController {
    func configureUI() {
        self.view.backgroundColor = .white
        [self.signInButton].forEach {
            self.view.addSubview($0)
        }
        
        self.signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(30)
        }
    }
    
    func bindViewModel() {
        let input = SignInViewModel.Input(
            didTapSignInButton: self.signInButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
    }
}
