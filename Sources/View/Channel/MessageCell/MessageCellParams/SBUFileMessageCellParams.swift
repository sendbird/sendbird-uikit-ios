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
    
    public init(
        message: FileMessage,
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
        
        self.voiceFileInfo = voiceFileInfo ?? SBUVoiceFileInfo.createVoiceFileInfo(with: message)
    }
}
