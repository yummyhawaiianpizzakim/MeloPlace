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

enum MapContentSection: Int, Hashable {
    case my = 0
    case following
    
    enum Item: Hashable {
        case my(MeloPlace?)
        case following(MeloPlace?)
    }
}

final class MapViewController: UIViewController {
    var viewModel: MapViewModel?
    let disposeBag = DisposeBag()
    
    typealias DataSource = UICollectionViewDiffableDataSource<MapContentSection, MapContentSection.Item>
    typealias Snapshot = NSDiffableDataSourceSnapshot<MapContentSection, MapContentSection.Item>
    
    var dataSource: DataSource?
    
    deinit {
        self.mainMapView.delegate = nil
    }
    
    lazy var mainMapView = MapView()

    lazy var searchBar = SearchBarView()
    
    lazy var searchLocationButton = ThemeButton(title: "이지역 재검색")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDelegate()
        self.configureUI()
        self.setFPC()
        self.setDataSource()
        self.bindUI()
        self.bindViewModel()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
        self.floatingPanelController.track(scrollView: self.contentView.scrollView)
        self.floatingPanelController.changePanelStyle()
        self.floatingPanelController.layout = CustomFloatingPanelLayout()
        self.floatingPanelController.show()
        self.contentView.loadViewIfNeeded()
    }
    
    func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        
        appearance.configureWithTransparentBackground()
        
        self.navigationItem.titleView = searchBar
        self.navigationItem.backButtonTitle = ""
        self.navigationItem.standardAppearance = appearance
        self.navigationItem.scrollEdgeAppearance = appearance
    }
    
    func configureUI() {
        [self.mainMapView].forEach {
            self.view.addSubview($0)
        }
        
        self.mainMapView.addSubview(self.searchLocationButton)
        
        self.mainMapView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.searchLocationButton.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalTo(100)
        }
        
    }
    
    func bindUI() {
        
    }
    
    func bindViewModel() {
        let region = self.mainMapView.rx.regionDidChangeAnimated
            .withUnretained(self)
            .map({ owner, mapView in
                let region = mapView.region
                let generatedRegion = owner.generateToRegion(with: region)
                print(generatedRegion)
//                self?.viewModel?.region.accept(generatedRegion)
                return generatedRegion
            })
            .share()
        
        let didTapPointAnnotation = self.mainMapView.rx.calloutAccessoryControlTapped
            .map { val in
                let (_, annotationView, _) = val
                guard
                    let annotationView = annotationView.annotation as? PointAnnotation,
                    let uuid = annotationView.uuid
                else { return "" }
                
                return uuid
            }
        
        let input = MapViewModel.Input(
            viewWillAppear: self.rx.viewWillAppear
                .map({ _ in })
                .asObservable(),
            viewWillDisappear: self.rx.viewWillDisappear
                .map({ _ in })
                .asObservable(),
            region: region.skip(1),
            didTapSearchBar: self.searchBar.rx.tapGesture()
                .when(.recognized)
                .map({ _ in })
                .asObservable(),
            didTapSearchLocationButton: self.searchLocationButton.rx.tapGesture()
                .when(.recognized)
                .throttle(.seconds(1), scheduler: MainScheduler.instance)
                .map({ _ in })
                .asObservable(),
            didTapListCell: self.contentView.meloPlaceCollectionView.rx.itemSelected.asObservable(),
            didTapPointAnnotation: didTapPointAnnotation,
            mapMeloPlaceFilter: self.contentView.filterView.rx.itemSelected
                .map { MapMeloPlaceFilter(index: $0.row) }.startWith(.my)
                .share()
        )
        
        let output = self.viewModel?.transform(input: input)
        
        output?.annotations
            .drive(onNext: {[weak self] annotations in
                guard let self = self else { return }
                self.removeAllAnnotations()
                self.addInitialAnnotations(annotations: annotations)
            })
            .disposed(by: self.disposeBag)
        
        output?.searchedText
            .drive(onNext: { text in
                let replaceName = text.replaceString(where: "대한민국", of: "대한민국 ", with: "")
                self.searchBar.searchLabel.text = replaceName
                self.contentView.locationLabel.text = replaceName
            })
            .disposed(by: self.disposeBag)
        
        output?.geoPoint
            .drive(onNext: {[weak self] geoPoint in
                guard let self = self,
                      let geoPoint = geoPoint
                else { return }
                
                self.goToLocation(geoPoint: geoPoint)
            })
            .disposed(by: self.disposeBag)
        
        output?.dataSources
            .debug("mapDataSources")
            .compactMap({ [weak self] dataSources in
                self?.generateSnapshot(dataSources: dataSources)
            })
            .drive(onNext: { [weak self] snapshot in
                self?.dataSource?.apply(snapshot, animatingDifferences: false)
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
            userLocationview.isEnabled = false
            
            return userLocationview
            
        default:
            return nil
        }
    }
    
    private func goToLocation(geoPoint: GeoPoint) {
        let coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        self.mainMapView.setRegion(region, animated: true)
        
//        self.resetMonitoringRegion(from: nil)
    }
    
    private func removeAllAnnotations() {
        let annotations = self.mainMapView.annotations
        self.mainMapView.removeAnnotations(annotations)
    }
    
    // MARK: 처음 Annotation 그릴 때 사용
    
    private func addInitialAnnotations(annotations: [PointAnnotation]) {
        self.mainMapView.addAnnotations(annotations)
    }
    
    private func generateToRegion(with region: MKCoordinateRegion) -> Region {
        let centerLocation: GeoPoint = .init(latitude: region.center.latitude, longitude: region.center.longitude)
        let latitudeDelta: Double = region.span.latitudeDelta
        let longitudeDelta: Double = region.span.longitudeDelta
        
        return Region(center: centerLocation, spanLatitude: latitudeDelta, spanLongitude: longitudeDelta)
    }
    
}

private extension MapViewController {
    func setDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource(collectionView: self.contentView.meloPlaceCollectionView, cellProvider: { [weak self] collectionView, indexPath, itemIdentifier in
            guard let self else { return UICollectionViewCell() }
            switch itemIdentifier {
            case .my(let meloPlace):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapMeloPlaceListCollectionCell.id, for: indexPath) as? MapMeloPlaceListCollectionCell,
                      let meloPlace
                else { return UICollectionViewCell() }
                cell.configureCell(item: meloPlace)
                self.contentView.placeholderView.isHidden = true
                
                return cell
            case .following(let meloPlace):
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MapMeloPlaceListCollectionCell.id, for: indexPath) as? MapMeloPlaceListCollectionCell,
                      let meloPlace
                else { return UICollectionViewCell() }
                cell.configureCell(item: meloPlace)
                self.contentView.placeholderView.isHidden = true
                
                return cell
            }
        })
    }
    
    func generateSnapshot(dataSources: [MapDataSource]) -> Snapshot {
        var snapshot = Snapshot()
        dataSources.forEach { [weak self] items in
            items.forEach { section, values in
                if !values.isEmpty {
                    snapshot.appendSections([section])
                    snapshot.appendItems(values, toSection: section)
                } else {
                    self?.contentView.placeholderView.isHidden = false
                }
            }
        }
        return snapshot
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
                .tip: FloatingPanelLayoutAnchor(absoluteInset: 50.0, edge: .bottom, referenceGuide: .safeArea)
            ]
        }
}
