//
//  SBUMultipleFilesMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/07/21.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

/// An object that contains configurations for ``SBUMultipleFilesMessageCell``.
/// - Since: 3.10.0
public class SBUMultipleFilesMessageCellParams: SBUBaseMessageCellParams {
    public var multipleFilesMessage: MultipleFilesMessage? {
        self.message as? MultipleFilesMessage
    }
    
    public let useReaction: Bool
    
    public init(
        message: MultipleFilesMessage,
        hideDateView: Bool,
        useMessagePosition: Bool,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        useReaction: Bool = false,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        voiceFileInfo: SBUVoiceFileInfo? = nil
    ) {
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
