//
//  MeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
//import UIKit
import MapKit
import RxSwift
import RxRelay

class MeloPlaceDetailViewModel {
    let disposeBag = DisposeBag()
    let spotifyService = SpotifyService.shared
    
//    let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
    let meloPlaces = BehaviorRelay<[MeloPlace]>(value: [])
//    let indexPath = BehaviorRelay<IndexPath>(value: [0, 0])
    var indexPath: IndexPath?
    
    struct Input {
        var viewDidLoad: Observable<Void>
        var didTapPlayPauseButton: Observable<Void>
        var didTapPlayBackButton: Observable<Void>
        var didTapPlayNextButton: Observable<Void>
    }
    
    struct Output {
        let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
        let dataSource = BehaviorRelay<(meloPlaces: [MeloPlace], indexPath: IndexPath)>(value: (meloPlaces: [], indexPath: [0, 0]))
//        let dataSource = BehaviorRelay<[MeloPlace]>(value: [])
        let mapCoordinate = PublishRelay<CLLocationCoordinate2D>()
        let mapSnapshot = PublishRelay<UIImage>()
        let isPaused = BehaviorRelay<Bool>(value: false)
    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
//        guard let meloPlace = self.meloPlace.value else { return output }
        
        input.viewDidLoad
            .withUnretained(self)
            .subscribe { owner, _ in
                
            }
            .disposed(by: self.disposeBag)
        
        input.didTapPlayPauseButton
            .withUnretained(self)
            .subscribe { owner, _ in
                owner.spotifyService.didTapPauseOrPlay()
            }
            .disposed(by: self.disposeBag)
        
//        input.didTapPlayBackButton
//            .withLatestFrom(self.meloPlace)
//            .subscribe { meloPlace in
//
//            }
//            .disposed(by: self.disposeBag)
        
//        self.meloPlaces
//            .bind(to: output.dataSource)
//            .disposed(by: self.disposeBag)
        
//        Observable.combineLatest(self.meloPlaces)
//            .subscribe {meloPlaces, indexPath in
////                print("meloPlaces: \(meloPlaces) ,  indexPath: \(indexPath)")
//                output.dataSource.accept((meloPlaces: meloPlaces, indexPath: indexPath))
//            }
//            .disposed(by: self.disposeBag)
        
        self.meloPlaces
            .subscribe { [weak self] meloPlaces in
                guard let self = self, let indexPath = self.indexPath else { return }
                output.dataSource.accept((meloPlaces: meloPlaces, indexPath: indexPath))
//                output.dataSource.accept(meloPlaces)
            }
            .disposed(by: self.disposeBag)
        
//        self.meloPlace
//            .withUnretained(self)
//            .subscribe(onNext: { owner, meloPlace in
//                guard let meloPlace = meloPlace else { return }
//                output.meloPlace.accept(meloPlace)
//                output.mapCoordinate.accept(
//                    CLLocationCoordinate2D(
//                        latitude: meloPlace.latitude,
//                        longitude: meloPlace.longitude
//                    )
//                )
//            })
//            .disposed(by: self.disposeBag)
        
        self.spotifyService.isPaused
            .bind(to: output.isPaused)
            .disposed(by: self.disposeBag)
        
        return output
    }
}

private extension MeloPlaceDetailViewModel {
    func drawAnnotation(with center: CLLocationCoordinate2D, on snapshot: MKMapSnapshotter.Snapshot) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(snapshot.image.size, true, snapshot.image.scale)
        snapshot.image.draw(at: .zero)
        
        let point = snapshot.point(for: center)
        let annotation = PointAnnotation(uuid: nil, memoryDate: nil, latitude: center.latitude, longitude: center.longitude)
        
        let annotationView = AnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
        let rect = CGRect(x: point.x - (annotationView.bounds.width / 2),
                          y: point.y - (annotationView.bounds.height / 2),
                          width: annotationView.bounds.width,
                          height: annotationView.bounds.height)
        
        annotationView.drawHierarchy(in: rect, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

extension MeloPlaceDetailViewModel {
    func playMusic(uri: String) {
        self.spotifyService.playMusic(uri: uri)
    }
    
}
