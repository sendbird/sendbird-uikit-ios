//
//  SBUTypingIndicatorMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/17/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// An object that contains configurations for ``SBUTypingIndicatorMessageCell``.
/// - Since: 3.12.0
public class SBUTypingIndicatorMessageCellParams: SBUBaseMessageCellParams {
    public var typingMessage: SBUTypingIndicatorMessage? {
        self.message as? SBUTypingIndicatorMessage
    }
    
    public var shouldRedrawTypingBubble: Bool = true
    
    public init(message: SBUTypingIndicatorMessage, shouldRedrawTypingBubble: Bool = true) {
        self.shouldRedrawTypingBubble = shouldRedrawTypingBubble
        super.init(message: message, hideDateView: true, messagePosition: .left)
    }
}
