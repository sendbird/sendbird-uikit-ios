//
//  SBUBaseChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUBaseChannelModule

/// The class that represents the base of the channel module
extension SBUBaseChannelModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton`` and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUBaseChannelModule.Header.Type = SBUBaseChannelModule.Header.self
    /// The module component that shows the list of message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUBaseChannelModule.List.Type = SBUBaseChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUBaseChannelModule.Input.Type = SBUBaseChannelModule.Input.self
}

// MARK: Header
extension SBUBaseChannelModule.Header {
    
}

// MARK: List
extension SBUBaseChannelModule.List {
    
}

// MARK: Input
extension SBUBaseChannelModule.Input {
    
}
