//
//  SBUSuggestedReplyViewParams.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The data model used for configuring ``SBUSuggestedReplyView``.
/// - Since: 3.11.0
public struct SBUSuggestedReplyViewParams {
    // MARK: - Properties
    /// The ID of the message that provides quick reply.
    public let messageId: Int64
    /// The list of the reply options.
    public let replyOptions: [String]
}
