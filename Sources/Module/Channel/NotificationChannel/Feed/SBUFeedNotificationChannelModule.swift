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
    
    /// The module component that contains `titleView`, `leftBarButtons`, and `rightBarButtons`
    public var headerComponent: SBUFeedNotificationChannelModule.Header? {
        get { _headerComponent ?? SBUFeedNotificationChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of notifications in the channel.
    public var listComponent: SBUFeedNotificationChannelModule.List? {
        get { _listComponent ?? SBUFeedNotificationChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUFeedNotificationChannelModule.Header?
    private var _listComponent: SBUFeedNotificationChannelModule.List?
    
    public init(
        _headerComponent: SBUFeedNotificationChannelModule.Header? = nil,
        _listComponent: SBUFeedNotificationChannelModule.List? = nil
    ) {
        self._headerComponent = _headerComponent
        self._listComponent = _listComponent
    }
}

