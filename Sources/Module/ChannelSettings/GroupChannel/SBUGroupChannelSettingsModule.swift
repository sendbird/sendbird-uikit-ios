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
    /// Represents the metatype of left bar button on the group channel settings module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the metatype of right bar button on the group channel settings module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the metatype of title view on the group channel settings module.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
}

// MARK: List
extension SBUGroupChannelSettingsModule.List {
    
    /// Represents the metatype of channel info view on the group channel settings module.
    /// - Since: 3.28.0
    public static var ChannelInfoView: SBUChannelSettingsChannelInfoView.Type = SBUChannelSettingsChannelInfoView.self
    
    /// Represents the metatype of setting cell on the group channel settings module.
    /// - Since: 3.28.0
    public static var SettingCell: SBUGroupChannelSettingCell.Type = SBUGroupChannelSettingCell.self
}
