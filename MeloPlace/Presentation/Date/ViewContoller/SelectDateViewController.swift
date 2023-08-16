//
//  SelectDateViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/16.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxRelay
import RxCocoa


class SelectDateViewController: UIViewController {
    var viewModel: SelectDateViewModel?
    let disposeBag = DisposeBag()
    
    lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "날짜 선택"
        label.font = .systemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()

    let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 12.0)
        button.setTitleColor(.black, for: .normal)

        return button
    }()
    
    lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .inline
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ko-KR")
        datePicker.timeZone = .autoupdatingCurrent
        datePicker.tintColor = .themeColor300
        datePicker.backgroundColor = .white
        datePicker.setValue(UIColor.black, forKey: "textColor")
        
        return datePicker
    }()
    
    lazy var doneButton = ThemeButton(title: "선택 완료")
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: SelectDateViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension SelectDateViewController {
    func configureUI() {
        self.view.backgroundColor = .white
        [self.cancelButton, self.titleLabel].forEach {
            self.topView.addSubview($0)
        }
        
        [self.topView, self.datePicker, self.doneButton].forEach {
            self.view.addSubview($0)
        }
        
        self.topView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(70)
        }
        
        self.cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
//            make.bottom.equalToSuperview().offset(-10)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
        }
        
        self.titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
        }
        
        self.datePicker.snp.makeConstraints { make in
            make.top.equalTo(self.topView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
        }
        
        self.doneButton.snp.makeConstraints { make in
            make.top.equalTo(self.datePicker.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.equalTo(50)
        }
    }
    
    func bindUI() {
        self.doneButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
        
        self.cancelButton.rx.tap
            .asDriver()
            .drive(with: self) { owner, _ in
                owner.dismiss(animated: true)
            }
            .disposed(by: self.disposeBag)
    }
    
    func bindViewModel() {
        let input = SelectDateViewModel.Input(
            selectedDate: self.datePicker.rx.date.asObservable(),
            didTapDoneButton: self.doneButton.rx.tap.asObservable()
        )
        let output = self.viewModel?.transform(input: input)
        
        
        
    }
}
