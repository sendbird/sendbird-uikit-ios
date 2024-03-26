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
    /// The flag that determines whether to show the icon for the empty view.
    /// This is a boolean value where `true` means the icon will be shown and `false` means it will not.
    public let showEmptyViewIcon: Bool
    
    /// Initializes a new `SBUFeedNotificationChannelViewParams` instance.
    /// - Parameter showEmptyViewIcon: A Boolean value that determines whether to show the icon for the empty view. 
    ///   If `true`, the icon will be shown; if `false`, it will not.
    public init(showEmptyViewIcon: Bool) {
        self.showEmptyViewIcon = showEmptyViewIcon
    }
}
