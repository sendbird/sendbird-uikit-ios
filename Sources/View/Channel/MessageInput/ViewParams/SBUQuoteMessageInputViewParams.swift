//
//  SBUQuoteMessageInputViewParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/21.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


public class SBUQuoteMessageInputViewParams {
    /// The message that is going to be replied.
    /// - Since: 2.2.0
    public let message: BaseMessage
    
    /// The sender nickname of the message.
    /// - Since: 2.2.0
    public let quotedMessageNickname: String
    
    /// `SBUStringSet.MessageInput_Reply_To` value with `quotedMessageNickname`.
    /// - Since: 2.2.0
    public var replyToText: String {
        SBUStringSet.MessageInput_Reply_To(self.quotedMessageNickname)
    }
    /// if `true`, `message` is type of `FileMessage`.
    /// - Since: 2.2.0
    public var isFileType: Bool { message is FileMessage }
    
    /// The file type of `message`.
    /// - Since: 2.2.0
    public var fileType: String? { (message as? FileMessage)?.type }
    
    /// The file name preview of `message`.
    /// - Since: 2.2.0
    public var fileName: String? {
        guard let fileType = fileType else { return nil }
        switch SBUUtils.getFileType(by: fileType) {
        case .image:
            return fileType.hasPrefix("image/gif")
                ? SBUStringSet.MessageInput_Quote_Message_GIF
                : SBUStringSet.MessageInput_Quote_Message_Photo
        case .video:
            return SBUStringSet.MessageInput_Quote_Message_Video
        case .audio, .pdf, .etc:
            return (message as? FileMessage)?.name
        }
    }
    
    /// The original file name of `message`.
    /// - Since: 2.2.0
    public var originalFileNAme: String? { (message as? FileMessage)?.name }
    
    public init(message: BaseMessage) {
        self.message = message
        self.quotedMessageNickname = SBUUser(user: message.sender!).refinedNickname()
    }
}
