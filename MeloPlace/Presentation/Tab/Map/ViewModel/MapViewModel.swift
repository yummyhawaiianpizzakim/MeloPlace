//
//  MapViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import RxSwift
import RxRelay

struct MapViewModelActions {
    let showMapMeloPlaceListView: (_ meloPlaces: [MeloPlace]) -> Void
    let showMeloPlaceDetailView: (_ meloPlaces: [MeloPlace], _ indexPath: IndexPath) -> Void
    let showSearchView: (_ sender: MapViewModel) -> Void
}

class MapViewModel {
    let fireBaseService = FireBaseNetworkService.shared
    let locationManager = LocationManager.shared
    let disposeBag = DisposeBag()
    
    var actions: MapViewModelActions?
    
    let searchedSpace = PublishRelay<Space>()
    weak var coordinate: BehaviorRelay<GeoPoint?>?
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
    
    struct Input {
        var viewWillAppear: Observable<Void>
        var didTapSearchBar: Observable<Void>
        var didTapListCell: Observable<IndexPath>
    }
    
    struct Output {
        let annotations = BehaviorRelay<[PointAnnotation]>(value: [])
        let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
        let searchedKeyword = PublishRelay<String>()
        let searchedGeoPoint = PublishRelay<GeoPoint?>()
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.viewWillAppear
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.fireBaseService.read(type: MeloPlaceDTO.self, userCase: .currentUser, access: .meloPlace)
                    .map { dto in
//                        print(dto)
                        return dto.toDomain()
                    }
                    .toArray()
                    .subscribe { [weak self] meloPlaces in
//                        print(meloPlaces)
                        let annotations = owner.updateAnnotations(meloPlaces: meloPlaces)
                        
                        self?.meloPlaces.accept(meloPlaces)
                        output.annotations.accept(annotations)
                    } onFailure: { error in
                        print(error)
                    }
                    .disposed(by: owner.disposeBag)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapSearchBar
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.actions?.showSearchView(owner)
            }
            .disposed(by: self.disposeBag)
        
        input.didTapListCell
            .withUnretained(self)
            .subscribe { owner, indexPath in
                let meloPlaces = owner.meloPlaces.value
                owner.actions?.showMeloPlaceDetailView(meloPlaces, indexPath)
            }
            .disposed(by: self.disposeBag)
        
        self.meloPlaces
            .bind(to: output.meloPlaces)
            .disposed(by: self.disposeBag)
        
        self.searchedSpace
            .do(onNext: { space in
                output.searchedKeyword.accept(space.name)
            })
            .map({ space in
                return GeoPoint(latitude: space.lat, longitude: space.lng)
            })
            .bind(to: output.searchedGeoPoint)
            .disposed(by: self.disposeBag)
                
                
        return output
    }
}

extension MapViewModel {
    func setActions(actions: MapViewModelActions) {
        self.actions = actions
    }
    
    func updateAnnotations(meloPlaces: [MeloPlace]) -> [PointAnnotation] {
            let annotations = meloPlaces.map {
                PointAnnotation(
                    uuid: $0.id,
                    memoryDate: $0.memoryDate,
                    latitude: $0.latitude,
                    longitude: $0.longitude
                )
            }

            return annotations
        }
}

extension MapViewModel: SearchViewModelDelegate {
    func searchSpaceDidSelect(space: Space) {
        self.searchedSpace.accept(space)
    }
}
