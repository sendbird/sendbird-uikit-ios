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
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUCreateChannelModule.Header.Type = SBUCreateChannelModule.Header.self
    /// The module component that shows the list of users to create a new channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUCreateChannelModule.List.Type = SBUCreateChannelModule.List.self
    
    // MARK: Properties (Public)
    
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton``, and ``SBUBaseSelectUserModule/Header/rightBarButton``.
    /// 
    /// - The default function of each button is as below:
    ///   - `title`: Shows the title that uses ``SBUStringSet/CreateChannel_Header_Select_Members`` in ``SBUStringSet``
    ///   - `leftBarButton`: Goes back to the previous view.
    /// - `rightBarButton`: Creates a new channel and uses  ``SBUStringSet/CreateChannel_Create`` in ``SBUStringSet`` as its title.
    @available(*, deprecated, message: "Use `SBUCreateChannelModule.HeaderComponent` instead.")
    public var headerComponent: SBUCreateChannelModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    
    /// The module component that shows the list of users to create a new channel.
    @available(*, deprecated, message: "Use `SBUCreateChannelModule.ListComponent` instead.")
    public var listComponent: SBUCreateChannelModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUCreateChannelModule.Header?
    private var _listComponent: SBUCreateChannelModule.List?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.CreateGroupChannelModule`")
    public required init(headerComponent: SBUCreateChannelModule.Header? = nil,
                listComponent: SBUCreateChannelModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
