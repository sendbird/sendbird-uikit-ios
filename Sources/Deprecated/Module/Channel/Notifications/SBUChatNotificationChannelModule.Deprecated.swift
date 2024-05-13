//
//  SBUChatNotificationChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the group channel module
public class SBUChatNotificationChannelModule {
    /// The module component that represents navigation bar such  as `titleView`, `leftBarButton`, and `rightBarButton`
    @available(*, deprecated, message: "Use `SBUChatNotificationChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUChatNotificationChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of message in the group channel.
    @available(*, deprecated, message: "Use `SBUChatNotificationChannelModule.ListComponent` instead.")
    public var listComponent: SBUChatNotificationChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUChatNotificationChannelModule.Header?
    private var _listComponent: SBUChatNotificationChannelModule.List?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    // swiftlint:disable missing_docs
    @available(*, deprecated, message: "Use `SBUModuleSet.ChatNotificationChannelModule`")
    public required init(
        headerComponent: SBUChatNotificationChannelModule.Header?
    ) {
        self._headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.ChatNotificationChannelModule`")
    public required init(
        listComponent: SBUChatNotificationChannelModule.List?
    ) {
        self._listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.ChatNotificationChannelModule`")
    public required init(
        headerComponent: SBUChatNotificationChannelModule.Header?,
        listComponent: SBUChatNotificationChannelModule.List?
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
