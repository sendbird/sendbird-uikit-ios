//
//  SBUQuickReplyOptions.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The quick reply options that are used for ``SBUQuickReplyView``
/// - Since: 3.7.0
public struct SBUQuickReplyOptions: Codable {
    /// The options that are used for configuring ``SBUQuickReplyView``. e.g., `["How are you", "How's the weather today"]`
    /// - Since: 3.7.0
    public let options: [String]
}
