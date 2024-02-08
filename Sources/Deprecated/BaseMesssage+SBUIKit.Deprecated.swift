//
//  BaseMesssage+SBUIKit.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/26.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import UIKit

extension BaseMessage {
    
    /// list of string options.
    /// - Since: 3.11.0
    @available(*, deprecated, message: "Use `BaseMessage.suggestedReplies`")
    public var asSuggestedReplies: [String]? { self.suggestedReplies }

    /// List of form data.
    /// - Since: 3.11.0
    @available(*, unavailable, message: "Use `BaseMessage.forms`")
    public var asForms: [SBUForm]? { nil }
}
