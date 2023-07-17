//
//  SBUQuickReplyViewParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/11.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The data model used for configuring ``SBUQuickReplyView``.
/// - Since: 3.7.0
public struct SBUQuickReplyViewParams {
    // MARK: - Properties
    /// The ID of the message that provides quick reply.
    /// - Since: 3.7.0
    public let messageId: Int64
    /// The list of the reply options.
    /// - Since: 3.7.0
    public let replyOptions: [String]
    
    // MARK: - Initializer
    /// Initializes ``SBUQuickReplyViewParams``.
    /// - Since: 3.7.0
    public init(messageId: Int64, replyOptions: [String]) {
        self.messageId = messageId
        self.replyOptions = replyOptions
    }
}
