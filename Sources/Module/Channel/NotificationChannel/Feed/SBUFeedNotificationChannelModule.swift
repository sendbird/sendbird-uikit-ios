//
//  SBUFeedNotificationChannelModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUFeedNotificationChannelModule

/// The class that represents the notification channel module
extension SBUFeedNotificationChannelModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUFeedNotificationChannelModule.Header.Type = SBUFeedNotificationChannelModule.Header.self
    
    /// - Since: 3.9.0
    public static var CategoryFilterComponent: SBUFeedNotificationChannelModule.CategoryFilter.Type = SBUFeedNotificationChannelModule.CategoryFilter.self
    
    /// The module component that shows the list of notifications in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUFeedNotificationChannelModule.List.Type = SBUFeedNotificationChannelModule.List.self
}

// MARK: Header
extension SBUFeedNotificationChannelModule.Header {
    
}

// MARK: CategoryFilter
extension SBUFeedNotificationChannelModule.CategoryFilter {
    
}

// MARK: List
extension SBUFeedNotificationChannelModule.List {
    
}
