//
//  SBUEnums.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/02/07.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

@available(*, deprecated, renamed: "UserListType") // 1.2.0
@objc public enum MemberListType: Int {
    case none
    case createChannel
    case channelMembers
    case inviteUser
    case reaction
}

@available(*, deprecated, renamed: "ChannelUserListType") // 3.0.0
@objc public enum ChannelMemberListType: Int {
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
