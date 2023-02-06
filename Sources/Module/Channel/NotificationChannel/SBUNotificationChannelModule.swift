//
//  SBUNotificationChannelModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUNotificationChannelModule

/// The class that represents the notification channel module
open class SBUNotificationChannelModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButtons`, and `rightBarButtons`
    public var headerComponent: SBUNotificationChannelModule.Header? {
        get { _headerComponent ?? SBUNotificationChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of notifications in the channel.
    public var listComponent: SBUNotificationChannelModule.List? {
        get { _listComponent ?? SBUNotificationChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUNotificationChannelModule.Header?
    private var _listComponent: SBUNotificationChannelModule.List?
    
    public init(
        _headerComponent: SBUNotificationChannelModule.Header? = nil,
        _listComponent: SBUNotificationChannelModule.List? = nil
    ) {
        self._headerComponent = _headerComponent
        self._listComponent = _listComponent
    }
}

