//
//  MapViewModelTests.swift
//  MeloPlaceTests
//
//  Created by 김요한 on 2024/01/05.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import MeloPlace

final class MapViewModelTests: XCTestCase {
    private var mapViewModel: MapViewModel!
    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!
    private var input: MapViewModel.Input!
    private var output: MapViewModel.Output!
    
    
    override func setUpWithError() throws {
        self.mapViewModel = MapViewModel(
            updateLocationUseCase: MockUpdateLocationUseCase(),
            fetchMapMeloPlaceUseCase: MockFetchMapMeloPlaceUseCase(),
            fetchCurrentLocationUseCase: MockFetchCurrentLocationUseCase(),
            reverseGeoCodeUseCase: MockReverseGeoCodeUseCase()
        )
        self.scheduler = TestScheduler(initialClock: 0)
        self.disposeBag = DisposeBag()
    }
    
    override func tearDownWithError() throws {
        self.mapViewModel = nil
        self.scheduler = nil
        self.disposeBag = nil
        self.input = nil
    }
    
    func test_dataSource() {
        let region = self.scheduler.createHotObservable([
            .next(100, Region(
                center: GeoPoint(latitude: 1, longitude: 1),
                spanLatitude: 1,
                spanLongitude: 1))
        ])
        
        let didTapSearchLocationButton =  self.scheduler.createHotObservable([.next(0, ())])
        
        let searchedText = self.scheduler.createHotObservable([.next(50, "대연동")])
        
        let mapMeloPlaceFilter = self.scheduler.createHotObservable([.next(0, MapMeloPlaceFilter(index: 0))])
        
        let dataSourceObservable = self.scheduler.createObserver(Bool.self)
        
        self.input = MapViewModel.Input(
            viewWillAppear: Observable.just(()),
            viewWillDisappear: Observable.just(()),
            region: region.asObservable(),
            didTapSearchBar: Observable.just(()),
            didTapSearchLocationButton: didTapSearchLocationButton.asObservable(),
            didTapListCell: Observable.just(
                IndexPath(row: 0, section: 0)),
            didTapPointAnnotation: Observable.just(""),
            mapMeloPlaceFilter: mapMeloPlaceFilter.asObservable()
        )
        
        self.mapViewModel.transform(input: self.input)
            .dataSources
            .asObservable()
            .map({ sources in
                return true
            })
            .catchAndReturn(false)
            .bind(to: dataSourceObservable)
            .disposed(by: self.disposeBag)
        
        self.scheduler.start()
        
        XCTAssertEqual(dataSourceObservable.events,
                       [.next(100, true)])
    }
}
