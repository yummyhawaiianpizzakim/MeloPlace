//
//  MainViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa


class MainViewController: UIViewController {
    var viewModel: MainViewModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MainViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bind()
    }
}

private extension MainViewController {
    func configureUI() {
        
    }
    
    func bind() {
        
    }
}
