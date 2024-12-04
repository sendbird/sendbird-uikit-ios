//
//  SBUBaseMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// This class is used to define the parameters for a base message cell.
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
    
    /// If `true` when `SBUGloabls.reply.replyType` is `.quoteReply` or `.thread` and  message is not for message thread and the message has the parent message.
    public internal(set) var useQuotedMessage: Bool
    
    /// If `true` when `SendbirdUI.config.groupChannel.channel.replyType` is `.thread` and replier of message is is at least 1.
    public internal(set) var useThreadInfo: Bool = false
    
    /// Time the current user joined the channel.
    public internal(set) var joinedAt: Int64 = 0
    
    /// Message offset of a channel. User can only see messages after this offset.
    /// - Since: 3.9.1
    public internal(set) var messageOffsetTimestamp: Int64 = 0
    
    /// Indicates whether the form type view should be exposed with a message.
    /// - Since: 3.11.0
    public internal(set) var useOnlyFromView: Bool = true

    /// Profile image URL for chat notification channel.
    var profileImageURL: String?
    
    /// The boolean value to indicates that the message cell should hide form type message.
    /// If it's `true`, never show the form type message view even the `BaseMessage/myFeedbackStatus` has valid status.
    /// - Since: 3.15.0
    public var shouldHideFeedback: Bool = true
    
    /// - Since: 3.28.0
    var isThreadMessage: Bool = false
    
    /**
     - Parameters:
        - messagePosition: Cell position (left / right / center)
        - hideDateView: Hide or expose date information
        - receiptState: ReadReceipt state
     */
    public init(message: BaseMessage,
                hideDateView: Bool,
                messagePosition: MessagePosition = .center,
                groupPosition: MessageGroupPosition = .none,
                receiptState: SBUMessageReceiptState = .none,
                isThreadMessage: Bool = false,
                joinedAt: Int64 = 0,
                shouldHideFeedback: Bool = true,
                messageOffsetTimestamp: Int64 = 0) {
        self.message = message
        self.hideDateView = hideDateView
        self.messagePosition = messagePosition
        self.receiptState = receiptState
        self.shouldHideFeedback = shouldHideFeedback
        self.isThreadMessage = isThreadMessage
        
        self.useQuotedMessage =
            (SendbirdUI.config.groupChannel.channel.replyType != .none)
            && !isThreadMessage
            && message.parentMessage != nil
        
        self.useThreadInfo = SendbirdUI.config.groupChannel.channel.replyType == .thread && message.threadInfo.replyCount > 0
        
        let filterTypes: [SBUReplyType] = [.quoteReply, .thread]
        
        if isThreadMessage {
            self.groupPosition = groupPosition
        } else {
            self.groupPosition = filterTypes.contains(SendbirdUI.config.groupChannel.channel.replyType) && message.parentMessage != nil
            ? .none
            : groupPosition
        }
        
        self.joinedAt = joinedAt
        self.messageOffsetTimestamp = messageOffsetTimestamp
    }
}
