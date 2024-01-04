//
//  AnnotationView.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/25.
//

import Foundation
import MapKit
import Kingfisher

final class PointAnnotation: MKPointAnnotation {
    let uuid: String?
    let date: Date?
    weak var annotationView: AnnotationView?
    var imageURLString: String?
    
    required init(uuid: String?, memoryDate: Date?, imageURLString: String,  latitude: Double, longitude: Double) {
        self.uuid = uuid
        self.date = memoryDate
        super.init()
        
        if let memoryDateString = memoryDate?.toString() {
            title = memoryDateString
        }
        
        self.imageURLString = imageURLString
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

final class AnnotationView: MKAnnotationView {
    lazy var imageView: UIImageView = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // frame 설정
        let cornerRadius = 50.0 / 2
        view.layer.cornerRadius = cornerRadius
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.layer.borderColor = UIColor.themeColor300?.cgColor
        view.layer.borderWidth = 1.5
        return view
    }()
    
    private let detailButton = {
        let detailButton = UIButton(type: .detailDisclosure)
        detailButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        detailButton.tintColor = .themeColor300
        return detailButton
    }()

    override var annotation: MKAnnotation? {
        didSet {
            (annotation as? PointAnnotation)?.annotationView = self
        }
    }

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configure()
        update(for: annotation)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        centerOffset = CGPoint(x: 0, y: frame.size.height / 2)
        self.canShowCallout = true
//        self.clipsToBounds = true
        self.bounds.size = .init(width: 50, height: 50)
        rightCalloutAccessoryView = detailButton
        self.addSubview(self.imageView)
    }

    func update(for annotation: MKAnnotation?) {
        guard
                let annotation = annotation as? PointAnnotation,
                let imageURLString = annotation.imageURLString
        else { return }
        
        self.setImage(imageURLString: imageURLString)
//        self.image = self.imageView.image
    }
    
    func setImage(imageURLString: String) {
        let url = URL(string: imageURLString)
        let size = CGSize(width: 100, height: 100)
        let downSampling = DownsamplingImageProcessor(size: size)
        self.imageView.kf.setImage(with: url,options: [.processor(downSampling)])
    }
}
