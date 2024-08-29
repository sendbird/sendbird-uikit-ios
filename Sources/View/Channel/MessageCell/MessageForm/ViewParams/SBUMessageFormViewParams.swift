//
//  SBUFormViewParams.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/07/02.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The data model used for configuring ``SBUFormView``.
/// - Since: 3.27.0
public struct SBUMessageFormViewParams {
    // MARK: - Properties
    /// The ID of the message that provides form.
    public let messageId: Int64
    
    /// The form.
    public let messageForm: SendbirdChatSDK.MessageForm
    
    /// Boolean value to handle whether the submit is in progress on the UI
    public let isSubmitting: Bool
    
    /// Tracks validation status of each form item to prevent duplicate submissions.
    public let itemValidationStatus: [Int64: Bool]
}
