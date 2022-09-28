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
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the search bar
    /// - `leftBarButton`: Not set.
    /// - `rightBarButton`: Not set.
    public var headerComponent: SBUMessageSearchModule.Header? {
        get { _headerComponent ?? SBUMessageSearchModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of searched message in the channel.
    public var listComponent: SBUMessageSearchModule.List? {
        get { _listComponent ?? SBUMessageSearchModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUMessageSearchModule.Header?
    private var _listComponent: SBUMessageSearchModule.List?
    
    
    // MARK: -
    
    /// Initializes module with components.
    public init(headerComponent: SBUMessageSearchModule.Header? = nil,
                listComponent: SBUMessageSearchModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

