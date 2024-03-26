//
//  SBUGroupChannelPushSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This is the main class for the Group Channel Push Settings Module in Sendbird UIKit.
/// It handles the configuration and behavior of the push settings for group channels.
open class SBUGroupChannelPushSettingsModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelPushSettingsModule.Header.Type = SBUGroupChannelPushSettingsModule.Header.self
    /// The module component that shows the list of push setting options
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelPushSettingsModule.List.Type = SBUGroupChannelPushSettingsModule.List.self
    
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
