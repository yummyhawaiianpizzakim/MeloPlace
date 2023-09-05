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

    lazy var pinImage: UIImage? = {
        let image = UIImage(systemName: "circle.circle.fill")?.resize(size: .init(width: 20, height: 20))
        return image
    }()

    required init(uuid: String?, memoryDate: Date?, latitude: Double, longitude: Double) {
        self.uuid = uuid
        date = memoryDate
        super.init()

        if let memoryDateString = memoryDate?.toString() {
            title = memoryDateString
        }
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

final class AnnotationView: MKAnnotationView {
    private let detailButton = {
        let detailButton = UIButton(type: .detailDisclosure)
        detailButton.setImage(UIImage(systemName: "mappin.and.ellipse"), for: .normal)
        detailButton.tintColor = .red
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
        centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
        canShowCallout = true
        rightCalloutAccessoryView = detailButton
    }

    func update(for annotation: MKAnnotation?) {
        guard let pinImage = (annotation as? PointAnnotation)?.pinImage,
              let imageData = pinImage.pngData() else {
            return
        }

        let newWidth: CGFloat = 10.0
        let ratio = newWidth / pinImage.size.width
        let newHeight = pinImage.size.height * ratio
        let size = CGSize(width: newWidth, height: newHeight)
        self.image = UIImage(data: imageData, scale: 2.0)?.resize(size: size)
        
    }
}
