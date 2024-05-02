//
//  SBUAvailable.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/24.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol SendbirdChatProtocol {
    func getAppInfo() -> AppInfo?
}

class SendbirdChatImplementation: SendbirdChatProtocol {
    public func getAppInfo() -> AppInfo? {
        return SendbirdChat.getAppInfo()
    }
}

/// This class is responsible for checking the availability of various features in the Sendbird Chat SDK.
public class SBUAvailable {
    //  swiftlint:disable identifier_name
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
    static let MESSAGE_SEARCH = "message_search_v3"
    //  swiftlint:enable identifier_name
    
    /// - Since: 3.5.6
    static let ALLOW_USER_UPDATE_FROM_SDK = "allow_user_update_from_sdk"
    
    static var sendbirdChat: SendbirdChatProtocol = SendbirdChatImplementation()
    
    private static func isAvailable(key: String) -> Bool {
        guard let appInfo = sendbirdChat.getAppInfo(),
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
    
    /// This method checks if the application support reactions for Group Channel.
    /// - Returns: `true` if the reaction operation can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportReactions() -> Bool {
        isSupportReactions(for: .group)
    }
    
    /// This method checks if the application supports Reactions for the given channel type.
    /// - Parameter channelType: The ``SBUChannelType`` of the target channel.
    /// - Returns: `true` if the Reactions feature is supported for the given channel type,`false` otherwise.
    /// - Since: 3.19.0
    public static func isSupportReactions(for channelType: SBUChannelType) -> Bool {
        let reactionsIsAvailable = self.isAvailable(key: REACTIONS)
        
        switch channelType {
        case .group:
            return reactionsIsAvailable 
            && SendbirdUI.config.groupChannel.channel.isReactionsEnabled
        case .superGroup:
            return reactionsIsAvailable
            && SendbirdUI.config.groupChannel.channel.isSuperGroupReactionsEnabled
        }
    }
    
    /// This method checks if the application support og metadata.
    /// - Returns: `true` if the og metadata can be usable, `false` otherwise.
    /// - Since: 1.2.0
    public static func isSupportOgTag(channelType: ChannelType = .group) -> Bool {
        return self.isAvailable(key: ENABLE_OG_TAG)
        && (channelType == .group
            ? SendbirdUI.config.groupChannel.channel.isOGTagEnabled
            : SendbirdUI.config.openChannel.channel.isOGTagEnabled
        )
    }
    
    /// This method checks if the application support message search.
    /// - Returns: `true` if the message search can be used, `false` otherwise.
    /// - Since: 2.1.0
    public static func isSupportMessageSearch() -> Bool {
        return  self.isAvailable(key: MESSAGE_SEARCH)
        && SendbirdUI.config.groupChannel.setting.isMessageSearchEnabled
    }
    
    /// This method gets notification info.
    /// - Returns: `NotificationInfo` object
    /// - Since: 3.5.0
    static func notificationInfo() -> NotificationInfo? {
        return SendbirdChat.getAppInfo()?.notificationInfo
    }
    
    /// This method checks if the application enabled notification channel feature.
    /// - Returns: `true` if the notification channel was enabled, `false` otherwise.
    /// - Since: 3.5.0
    static var isNotificationChannelEnabled: Bool {
        SendbirdChat.getAppInfo()?.notificationInfo?.isEnabled ?? false
    }

    /// This method checks if the application enabled notification channel feature.
    /// - Returns: `true` if the user update was enabled, `false` otherwise.
    /// - Since: 3.5.6
    static func isSupportUserUpdate() -> Bool {
        // #SBISSUE-12044
        return self.isAvailable(key: ALLOW_USER_UPDATE_FROM_SDK)
    }
    
    /// The maximum number of files that can be selected when sending a message in GroupChannel.
    /// This is decided as the minimum value between the count limit set by the server, and the count limit set by Sendbird UIKit.
    /// - Since: 3.10.0
    public static var multipleFilesMessageFileCountLimit: Int {
        min(SendbirdChat.getMultipleFilesMessageFileCountLimit(), 10)
    }
    
    /// The size limit of a file upload in bytes.
    /// - Since: 3.10.0
    public static var uploadSizeLimitBytes: Int64 {
        SendbirdChat.getAppInfo()?.uploadSizeLimit ?? (25 * 1024 * 1024)
    }
    
    /// The size limit of a file upload in MB.
    /// - Since: 3.10.0
    public static var uploadSizeLimitMB: Int64 {
        SBUAvailable.uploadSizeLimitBytes / (1024 * 1024)
    }
    
    /// This method checks if the application enabled group message template feature feature.
    /// - Returns: `true` if the group message template feature was enabled, `false` otherwise.
    /// - Since: 3.21.0
    static var isGroupMessageTemplateEnabled: Bool {
        SendbirdChat.getAppInfo()?.messageTemplateInfo?.templateListToken != nil
    }

}
