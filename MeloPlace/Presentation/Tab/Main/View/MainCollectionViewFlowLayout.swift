//
//  FlowLayout.swift
//  MeloPlace
//
//  Created by 김요한 on 2023/08/07.
//

import Foundation
import UIKit

class ZoomAndSnapFlowLayout: UICollectionViewFlowLayout {

    let activeDistance: CGFloat = 200
    let zoomFactor: CGFloat = 0.3

    override init() {
        super.init()

        scrollDirection = .horizontal
        minimumLineSpacing = 40
        itemSize = CGSize(width: 150, height: 150)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepare() {
        guard let collectionView = collectionView else { fatalError() }
        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
        let horizontalInsets = (collectionView.frame.width - collectionView.adjustedContentInset.right - collectionView.adjustedContentInset.left - itemSize.width) / 2
        sectionInset = UIEdgeInsets(top: verticalInsets, left: horizontalInsets, bottom: verticalInsets, right: horizontalInsets)

        super.prepare()
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = collectionView else { return nil }
        let rectAttributes = super.layoutAttributesForElements(in: rect)!.map { $0.copy() as! UICollectionViewLayoutAttributes }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.frame.size)

        // Make the cells be zoomed when they reach the center of the screen
        for attributes in rectAttributes where attributes.frame.intersects(visibleRect) {
            let distance = visibleRect.midX - attributes.center.x
            let normalizedDistance = distance / activeDistance

            if distance.magnitude < activeDistance {
                let zoom = 1 + zoomFactor * (1 - normalizedDistance.magnitude)
                attributes.transform3D = CATransform3DMakeScale(zoom, zoom, 1)
                attributes.zIndex = Int(zoom.rounded())
            }
        }

        return rectAttributes
    }

    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        guard let collectionView = collectionView else { return .zero }

        // Add some snapping behaviour so that the zoomed cell is always centered
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else { return .zero }

        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2

        for layoutAttributes in rectAttributes {
            let itemHorizontalCenter = layoutAttributes.center.x
            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
                offsetAdjustment = itemHorizontalCenter - horizontalCenter
            }
        }

        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        // Invalidate layout so that every cell get a chance to be zoomed when it reaches the center of the screen
        return true
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }

}


//class MainCollectionViewFlowLayout: UICollectionViewFlowLayout {
//
//    var sideItemScale: CGFloat = 0.5
//    var sideItemAlpha: CGFloat = 0.5
//    var spacing: CGFloat = 10
//
//    private var isSetup: Bool = false
//
//    override func prepare() {
//        super.prepare()
//        if isSetup == false {
//            setupLayout()
//            isSetup = true
//        }
//    }
//
//    private func setupLayout() {
//        guard let collectionView = self.collectionView else {
//            return
//        }
//
//        collectionView.decelerationRate = .fast
//
//
//        itemSize = CGSize(width: 216.0, height: 216)
//
////        let xInset = (collectionViewSize.width - self.itemSize.width) / 2
//        let xInset: CGFloat = 10.0
//
////        let yInset = (collectionViewSize.height - self.itemSize.height) / 2
//        let yInset: CGFloat = 10.0
//
//        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
//
//        let itemWidth = self.itemSize.width
//
//        let scaledItemOffset = (itemWidth - itemWidth * self.sideItemScale) / 2
//        self.minimumLineSpacing = spacing - scaledItemOffset
//
//        self.scrollDirection = .horizontal
//    }
//
//    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
//        return true
//    }
//
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        guard let superAttributes = super.layoutAttributesForElements(in: rect),
//              let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
//        else {
//            return nil
//        }
//
//        return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
//    }
//
//    private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
//
//        guard let collectionView = self.collectionView else {
//            return attributes
//        }
//
//        let collectionCenter = collectionView.frame.size.width / 2
//        let contentOffset = collectionView.contentOffset.x
//        let center = attributes.center.x - contentOffset
//
//        let maxDistance = self.itemSize.width + self.minimumLineSpacing
//        let distance = min(abs(collectionCenter - center), maxDistance)
//
//        let ratio = (maxDistance - distance) / maxDistance
//
//        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
//        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
//
//        attributes.alpha = alpha
//
//        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
//        let dist = attributes.frame.midX - visibleRect.midX
//        var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
//        transform = CATransform3DTranslate(transform, 0, 0, -abs(dist / 1000))
//        attributes.transform3D = transform
//
//        return attributes
//    }
//
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//
//        guard let collectionView = self.collectionView else {
//            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
//            return latestOffset
//        }
//
//        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
//        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else {
//            return .zero
//        }
//
//        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
//        let horizontalCenter = proposedContentOffset.x + collectionView.frame.width / 2
//
//        for layoutAttributes in rectAttributes {
//            let itemHorizontalCenter = layoutAttributes.center.x
//            if (itemHorizontalCenter - horizontalCenter).magnitude < offsetAdjustment.magnitude {
//                offsetAdjustment = itemHorizontalCenter - horizontalCenter
//            }
//        }
//
//        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
//    }
//}
