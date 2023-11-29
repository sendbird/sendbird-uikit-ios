//
//  SBUTypingIndicatorInfo.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/13/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// A struct that holds information related to typing bubble message.
/// - Since: 3.12.0
public struct SBUTypingIndicatorInfo {
    public var typers: [SendbirdChatSDK.User]
    
    public var numberOfTypers: Int = 0
}
