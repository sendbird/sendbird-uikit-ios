//
//  SBUGroupChannelListComponent.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: GroupChannelListModule

/// The class that represents the list of the group channel module
open class SBUGroupChannelListModule {
    // MARK: Properties (Public)
    
    /// The module component that contains `titleView`, `leftBarButton`, and `rightBarButton`
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses `SBUStringSet.ChannelList_Header_Title`
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows a view controller creating a new group channel.
    public var headerComponent: SBUGroupChannelListModule.Header? {
        get { _headerComponent ?? SBUGroupChannelListModule.Header() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the channel.
    public var listComponent: SBUGroupChannelListModule.List? {
        get { _listComponent ?? SBUGroupChannelListModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUGroupChannelListModule.Header?
    private var _listComponent: SBUGroupChannelListModule.List?
    
    
    // MARK: - 
    public init(headerComponent: SBUGroupChannelListModule.Header? = nil,
                listComponent: SBUGroupChannelListModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
