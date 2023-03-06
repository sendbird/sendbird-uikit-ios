//
//  SBUReplyConfiguration.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/09/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK


/// The configuration for reply.
/// - Since: 3.3.0
public class SBUReplyConfiguration {
    
    /// If this value is not `.none`, replying features will be activated. The default value is `.none`
    public var replyType: SBUReplyType = .none {
        didSet {
            self.setupDefaultSelectType()
        }
    }
    
    /// This enum property allows you to direct your users to view either the parent message or the message thread when they tap on a reply in the group channel view.
    public var threadReplySelectType: SBUThreadReplySelectType = .thread {
        didSet {
            if replyType == .quoteReply {
                self.threadReplySelectType = .parent
            }
        }
    }
    
    var includesThreadInfo: Bool = true
    var includesParentMessageInfo: Bool {
        return self.replyType != .none
    }
    
    /// Initilizes `replyType` and `selectedType`.
    ///
    /// - Note: If you don't set `selectedType`, it will be set to the default value according to `replyType` value.
    /// - If `replyType` is `.none`, the `selectedType` will be set `.none`
    /// - If `replyType` is `.quoteReply`, the `selectedType` will be set `.parent`
    /// - If `replyType` is `.thread`, the `selectedType` will be set `.thread`
    ///
    /// - Parameters:
    ///   - replyType: Reply type
    ///   - threadReplySelectType: Action type when selecting a thread reply.
    public init(type replyType: SBUReplyType = .none, threadReplySelectType: SBUThreadReplySelectType? = nil) {
        self.replyType = replyType

        if threadReplySelectType == nil {
            self.setupDefaultSelectType()
        }
    }
    
    func setupDefaultSelectType() {
        switch self.replyType {
        case .none:
            self.threadReplySelectType = .none
        case .quoteReply:
            self.threadReplySelectType = .parent
        case .thread:
            self.threadReplySelectType = .thread
        }
    }
}

public enum SBUReplyType: Int {
    /// Doesn’t display any replies.
    case `none`
    
    /// Displays the replies on the message list
    case quoteReply
    
    /// Displays the replies on the message list and thread info in the parent messge.
    case thread
    
    // Get values for ChatSDK
    public var filterValue: ReplyType {
        switch self {
        case .none: return .none
        default: return .all
        }
    }
}

/// The action when a reply is selected.
/// - Since: 3.3.0
public enum SBUThreadReplySelectType: Int {
    /// Doesn't move
    case `none`
    
    /// Move to parent message, when replying message is clicked
    case parent
    
    /// Move to thread list, when replying message is clicked
    case thread
}
