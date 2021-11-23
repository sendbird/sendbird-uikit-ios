//
//  SBUUserMessageCellParams.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendBirdSDK

@objcMembers
public class SBUUserMessageCellParams: SBUBaseMessageCellParams {
    public var userMessage: SBDUserMessage? {
        self.message as? SBDUserMessage
    }
    public let useReaction: Bool
    public let withTextView: Bool
    
    public init(message: SBDUserMessage, hideDateView: Bool, useMessagePosition: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool = false, withTextView: Bool) {
        
        self.useReaction = useReaction
        self.withTextView = withTextView
        
        var messagePosition: MessagePosition = .left
        if useMessagePosition {
            let isMyMessage = SBUGlobals.CurrentUser?.userId == message.sender?.userId
            messagePosition = isMyMessage ? .right : .left
        }
        
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: messagePosition,
            groupPosition: groupPosition,
            receiptState: receiptState
        )
    }
}
