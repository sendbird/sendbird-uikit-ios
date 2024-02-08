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
    
    /// The boolean value to indicates that the message cell should hide suggested replies.
    /// If it's `true`, never show the suggested replies view even the `BaseMessage/ExtendedMessagePayload` has the reply `option` values.
    /// - Since: 3.11.0
    public let shouldHideSuggestedReplies: Bool
    
    /// The boolean value to indicates that the message cell should hide form type message.
    /// If it's `true`, never show the form type message view even the `BaseMessage/ExtendedMessagePayload` has the `forms` values.
    /// - Since: 3.11.0
    public let shouldHideFormTypeMessage: Bool

    public init(
        message: UserMessage,
        hideDateView: Bool,
        useMessagePosition: Bool,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        useReaction: Bool = false,
        withTextView: Bool,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        messageOffsetTimestamp: Int64 = 0,
        shouldHideSuggestedReplies: Bool = true,
        shouldHideFormTypeMessage: Bool = true
    ) {
        self.useReaction = useReaction
        self.withTextView = withTextView
        self.shouldHideSuggestedReplies = shouldHideSuggestedReplies
        self.shouldHideFormTypeMessage = shouldHideFormTypeMessage
        
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
            joinedAt: joinedAt,
            messageOffsetTimestamp: messageOffsetTimestamp
        )
    }
}
