//
//  SBUCardListViewParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The data model used for configuring ``SBUCardListView``.
/// - Since: 3.7.0
public struct SBUCardListViewParams {
    /// The ID of message that contains card list view
    /// - Since: 3.7.0
    public let messageId: Int64
    /// The params for each card view
    /// - Since: 3.7.0
    public let items: [SBUCardViewParams]
    /// Initializes ``SBUCardListViewParams``.
    /// - Since: 3.7.0
    public init(messageId: Int64, items: [SBUCardViewParams]) {
        self.messageId = messageId
        self.items = items
    }
}
