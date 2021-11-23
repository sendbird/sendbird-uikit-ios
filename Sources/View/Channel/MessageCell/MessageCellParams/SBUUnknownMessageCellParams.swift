//
//  SBUUnknownMessageCellParams.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/10/07.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendBirdSDK

@objcMembers
public class SBUUnknownMessageCellParams: SBUBaseMessageCellParams {
    public var unknownMessage: SBDBaseMessage {
        self.message
    }
    public let useReaction: Bool
    public let withTextView: Bool = false
    
    public init(message: SBDBaseMessage, hideDateView: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool) {
        self.useReaction = useReaction
        
        var messagePosition: MessagePosition = .left
        let isMyMessage = SBUGlobals.CurrentUser?.userId == message.sender?.userId
        messagePosition = isMyMessage ? .right : .left
        
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: messagePosition,
            groupPosition: groupPosition,
            receiptState: receiptState
        )
    }
}
