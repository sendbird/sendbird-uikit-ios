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
@objc public enum MediaResourceType: Int {
    case camera
    case library
    case document
    case unknown
    case delete
}

/// This is an enumeration used to select the channel editing type.
@objc public enum ChannelEditType: Int {
    case name
    case image
}

/// This is an enumeration used to select the message position.
@objc public enum MessagePosition: Int {
    case left
    case right
    case center
}

/// This is an enumeration used to select the message position in group messages.
@objc public enum MessageGroupPosition: Int {
    case none
    case top
    case middle
    case bottom
}

@available(*, deprecated, renamed: "SBUMessageFileType")
public typealias MessageFileType = SBUMessageFileType

/// This is an enumeration to file type in the message.
@objc public enum SBUMessageFileType: Int {
    case image
    case video
    case audio
    case voice
    case pdf
    case etc
}
 
/// This is an enumeration to message receipt state.
@objc public enum SBUMessageReceiptState: Int {
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
@objc public enum MessageEditItem: Int {
    case copy
    case edit
    case delete
}

/// This is an enumeration for cell's menu item type.
/// - Since: 1.2.5
@available(*, deprecated, message: "Please refer to `setupMenuItems()` function in `SBUBaseChannelModule.List` or `SBUMenuSheetViewController`") // 3.1.2
public enum MessageMenuItem {
    case save
    case copy
    case edit
    case delete
    case reply
}

/// This is an enumeration for new message info item type.
/// - Since: 2.0.0
@objc public enum NewMessageInfoItemType: Int {
    case tooltip
    case button
}

@objc public enum LogType: UInt8 {
    case none    = 0b00000000
    case error   = 0b00000001
    case warning = 0b00000010
    case info    = 0b00000100
    case all     = 0b00000111
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
