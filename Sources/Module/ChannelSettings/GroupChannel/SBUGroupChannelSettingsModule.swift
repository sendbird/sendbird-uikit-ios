//
//  SBUGroupChannelSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUGroupChannelSettingsModule

/// The class that represents the group channel setting module.
open class SBUGroupChannelSettingsModule {
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelSettingsModule.Header.Type = SBUGroupChannelSettingsModule.Header.self
    /// The module component that shows the list of setting menus in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelSettingsModule.List.Type = SBUGroupChannelSettingsModule.List.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    ///
    /// The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/ChannelSettings_Header_Title`` in ``SBUStringSet``
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the channel edits menu and uses ``SBUStringSet/Edit`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUGroupChannelSettingsModule.HeaderComponent` instead.")
    public var headerComponent: SBUGroupChannelSettingsModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of setting menus in the channel.
    @available(*, deprecated, message: "Use `SBUGroupChannelSettingsModule.ListComponent` instead.")
    public var listComponent: SBUGroupChannelSettingsModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUGroupChannelSettingsModule.Header?
    private var _listComponent: SBUGroupChannelSettingsModule.List?
    
    // MARK: -
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupChannelSettingsModule`")
    public required init(headerComponent: SBUGroupChannelSettingsModule.Header? = nil,
                listComponent: SBUGroupChannelSettingsModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
