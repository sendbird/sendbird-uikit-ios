//
//  SBUOpenChannelListModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: OpenChannelListModule

/// The class that represents the list of the open channel module
open class SBUOpenChannelListModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses `SBUStringSet.ChannelList_Header_Title`
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows a view controller creating a new open channel.
    public var headerComponent: SBUOpenChannelListModule.Header? {
        get { _headerComponent ?? SBUOpenChannelListModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the channel.
    public var listComponent: SBUOpenChannelListModule.List? {
        get { _listComponent ?? SBUOpenChannelListModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelListModule.Header?
    private var _listComponent: SBUOpenChannelListModule.List?
    
    
    // MARK: -
    public init(headerComponent: SBUOpenChannelListModule.Header? = nil,
                listComponent: SBUOpenChannelListModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
