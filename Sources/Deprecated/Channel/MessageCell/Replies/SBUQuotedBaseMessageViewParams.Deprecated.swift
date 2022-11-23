//
//  SBUQuotedBaseMessageViewParams.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/23.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUQuotedBaseMessageViewParams {
    // MARK: - 3.3.0

    @available(*, deprecated, renamed: "useQuotedMessage")
    public var usingQuotedMessage: Bool { self.useQuotedMessage }
    
    @available(*, deprecated, renamed: "init(message:position:useQuotedMessage:joinedAt:)")
    public convenience init(message: BaseMessage, position: MessagePosition, usingQuotedMessage: Bool, joinedAt: Int64 = 0) {
        self.init(message: message, position: position, useQuotedMessage: usingQuotedMessage)
    }
    
    @available(*, deprecated, renamed: "init(messageId:messagePosition:quotedMessageNickname:replierNickname:text:useQuotedMessage:quotedMessageCreatedAt:)")
    public convenience init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, text: String, usingQuotedMessage: Bool = true, quotedMessageCreatedAt: Int64) {
        self.init(messageId: messageId, messagePosition: messagePosition, quotedMessageNickname: quotedMessageNickname, replierNickname: replierNickname, text: text, useQuotedMessage: usingQuotedMessage, quotedMessageCreatedAt: quotedMessageCreatedAt)
    }
    
    @available(*, deprecated, renamed: "init(messageId:messagePosition:quotedMessageNickname:replierNickname:name:type:urlString:useQuotedMessage:quotedMessageCreatedAt:)")
    public convenience init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, name: String, type: String, urlString: String, usingQuotedMessage: Bool = true, quotedMessageCreatedAt: Int64) {
        self.init(messageId: messageId, messagePosition: messagePosition, quotedMessageNickname: quotedMessageNickname, replierNickname: replierNickname, name: name, type: type, urlString: urlString, useQuotedMessage: usingQuotedMessage, quotedMessageCreatedAt: quotedMessageCreatedAt)
    }
}
