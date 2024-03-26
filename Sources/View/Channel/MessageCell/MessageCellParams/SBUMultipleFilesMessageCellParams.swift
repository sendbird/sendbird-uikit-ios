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
    
    /// The boolean value that decides whether to enable a long press on a reaction emoji.
    /// If `true`, a member list for each reaction emoji is shown. 
    /// - Since: 3.19.0
    public let enableEmojiLongPress: Bool
    
    public init(
        message: MultipleFilesMessage,
        hideDateView: Bool,
        useMessagePosition: Bool,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        useReaction: Bool = false,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        voiceFileInfo: SBUVoiceFileInfo? = nil,
        enableEmojiLongPress: Bool = true
    ) {
        self.useReaction = useReaction
        
        var messagePosition: MessagePosition = .left
        if useMessagePosition {
            let isMyMessage = SBUGlobals.currentUser?.userId == message.sender?.userId
            messagePosition = isMyMessage ? .right : .left
        }
        
        self.enableEmojiLongPress = enableEmojiLongPress
        
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
