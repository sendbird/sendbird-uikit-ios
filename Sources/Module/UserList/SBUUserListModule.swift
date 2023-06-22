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
open class SBUUserListModule {
    /// The module component that contains ``SBUUserListModule/Header/titleView``, ``SBUUserListModule/Header/leftBarButton``, and ``SBUUserListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUUserListModule.Header.Type = SBUUserListModule.Header.self
    /// The module component that shows the list of users.
    /// - Since: 3.6.0
    public static var ListComponent: SBUUserListModule.List.Type = SBUUserListModule.List.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the title according to the type of user list.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the add button. (The button is set or not set according to the type of user list.)
    @available(*, deprecated, message: "Use `SBUUserListModule.HeaderComponent` instead.")
    public var headerComponent: SBUUserListModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of users.
    @available(*, deprecated, message: "Use `SBUUserListModule.ListComponent` instead.")
    public var listComponent: SBUUserListModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUUserListModule.Header?
    private var _listComponent: SBUUserListModule.List?
    
    // MARK: -
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupUserListModule` or `SBUModuleSet.OpenUserListModule`")
    public required init(headerComponent: SBUUserListModule.Header? = nil,
                listComponent: SBUUserListModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
