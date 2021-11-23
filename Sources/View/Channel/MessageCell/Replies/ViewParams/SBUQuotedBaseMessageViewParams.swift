//
//  SBUQuotedBaseMessageViewParams.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
public class SBUQuotedBaseMessageViewParams: NSObject {
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
    public let usingQuotedMessage: Bool
    
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
    
    /// if `true`, the quoted message is type of `SBDFileMessage`.
    /// - Since: 2.2.0
    public var isFileType: Bool {
        switch messageType {
            case .fileMessage: return true
            default: return false
        }
    }
    
    // MARK: - Internal (only for Swift)
    let messageType: QuotedMessageType
    
    public init(message: SBDBaseMessage, position: MessagePosition, usingQuotedMessage: Bool) {
        self.messageId = message.parentMessageId
        self.text = message.parent?.message ?? ""
        if let quotedMessageSender = message.parent?.sender {
            let isRepliedToMe = quotedMessageSender.userId == SBUGlobals.CurrentUser?.userId
            self.quotedMessageNickname = isRepliedToMe
            ? SBUStringSet.Message_You
            : SBUUser(user: quotedMessageSender).refinedNickname()
        } else {
            self.quotedMessageNickname = SBUStringSet.User_No_Name
        }
        
        if let replier = message.sender {
            let isRepliedByMe = replier.userId == SBUGlobals.CurrentUser?.userId
            self.replierNickname = isRepliedByMe
            ? SBUStringSet.Message_You
            : SBUUser(user: replier).refinedNickname()
        } else {
            self.replierNickname = SBUStringSet.User_No_Name
        }
        
        if let fileMessage = message.parent as? SBDFileMessage {
            let urlString = fileMessage.url
            let type = fileMessage.type
            let name = fileMessage.name
            self.messageType = .fileMessage(name, type, urlString)
        } else {
            self.messageType = .userMessage
        }
        self.messagePosition = position
        self.usingQuotedMessage = usingQuotedMessage
    }
    
    // MARK: Test model
    init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, text: String, usingQuotedMessage: Bool = true) {
        self.messageId = messageId
        self.messagePosition = messagePosition
        self.quotedMessageNickname = quotedMessageNickname
        self.replierNickname = replierNickname
        self.text = text
        self.messageType = .userMessage
        self.usingQuotedMessage = usingQuotedMessage
    }
    
    init(messageId: Int64, messagePosition: MessagePosition, quotedMessageNickname: String, replierNickname: String, name: String, type: String, urlString: String, usingQuotedMessage: Bool = true) {
        self.messageId = messageId
        self.messagePosition = messagePosition
        self.quotedMessageNickname = quotedMessageNickname
        self.replierNickname = replierNickname
        self.text = nil
        self.messageType = .fileMessage(name, type, urlString)
        self.usingQuotedMessage = usingQuotedMessage
    }
}
