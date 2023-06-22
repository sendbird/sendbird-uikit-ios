//
//  SBUGroupChannelPushSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUGroupChannelPushSettingsModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelPushSettingsModule.Header.Type = SBUGroupChannelPushSettingsModule.Header.self
    /// The module component that shows the list of push setting options
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelPushSettingsModule.List.Type = SBUGroupChannelPushSettingsModule.List.self
    
    @available(*, deprecated, message: "Use `SBUGroupChannelPushSettingsModule.HeaderComponent` instead.")
    public var headerComponent: SBUGroupChannelPushSettingsModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    @available(*, deprecated, message: "Use `SBUGroupChannelPushSettingsModule.ListComponent` instead.")
    public var listComponent: SBUGroupChannelPushSettingsModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Private)
    private var _headerComponent: SBUGroupChannelPushSettingsModule.Header?
    private var _listComponent: SBUGroupChannelPushSettingsModule.List?
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelPushSettingsModule`")
    public required init(
        headerComponent: SBUGroupChannelPushSettingsModule.Header? = nil,
        listComponent: SBUGroupChannelPushSettingsModule.List? = nil
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
}
