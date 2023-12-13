//
//  SBUScrollOptions.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/11/22.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Options for scroll position.
/// - Since: 3.13.0
public struct SBUScrollOptions {
    /// Message count that to process scroll position.
    public let count: Int?
    /// specific cell postion to scroll messages.
    public let position: SBUScrollPosition
    /// Indicates if scrolling is reversed.
    public let isInverted: Bool

    /// Initilizes `options`.
    /// - Parameters:
    ///   - count: Number of new messsages.
    ///   - position: Message scroll position.
    ///   - isInverted: Indicates if scrolling is inverted.
    public init(count: Int? = nil, position: SBUScrollPosition, isInverted: Bool) {
        self.count = count
        self.position = position
        self.isInverted = isInverted
    }
}

extension SBUScrollOptions {
    func row(with indexPath: IndexPath = IndexPath(row: 0, section: 0)) -> Int {
        guard let count = self.count, count > 0 else { return indexPath.row }
        guard position == .top else { return indexPath.row }
            
        let offset = max(0, count - 1)
        
        if isInverted == true {
            return max(0, indexPath.row + offset)
        } else {
            return max(0, indexPath.row - offset)
        }
    }
    
    func at() -> UITableView.ScrollPosition {
        self.position.transform(isInverted: self.isInverted)
    }
    
}
