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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the title according to the type of user list.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the add button. (The button is set or not set according to the type of user list.)
    public var headerComponent: SBUUserListModule.Header? {
        get { _headerComponent ?? SBUUserListModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of users.
    public var listComponent: SBUUserListModule.List? {
        get { _listComponent ?? SBUUserListModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUUserListModule.Header?
    private var _listComponent: SBUUserListModule.List?
    
    
    // MARK: -
    /// Initializes module with components.
    public init(headerComponent: SBUUserListModule.Header? = nil,
                listComponent: SBUUserListModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

