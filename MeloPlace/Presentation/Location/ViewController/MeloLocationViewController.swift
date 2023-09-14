//
//  LocationViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import CoreLocation
import MapKit
import RxSwift
import UIKit

final class MeloLocationViewController: UIViewController {
    var disposeBag = DisposeBag()
    var viewModel: MeloLocationViewModel?

    let mainView = MeloLocateView()
    let locationManager = LocationManager.shared.core
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    convenience init(viewModel: MeloLocationViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = self.mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
        goToCurrentLocation()
        bindViewModel()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
    }

    func bindViewModel() {
        
        let input = MeloLocationViewModel
            .Input(done: self.mainView.doneButton.rx.tap.asObservable(),
                   cancel: self.mainView.cancelButton.rx.tap.asObservable()
            )
        
        let output = self.viewModel?.transform(input: input)
        // Drag
//        viewModel?.input.isDragging
//            .withUnretained(self)
//            .bind { owner, isDragging in
//                if isDragging {
//                    owner.mainView.cursor.image = .locateDisabled
//                } else {
//                    owner.mainView.cursor.image = .locate
//                }
//            }.disposed(by: disposeBag)
        
        output?.isDragging
            .asDriver(onErrorJustReturn: false)
            .drive(with: self,
                   onNext: { owner, isDragging in
                if isDragging {
                    owner.mainView.cursor.image = UIImage(systemName: "x.circle")
                } else {
                    owner.mainView.cursor.image = UIImage(systemName: "o.circle")
                }
            })
            .disposed(by: self.disposeBag)

        output?.doneButtonState
            .withUnretained(self)
            .subscribe(onNext: { owner, state in
                owner.mainView.doneButton.isEnabled = state
            })
            .disposed(by: disposeBag)

        // 주소
        output?.fullAddress
            .subscribe(onNext: { [weak self] in
                self?.mainView.locationLabel.text = $0 ?? LocationError.invalidGeopoint.errorDescription
            })
            .disposed(by: disposeBag)
        
        output?.isCenceled
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isCenceled in
                owner.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        output?.isDone
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { owner, isCenceled in
                owner.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)

        self.mainView.locateMap.rx.regionDidChangeAnimated
            .subscribe(onNext: { [weak self] mapView in
                let coordinate = mapView.centerCoordinate
                
                output?.geopoint.accept(
                    GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                )
            })
            .disposed(by: disposeBag)
        
    }

    private func configure() {
        view.backgroundColor = .white
//        self.view.addSubview(self.mainView)
        configureLocationManager()
        configureGesture()
    }

    private func goToCurrentLocation() {
        guard let center = LocationManager.shared.coordinate else {
            return
        }

        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: center, span: span)

        mainView.locateMap.setRegion(region, animated: true)
    }
}

// MARK: - CLLocationManager

extension MeloLocationViewController: CLLocationManagerDelegate {
    private func configureLocationManager() {
        locationManager.delegate = self
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        LocationManager.shared.checkAuthorization(status: status)
    }
}

// MARK: - Gesture Recognizer

extension MeloLocationViewController: UIGestureRecognizerDelegate {
    private func configureGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(sender:)))
        panGesture.delegate = self

        mainView.locateMap.addGestureRecognizer(panGesture)
    }

    @objc func drag(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            self.viewModel?.isDragging(bool: true)
        case .ended, .cancelled:
            self.viewModel?.isDragging(bool: false)
        default:
            break
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
