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
import RxGesture
import PhotosUI

class AddMeloPlaceViewController: UIViewController {
    var viewModel: AddMeloPlaceViewModel?
    let disposeBag = DisposeBag()
    
    lazy var scrollView = UIScrollView()
    
    private lazy var imagePicker: PHPickerViewController = {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        configuration.selection = .ordered
        var imagePicker = PHPickerViewController(configuration: configuration)
        imagePicker.delegate = self
        return imagePicker
    }()
    
    lazy var addMeloPlaceView = AddMeloPlaceView()
    
    lazy var doneButton = ThemeButton(title: "선택 완료")
    
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
//        self.view.backgroundColor = .white
        self.configureUI()
//        self.configureNavigationBar()
        self.bindUI()
        self.bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
}

private extension AddMeloPlaceViewController {
    func configureUI() {
        self.view.addSubview(self.scrollView)
        self.view.addSubview(self.doneButton)
        self.scrollView.addSubview(self.addMeloPlaceView)
        
        self.scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.addMeloPlaceView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        self.doneButton.snp.makeConstraints { make in
//            make.bottom.equalToSuperview().offset(-20)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }
        
    }
    
    func bindUI() {
        self.addMeloPlaceView.imageView.rx.tapGesture()
            .when(.recognized)
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.checkAccessForPHPicker()
            }
            .disposed(by: self.disposeBag)
        
        self.addMeloPlaceView.backButton.rx.tap
            .asDriver()
            .drive { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: self.disposeBag)
        
    }
    
    func bindViewModel() {
        
        let input = AddMeloPlaceViewModel.Input(
            viewDidLoad: Observable.just(()),
            meloPlaceTitle: self.addMeloPlaceView.titleTextField.rx.text.orEmpty.asObservable(),
            meloPlaceContent: self.addMeloPlaceView.contentTextView.rx.text.orEmpty.asObservable(),
            didTapPlaceButton: self.addMeloPlaceView.placeButton.rx.tapGesture()
                .when(.recognized)
                .map({ _ in  })
                .asObservable(),
            didTapMusicButton: self.addMeloPlaceView.musicButton.rx.tapGesture()
                .when(.recognized)
                .map({ _ in })
                .asObservable(),
            didTapDateButton: self.addMeloPlaceView.dateButton.rx.tapGesture()
                .when(.recognized)
                .map({ _ in })
                .asObservable(),
            didTapTagUserButton: self.addMeloPlaceView.tagUserButton.rx.tapGesture()
                .when(.recognized)
                .map({ _ in })
                .asObservable(),
            didTapTagUserDeleteButton: self.addMeloPlaceView.tagUserButton.deletedName.asObservable(),
            didTapDoneButton: self.doneButton.rx.tap.throttle(.seconds(1), scheduler: MainScheduler.instance).asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.selectedSpace
            .drive(onNext: { [weak self] space in
                guard let space else { return }
                self?.addMeloPlaceView.placeButton.setText(space.name)
            })
            .disposed(by: self.disposeBag)
        
        output?.selectedDate
            .drive(with: self, onNext: { owner, date in
                guard let date else { return }
                owner.addMeloPlaceView.dateButton.setText(date.toString())
            })
            .disposed(by: self.disposeBag)
        
        output?.selectedMusic
            .drive(with: self, onNext: { owner, music in
                guard let music = music else { return }
                owner.addMeloPlaceView.musicButton.setText(music.name)
            })
            .disposed(by: self.disposeBag)
        
        output?.selectedUserNames
            .drive(onNext: { [weak self] names in
                self?.addMeloPlaceView.tagUserButton.setSnapshot(models: names)
            })
            .disposed(by: self.disposeBag)
        
        output?.deletedUserName
            .drive(with: self, onNext: { owner, name in
                self.addMeloPlaceView.tagUserButton
                    .deleteItem(item: name)
            })
            .disposed(by: self.disposeBag)
            
        output?.isEnableDoneButton
            .drive(with: self, onNext: { owner, isEnable in
                owner.doneButton.isEnabled = isEnable
            })
            .disposed(by: self.disposeBag)
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        let backButtonImage = UIImage(systemName: "arrow.backward")
        
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(backButtonImage, transitionMaskImage: backButtonImage)
//        appearance.shadowColor = TrinapAsset.white.color
        appearance.shadowColor = .themeGray100
        self.navigationController?.navigationBar.tintColor = .black
        
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
        self.navigationItem.backButtonTitle = ""
        
    }
}

extension AddMeloPlaceViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let result = results.first else { return }
        
        result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("Image loading error: \(error)")
                return
            }
            
            guard let image = image as? UIImage,
            let data = image.jpegData(compressionQuality: 0.9)
            else { return }
            DispatchQueue.main.async {
                // 여기에서 이미지를 처리합니다. 예를 들어, 이미지 뷰에 표시할 수 있습니다.
                self.addMeloPlaceView.imageView.image = image
            }
            
            self.viewModel?.addImage(data: data)
//            self.pickedImage.accept(data)
        }
        
    }
    
    private func checkAccessForPHPicker() {
        
        switch PHPhotoLibrary.authorizationStatus(for: .readWrite) {
        case .authorized, .limited:
            present(self.imagePicker, animated: true)
            
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
                switch status {
                case .authorized, .limited:
                    DispatchQueue.main.async {
                        self?.present(self!.imagePicker, animated: true)
                    }
                case .notDetermined, .restricted, .denied:
                    print("앨범 접근이 필요합니다.")
                @unknown default:
                    print("\(#function) unknown error")
                }
            }
            
        case .denied, .restricted:
            print("앨범 접근이 필요합니다.")
        @unknown default:
            print("\(#function) unknown error")
        }
    }
    
}

extension AddMeloPlaceViewController {
//    func showDateSelectView() {
//
//        let alert = UIAlertController(
//            title: "만료 기한을 선택해주세요",
//            message: nil,
//            preferredStyle: .alert
//        )
//
//        let datePicker = createDatePicker()
//        alert.view.addSubview(datePicker)
//        datePicker.snp.makeConstraints { make in
//            make.centerX.equalTo(alert.view)
//            make.top.equalTo(alert.view).inset(55)
//            make.bottom.equalTo(alert.view).inset(60)
//        }
//
//
//        let cancelAction = UIAlertAction(
//            title: "취소",
//            style: .cancel,
//            handler: nil
//        )
//
//        let selectAction = UIAlertAction(
//            title: "선택",
//            style: .default,
//            handler: { [weak self] _ in
//                let date = datePicker.date
//                let dateString = date.toString()
//                self?.addMeloPlaceView.dateButton.setText(dateString)
////                self?.date.accept(date)
//            }
//        )
//
//        alert.addAction(cancelAction)
//        alert.addAction(selectAction)
//        alert.view.tintColor = .white
//        present(alert, animated: true)
//
//    }
//
//    func createDatePicker() -> UIDatePicker {
//        let datePicker = UIDatePicker()
////        datePicker.date = Date()
//        datePicker.preferredDatePickerStyle = .wheels
//        datePicker.datePickerMode = .date
//        datePicker.locale = Locale(identifier: "ko-KR")
//        datePicker.timeZone = .autoupdatingCurrent
//        datePicker.tintColor = .gray
//
//        return datePicker
//    }
}
