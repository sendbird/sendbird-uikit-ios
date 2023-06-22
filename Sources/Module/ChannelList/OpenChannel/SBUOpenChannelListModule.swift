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
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelListModule.Header.Type = SBUOpenChannelListModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelListModule.List.Type = SBUOpenChannelListModule.List.self
    
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/ChannelList_Header_Title`` in ``SBUStringSet``
    ///   - `leftBarButton`: Goes back to the previous view.
    ///   - `rightBarButton`: Shows a view controller creating a new open channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelListModule.HeaderComponent` instead.")
    public var headerComponent: SBUOpenChannelListModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of message in the channel.
    @available(*, deprecated, message: "Use `SBUOpenChannelListModule.ListComponent` instead.")
    public var listComponent: SBUOpenChannelListModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUOpenChannelListModule.Header?
    private var _listComponent: SBUOpenChannelListModule.List?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.OpenChannelListModule`")
    public required init(
        headerComponent: SBUOpenChannelListModule.Header? = nil,
        listComponent: SBUOpenChannelListModule.List? = nil
    ) {
        self._headerComponent = headerComponent
        self._listComponent = listComponent
    }
}
