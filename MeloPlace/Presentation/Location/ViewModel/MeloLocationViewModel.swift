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

protocol MeloLocationViewModelDelegate: AnyObject {
    func locationSelected(address: Address,geopoint: GeoPoint)
}

struct MeloLocationViewModelActions {
    let closeMeloLocationView: () -> Void
}

final class MeloLocationViewModel {
    
    struct Input {
        var done: Observable<Void>
        var cancel: Observable<Void>
    }

    struct Output {
        let address = PublishRelay<Address>()
        let fullAddress = PublishRelay<String?>()
        let simpleAddress = PublishRelay<String>()
        let geopoint = PublishRelay<GeoPoint>()
        let doneButtonState = BehaviorRelay<Bool>(value: false)
        let isDone = PublishRelay<Bool>()
        let isCenceled = PublishRelay<Bool>()
        let isDragging = PublishRelay<Bool>()

        var locationObservable: Observable<(address: Address, geopoint: GeoPoint)> {
            Observable.combineLatest(address, geopoint) { address, geopoint in
                (address: address, geopoint: geopoint)
            }
        }
    }
    
    var disposeBag: DisposeBag = DisposeBag()

    var actions: MeloLocationViewModelActions?
    var delegate: MeloLocationViewModelDelegate?
    
    let isDragging = PublishRelay<Bool>()
    
    func setActions(actions: MeloLocationViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.cancel
            .subscribe(onNext: { [weak self] in
                self?.actions?.closeMeloLocationView()
                output.isCenceled.accept(true)
            })
            .disposed(by: disposeBag)

        input.done
            .withLatestFrom(output.locationObservable)
            .subscribe(onNext: { [weak self] address, geopoint in
                print("done tap!")
                self?.delegate?.locationSelected(address: address, geopoint: geopoint)
                self?.actions?.closeMeloLocationView()
                output.isDone.accept(true)
            })
            .disposed(by: disposeBag)

        output.geopoint
            .subscribe(
                onNext: { [weak self] in
                    LocationManager.shared.reverseGeocode(point: $0) { address in
                        guard let address else {
                            output.doneButtonState.accept(false)
                            output.fullAddress.accept(LocationError.invalidGeopoint.localizedDescription)
                            return
                        }

                        output.doneButtonState.accept(true)
                        output.address.accept(address)
                        output.fullAddress.accept(address.full)
                        output.simpleAddress.accept(address.simple)
                    }
                },
                onError: { [weak self] error in
                    output.doneButtonState.accept(false)
                    output.fullAddress.accept(error.localizedDescription)
                }
            )
            .disposed(by: disposeBag)
        
        self.isDragging
            .bind(to: output.isDragging)
            .disposed(by: self.disposeBag)
        
        return output
    }
    
}

extension MeloLocationViewModel {
    func isDragging(bool: Bool) {
        self.isDragging.accept(bool)
    }
}
