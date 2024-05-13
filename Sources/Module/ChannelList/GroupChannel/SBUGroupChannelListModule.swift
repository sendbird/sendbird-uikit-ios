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
extension SBUGroupChannelListModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelListModule/Header/titleView``, ``SBUBaseChannelListModule/Header/leftBarButton``, and ``SBUBaseChannelListModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelListModule.Header.Type = SBUGroupChannelListModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelListModule.List.Type = SBUGroupChannelListModule.List.self
}

// MARK: Header
extension SBUGroupChannelListModule.Header {
    
}

// MARK: List
extension SBUGroupChannelListModule.List {
    
}
