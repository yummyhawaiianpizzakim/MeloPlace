//
//  MeloPlaceViewModel.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import MapKit
import RxSwift
import RxRelay

class MeloPlaceDetailViewModel {
    let disposeBag = DisposeBag()
    
    let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
    
    struct Input {
        
    }
    
    struct Output {
        let meloPlace = BehaviorRelay<MeloPlace?>(value: nil)
        let mapCoordinate = PublishRelay<CLLocationCoordinate2D>()
        let mapSnapshot = PublishRelay<UIImage>()

    }
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        guard let meloPlace = self.meloPlace.value else { return output }
        
        self.meloPlace
            .withUnretained(self)
            .subscribe(onNext: { owner, meloPlace in
                guard let meloPlace = meloPlace else { return }
                output.meloPlace.accept(meloPlace)
                output.mapCoordinate.accept(
                    CLLocationCoordinate2D(
                        latitude: meloPlace.latitude,
                        longitude: meloPlace.longitude
                    )
                )
                
            })
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
