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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the title that uses `SBUStringSet.ChannelSettings_Header_Title`.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the channel edits menu and uses `SBUStringSet.Edit` as its title.
    public var headerComponent: SBUOpenChannelSettingsModule.Header? {
        get { _headerComponent ?? SBUOpenChannelSettingsModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of setting menus in the channel.
    public var listComponent: SBUOpenChannelSettingsModule.List? {
        get { _listComponent ?? SBUOpenChannelSettingsModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelSettingsModule.Header?
    private var _listComponent: SBUOpenChannelSettingsModule.List?
    
    
    // MARK: -
    /// Initializes module with components.
    public init(headerComponent: SBUOpenChannelSettingsModule.Header? = nil,
                listComponent: SBUOpenChannelSettingsModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

