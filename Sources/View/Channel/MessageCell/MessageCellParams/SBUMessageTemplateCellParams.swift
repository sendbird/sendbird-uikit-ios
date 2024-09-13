//
//  SBUMessageTemplateCellParams.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 9/2/24.
//

import SendbirdChatSDK

/// This is the message template parameter class
/// - Since: 3.27.2
public class SBUMessageTemplateCellParams: SBUBaseMessageCellParams {
    
    /// Template data values
    let messageTempalteData: [String: Any]?
    
    /// The boolean value to indicates that the message cell should hide suggested replies.
    /// If it's `true`, never show the suggested replies view even the `BaseMessage/ExtendedMessagePayload` has the reply `option` values.
    public let shouldHideSuggestedReplies: Bool
    
    /// Model struct for ui configuration of subviews inside the container
    public let container: SBUMessageTemplate.Container

    public init(
        message: BaseMessage,
        hideDateView: Bool = false,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        messageOffsetTimestamp: Int64 = 0,
        shouldHideSuggestedReplies: Bool = true
    ) {
        let templateData = message.asMessageTemplate
        self.messageTempalteData = templateData
        self.shouldHideSuggestedReplies = shouldHideSuggestedReplies
        self.container = .create(with: templateData)
        
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: .left,
            groupPosition: groupPosition,
            receiptState: receiptState,
            isThreadMessage: isThreadMessage,
            joinedAt: joinedAt,
            messageOffsetTimestamp: messageOffsetTimestamp
        )
    }
}
