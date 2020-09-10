//
//  SBUEnums.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//


/// This is an enumeration for channel type.
/// - Since: 1.2.0
@objc public enum ChannelType: Int {
    case group
    case supergroup
    case broadcast
}

/// This is an enumeration used to handling action and display by type in `ChannelSettingsViewController` and `ChannelSettingCell`.
/// - Since: 1.2.0
@objc public enum ChannelSettingItemType: Int {
    case moderations
    case notifications
    case members
    case leave
    
    static func allTypes(isOperator: Bool) -> [ChannelSettingItemType] {
        return isOperator
            ? [.moderations, notifications, members, leave]
            : [.notifications, members, leave]
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
}

/// This is an enumeration used in `MemberListViewController` to load member list by type.
/// - Since: 1.2.0
@objc public enum ChannelMemberListType: Int {
    case none
    case channelMembers
    case operators
    case mutedMembers
    case bannedMembers
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

@objc public enum EmptyViewType: Int {
    case none
    case noChannels
    case noMessages
    case noMutedMembers
    case noBannedMembers
    case error
}

@objc public enum MediaResourceType: Int {
    case camera
    case library
    case document
    case unknown
}

@objc public enum ChannelEditType: Int {
    case name
    case image
}

@objc public enum MessagePosition: Int {
    case left
    case right
    case center
}

@objc public enum MessageGroupPosition: Int {
    case none
    case top
    case middle
    case bottom
}

@objc public enum MessageFileType: Int {
    case image
    case video
    case audio
    case pdf
    case etc
}
 
@objc public enum SBUMessageReceiptState: Int {
    case none 
    case readReceipt
    case deliveryReceipt
}

@objc public enum MessageEditItem: Int {
    case copy
    case edit
    case delete
}

@objc public enum FailedMessageOption: Int {
    case retry
    case remove
}

@objc public enum LogType: UInt8 {
    case none    = 0b00000000
    case error   = 0b00000001
    case warning = 0b00000010
    case info    = 0b00000100
    case all     = 0b00000111
}
