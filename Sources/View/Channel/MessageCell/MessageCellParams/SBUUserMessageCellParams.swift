//
//  SBUUserMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

public class SBUUserMessageCellParams: SBUBaseMessageCellParams {
    public var userMessage: UserMessage? {
        self.message as? UserMessage
    }
    public let useReaction: Bool
    public let withTextView: Bool
    /// The boolead value to indicates that the message cell should hide quick reply. If it's `true`, never show the quick reply view even the `UserMessage/data` has the reply option values.
    public let shouldHideQuickReply: Bool
    
    public init(message: UserMessage, hideDateView: Bool, useMessagePosition: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool = false, withTextView: Bool, isThreadMessage: Bool = false, joinedAt: Int64 = 0, shouldHideQuickReply: Bool = true) {
        
        self.useReaction = useReaction
        self.withTextView = withTextView
        self.shouldHideQuickReply = shouldHideQuickReply
        
        var messagePosition: MessagePosition = .left
        if useMessagePosition {
            let isMyMessage = SBUGlobals.currentUser?.userId == message.sender?.userId
            messagePosition = isMyMessage ? .right : .left
        }
        
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: messagePosition,
            groupPosition: groupPosition,
            receiptState: receiptState,
            isThreadMessage: isThreadMessage,
            joinedAt: joinedAt
        )
    }
}
