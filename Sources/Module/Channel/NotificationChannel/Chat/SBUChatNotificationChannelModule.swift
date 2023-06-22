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
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUChatNotificationChannelModule.Header.Type = SBUChatNotificationChannelModule.Header.self
    /// The module component that shows the list of message in the group channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUChatNotificationChannelModule.List.Type = SBUChatNotificationChannelModule.List.self
    
    /// The module component that represents navigation bar such  as `titleView`, `leftBarButton`, and `rightBarButton`
    @available(*, deprecated, message: "Use `SBUChatNotificationChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUChatNotificationChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the group channel.
    @available(*, deprecated, message: "Use `SBUChatNotificationChannelModule.ListComponent` instead.")
    public var listComponent: SBUChatNotificationChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUChatNotificationChannelModule.Header?
    private var _listComponent: SBUChatNotificationChannelModule.List?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.ChatNotificationChannelModule`")
    public required init(
        headerComponent: SBUChatNotificationChannelModule.Header? = nil,
        listComponent: SBUChatNotificationChannelModule.List? = nil
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
}
