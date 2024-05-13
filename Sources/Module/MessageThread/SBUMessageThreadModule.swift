//
//  SBUMessageThreadModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMessageThreadModule

/// The class that represents the message thread module.
extension SBUMessageThreadModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelModule/Header/title``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageThreadModule.Header.Type = SBUMessageThreadModule.Header.self
    /// The module component that shows the list of thread message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageThreadModule.List.Type = SBUMessageThreadModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUMessageThreadModule.Input.Type = SBUMessageThreadModule.Input.self
}

// MARK: Header
extension SBUMessageThreadModule.Header {
    
}

// MARK: List
extension SBUMessageThreadModule.List {
    
}

// MARK: Input
extension SBUMessageThreadModule.Input {
    
}
