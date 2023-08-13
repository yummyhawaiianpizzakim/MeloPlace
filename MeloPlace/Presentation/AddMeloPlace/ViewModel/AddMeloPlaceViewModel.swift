//
//  AddMeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/08.
//

import Foundation
import RxSwift
import RxRelay

struct AddMeloPlaceViewModelActions {
    let showMeloLocationView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
}

class AddMeloPlaceViewModel {
    let disposeBag = DisposeBag()
    
//    let image = BehaviorRelay<Data>(value: Data())
    let selectedAddress = PublishRelay<Address>()
    let selectedGeoPoint = PublishRelay<GeoPoint>()
    
    struct Input {
        var imageData: Observable<Data>
        var date: Observable<Date>
        var didTapPlaceButton: Observable<Void>
    }
    
    struct Output {
        let selectedAddress = PublishRelay<Address>()
        let selectedGeoPoint = PublishRelay<GeoPoint>()
    }
    
    var actions: AddMeloPlaceViewModelActions?
    
    func setActions(actions: AddMeloPlaceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didTapPlaceButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showMeloLocationView( self )
            })
            .disposed(by: self.disposeBag)
        
        self.selectedAddress
            .bind(to: output.selectedAddress)
            .disposed(by: self.disposeBag)
        
        self.selectedGeoPoint
            .bind(to: output.selectedGeoPoint)
            .disposed(by: self.disposeBag)
        
        return output
    }
}

extension AddMeloPlaceViewModel {
//    func addImage(data: Data) {
//        self.image.accept(data)
//    }
}

extension AddMeloPlaceViewModel: MeloLocationViewModelDelegate {
    func locationSelected(address: Address, geopoint: GeoPoint) {
        self.selectedAddress.accept(address)
        self.selectedGeoPoint.accept(geopoint)
        print(address, geopoint)
    }
    
}
