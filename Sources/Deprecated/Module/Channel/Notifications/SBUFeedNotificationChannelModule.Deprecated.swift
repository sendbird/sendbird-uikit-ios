//
//  SBUFeedNotificationChannelModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// The class that represents the notification channel module
public class SBUFeedNotificationChannelModule {
    /// The module component that contains `titleView`, `leftBarButtons`, and `rightBarButtons`
    @available(*, deprecated, message: "Use `SBUFeedNotificationChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUFeedNotificationChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    /// The module component that shows the list of notifications in the channel.
    @available(*, deprecated, message: "Use `SBUFeedNotificationChannelModule.ListComponent` instead.")
    public var listComponent: SBUFeedNotificationChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUFeedNotificationChannelModule.Header?
    private var _listComponent: SBUFeedNotificationChannelModule.List?
    
    /// Default initializer
    public required init() {}
    
    // swiftlint:disable missing_docs
    // swiftlint:disable identifier_name
    @available(*, deprecated, message: "Use `SBUModuleSet.FeedNotificationChannelModule`")
    public required init(
        _headerComponent: SBUFeedNotificationChannelModule.Header?
    ) {
        self._headerComponent = _headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.FeedNotificationChannelModule`")
    public required init(
        _listComponent: SBUFeedNotificationChannelModule.List?
    ) {
        self._listComponent = _listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.FeedNotificationChannelModule`")
    public required init(
        _headerComponent: SBUFeedNotificationChannelModule.Header?,
        _listComponent: SBUFeedNotificationChannelModule.List?
    ) {
        self._headerComponent = _headerComponent
        self._listComponent = _listComponent
    }
    // swiftlint:enable missing_docs
    // swiftlint:enable identifier_name
}
