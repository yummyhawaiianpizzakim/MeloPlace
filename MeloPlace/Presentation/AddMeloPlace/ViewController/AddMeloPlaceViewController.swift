//
//  AddMeloPlaceViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa


class AddMeloPlaceViewController: UIViewController {
    var viewModel: AddMeloPlaceViewModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: AddMeloPlaceViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .orange
        self.configureUI()
        self.bind()
    }
}

private extension AddMeloPlaceViewController {
    func configureUI() {
        
    }
    
    func bind() {
        
    }
}
