//
//  UserMessage+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/07/13.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

extension UserMessage {
    // MARK: - Quick Reply
    public var quickReply: SBUQuickReplyOptions? {
        guard let data = self.data.data(using: .utf8) else { return nil }
        let options = try? JSONDecoder().decode(SBUQuickReplyOptions.self, from: data)
        return options
    }
    
    // MARK: - Card List
    public var cardListData: [String: Any]? {
        guard let data = self.data.data(using: .utf8) else { return nil }
        let cardListData = try? JSONDecoder().decode([String: String].self, from: data)
        return cardListData
    }
}
