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
extension SBUOpenChannelListModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelListModule.Header.Type = SBUOpenChannelListModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelListModule.List.Type = SBUOpenChannelListModule.List.self
}

// MARK: Header
extension SBUOpenChannelListModule.Header {
    
}

// MARK: List
extension SBUOpenChannelListModule.List {
    
}
