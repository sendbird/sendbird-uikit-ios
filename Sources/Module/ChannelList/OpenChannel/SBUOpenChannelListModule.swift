//
//  SBUOpenChannelListModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: OpenChannelListModule

/// The class that represents the list of the open channel module
extension SBUOpenChannelListModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelListModule.Header.Type = SBUOpenChannelListModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelListModule.List.Type = SBUOpenChannelListModule.List.self
}

// MARK: Header
extension SBUOpenChannelListModule.Header {
    /// Represents the type of left bar button on the open channel list module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the open channel list module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the open channel list module.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
}

// MARK: List
extension SBUOpenChannelListModule.List {
    /// Represents the type of empty view on the open channel list module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self

    /// Represents the type of channel cell on the open channel list module.
    /// - Since: 3.28.0
    public static var ChannelCell: SBUBaseChannelCell.Type = SBUOpenChannelCell.self
}
