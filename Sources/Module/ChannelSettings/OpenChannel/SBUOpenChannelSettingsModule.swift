//
//  SBUOpenChannelSettingsModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUOpenChannelSettingsModule

/// The class that represents the open channel setting module.
open class SBUOpenChannelSettingsModule {
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelSettingsModule.Header.Type = SBUOpenChannelSettingsModule.Header.self
    /// The module component that shows the list of setting menus in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelSettingsModule.List.Type = SBUOpenChannelSettingsModule.List.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    ///
    /// The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/ChannelSettings_Header_Title`` in ``SBUStringSet``
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the channel edits menu and uses ``SBUStringSet/Edit`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUOpenChannelSettingsModule.HeaderComponent` instead.")
    public var headerComponent: SBUOpenChannelSettingsModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of setting menus in the channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelSettingsModule.ListComponent` instead.")
    public var listComponent: SBUOpenChannelSettingsModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelSettingsModule.Header?
    private var _listComponent: SBUOpenChannelSettingsModule.List?
    
    // MARK: -
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelSettingsModule`")
    public required init(headerComponent: SBUOpenChannelSettingsModule.Header? = nil,
                listComponent: SBUOpenChannelSettingsModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
