//
//  SBUMemberListModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMemberListModule

/// The class that represents the module for multiple types of the member list.
public class SBUMemberListModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the title according to the type of member list.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Shows the add button. (The button is set or not set according to the type of member list.)
    public var headerComponent: SBUMemberListModule.Header? {
        get { _headerComponent ?? SBUMemberListModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of members.
    public var listComponent: SBUMemberListModule.List? {
        get { _listComponent ?? SBUMemberListModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMemberListModule.Header?
    private var _listComponent: SBUMemberListModule.List?
    
    
    // MARK: -
    /// Initializes module with components.
    public init(headerComponent: SBUMemberListModule.Header? = nil,
                listComponent: SBUMemberListModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

