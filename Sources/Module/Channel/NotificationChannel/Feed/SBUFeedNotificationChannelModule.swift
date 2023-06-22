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
public class SBUFeedNotificationChannelModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUFeedNotificationChannelModule.Header.Type = SBUFeedNotificationChannelModule.Header.self
    /// The module component that shows the list of notifications in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUFeedNotificationChannelModule.List.Type = SBUFeedNotificationChannelModule.List.self
    
    /// The module component that contains `titleView`, `leftBarButtons`, and `rightBarButtons`
    @available(*, deprecated, message: "Use `SBUFeedNotificationChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUFeedNotificationChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of notifications in the channel.
    @available(*, deprecated, message: "Use `SBUFeedNotificationChannelModule.ListComponent` instead.")
    public var listComponent: SBUFeedNotificationChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUFeedNotificationChannelModule.Header?
    private var _listComponent: SBUFeedNotificationChannelModule.List?
    
    @available(*, deprecated, message: "Use `SBUModuleSet.FeedNotificationChannelModule`")
    public required init(
        _headerComponent: SBUFeedNotificationChannelModule.Header? = nil,
        _listComponent: SBUFeedNotificationChannelModule.List? = nil
    ) {
        self._headerComponent = _headerComponent
        self._listComponent = _listComponent
    }
}
