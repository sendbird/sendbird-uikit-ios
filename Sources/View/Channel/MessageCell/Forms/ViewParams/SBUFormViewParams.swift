//
//  SBUFormViewParams.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2023/10/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

/// The data model used for configuring ``SBUFormView``.
/// - Since: 3.11.0
public struct SBUFormViewParams {
    // MARK: - Properties
    /// The ID of the message that provides form.
    public let messageId: Int64
    /// The form.
    public let form: SendbirdChatSDK.Form
}
