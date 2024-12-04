//
//  SBUCreateChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUCreateChannelModule

/// The class that represents the module for creating a new channel.
extension SBUCreateChannelModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUCreateChannelModule.Header.Type = SBUCreateChannelModule.Header.self
    /// The module component that shows the list of users to create a new channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUCreateChannelModule.List.Type = SBUCreateChannelModule.List.self
}

// MARK: Header
extension SBUCreateChannelModule.Header {
    /// Represents the metatype of left bar button in ``SBUCreateChannelModule.Header``.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the metatype of title view in ``SBUCreateChannelModule.Header``.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
    
    /// Represents the metatype of right bar button in ``SBUCreateChannelModule.Header``.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
}

// MARK: List
extension SBUCreateChannelModule.List {
    /// Represents the type of empty view on the create channel module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of user cell on the create channel module.
    /// - Since: 3.28.0
    public static var UserCell: SBUUserCell.Type = SBUUserCell.self
}
