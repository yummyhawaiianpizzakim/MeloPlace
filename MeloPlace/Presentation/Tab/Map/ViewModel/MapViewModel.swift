//
//  MapViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxCocoa
import RxRelay
import CoreLocation

struct MapViewModelActions {
//    let showMapMeloPlaceListView: (_ meloPlaces: [MeloPlace]) -> Void
    let showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
    let showSearchView: () -> Void
}

typealias MapDataSource = [MapContentSection: [MapContentSection.Item]]

class MapViewModel {
    private let updateLocationUseCase: UpdateLocationUseCaseProtocol
    private let fetchMapMeloPlaceUseCase: FetchMapMeloPlaceUseCaseProtocol
    private let fetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol
    private let reverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol
    let disposeBag = DisposeBag()
    
    var actions: MapViewModelActions?
    
    let searchedText = BehaviorRelay<String>(value: "")
    let geoPoint = BehaviorRelay<GeoPoint?>(value: nil)
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    let annotations = BehaviorRelay<[PointAnnotation]>(value: [])
    
    init(updateLocationUseCase: UpdateLocationUseCaseProtocol,
         fetchMapMeloPlaceUseCase: FetchMapMeloPlaceUseCaseProtocol,
         fetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol,
         reverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol) {
        self.updateLocationUseCase = updateLocationUseCase
        self.fetchMapMeloPlaceUseCase = fetchMapMeloPlaceUseCase
        self.fetchCurrentLocationUseCase = fetchCurrentLocationUseCase
        self.reverseGeoCodeUseCase = reverseGeoCodeUseCase
        
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        let region: Observable<Region>
        let didTapSearchBar: Observable<Void>
        let didTapSearchLocationButton: Observable<Void>
        let didTapListCell: Observable<IndexPath>
        let didTapPointAnnotation: Observable<String>
        let mapMeloPlaceFilter: Observable<MapMeloPlaceFilter>
    }
    
    struct Output {
        let annotations: Driver<[PointAnnotation]>
        let geoPoint: Driver<GeoPoint?>
        let searchedText: Driver<String>
        let meloPlaces: Driver<[MeloPlace]>
        let dataSources: Driver<[MapDataSource]>
        let locationAuth: Driver<Bool>
    }
    
    func transform(input: Input) -> Output {
        
        let locationAuth = input.viewWillAppear
            .withUnretained(self)
            .flatMap({ owner, _ in
                owner.updateLocationUseCase.executeLocationTracker()
                return owner.updateLocationUseCase.observeAuthorizationStatus()
            })
            .asDriver(onErrorJustReturn: false)
            
        input.viewWillDisappear
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.updateLocationUseCase.terminateLocationTracker()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapSearchBar
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.actions?.showSearchView()
            }
            .disposed(by: self.disposeBag)
        
        input.didTapListCell
            .withUnretained(self)
            .subscribe { owner, indexPath in
                let meloPlaces = owner.meloPlaces.value
                owner.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapPointAnnotation
            .bind(onNext: { [weak self] uuid in
                guard let meloPlaces = self?.meloPlaces.value
                else { return }
                meloPlaces.enumerated().forEach { val in
                    let (index, meloPlace) = val
                    let indexPath = IndexPath(row: index, section: 0)
                    if uuid == meloPlace.id {
                        self?.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
                    }
                }
            })
            .disposed(by: self.disposeBag)
        
        self.fetchCurrentLocationUseCase.fetchCurrentLocation()
            .flatMap { [weak self] value -> Observable<String> in
                guard let self = self else { return Observable.error(LocationError.invalidGeopoint)}
                let (geoPoint, address) = value

                self.geoPoint.accept(geoPoint)
                return self.reverseGeoCodeUseCase.reverse(point: geoPoint).map { $0.name }
            }
            .bind(to: self.searchedText)
            .disposed(by: self.disposeBag)

        let dataSource = Observable.combineLatest(
            input.region.take(1),
            input.didTapSearchLocationButton.startWith(()),
            self.searchedText,
            input.mapMeloPlaceFilter
                .map({ $0.rawValue })
                .startWith(0)
        )
            .withLatestFrom(
                Observable.combineLatest(
                    input.region,
                    input.mapMeloPlaceFilter
                        .map({ $0.rawValue })
//                        .startWith(0)
                )
            )
            .flatMap({ [weak self] val -> Observable<[MapDataSource]> in
                let (region, state) = val
                guard
//                    let region,
                      let meloPlaceObservable = self?.fetchMapMeloPlaceUseCase
                    .fetch(region: region, tapState: state)
                    .do(onNext: { [weak self] meloPlaces in
                        guard let self else { return }
                        let annotations = self.updateAnnotations(meloPlaces: meloPlaces)
                        
                        self.annotations.accept(annotations)
                        self.meloPlaces.accept(meloPlaces)
                    })
                    .asObservable()
                else { return Observable.just([]) }
                
                return meloPlaceObservable.map { [weak self] meloPlaces in
                    guard let dataSource = self?.mappingDataSource(state: state, meloPlaces: meloPlaces)
                    else { return [] }
                    
                    return dataSource
                }
            })
            .share()
        
        
        return Output(
            annotations: self.annotations.asDriver(),
            geoPoint: self.geoPoint.asDriver(),
            searchedText: self.searchedText.asDriver(),
            meloPlaces: self.meloPlaces.asDriver(),
            dataSources: dataSource.asDriver(onErrorJustReturn: []),
            locationAuth: locationAuth
        )
    }
}

extension MapViewModel {
    func setActions(actions: MapViewModelActions) {
        self.actions = actions
    }
    
    private func updateAnnotations(meloPlaces: [MeloPlace]) -> [PointAnnotation] {
        let annotations = meloPlaces.map {
            return PointAnnotation(
                uuid: $0.id,
                memoryDate: $0.memoryDate,
                imageURLString: $0.images.first!,
                latitude: $0.latitude,
                longitude: $0.longitude
            )
        }
        
        return annotations
    }
    
    private func mappingDataSource(state: Int, meloPlaces: [MeloPlace]) -> [MapDataSource] {
        switch state {
        case 0:
            return [mappingMyDataSurce(meloPlaces: meloPlaces)]
        case 1:
            return [mappingFollowingDataSurce(meloPlaces: meloPlaces)]
        default:
            return []
        }
    }
    
    private func mappingMyDataSurce(meloPlaces: [MeloPlace]) -> MapDataSource {
        if meloPlaces.isEmpty {
            return [MapContentSection.my: []]
        }
        
        return [MapContentSection.my:
                    meloPlaces.map({ MapContentSection.Item.my($0)
        })]
    }
    
    private func mappingFollowingDataSurce(meloPlaces: [MeloPlace]) -> MapDataSource {
        if meloPlaces.isEmpty {
            return [MapContentSection.following: []]
        }
        return [MapContentSection.following:
                    meloPlaces.map({ MapContentSection.Item.following($0)
        })]
    }
    
}

extension MapViewModel {
    func searchSpaceDidSelect(space: Space) {
        
        print("space:: \(space)")
        let searchedText = space.name
        let geoPoint = GeoPoint(latitude: space.lat, longitude: space.lng)
        self.searchedText.accept(searchedText)
        self.geoPoint.accept(geoPoint)
    }
}
