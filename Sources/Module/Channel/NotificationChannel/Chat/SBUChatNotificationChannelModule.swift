//
//  SBUChatNotificationChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUChatNotificationChannelModule

/// The class that represents the group channel module
public class SBUChatNotificationChannelModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - NOTE: The default function of each button is as below:
    ///     - `title`: Shows the group channel name
    ///     - `leftBarButton`: Goes back to the previous view.
    ///     - `rightBarButton`: Shows the group channel settings.
    public var headerComponent: (SBUChatNotificationChannelModule.Header)? {
        get { _headerComponent ?? SBUChatNotificationChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the group channel.
    public var listComponent: (SBUChatNotificationChannelModule.List)? {
        get { _listComponent ?? SBUChatNotificationChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: (SBUChatNotificationChannelModule.Header)?
    private var _listComponent: (SBUChatNotificationChannelModule.List)?
    
    // MARK: -
    public init(
        headerComponent: (SBUChatNotificationChannelModule.Header)? = nil,
        listComponent: (SBUChatNotificationChannelModule.List)? = nil
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

