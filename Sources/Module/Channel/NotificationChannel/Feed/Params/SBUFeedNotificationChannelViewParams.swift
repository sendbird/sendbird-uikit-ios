//
//  SBUFeedNotificationChannelViewParams.swift
//  SendbirdUIKit
//
//  Created by Jed Gyeong on 3/18/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import Foundation

/// The collection of parameters for the views in  `SBUFeedNotificationChannelViewController`.
/// - Since: 3.18.0
public struct SBUFeedNotificationChannelViewParams {
    /// - Since: 3.18.0
    public let showEmptyViewIcon: Bool
    
    public init(showEmptyViewIcon: Bool) {
        self.showEmptyViewIcon = showEmptyViewIcon
    }
}
