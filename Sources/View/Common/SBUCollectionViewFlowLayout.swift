//
//  SBUCollectionViewFlowLayout.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/06/04.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Emoji reaction bar cell flowLayout
class SBUCollectionViewFlowLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return false
    }

     override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)?
            .compactMap { $0.copy() as? UICollectionViewLayoutAttributes } ?? []
        guard scrollDirection == .vertical else { return layoutAttributes }

        // Filter attributes to compute only cell attributes
        let cellAttributes = layoutAttributes.filter { $0.representedElementCategory == .cell }

        // Group cell attributes by row (cells with same vertical center) and loop on those groups
        Dictionary(grouping: cellAttributes, by: { ($0.center.y / 10).rounded(.up) })
            .forEach { _, attributes in

            // Set the initial left inset
            var leftInset = sectionInset.left

            // Loop on cells to adjust each cell's origin and prepare leftInset for the next cell
            for attribute in attributes {
                attribute.frame.origin.x = leftInset
                leftInset = attribute.frame.maxX + minimumInteritemSpacing
            }
        }

        return layoutAttributes
    }
}
