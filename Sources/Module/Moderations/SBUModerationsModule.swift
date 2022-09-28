//
//  SBUModerationsModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/04.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUModerationsModule

/// The class that represents the moderation module.
open class SBUModerationsModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`.
    ///
    /// The default function of each button is as below:
    /// - `title`: Shows the moderation view's title.
    /// - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Not set.
    public var headerComponent: SBUModerationsModule.Header? {
        get { _headerComponent ?? SBUModerationsModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of moderation items in the channel.
    public var listComponent: SBUModerationsModule.List? {
        get { _listComponent ?? SBUModerationsModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUModerationsModule.Header?
    private var _listComponent: SBUModerationsModule.List?
    
    
    // MARK: -
    
    /// Initializes module with components.
    public init(headerComponent: SBUModerationsModule.Header? = nil,
                listComponent: SBUModerationsModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

