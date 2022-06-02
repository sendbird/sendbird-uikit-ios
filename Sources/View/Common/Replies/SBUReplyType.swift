//
//  SBUReplyType.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/09/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

@objc
public enum SBUReplyType: Int {
    /// Doesn’t display any replies.
    case `none`
    
    /// Displays the replies on the message list
    case quoteReply
    
    @available(*, unavailable, renamed: "quoteReply")
    case thread
    
    public var filterValue: SBDReplyType {
        switch self {
        case .none: return .none
        default: return .onlyReplyToChannel
        }
    }
    
    var includesThreadInfo: Bool {
        return true
    }
    
    var includesParentMessageInfo: Bool {
        return self != .none
    }
}
