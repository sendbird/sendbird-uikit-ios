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
    /// ``SBUVoiceFileInfo`` object that has voice file informations.
    public var voiceFileInfo: SBUVoiceFileInfo?
    
    /// The boolean value that decides whether to enable a long press on a reaction emoji.
    /// If `true`, a member list for each reaction emoji is shown. 
    /// - Since: 3.19.0
    public let enableEmojiLongPress: Bool
    
    public init(
        message: FileMessage,
        hideDateView: Bool,
        useMessagePosition: Bool,
        groupPosition: MessageGroupPosition = .none,
        receiptState: SBUMessageReceiptState = .none,
        useReaction: Bool = false,
        isThreadMessage: Bool = false,
        joinedAt: Int64 = 0,
        messageOffsetTimestamp: Int64 = 0,
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
            joinedAt: joinedAt,
            messageOffsetTimestamp: messageOffsetTimestamp
        )
        
        self.voiceFileInfo = voiceFileInfo ?? SBUVoiceFileInfo.createVoiceFileInfo(with: message)
    }
}
