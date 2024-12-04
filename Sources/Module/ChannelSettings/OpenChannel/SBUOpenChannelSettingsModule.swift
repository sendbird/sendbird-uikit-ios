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
extension SBUOpenChannelSettingsModule {
    /// The module component that contains ``SBUBaseChannelSettingsModule/Header/titleView``, ``SBUBaseChannelSettingsModule/Header/leftBarButton``, and ``SBUBaseChannelSettingsModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelSettingsModule.Header.Type = SBUOpenChannelSettingsModule.Header.self
    /// The module component that shows the list of setting menus in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelSettingsModule.List.Type = SBUOpenChannelSettingsModule.List.self
}

// MARK: Header
extension SBUOpenChannelSettingsModule.Header {
    /// Represents the type of left bar button on the open channel settings module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the open channel settings module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the open channel settings module.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
}

// MARK: List
extension SBUOpenChannelSettingsModule.List {
    /// Represents the type of channel info view on the open channel settings module.
    /// - Since: 3.28.0
    public static var ChannelInfoView: SBUChannelSettingsChannelInfoView.Type = SBUChannelSettingsChannelInfoView.self
    
    /// Represents the type of setting cell on the open channel settings module.
    /// - Since: 3.28.0
    public static var SettingCell: SBUOpenChannelSettingCell.Type = SBUOpenChannelSettingCell.self
}
