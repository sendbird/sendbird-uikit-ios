//
//  SBUMessageSearchModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMessageSearchModule

/// The class that represents the message search module.
extension SBUMessageSearchModule {
    /// The module component that contains ``SBUMessageSearchModule/Header/titleView``, ``SBUMessageSearchModule/Header/leftBarButton``, and ``SBUMessageSearchModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageSearchModule.Header.Type = SBUMessageSearchModule.Header.self
    /// The module component that shows the list of searched message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageSearchModule.List.Type = SBUMessageSearchModule.List.self
}

// MARK: Header
extension SBUMessageSearchModule.Header {
    /// Represents the metatype of left bar button in ``SBUMessageSearchModule.Header``.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type?
    
    /// Represents the metatype of title view in ``SBUMessageSearchModule.Header``.
    /// - Since: 3.28.0
    public static var TitleView: SBUSearchBar.Type = SBUSearchBar.self
    
    /// Represents the metatype of right bar button in ``SBUMessageSearchModule.Header``.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
}

// MARK: List
extension SBUMessageSearchModule.List {
    /// Represents the type of empty view on the message search module module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of message search result cell on the message search module module.
    /// - Since: 3.28.0
    public static var MessageSearchResultCell: SBUMessageSearchResultCell.Type = SBUMessageSearchResultCell.self
}
