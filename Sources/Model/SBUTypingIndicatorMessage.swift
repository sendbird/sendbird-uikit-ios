//
//  SBUTypingIndicatorMessage.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/13/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// The message type used to show a typing bubble message. 
/// - Since: 3.12.0
public class SBUTypingIndicatorMessage: BaseMessage {
    public var typingIndicatorInfo: SBUTypingIndicatorInfo?
}
