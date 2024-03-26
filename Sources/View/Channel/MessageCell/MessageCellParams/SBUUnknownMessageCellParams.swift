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
    
    /// The boolean value that decides whether to enable a long press on a reaction emoji.
    /// If `true`, a member list for each reaction emoji is shown. 
    /// - Since: 3.19.0
    public let enableEmojiLongPress: Bool
    
    public init(
        message: BaseMessage,
        hideDateView: Bool,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        useReaction: Bool,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        messageOffsetTimestamp: Int64 = 0,
        enableEmojiLongPress: Bool = true
    ) {
        self.useReaction = useReaction
        
        var messagePosition: MessagePosition = .left
        let isMyMessage = SBUGlobals.currentUser?.userId == message.sender?.userId
        messagePosition = isMyMessage ? .right : .left
        
        self.enableEmojiLongPress = enableEmojiLongPress
        
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
