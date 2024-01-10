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


final class SignInViewController: UIViewController {
    var viewModel: SignInViewModel?
    let disposeBag = DisposeBag()
    
    private var indicator: UIActivityIndicatorView?
    
    private var appUIImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "Album")?.withRenderingMode(.alwaysTemplate)
        view.tintColor = .themeColor300
        return view
    }()
    
    lazy var signInButton: ThemeButton = {
        let button = ThemeButton(title: "Sign In With Spotify")
        button.titleLabel?.font = .systemFont(ofSize: 15)
        return button
    }()
    
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
        self.view.backgroundColor = .white
        self.configureUI()
        self.bindViewModel()
    }
}

private extension SignInViewController {
    func configureUI() {
        [self.appUIImageView, self.signInButton].forEach {
            self.view.addSubview($0)
        }
        
        self.appUIImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.width.equalTo(100)
        }
        
        self.signInButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(30)
            make.trailing.equalToSuperview().offset(-30)
            make.bottom.equalToSuperview().offset(-30)
            make.height.equalTo(50)
        }
    }
    
    func bindViewModel() {
        let input = SignInViewModel.Input(
            didTapSignInButton: self.signInButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        output?.isIndicatorActived
            .drive(with: self, onNext: { owner, isActived in
                if isActived {
                    owner.showFullSizeIndicator()
                }
                
                if !isActived && owner.indicator != nil {
                    owner.hideFullSizeIndicator()
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    func showFullSizeIndicator() {
            let indicator = createIndicator()
            self.indicator = indicator
            
            self.view.addSubview(indicator)
            indicator.snp.makeConstraints { make in
                make.width.equalTo(258)
                make.height.equalTo(280)
                make.center.equalToSuperview()
            }
            
            indicator.startAnimating()
        }
        
    func hideFullSizeIndicator() {
        self.indicator?.stopAnimating()
        self.indicator?.removeFromSuperview()
        self.indicator = nil
    }
    
    private func createIndicator() -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.backgroundColor = .themeGray100?.withAlphaComponent(0.7)
        indicator.color = .black
        indicator.layer.cornerRadius = 20
        return indicator
    }
}
