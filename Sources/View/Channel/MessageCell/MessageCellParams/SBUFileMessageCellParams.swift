//
//  SBUFileMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK


public class SBUFileMessageCellParams: SBUBaseMessageCellParams {
    public var fileMessage: FileMessage? {
        self.message as? FileMessage
    }
    public let useReaction: Bool
    
    public init(message: FileMessage, hideDateView: Bool, useMessagePosition: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool = false, isThreadMessage: Bool = false, joinedAt: Int64 = 0) {
        self.useReaction = useReaction
        
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
