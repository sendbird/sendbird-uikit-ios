//
//  SBUUserListModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUUserListModule

/// The class that represents the module for multiple types of the user list.
extension SBUUserListModule {
    /// The module component that contains ``SBUUserListModule/Header/titleView``, ``SBUUserListModule/Header/leftBarButton``, and ``SBUUserListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUUserListModule.Header.Type = SBUUserListModule.Header.self
    /// The module component that shows the list of users.
    /// - Since: 3.6.0
    public static var ListComponent: SBUUserListModule.List.Type = SBUUserListModule.List.self
}

// MARK: Header
extension SBUUserListModule.Header {
    /// Represents the metatype of left bar button in ``SBUUserListModule.Header``.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the metatype of title view in ``SBUUserListModule.Header``.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
    
    /// Represents the metatype of right bar button in ``SBUUserListModule.Header``.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
}

// MARK: List
extension SBUUserListModule.List {
    /// Represents the type of empty view on the user list module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of user cell on the user list module.
    /// - Since: 3.28.0
    public static var UserCell: SBUUserCell.Type = SBUUserCell.self
}
