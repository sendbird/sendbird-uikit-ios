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
open class SBUMessageSearchModule {
    /// The module component that contains ``SBUMessageSearchModule/Header/titleView``, ``SBUMessageSearchModule/Header/leftBarButton``, and ``SBUMessageSearchModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageSearchModule.Header.Type = SBUMessageSearchModule.Header.self
    /// The module component that shows the list of searched message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageSearchModule.List.Type = SBUMessageSearchModule.List.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the search bar
    /// - `leftBarButton`: Not set.
    /// - `rightBarButton`: Not set.
    @available(*, deprecated, message: "Use `SBUMessageSearchModule.HeaderComponent` instead.")
    public var headerComponent: SBUMessageSearchModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of searched message in the channel.
    @available(*, deprecated, message: "Use `SBUMessageSearchModule.ListComponent` instead.")
    public var listComponent: SBUMessageSearchModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMessageSearchModule.Header?
    private var _listComponent: SBUMessageSearchModule.List?
    
    // MARK: -
    
    /// Initializes module with components.
    @available(*, deprecated, message: "Use `SBUModuleSet.MessageSearchModule")
    public required init(headerComponent: SBUMessageSearchModule.Header? = nil,
                listComponent: SBUMessageSearchModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
