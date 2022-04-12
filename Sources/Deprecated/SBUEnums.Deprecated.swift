//
//  SBUEnums.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/02/07.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This is an enumeration for channel type.
/// - Since: 1.2.0
@available(*, deprecated, renamed: "ChannelCreationType") // 3.0.0
@objc public enum ChannelType: Int {
    case open
    case group
    case supergroup
    case broadcast
}

@available(*, deprecated, renamed: "UserListType") // 1.2.0
@objc public enum MemberListType: Int {
    case none
    case createChannel
    case channelMembers
    case inviteUser
    case reaction
}

