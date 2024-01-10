//
//  LocationViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/12.
//

import Foundation
import RxCocoa
import RxSwift

enum LocationError: LocalizedError {
    case invalidGeopoint
    
    var errorDescription: String? {
        switch self {
        case .invalidGeopoint:
            return "해당 지역의 주소를 불러올 수 없습니다."
        }
    }
}

//protocol MeloLocationViewModelDelegate: AnyObject {
//    func locationSelected(space: Space)
//}

struct MeloLocationViewModelActions {
    let closeMeloLocationView: (_ space: Space?) -> Void
//    let submitMeloLocationView: (_ space: Space) -> Void
}

final class MeloLocationViewModel {
    let disposeBag = DisposeBag()
    private let updateLocationUseCase: UpdateLocationUseCaseProtocol
    private let fetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol
    private let reverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol
    
    var actions: MeloLocationViewModelActions?
//    var delegate: MeloLocationViewModelDelegate?
    
    let geoPoint = PublishRelay<GeoPoint>()
    let space = BehaviorRelay<Space?>(value: nil)
    let isDragging = PublishRelay<Bool>()
    
    init(updateLocationUseCase: UpdateLocationUseCaseProtocol, fetchCurrentLocationUseCase: FetchCurrentLocationUseCaseProtocol, reverseGeoCodeUseCase: ReverseGeoCodeUseCaseProtocol) {
        self.updateLocationUseCase = updateLocationUseCase
        self.fetchCurrentLocationUseCase = fetchCurrentLocationUseCase
        self.reverseGeoCodeUseCase = reverseGeoCodeUseCase
    }
    
    struct Input {
        let viewWillAppear: Observable<Void>
        let viewWillDisappear: Observable<Void>
        var done: Observable<Void>
        var cancel: Observable<Void>
    }

    struct Output {
        let isCenceled: Driver<Bool>
        let isDone: Driver<Bool>
        let isDragging: Driver<Bool>
        let space: Driver<Space?>
        let geoPoint: Driver<GeoPoint>
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
        
        self.geoPoint.asObservable()
            .debounce(.milliseconds(200), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMap({  owner, geoPoint in
                owner.reverseGeoCodeUseCase.reverse(point: geoPoint)
            })
            .bind(to: self.space)
            .disposed(by: self.disposeBag)
        
        let isCenceled = input.cancel
            .do(onNext: {[weak self] _ in
                self?.actions?.closeMeloLocationView(nil)
            })
            .map { _ in
                return true
            }
            .asDriver(onErrorJustReturn: false)

        let isdone = input.done
            .withLatestFrom(self.space)
            .do { [weak self] space in
                guard let space else { return }
                self?.actions?.closeMeloLocationView(space)
            }
            .map { _ in
                return true
            }
            .asDriver(onErrorJustReturn: false)
        
        let geoPoint = self.fetchCurrentLocationUseCase.fetchCurrentLocation()
            .map { val in
                let (geoPoint, _) = val
                return geoPoint
            }
        
        return Output(
            isCenceled: isCenceled,
            isDone: isdone,
            isDragging: self.isDragging.asDriver(onErrorJustReturn: false),
            space: self.space.asDriver(),
            geoPoint: geoPoint.asDriver(onErrorJustReturn: GeoPoint.seoulCoordinate),
            locationAuth: locationAuth
        )
    }
    
    func setActions(actions: MeloLocationViewModelActions) {
        self.actions = actions
    }
    
}

extension MeloLocationViewModel {
    func isDragging(bool: Bool) {
        self.isDragging.accept(bool)
    }
}
