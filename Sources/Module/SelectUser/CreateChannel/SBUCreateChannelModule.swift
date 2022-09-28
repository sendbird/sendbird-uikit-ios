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
open class SBUCreateChannelModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses `SBUStringSet.CreateChannel_Header_Select_Members`
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Creates a new channel and uses `SBUStringSet.CreateChannel_Create(_:)` as its title.
    public var headerComponent: SBUCreateChannelModule.Header? {
        get { _headerComponent ?? SBUCreateChannelModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of users to create a new channel.
    public var listComponent: SBUCreateChannelModule.List? {
        get { _listComponent ?? SBUCreateChannelModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateChannelModule.Header?
    private var _listComponent: SBUCreateChannelModule.List?
    
    
    // MARK: -
    public init(headerComponent: SBUCreateChannelModule.Header? = nil,
                listComponent: SBUCreateChannelModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

