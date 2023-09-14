//
//  MapViewController.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit
import FloatingPanel
import SnapKit
import RxSwift
import RxRelay
import RxCocoa
import RxGesture
import MapKit
import CoreLocation


class MapViewController: UIViewController {
    var viewModel: MapViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, MeloPlace>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, MeloPlace>
    
    struct Settings {
        static let openableRange: Double = LocationManager.openableRange
        static let monitoringRange: Double = 1000
        static let monitoringUpdateRange: Double = 850
        static let locationUpdateRange: Double = 5
    }
    
    var dataSource: DataSource?

    private var smallOverlay: MKCircle?
    private var bigOverlay: MKCircle?
    
    deinit {
        self.mainMapView.delegate = nil
    }
    
    lazy var mainMapView = MapView()
    lazy var locationManager = LocationManager.shared.core
    
    lazy var searchBar = SearchBarView()
    
    lazy var floatingPanelController = FloatingPanelController()
    
    lazy var contentView = MapMeloPlaceListViewController()
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(viewModel: MapViewModel) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegate()
        self.configureUI()
        self.setFPC()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
}

private extension MapViewController {
    func setDelegate() {
        self.floatingPanelController.delegate = self
        self.mainMapView.delegate = self
    }
    
    func setFPC() {
        self.floatingPanelController.set(contentViewController: self.contentView)
        self.floatingPanelController.addPanel(toParent: self)
        self.floatingPanelController.track(scrollView: self.contentView.meloPlaceCollectionView)
        self.floatingPanelController.changePanelStyle()
        self.floatingPanelController.layout = CustomFloatingPanelLayout()
        self.floatingPanelController.show()
        self.contentView.view.backgroundColor = .white
        self.contentView.loadViewIfNeeded()

    }
    
    func configureUI() {
        [self.mainMapView].forEach {
            self.view.addSubview($0)
        }
        
        [self.searchBar].forEach {
            self.mainMapView.addSubview($0)
        }
        
        self.mainMapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.searchBar.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.height.equalTo(30)
        }
        
    }
    
    func bindUI() {
        self.goToCurrentLocation()
        
        self.locationManager.rx.didChangeAuthorization
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { owner, status in
                if LocationManager.shared.checkAuthorization(status: status) {
                    owner.goToCurrentLocation()
                }
            })
            .disposed(by: disposeBag)
        
        self.locationManager.rx.didUpdateLocations
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
//                owner.markIfOpenable()
            })
            .disposed(by: disposeBag)
        
        self.locationManager.rx.willExitMonitoringRegion
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { owner, region in
                owner.resetMonitoringRegion(from: region)
            })
            .disposed(by: disposeBag)
            
    }
    
    func bindViewModel() {
        let input = MapViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear.map({ _ in () }),
            didTapSearchBar: self.searchBar.rx.tapGesture()
                    .when(.recognized)
                    .map({ _ in })
                    .asObservable(),
            didTapListCell: self.contentView.meloPlaceCollectionView.rx.itemSelected.asObservable()
        )
        
        
        let output = self.viewModel?.transform(input: input)
        
        output?.annotations.asDriver()
            .drive(onNext: {[weak self] annotations in
                guard let self = self else { return }
                self.removeAllAnnotations()
                self.addInitialAnnotations(annotations: annotations)
//                self.mainMapView.stopRotatingRefreshButton()
            })
            .disposed(by: self.disposeBag)
        
        output?.meloPlaces.asDriver()
            .drive(onNext: {[weak self] meloPlaces in
                self?.setSnapshot(models: meloPlaces)
            })
            .disposed(by: self.disposeBag)
        
        output?.searchedKeyword.asDriver(onErrorJustReturn: "")
            .drive(onNext: { text in
                self.searchBar.searchLabel.text = text
            })
            .disposed(by: self.disposeBag)
        
        output?.searchedGeoPoint.asDriver(onErrorJustReturn: nil)
            .drive(onNext: {[weak self] geoPoint in
                guard let self = self, let geoPoint = geoPoint
                else { return }
                let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
                let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta:0.01, longitudeDelta:0.01))

                self.mainMapView.setRegion(region, animated: true)
            })
            .disposed(by: self.disposeBag)
        
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation {
        case is PointAnnotation:
            let annotationView = AnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            return annotationView
            
        case is MKUserLocation:
            let userLocationview = MKUserLocationView(annotation: annotation, reuseIdentifier: "userLocation")
            userLocationview.zPriority = .max
            return userLocationview
            
        default:
            return nil
        }
    }
    
    private func goToCurrentLocation() {
        guard let currentLocation = locationManager.location?.coordinate else {
            return
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        let region = MKCoordinateRegion(center: currentLocation, span: span)
        self.mainMapView.setRegion(region, animated: true)
        
        self.resetMonitoringRegion(from: nil)
    }
    
    private func removeAllAnnotations() {
        let annotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(annotations)
    }
    
    // MARK: 처음 Annotation 그릴 때 사용
    
    private func addInitialAnnotations(annotations: [PointAnnotation]) {
        self.mainMapView.addAnnotations(annotations)
    }

        // MARK: Region 업데이트 및 AnnotationsToMonitor 새로 계산

    private func resetMonitoringRegion(from previousRegion: CLRegion?) {
        guard let currentLocation = locationManager.location?.coordinate else {
            return
        }
        
        if let previousRegion = previousRegion {
            locationManager.stopMonitoring(for: previousRegion)
        }
        
        let newRegion = CLCircularRegion(
            center: currentLocation,
            radius: Settings.monitoringUpdateRange,
            identifier: "regionsToMonitor"
        )
        
        newRegion.notifyOnExit = true
        
        locationManager.startMonitoring(for: newRegion)
        
        if let bigOverlay = bigOverlay {
            self.mainMapView.removeOverlay(bigOverlay)
        }
        
        let bigCircle = MKCircle(center: currentLocation, radius: Settings.monitoringRange)
        self.mainMapView.addOverlay(bigCircle)
        bigOverlay = bigCircle
    }
    
}

private extension MapViewController {
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.contentView.meloPlaceCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapMeloPlaceListCollectionCell.id, for: indexPath) as? MapMeloPlaceListCollectionCell else { return UICollectionViewCell() }
            cell.configureCell(item: itemIdentifier)
            return cell
        })
        
    }
    
    func setSnapshot(models: [MeloPlace]) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(models, toSection: 0)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

extension MapViewController: FloatingPanelControllerDelegate {
    
}

extension FloatingPanelController {
    func changePanelStyle() {
        let appearance = SurfaceAppearance()
        let shadow = SurfaceAppearance.Shadow()
        shadow.color = UIColor.black
        shadow.offset = CGSize(width: 0, height: -4.0)
        shadow.opacity = 0.15
        shadow.radius = 2
        appearance.shadows = [shadow]
        appearance.cornerRadius = 15.0
        appearance.backgroundColor = .clear
        appearance.borderColor = .clear
        appearance.borderWidth = 0
        
        self.surfaceView.grabberHandle.isHidden = false
        self.surfaceView.appearance = appearance
        
    }
}

class CustomFloatingPanelLayout: FloatingPanelLayout{
    var position: FloatingPanelPosition = .bottom
    var initialState: FloatingPanelState = .half
    
    var anchors: [FloatingPanelState: FloatingPanelLayoutAnchoring] {
            return [
                .half: FloatingPanelLayoutAnchor(fractionalInset: 0.5, edge: .bottom, referenceGuide: .safeArea),
                .full: FloatingPanelLayoutAnchor(absoluteInset: 16.0, edge: .top, referenceGuide: .safeArea),
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 30.0, edge: .bottom, referenceGuide: .safeArea)
            ]
        }
}
