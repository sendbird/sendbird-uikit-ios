//
//  SBUQuotedBaseMessageViewParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUQuotedBaseMessageViewParams {
    // MARK: Public
    /// The ID of the quoted message.
    /// - Since: 2.2.0
    public let messageId: Int64
    
    /// The position of the quoted message.
    /// - Since: 2.2.0
    public let messagePosition: MessagePosition
    
    /// The sender nickname of the quoted message.
    /// - Since: 2.2.0
    public let quotedMessageNickname: String
    
    /// The sender nickname of the reply message.
    /// - Since: 2.2.0
    public let replierNickname: String
    
    /// The text of the quoted message.
    public let text: String?
    
    /// If `true`, the message cell shows its quoted message view.
    public let useQuotedMessage: Bool
    
    // MARK: Read-only properties for file message
    
    /// The file URL of the quoted message.
    /// - Since: 2.2.0
    public var urlString: String? {
        switch messageType {
            case .fileMessage(_, _, let urlString): return urlString
            default: return nil
        }
    }
    
    /// The file name of the quoted message.
    /// - Since: 2.2.0
    public var fileName: String? {
        switch messageType {
            case .fileMessage(let name, _, _): return name
            default: return nil
        }
    }
    
    /// The file type of the quoted message.
    /// - Since: 2.2.0
    public var fileType: String? {
        switch messageType {
        case .fileMessage(_, let type, _): return type
        default: return nil
        }
    }
    
    /// if `true`, the quoted message is type of `FileMessage`.
    /// - Since: 2.2.0
    public var isFileType: Bool {
        switch messageType {
            case .fileMessage: return true
            default: return false
        }
    }
    
    /// The creation time of the quoted message
    /// - Since: 3.2.3
    public private(set) var quotedMessageCreatedAt: Int64?
    
    /// The creation time of the message.
    /// - Since: 3.3.0
    public private(set) var messageCreatedAt: Int64?
    
    /// Time the current user joined the channel.
    /// - Since: 3.3.0
    public private(set) var joinedAt: Int64 = 0
    
    /// Gets messageFileType with message.
    ///
    /// Checking step:
    /// 1. message.type
    /// 2. message.metaArrays
    ///
    /// - Since: 3.4.0
    public var messageFileType: SBUMessageFileType? {
        guard let fileType = fileType else { return nil }
        
        let type = SBUUtils.getFileType(by: fileType)
        if type == .audio,
           let metaArray = self.metaArrays?.filter({ $0.key == SBUConstant.internalMessageTypeKey }),
           let internalType = metaArray.first?.value.first {
            return SBUUtils.getFileType(by: internalType)
        }

        return type
    }
    
    // MARK: - Internal (only for Swift)
    let message: BaseMessage
    
    let messageType: QuotedMessageType
    
    let requestId: String
    
    var metaArrays: [MessageMetaArray]?
    
    public init(message: BaseMessage, position: MessagePosition, useQuotedMessage: Bool, joinedAt: Int64 = 0) {
        self.message = message
        self.messageId = message.parentMessageId
        if let quotedMessageSender = message.parentMessage?.sender {
            let isRepliedToMe = quotedMessageSender.userId == SBUGlobals.currentUser?.userId
            self.quotedMessageNickname = isRepliedToMe
            ? SBUStringSet.Message_You
            : SBUUser(user: quotedMessageSender).refinedNickname()
        } else {
            self.quotedMessageNickname = SBUStringSet.User_No_Name
        }
        
        if let replier = message.sender {
            let isRepliedByMe = replier.userId == SBUGlobals.currentUser?.userId
            self.replierNickname = isRepliedByMe
            ? SBUStringSet.Message_You
            : SBUUser(user: replier).refinedNickname()
        } else {
            self.replierNickname = SBUStringSet.User_No_Name
        }
        
        if let fileMessage = message.parentMessage as? FileMessage {
            let urlString = fileMessage.url
            let type = fileMessage.type
            let name = fileMessage.name
            self.messageType = .fileMessage(name, type, urlString)
        } else {
            self.messageType = .userMessage
        }
        self.messagePosition = position
        self.useQuotedMessage = useQuotedMessage
        self.requestId = message.requestId
        
        if let parentMessage = message.parentMessage {
            self.quotedMessageCreatedAt = parentMessage.createdAt
        }
        
        self.messageCreatedAt = message.createdAt
        
        self.joinedAt = joinedAt
        
        if (message.parentMessage?.createdAt ?? 0) < (joinedAt * 1000)
            && SendbirdUI.config.groupChannel.channel.replyType == .thread {
            self.text = SBUStringSet.Message_Unavailable
        } else {
            self.text = message.parentMessage?.message ?? ""
        }
        
        self.metaArrays = message.parentMessage?.metaArrays
    }
    
    // MARK: Test model
    public init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, text: String, useQuotedMessage: Bool = true, quotedMessageCreatedAt: Int64) {
        self.message = BaseMessage.make(["message": "deprecated"])!
        self.messageId = messageId
        self.messagePosition = messagePosition
        self.quotedMessageNickname = quotedMessageNickname
        self.replierNickname = replierNickname
        self.text = text
        self.messageType = .userMessage
        self.useQuotedMessage = useQuotedMessage
        self.requestId = ""
        self.quotedMessageCreatedAt = quotedMessageCreatedAt
    }
    
    public init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, name: String, type: String, urlString: String, useQuotedMessage: Bool = true, quotedMessageCreatedAt: Int64) {
        self.message = BaseMessage.make(["message": "deprecated"])!
        self.messageId = messageId
        self.messagePosition = messagePosition
        self.quotedMessageNickname = quotedMessageNickname
        self.replierNickname = replierNickname
        self.text = nil
        self.messageType = .fileMessage(name, type, urlString)
        self.useQuotedMessage = useQuotedMessage
        self.requestId = ""
        self.quotedMessageCreatedAt = quotedMessageCreatedAt
    }
}
