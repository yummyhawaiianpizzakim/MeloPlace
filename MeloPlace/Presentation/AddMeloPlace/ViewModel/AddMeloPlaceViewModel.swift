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
    let showMusicListView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
    let showSelectDateView: (_ addViewModel: AddMeloPlaceViewModel) -> Void
}

class AddMeloPlaceViewModel {
    let disposeBag = DisposeBag()
    
    struct Input {
        var imageData: Observable<Data>
        var date: Observable<Date>
        var didTapPlaceButton: Observable<Void>
        var didTapMusicButton: Observable<Void>
        var didTapDateButton: Observable<Void>
    }
    
    struct Output {
        let selectedAddress = PublishRelay<Address>()
        let selectedGeoPoint = PublishRelay<GeoPoint>()
        let selectedDate = PublishRelay<Date>()
        let selectedMusic = PublishRelay<Music?>()
    }
    
//    let image = BehaviorRelay<Data>(value: Data())
    let selectedAddress = PublishRelay<Address>()
    let selectedGeoPoint = PublishRelay<GeoPoint>()
    let selectedDate = PublishRelay<Date>()
    let selectedMusic = PublishRelay<Music>()
    
    var actions: AddMeloPlaceViewModelActions?
    
    func setActions(actions: AddMeloPlaceViewModelActions) {
        self.actions = actions
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        input.didTapMusicButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                print("music tap!")
                owner.actions?.showMusicListView( self )
            })
            .disposed(by: self.disposeBag)
        
        input.didTapPlaceButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showMeloLocationView( self )
            })
            .disposed(by: self.disposeBag)
        
        input.didTapDateButton
            .withUnretained(self)
            .subscribe(onNext: { owner, _ in
                owner.actions?.showSelectDateView( self )
            })
            .disposed(by: self.disposeBag)
        
        self.selectedAddress
            .bind(to: output.selectedAddress)
            .disposed(by: self.disposeBag)
        
        self.selectedGeoPoint
            .bind(to: output.selectedGeoPoint)
            .disposed(by: self.disposeBag)
        
        self.selectedDate
            .bind(to: output.selectedDate)
            .disposed(by: self.disposeBag)
        
        self.selectedMusic
            .bind(to: output.selectedMusic)
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

extension AddMeloPlaceViewModel: SelectDateViewModelDelegate {
    func dateDidSelect(date: Date) {
        self.selectedDate.accept(date)
    }
    
}

extension AddMeloPlaceViewModel: MusicListViewModelDelegate {
    func musicDidSelect(music: Music) {
        self.selectedMusic.accept(music)
    }
}
