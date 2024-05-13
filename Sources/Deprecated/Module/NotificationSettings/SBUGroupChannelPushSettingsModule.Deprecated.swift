//
//  SBUGroupChannelPushSettingsModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// This is the main class for the Group Channel Push Settings Module in Sendbird UIKit.
/// It handles the configuration and behavior of the push settings for group channels.
open class SBUGroupChannelPushSettingsModule {
    // swiftlint:disable missing_docs
    @available(*, deprecated, message: "Use `SBUGroupChannelPushSettingsModule.HeaderComponent` instead.")
    public var headerComponent: SBUGroupChannelPushSettingsModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    
    @available(*, deprecated, message: "Use `SBUGroupChannelPushSettingsModule.ListComponent` instead.")
    public var listComponent: SBUGroupChannelPushSettingsModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUGroupChannelPushSettingsModule.Header?
    private var _listComponent: SBUGroupChannelPushSettingsModule.List?
    
    /// Default initializer for `SBUGroupChannelPushSettingsModule`.
    /// This initializer does not take any parameters and initializes the module with default settings.
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelPushSettingsModule`")
    public required init(
        headerComponent: SBUGroupChannelPushSettingsModule.Header?
    ) {
        self._headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelPushSettingsModule`")
    public required init(
        listComponent: SBUGroupChannelPushSettingsModule.List?
    ) {
        self._listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelPushSettingsModule`")
    public required init(
        headerComponent: SBUGroupChannelPushSettingsModule.Header?,
        listComponent: SBUGroupChannelPushSettingsModule.List?
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
