//
//  SBUHighlightInfo.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The structure that cotains the highlight information
public struct SBUHighlightMessageInfo {
    /// The text that's going to be highlighted. If the value is empty, a whole message is highlighted.
    public let keyword: String?
    /// The ID of highlighted message.
    public let messageId: Int64
    /// The time when the message updated.
    public let updatedAt: Int64
    /// The animation enable state.
    public var animated: Bool
    
    /// Creates a new instance of `SBUHighlightMessageInfo`.
    /// - Parameters:
    ///   - keyword: The text that's going to be highlighted. If the value is empty, a whole message is highlighted.
    ///   - messageId: The ID of the highlighted message.
    ///   - updatedAt: The time when the message was updated.
    ///   - animated: The animation enable state.
    public init(keyword: String?, messageId: Int64, updatedAt: Int64, animated: Bool = false) {
        self.keyword = keyword
        self.messageId = messageId
        self.updatedAt = updatedAt
        self.animated = animated
    }
    
    /// This initializer is deprecated.
    /// Use `init(keyword:messageId:updatedAt:)` instead.
    @available(*, deprecated, renamed: "init(keyword:messageId:updatedAt:)")
    public init(messageId: Int64, updatedAt: Int64) {
        self.keyword = ""
        self.messageId = messageId
        self.updatedAt = updatedAt
        self.animated = false
    }
}
