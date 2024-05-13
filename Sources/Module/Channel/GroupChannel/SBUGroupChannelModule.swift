//
//  SBUGroupChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUGroupChannelModule

/// The class that represents the group channel module
extension SBUGroupChannelModule {
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelModule.Header.Type = SBUGroupChannelModule.Header.self
    /// The module component that shows the list of message in the group channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelModule.List.Type = SBUGroupChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUGroupChannelModule.Input.Type = SBUGroupChannelModule.Input.self
}

// MARK: Header
extension SBUGroupChannelModule.Header {
    
}

// MARK: List
extension SBUGroupChannelModule.List {
    
}

// MARK: Input
extension SBUGroupChannelModule.Input {
    
}
