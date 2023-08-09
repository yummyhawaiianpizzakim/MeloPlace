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
    
    lazy var scrollView = UIScrollView()
    
    lazy var addMeloPlaceView = AddMeloPlaceView()
    
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
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.addMeloPlaceView)
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.addMeloPlaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
    }
    
    func bind() {
        
    }
}
