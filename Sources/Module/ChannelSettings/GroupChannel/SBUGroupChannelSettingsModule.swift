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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the title that uses `SBUStringSet.ChannelSettings_Header_Title`.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the channel edits menu and uses `SBUStringSet.Edit` as its title.
    public var headerComponent: SBUGroupChannelSettingsModule.Header? {
        get { _headerComponent ?? SBUGroupChannelSettingsModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of setting menus in the channel.
    public var listComponent: SBUGroupChannelSettingsModule.List? {
        get { _listComponent ?? SBUGroupChannelSettingsModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUGroupChannelSettingsModule.Header?
    private var _listComponent: SBUGroupChannelSettingsModule.List?
    
    
    // MARK: -
    /// Initializes module with components.
    public init(headerComponent: SBUGroupChannelSettingsModule.Header? = nil,
                listComponent: SBUGroupChannelSettingsModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

