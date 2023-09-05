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
        let verticalInsets = CGFloat(0)
//        let verticalInsets = (collectionView.frame.height - collectionView.adjustedContentInset.top - collectionView.adjustedContentInset.bottom - itemSize.height) / 2
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

class CarouselCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    var sideItemScale: CGFloat = 0.5
    var sideItemAlpha: CGFloat = 0.5
    var spacing: CGFloat = 10
    
    private var isSetup: Bool = false
    
    override func prepare() {
        super.prepare()
        if isSetup == false {
            setupLayout()
            isSetup = true
        }
    }
    
    private func setupLayout() {
        guard let collectionView = self.collectionView else {
            return
        }
        
        collectionView.decelerationRate = .fast
        
        let collectionViewSize = collectionView.bounds.size
        
        itemSize = CGSize(width: 216.0, height: 216.0)
        
        let xInset = (collectionViewSize.width - self.itemSize.width) / 2
        let yInset = (collectionViewSize.height - self.itemSize.height) / 2
        
        self.sectionInset = UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
        
        let itemWidth = self.itemSize.width
        
        let scaledItemOffset = (itemWidth - itemWidth * self.sideItemScale) / 2
        self.minimumLineSpacing = spacing - scaledItemOffset
        
        self.scrollDirection = .horizontal
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let superAttributes = super.layoutAttributesForElements(in: rect),
              let attributes = NSArray(array: superAttributes, copyItems: true) as? [UICollectionViewLayoutAttributes]
        else {
            return nil
        }
        
        return attributes.map({ self.transformLayoutAttributes(attributes: $0) })
    }
    
    private func transformLayoutAttributes(attributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        guard let collectionView = self.collectionView else {
            return attributes
        }
        
        let collectionCenter = collectionView.frame.size.width / 2
        let contentOffset = collectionView.contentOffset.x
        let center = attributes.center.x - contentOffset
        
        let maxDistance = self.itemSize.width + self.minimumLineSpacing
        let distance = min(abs(collectionCenter - center), maxDistance)
        
        let ratio = (maxDistance - distance) / maxDistance
        
        let alpha = ratio * (1 - self.sideItemAlpha) + self.sideItemAlpha
        let scale = ratio * (1 - self.sideItemScale) + self.sideItemScale
        
        attributes.alpha = alpha
        
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let dist = attributes.frame.midX - visibleRect.midX
        var transform = CATransform3DScale(CATransform3DIdentity, scale, scale, 1)
        transform = CATransform3DTranslate(transform, 0, 0, -abs(dist / 1000))
        attributes.transform3D = transform
        
        return attributes
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = self.collectionView else {
            let latestOffset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
            return latestOffset
        }
        
        let targetRect = CGRect(x: proposedContentOffset.x, y: 0, width: collectionView.frame.width, height: collectionView.frame.height)
        guard let rectAttributes = super.layoutAttributesForElements(in: targetRect) else {
            return .zero
        }
        
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
}

class HSCycleGalleryViewLayout: UICollectionViewFlowLayout {
    
    var itemWidth: CGFloat = 250
    var itemHeight: CGFloat = 400
    
    override func prepare() {
        super.prepare()
        
        self.itemSize = CGSize(width: itemWidth, height: itemHeight)
        self.scrollDirection = .horizontal
        // 下面 layoutAttributesForElements 中将item scale变换后，自然有空隙了
        self.minimumInteritemSpacing = 0
        self.minimumLineSpacing = 0
        
        // 为了让第一张图片与最后一张图片出现在最中央
        let left = (self.collectionView!.bounds.width - itemWidth) / 2
        let top = (self.collectionView!.bounds.height - itemHeight) / 2
//        let top = CGFloat(20)
        self.sectionInset = UIEdgeInsets.init(top: top, left: left, bottom: top, right: left)
        
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let array = super.layoutAttributesForElements(in: rect)
        let visiableRect = CGRect(x: self.collectionView!.contentOffset.x,
                                  y: self.collectionView!.contentOffset.y,
                                  width: self.collectionView!.frame.width,
                                  height: self.collectionView!.frame.height)
        
        // 当前屏幕中点，相对于collect view上的x坐标
        let centerX = self.collectionView!.contentOffset.x + self.collectionView!.bounds.width / 2
        
        for attributes in array! {
            if !visiableRect.intersects(attributes.frame) { continue }
            
            let offsetCenterX = abs(attributes.center.x - centerX)
            let scale = max(1 - offsetCenterX / self.collectionView!.bounds.width * 0.4, 0.8)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        
        return array
    }
    
    /// 用来设置collectionView停止滚动那一刻的位置(实现目的是当停止滑动，时刻有一张图片是位于屏幕最中央的)
    override func targetContentOffset(forProposedContentOffset
        proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y,
                              width: self.collectionView!.bounds.width,
                              height: self.collectionView!.bounds.height)
        // 当前屏幕中点，相对于collect view上的x坐标
        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width * 0.5;
        let array = self.layoutAttributesForElements(in: lastRect)
        
        //需要移动的距离
        var adjustOffsetX = CGFloat(MAXFLOAT);
        for attri in array! {
            //每个单元格里中点的偏移量
            let deviation = attri.center.x - centerX
            //保存偏移最小的那个
            if abs(deviation) < abs(adjustOffsetX) {
                adjustOffsetX = deviation
            }
        }
        
        //이거만 새로 추가
        let pageWidth = itemWidth + self.minimumLineSpacing
        let currentPage = round(proposedContentOffset.x / pageWidth)
        let targetX = (currentPage + ((velocity.x > 0) ? 1 : (velocity.x < 0 ? -1 : 0))) * pageWidth
        return CGPoint(x: targetX - self.collectionView!.contentInset.left, y: proposedContentOffset.y)


        // 通过偏移量返回最终停留的位置
//        return CGPoint(x: proposedContentOffset.x + adjustOffsetX, y: proposedContentOffset.y)
    }
    
//    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: self.collectionView!.bounds.width, height: self.collectionView!.bounds.height)
//        let centerX = proposedContentOffset.x + self.collectionView!.bounds.width * 0.5
//        let array = self.layoutAttributesForElements(in: lastRect)
//
//        var minCenterXDistance = CGFloat(MAXFLOAT)
//        for attributes in array! {
//            let centerXDistance = attributes.center.x - centerX
//
//            // attributes.center.x - centerX 의 거리가 가장 가까운 cell의 거리로 새로 지정합니다.
//            if abs(centerXDistance) < abs(minCenterXDistance) {
//                minCenterXDistance = centerXDistance
//            }
//        }
//
//        // itemWidth의 반만큼 오른쪽에 있으면 다음 페이지로 이동
//        // itemWidth의 반만큼 왼쪽에 있으면 이전 페이지로 이동
//        // UICollectionViewFlowLayout의 swift 문서 대로 -velocity.x 를 곱합니다.
//        let pageWidth = itemWidth + self.minimumLineSpacing
//        let currentPage = (proposedContentOffset.x.sorted(to: { $0 < $1 }) + (pageWidth / 2)) / pageWidth
//        let targetX = (currentPage + ((velocity.x > 0) ? 1 : (velocity.x < 0 ? -1 : 0))) * pageWidth
//        return CGPoint(x: targetX - self.collectionView!.contentInset.left, y: proposedContentOffset.y)
//    }

}
