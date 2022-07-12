//
//  SBUBaseMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK


public class SBUBaseMessageCellParams {
    /// The message.
    public let message: BaseMessage
    
    /// Hide or expose date information
    public let hideDateView: Bool
    
    /// Cell position (left / right / center)
    public let messagePosition: MessagePosition
    
    ///
    public let groupPosition: MessageGroupPosition
    
    /// ReadReceipt state
    public let receiptState: SBUMessageReceiptState
    
    /// If `true` when `SBUGloabls.ReplyTypeToUse` is `.quoteReply` and the message has the parent message.
    public var usingQuotedMessage: Bool {
        SBUGlobals.replyType == .quoteReply && message.parentMessage != nil
    }
    
    /**
     - Parameters:
        - messagePosition: Cell position (left / right / center)
        - hideDateView: Hide or expose date information
        - receiptState: ReadReceipt state
     */
    public init(message: BaseMessage, hideDateView: Bool, messagePosition: MessagePosition = .center, groupPosition: MessageGroupPosition = .none, receiptState: SBUMessageReceiptState = .none) {
        self.message = message
        self.hideDateView = hideDateView
        self.messagePosition = messagePosition
        self.receiptState = receiptState
        
        self.groupPosition = SBUGlobals.replyType == .quoteReply && message.parentMessage != nil
            ? .none
            : groupPosition
    }
}
