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
        self.view.backgroundColor = .white
        configure()
        bindViewModel()
    }

    func bindViewModel() {
        self.mainView.locateMap.rx.regionDidChangeAnimated
            .subscribe(onNext: { [weak self] mapView in
                let coordinate = mapView.centerCoordinate
                let geoPoint = GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude)
                
                self?.viewModel?.geoPoint.accept(geoPoint)
            })
            .disposed(by: disposeBag)
        
        let input = MeloLocationViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear
                .map({ _ in })
                .asObservable(),
            viewWillDisappear: self.rx.viewWillDisappear
                .map({ _ in })
                .asObservable(),
            done: self.mainView.doneButton.rx.tap.asObservable(),
            cancel: self.mainView.cancelButton.rx.tap.asObservable()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.isDragging
            .asDriver(onErrorJustReturn: false)
            .drive(with: self,
                   onNext: { owner, isDragging in
                if isDragging {
                    owner.mainView.cursor.image = UIImage(systemName: "mappin.and.ellipse")
                } else {
                    owner.mainView.cursor.image = UIImage(systemName: "mappin.and.ellipse")
                }
            })
            .disposed(by: self.disposeBag)
        
        output?.isCenceled
            .drive(with: self, onNext: { owner, isCenceled in
                owner.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)
        
        output?.isDone
            .drive(with: self, onNext: { owner, isCenceled in
                owner.dismiss(animated: true)
            })
            .disposed(by: self.disposeBag)

        output?.space
            .drive(onNext: { [weak self] space in
                guard let space else { return }
                self?.mainView.locationLabel.text = space.name
            })
            .disposed(by: self.disposeBag)
        
        output?.geoPoint
            .drive(onNext: {[weak self] geoPoint in
                guard let self = self
                else { return }
                
                self.goToLocation(geoPoint: geoPoint)
            })
            .disposed(by: self.disposeBag)
        
    }

    private func configure() {
        configureGesture()
    }
    
    private func goToLocation(geoPoint: GeoPoint) {
        let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        
        self.mainView.locateMap.setRegion(region, animated: true)
    }
}

// MARK: - CLLocationManager

extension MeloLocationViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        LocationManager.shared.checkAuthorization(status: status)
    }
}

// MARK: - Gesture Recognizer

extension MeloLocationViewController: UIGestureRecognizerDelegate {
    private func configureGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(drag(sender:)))
        panGesture.delegate = self

        self.mainView.locateMap.addGestureRecognizer(panGesture)
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
