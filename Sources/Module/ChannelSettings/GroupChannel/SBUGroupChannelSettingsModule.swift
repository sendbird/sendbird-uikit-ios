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
extension SBUGroupChannelSettingsModule {
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelSettingsModule.Header.Type = SBUGroupChannelSettingsModule.Header.self
    /// The module component that shows the list of setting menus in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelSettingsModule.List.Type = SBUGroupChannelSettingsModule.List.self
}

// MARK: Header
extension SBUGroupChannelSettingsModule.Header {
    
}

// MARK: List
extension SBUGroupChannelSettingsModule.List {
    
}
