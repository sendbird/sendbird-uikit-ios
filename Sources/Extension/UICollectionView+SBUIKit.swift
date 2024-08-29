//
//  UICollectionView+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 7/3/24.
//

import UIKit

final class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var rightMargin = collectionView?.bounds.width ?? 0 - sectionInset.right
        var maxY: CGFloat = -1.0
        
        let attribute = UIView.appearance().semanticContentAttribute
        let isRTL = UIView.userInterfaceLayoutDirection(for: attribute) == .rightToLeft
        
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
                rightMargin = collectionView?.bounds.width ?? 0 - sectionInset.right
            }
            
            if isRTL {
                layoutAttribute.frame.origin.x = rightMargin - layoutAttribute.frame.width
                rightMargin -= layoutAttribute.frame.width + minimumInteritemSpacing
            } else {
                layoutAttribute.frame.origin.x = leftMargin
                leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            }
            
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}

final class SBUWrappingCollectionView: UICollectionView {
    override func reloadData() {
        super.reloadData()

        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }

    override var intrinsicContentSize: CGSize { contentSize }

    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }
}
