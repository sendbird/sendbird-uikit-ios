//
//  SBUFeedbackViewParams.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/09.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The data model used for configuring ``SBUFeedbackView``.
/// - Since: 3.15.0
public struct SBUFeedbackViewParams {
    // MARK: - Properties
    /// The ID of the message that provides feedback.
    public let messageId: Int64
    /// The feedback.
    public let feedback: SendbirdChatSDK.Feedback?
    /// The status.
    public let status: SendbirdChatSDK.Feedback.Status
}
