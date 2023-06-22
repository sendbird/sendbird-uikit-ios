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
    @available(*, deprecated, renamed: "SendbirdUI.config.groupChannel.channel.replyType") // 3.6.0
    public var replyType: SBUReplyType {
        get { SendbirdUI.config.groupChannel.channel.replyType }
        set { SendbirdUI.config.groupChannel.channel.replyType = newValue }
    }
    
    /// This enum property allows you to direct your users to view either the parent message or the message thread when they tap on a reply in the group channel view.
    @available(*, deprecated, renamed: "SendbirdUI.config.groupChannel.channel.threadReplySelectType") // 3.6.0
    public var threadReplySelectType: SBUThreadReplySelectType {
        get { SendbirdUI.config.groupChannel.channel.threadReplySelectType }
        set { SendbirdUI.config.groupChannel.channel.threadReplySelectType = newValue }
    }
    
    var includesThreadInfo: Bool = true
    var includesParentMessageInfo: Bool {
        SendbirdUI.config.groupChannel.channel.replyType != .none
    }
    
    init() {}
    
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
    @available(*, deprecated, message: "Please set each configuration separately. `SendbirdUI.config.groupChannel.channel.replyType` and `SendbirdUI.config.groupChannel.channel.SBUThreadReplySelectType`") // 3.6.0
    public init(type replyType: SBUReplyType = .none, threadReplySelectType: SBUThreadReplySelectType? = nil) {
        SendbirdUI.config.groupChannel.channel.replyType = replyType

        if threadReplySelectType == nil {
            self.setupDefaultSelectType()
        }
    }
    
    func setupDefaultSelectType() {
        switch SendbirdUI.config.groupChannel.channel.replyType {
        case .none:
            SendbirdUI.config.groupChannel.channel.threadReplySelectType = .none
        case .quoteReply:
            SendbirdUI.config.groupChannel.channel.threadReplySelectType = .parent
        case .thread:
            SendbirdUI.config.groupChannel.channel.threadReplySelectType = .thread
        }
    }
}

public enum SBUReplyType: Int, Codable {
    case `none`
    case quoteReply
    case thread
    
    // Get values for ChatSDK
    public var filterValue: ReplyType {
        switch self {
        case .none: return .none
        default: return .all
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case `none`, quoteReply = "quote_reply", thread
    }
    
    /// - Since: 3.6.0
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(SBUFlexibleType.self)
        switch type {
        case .string(let value):
            switch value {
            case CodingKeys.none.rawValue:
                self = .none
            case CodingKeys.quoteReply.rawValue:
                self = .quoteReply
            case CodingKeys.thread.rawValue:
                self = .thread
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode SBUReplyType")
            }
        case .int(let value):
            switch value {
            case SBUReplyType.none.rawValue:
                self = .none
            case SBUReplyType.quoteReply.rawValue:
                self = .quoteReply
            case SBUReplyType.thread.rawValue:
                self = .thread
            default:
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode SBUReplyType")
            }
        }
    }
}

/// The action when a reply is selected.
/// - Since: 3.3.0
public enum SBUThreadReplySelectType: Int, Codable {
    /// Doesn't move
    case `none`
    
    /// Move to parent message, when replying message is clicked
    case parent
    
    /// Move to thread list, when replying message is clicked
    case thread
    
    enum CodingKeys: String, CodingKey {
        case `none`, parent, thread
    }
    
    /// - Since: 3.6.0
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let type = try container.decode(SBUFlexibleType.self)
        switch type {
        case .string(let value):
            switch value {
            case CodingKeys.none.rawValue:
                self = .none
            case CodingKeys.parent.rawValue:
                self = .parent
            case CodingKeys.thread.rawValue:
                self = .thread
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode SBUThreadReplySelectType"
                )
            }
        case .int(let value):
            switch value {
            case SBUThreadReplySelectType.none.rawValue:
                self = .none
            case SBUThreadReplySelectType.parent.rawValue:
                self = .parent
            case SBUThreadReplySelectType.thread.rawValue:
                self = .thread
            default:
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode SBUThreadReplySelectType"
                )
            }
        }
    }
}
