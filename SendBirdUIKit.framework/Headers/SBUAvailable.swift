//
//  SBUAvailable.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/24.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUAvailable: NSObject {
    // MARK: - Private
    static let REACTIONS = "reactions"
    static let ENABLE_OG_TAG = "enable_og_tag"
    static let USE_LAST_MESSEGE_ON_SUPER_GROUP = "use_last_messege_on_super_group"
    static let USE_LAST_SEEN_AT = "use_last_seen_at"
    static let ENABLE_MESSAGE_THREADING = "enable_message_threading"
    static let ALLOW_GROUP_CHANNEL_CREATE_FROM_SDK = "allow_group_channel_create_from_sdk"
    static let ALLOW_GROUP_CHANNEL_INVITE_FROM_SDK = "allow_group_channel_invite_from_sdk"
    static let ALLOW_OPERATORS_TO_EDIT_OPERATORS = "allow_operators_to_edit_operators"
    static let ALLOW_OPERATORS_TO_BAN_OPERATORS = "allow_operators_to_ban_operators"
    static let ALLOW_SUPER_GROUP_CHANNEL = "allow_super_group_channel"
    static let ALLOW_GROUP_CHANNEL_LEAVE_FROM_SDK = "allow_group_channel_leave_from_sdk"
    static let ALLOW_GROUP_CHANNEL_UPDATE_FROM_SDK = "allow_group_channel_update_from_sdk"
    static let ALLOW_ONLY_OPERATOR_SDK_TO_UPDATE_GROUP_CHANNEL = "allow_only_operator_sdk_to_update_group_channel"
    static let ALLOW_BROADCAST_CHANNEL = "allow_broadcast_channel"

    private static func isAvailable(key: String) -> Bool {
        guard let appInfo = SBDMain.getAppInfo(),
            let applicationAttributes = appInfo.applicationAttributes else { return false }
        
        return applicationAttributes.contains(key)
    }
    
    
    // MARK: - Public
    
    /// This method checks if the application support super group channel.
    /// - Returns: `true` if super group channel can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportSuperGroupChannel() -> Bool {
        return self.isAvailable(key: ALLOW_SUPER_GROUP_CHANNEL)
    }

    /// This method checks if the application support broadcast channel.
    /// - Returns: `true` if broadcast channel can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportBroadcastChannel() -> Bool {
        return self.isAvailable(key: ALLOW_BROADCAST_CHANNEL)
    }
    
    /// This method checks if the application support reactions.
    /// - Returns: `true` if the reaction operation can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportReactions() -> Bool {
        return self.isAvailable(key: REACTIONS)
    }
    
    /// This method checks if the application support og metadata.
    /// - Returns: `true` if the og metadata can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportOgTag() -> Bool {
        return self.isAvailable(key: ENABLE_OG_TAG)
    }
}
