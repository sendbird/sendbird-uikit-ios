//
//  SBUFileMessageCellParams.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendBirdSDK

@objcMembers
public class SBUFileMessageCellParams: SBUBaseMessageCellParams {
    public var fileMessage: SBDFileMessage? {
        self.message as? SBDFileMessage
    }
    public let useReaction: Bool
    
    public init(message: SBDFileMessage, hideDateView: Bool, useMessagePosition: Bool, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none, useReaction: Bool = false) {
        self.useReaction = useReaction
        
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
