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
    
}

// MARK: List
extension SBUUserListModule.List {
    
}
