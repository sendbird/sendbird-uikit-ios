//
//  SBUChatNotificationChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUChatNotificationChannelModule

/// The class that represents the group channel module
extension SBUChatNotificationChannelModule {
    // MARK: Properties (Public)
    /// The module component that represents navigation bar title and bar buttons.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUChatNotificationChannelModule.Header.Type = SBUChatNotificationChannelModule.Header.self
    /// The module component that shows the list of message in the group channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUChatNotificationChannelModule.List.Type = SBUChatNotificationChannelModule.List.self
}

// MARK: Header
extension SBUChatNotificationChannelModule.Header {
    
}

// MARK: List
extension SBUChatNotificationChannelModule.List {
    
}
