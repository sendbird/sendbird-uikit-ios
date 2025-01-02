//
//  SBUEnums.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//
import SendbirdChatSDK
import UIKit

/// This is an enumeration for channel type.
/// - Since: 3.0.0
public enum ChannelCreationType: Int {
    case open
    case group
    case supergroup
    case broadcast
}

/// This is an enumeration used to handling action and display by type in `ChannelSettingsViewController` and `ChannelSettingCell`.
/// - Since: 1.2.0
public enum ChannelSettingItemType: Int {
    case moderations
    case notifications
    case members
    case search
    case leave
    
    static func allTypes(isOperator: Bool) -> [ChannelSettingItemType] {
        var items: [ChannelSettingItemType] = isOperator
            ? [.moderations, notifications, members, leave]
            : [.notifications, members, leave]
        
        if SBUAvailable.isSupportMessageSearch() {
            items += [.search]
        }
        return items
    }
    
    static func from(row: Int) -> ChannelSettingItemType? {
        switch row {
        case 0: return .moderations
        case 1: return .notifications
        case 2: return .members
        case 3:
            if SBUAvailable.isSupportMessageSearch() {
                return .search
            } else {
                return .leave
            }
        case 4: return .leave
        default: return nil
        }
    }
}

/// This is an enumeration used to handling action and display by type in `OpenChannelSettingsViewController` and `ChannelSettingCell`.
/// - Since: 2.0.0
public enum OpenChannelSettingItemType: Int {
    case participants
    case delete
    
    static func allTypes(isOperator: Bool) -> [OpenChannelSettingItemType] {
        return isOperator
            ? [.participants, .delete]
            : [.participants]
    }
}

/// This is an enumeration used to handling action and display by type in `MederationsViewController` and `ModerationCell`.
/// - Since: 1.2.0
public enum ModerationItemType: Int {
    case operators
    case mutedMembers
    case bannedUsers
    case freezeChannel
    case mutedParticipants
    
    @available(*, unavailable, renamed: "bannedUsers") // 3.0.0
    case bannedMembers
    
    static func allTypes(isBroadcast: Bool, channelType: ChannelType = .group) -> [ModerationItemType] {
        return isBroadcast
        ? [.operators, .bannedUsers]
        : ((channelType == .group)
           ? [.operators, .mutedMembers, .bannedUsers, .freezeChannel]
           : [.operators, .mutedParticipants, .bannedUsers])
    }
    
    static func allTypes(channel: BaseChannel) -> [ModerationItemType] {
        var isBroadcast = false
        let channelType: ChannelType = (channel is GroupChannel) ? .group : .open
        
        if channelType == .group, let groupChannel = channel as? GroupChannel {
            isBroadcast = groupChannel.isBroadcast
        }
        
        return isBroadcast
        ? [.operators, .bannedUsers]
        : ((channelType == .group)
           ? [.operators, .mutedMembers, .bannedUsers, .freezeChannel]
           : [.operators, .mutedParticipants, .bannedUsers])
    }
}

/// This is an enumeration used to display `UserCell` by type.
/// - Since: 1.2.0
public enum UserListType: Hashable {
    case none
    case createChannel
    case members
    case invite
    case reaction
    case operators
    case muted
    case banned
    case participants
    case suggestedMention(_ withUserId: Bool)
    
    @available(*, unavailable, renamed: "members") // 3.0.0
    case channelMembers
    @available(*, unavailable, renamed: "invite") // 3.0.0
    case inviteUser
    
    @available(*, unavailable, renamed: "muted") // 3.0.0
    case mutedMembers
    @available(*, unavailable, renamed: "banned") // 3.0.0
    case bannedMembers
}

/// This is an enumeration used in `UserListViewController` to load user list by type.
/// - Since: 1.2.0
public enum ChannelUserListType: Int {
    case none
    case members
    case operators
    case muted
    case banned
    case participants
    
    @available(*, unavailable, renamed: "members") // 3.0.0
    case channelMembers
    @available(*, unavailable, renamed: "muted") // 3.0.0
    case mutedMembers
    @available(*, unavailable, renamed: "banned") // 3.0.0
    case bannedMembers
}

/// This is an enumeration used in `InviteUserViewController` to load user list by type.
/// - Since: 1.2.0
public enum ChannelInviteListType: Int {
    case none
    case users
    case operators
}

/// This is an enumeration used in `ChannelPushSettingsViewController` to show notification controls by types.
/// - Since: 3.0.0
public enum ChannelPushSettingsSubType: Int, CaseIterable {
    case all
    case mention
}

/// This is an enumeration used to display `EmptyView` by type.
public enum EmptyViewType: Int {
    case none
    case noChannels
    case noMessages
    case noNotifications
    case noMembers
    case noMutedMembers
    case noMutedParticipants
    case noBannedUsers
    case noSearchResults
    case error
    
    @available(*, unavailable, renamed: "noBannedUsers") // 3.0.0
    case noBannedMembers
    
    var isNone: Bool {
        switch self {
        case .none: return true
        default: return false
        }
    }
}

/// This is an enumeration used to select a media resource type.
@objc
public enum MediaResourceType: Int {
    case camera
    case library
    case document
    case unknown
    case delete
}

/// This is an enumeration used to select the channel editing type.
@objc
public enum ChannelEditType: Int {
    case name
    case image
}

/// This is an enumeration used to select the message position.
@objc
public enum MessagePosition: Int {
    case left
    case right
    case center
}

/// This is an enumeration used to select the message position in group messages.
@objc
public enum MessageGroupPosition: Int {
    case none
    case top
    case middle
    case bottom
}

/// This is a typealias for SBUMessageFileType which is deprecated.
@available(*, deprecated, renamed: "SBUMessageFileType")
public typealias MessageFileType = SBUMessageFileType

/// This is an enumeration to file type in the message.
@objc
public enum SBUMessageFileType: Int {
    case image
    case video
    case audio
    case voice
    case pdf
    case etc
}
 
/// This is an enumeration to message receipt state.
@objc
public enum SBUMessageReceiptState: Int {
    /// The message is sent
    case none
    /// The message is delivered
    case delivered
    /// The message is read
    case read
    /// Not use receipt state
    case notUsed
    
    @available(*, unavailable, renamed: "read") // 2.2.0
    case readReceipt
    
    @available(*, unavailable, renamed: "delivered") // 2.2.0
    case deliveryReceipt
}

/// This is an enumeration used to the message edit type.
@available(*, deprecated, message: "Please refer to `setupMenuItems()` function in `SBUBaseChannelModule.List` or `SBUMenuSheetViewController`") // 3.1.2
@objc
public enum MessageEditItem: Int {
    case copy
    case edit
    case delete
}

/// This is an enumeration for cell's menu item type.
/// - Since: 1.2.5
@available(*, deprecated, message: "Please refer to `setupMenuItems()` function in `SBUBaseChannelModule.List` or `SBUMenuSheetViewController`") // 3.1.2
public enum MessageMenuItem {
    /// This case represents the 'save' action
    case save
    /// This case represents the 'copy' action
    case copy
    /// This case represents the 'edit' action
    case edit
    /// This case represents the 'delete' action
    case delete
    /// This case represents the 'reply' action
    case reply
}

/// This is an enumeration for new message info item type.
/// - Since: 2.0.0
@objc
public enum NewMessageInfoItemType: Int {
    case tooltip
    case button
}

/// This is an enumeration for notification type.
/// - Since: 3.5.0
enum NotificationType: Int {
    case none
    case feed
    case chat
}

/// This is an enumeration for Font weight
/// - Since: 3.5.8
enum SBUFontWeightType: String, Codable {
    case normal, bold
    
    init(from decoder: Decoder) throws {
        self = try SBUFontWeightType(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .normal
    }
    
    var value: UIFont.Weight {
        switch self {
        case .normal:
            return UIFont.Weight.regular
        case .bold:
            return UIFont.Weight.bold
        }
    }
}

/// Enum to handle multiple types. (if other types are needed, expand and use)
enum SBUFlexibleType: Decodable {
    case string(String)
    case int(Int)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Data could not be decoded as `String` or `Int`."
            )
        }
    }
}

/// Enum for different typing indicator types.
/// - Since: 3.12.0
public enum SBUTypingIndicatorType {
    /// Text type typing indicator shown in``SBUChannelTitleView``.
    case text
    /// Animated bubble type typing indicator shown in ``SBUTypingIndicatorMessageCell``.
    case bubble
}

/// Enum for different suggested replies render types.
/// - Since: 3.19.0
public enum SBUSuggestedRepliesRenderType {
    /// Only displayed for the last message (default).
    case lastMessageOnly // default
    /// Remains visible even if it's not the last message.
    case allMessages
    
    /// This function determines whether to hide suggested replies for a given message.
    /// - Parameters:
    ///   - message: The `BaseMessage` object
    ///   - fullMessageList: The list of all `BaseMessage` objects.
    /// - Returns: A `Bool` indicating whether to hide the suggested replies. `true` means hide, `false` means show.
    public func shouldHideSuggestedReplies(
        message: BaseMessage,
        fullMessageList: [BaseMessage]
    ) -> Bool {
        switch self {
        case .lastMessageOnly:
            let latestMessageId = fullMessageList.first(where: { $0.sender != nil })?.messageId
            return message.messageId != latestMessageId
        case .allMessages:
            return false
        }
    }
}

/// Enum for suggested replies direction types.
/// - Since: 3.23.0
public enum SBUSuggestedRepliesDirection {
    /// vertical items layout (default)
    case vertical
    /// horizontal items layout
    case horizontal
}

/// Enum representing the scroll position.
/// - Since: 3.13.0
public enum SBUScrollPosition {
    /// Represents the bottom position in a scrollable view.
    case bottom
    /// Represents the middle position in a scrollable view.
    case middle
    /// Represents the top position in a scrollable view.
    case top
    
    var convert: UITableView.ScrollPosition {
        switch self {
        case .top: return .top
        case .middle: return .middle
        case .bottom: return .bottom
        }
    }

    var invert: UITableView.ScrollPosition {
        switch self {
        case .top: return .bottom
        case .middle: return .middle
        case .bottom: return .top
        }
    }
    
    func transform(with tableView: UITableView) -> UITableView.ScrollPosition {
        tableView.isInverted ? self.invert : self.convert
    }
    
    func transform(isInverted: Bool) -> UITableView.ScrollPosition {
        isInverted ? self.invert : self.convert
    }
}

extension UITableView {
    var isInverted: Bool {
        self.transform == CGAffineTransform(scaleX: 1, y: -1)
    }
}

/// Enum representing the type of a channel.
/// - Since: 3.19.0
public enum SBUChannelType {
    /// Represents a group channel type.
    case group
    /// Represents a super group channel type.
    case superGroup
}

// - MARK: Internal

/// - Since: 3.28.0
enum SBUItemUsageState<Item: Hashable> {
    case unused
    case usingDefault(Item)
    case usingCustom(Item)
    
    init(with item: Item?, defaultValue: Item) {
        if let item = item {
            if item == defaultValue {
                self = .usingDefault(item)
            } else {
                self = .usingCustom(item)
            }
        } else {
            self = .unused
        }
    }
    
    var item: Item? {
        switch self {
        case .usingDefault(let item): return item
        case .usingCustom(let item): return item
        default: return nil
        }
    }
    
    var isUsed: Bool {
        switch self {
        case .unused: return false
        default: return true
        }
    }
    
    var isUsingDefault: Bool {
        switch self {
        case .usingDefault: return true
        default: return false
        }
    }
    
    var isUsingCustom: Bool {
        switch self {
        case .usingCustom: return true
        default: return false
        }
    }
}
