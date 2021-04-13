//
//  SBUEnums.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//
import SendBirdSDK

/// This is an enumeration for channel type.
/// - Since: 1.2.0
@objc public enum ChannelType: Int {
    case group
    case supergroup
    case broadcast
    case open
}

/// This is an enumeration used to handling action and display by type in `ChannelSettingsViewController` and `ChannelSettingCell`.
/// - Since: 1.2.0
@objc public enum ChannelSettingItemType: Int {
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
@objc public enum OpenChannelSettingItemType: Int {
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
@objc public enum ModerationItemType: Int {
    case operators
    case mutedMembers
    case bannedMembers
    case freezeChannel
    
    static func allTypes(isBroadcast: Bool) -> [ModerationItemType] {
        return isBroadcast
        ? [.operators, .bannedMembers]
        : [.operators, .mutedMembers, .bannedMembers, .freezeChannel]
    }
}

/// This is an enumeration used to display `UserCell` by type.
/// - Since: 1.2.0
@objc public enum UserListType: Int {
    case none
    case createChannel
    case channelMembers
    case inviteUser
    case reaction
    case operators
    case mutedMembers
    case bannedMembers
    case participants
}

/// This is an enumeration used in `MemberListViewController` to load member list by type.
/// - Since: 1.2.0
@objc public enum ChannelMemberListType: Int {
    case none
    case channelMembers
    case operators
    case mutedMembers
    case bannedMembers
    case participants
}

/// This is an enumeration used in `InviteUserViewController` to load user list by type.
/// - Since: 1.2.0
@objc public enum ChannelInviteListType: Int {
    case none
    case users
    case operators
}

@available(*, deprecated, message: "deprecated in 1.2.0", renamed: "UserListType")
@objc public enum MemberListType: Int {
    case none
    case createChannel
    case channelMembers
    case inviteUser
    case reaction
}

/// This is an enumeration used to display `EmptyView` by type.
@objc public enum EmptyViewType: Int {
    case none
    case noChannels
    case noMessages
    case noMutedMembers
    case noBannedMembers
    case noSearchResults
    case error
}

/// This is an enumeration used to select a media resource type.
@objc public enum MediaResourceType: Int {
    case camera
    case library
    case document
    case unknown
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

/// This is an enumeration to file type in the message.
@objc public enum MessageFileType: Int {
    case image
    case video
    case audio
    case pdf
    case etc
}
 
/// This is an enumeration to message receipt state.
@objc public enum SBUMessageReceiptState: Int {
    case none 
    case readReceipt
    case deliveryReceipt
}

/// This is an enumeration used to the message edit type.
@objc public enum MessageEditItem: Int {
    case copy
    case edit
    case delete
}

/// This is an enumeration for cell's menu item type.
/// - Since: 1.2.5
@objc public enum MessageMenuItem: Int {
    case save
    case copy
    case edit
    case delete
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
