//
//  SBUUnknownMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/10/07.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

public class SBUUnknownMessageCellParams: SBUBaseMessageCellParams {
    public var unknownMessage: BaseMessage {
        self.message
    }
    public let useReaction: Bool
    public let withTextView: Bool = false
    
    public init(message: BaseMessage, hideDateView: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool, isThreadMessage: Bool = false, joinedAt: Int64 = 0) {
        self.useReaction = useReaction
        
        var messagePosition: MessagePosition = .left
        let isMyMessage = SBUGlobals.currentUser?.userId == message.sender?.userId
        messagePosition = isMyMessage ? .right : .left
        
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
