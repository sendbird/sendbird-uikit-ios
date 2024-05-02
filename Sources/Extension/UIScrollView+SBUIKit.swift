//
//  UIScrollView+SBUKit.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/04.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
extension UIScrollView {
    enum SBUScrollAdjustPosition {
        case first
        case middle
        case last

        init(in scrollView: UIScrollView, items: [UIView]) {
            if scrollView.contentOffset.x <= 0 {
                self = .first
            } else if scrollView.contentSize.width - scrollView.contentOffset.x <= scrollView.bounds.width {
                self = .last
            } else {
                self = .middle
            }
        }

        static func lastItemOffsetX(in scrollView: UIScrollView) -> CGFloat { scrollView.maxContentOffsetX }

        static func middleItemOffsetX(
            in scrollView: UIScrollView,
            items: [UIView],
            offset: CGFloat,
            velocityX: CGFloat
        ) -> CGFloat {
            let visibleItemsFrames = items
                .map { scrollView.convert($0.frame, from: $0.superview) }
                .filter { scrollView.bounds.intersects($0) }
                .sorted { $0.origin.x < $1.origin.x }
            
            let velocityX: CGFloat = abs(velocityX) > 0.2 ? velocityX * 100 : 0
            let scaledVelocityX = max(min(500, velocityX), -500)
            let centerPoint = CGPoint(
                x: scrollView.contentOffset.x + (scrollView.bounds.size.width / 2) + scaledVelocityX,
                y: scrollView.bounds.size.height / 2
            )
            
            let closestItem = visibleItemsFrames.min(by: { abs($0.midX - centerPoint.x) < abs($1.midX - centerPoint.x) })
            
            if let item = closestItem {
                return max(item.origin.x - offset, 0)
            } else if let firstVisibleItem = visibleItemsFrames.first {
                return firstVisibleItem.origin.x - offset
            } else {
                return scrollView.contentOffset.x - offset
            }
        }

        static func adjustContentOffsetX(
            in scrollView: UIScrollView,
            items: [UIView]? = nil,
            offset: CGFloat = 0.0,
            velocityX: CGFloat = .zero
        ) -> CGFloat {
            let items = items ?? scrollView.subviews
            
            switch Self(in: scrollView, items: items) {
            case .first:
                return 0
            case .last:
                return Self.lastItemOffsetX(in: scrollView)
            case .middle:
                let closeOffsetX = Self.middleItemOffsetX(
                    in: scrollView,
                    items: items,
                    offset: offset,
                    velocityX: velocityX
                )
                return min(closeOffsetX, scrollView.maxContentOffsetX)
            }
        }
    }
    
    fileprivate var maxContentOffsetX: CGFloat {
        max(contentSize.width - bounds.width, 0)
    }
}
