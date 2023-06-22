//
//  SBUModuleSet.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/04/27.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUModuleSet {
    // MARK: - Modules
    
    // MARK: Channel list
    
    /// The module for the list of group channels.  The default is ``SBUGroupChannelListModule`` type.
    /// ```swift
    /// SBUModuleSet.GroupChannelListModule = SBUGroupChannelListModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupChannelListModule: SBUGroupChannelListModule.Type = SBUGroupChannelListModule.self
    
    /// The module for the list of open channels. The default is ``SBUOpenChannelListModule`` type.
    /// ```swift
    /// SBUModuleSet.OpenChannelListModule = SBUOpenChannelListModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenChannelListModule: SBUOpenChannelListModule.Type = SBUOpenChannelListModule.self
    
    // MARK: Channel
    
    /// The base module for channels. The default is `SBUBaseChannelModule` type.
    /// ```swift
    /// SBUModuleSet.BaseChannelModule = SBUBaseChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var BaseChannelModule: SBUBaseChannelModule.Type = SBUBaseChannelModule.self
    
    /// The module for group channels. The default is `SBUGroupChannelModule` type.
    /// ```swift
    /// SBUModuleSet.GroupChannelModule = SBUGroupChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupChannelModule: SBUGroupChannelModule.Type = SBUGroupChannelModule.self
    
    /// The module for open channels. The default is `SBUOpenChannelModule` type.
    /// ```swift
    /// SBUModuleSet.OpenChannelModule = SBUOpenChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenChannelModule: SBUOpenChannelModule.Type = SBUOpenChannelModule.self
    
    // MARK: Notification Channel
    
    /// The module for feed notification channels. The default is `SBUFeedNotificationChannelModule` type.
    /// ```swift
    /// SBUModuleSet.FeedNotificationChannelModule = SBUFeedNotificationChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var FeedNotificationChannelModule: SBUFeedNotificationChannelModule.Type = SBUFeedNotificationChannelModule.self
    
    /// The module for chat notification channels. The default is `SBUChatNotificationChannelModule` type.
    /// ```swift
    /// SBUModuleSet.ChatNotificationChannelModule = SBUChatNotificationChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var ChatNotificationChannelModule: SBUChatNotificationChannelModule.Type = SBUChatNotificationChannelModule.self
    
    // MARK: Select User
    
    /// The module for selecting users. The default is `SBUInviteUserModule` type.
    /// ```swift
    /// SBUModuleSet.InviteUserModule = SBUInviteUserModule.self
    /// ```
    /// - Since: 3.6.0
    public static var InviteUserModule: SBUInviteUserModule.Type = SBUInviteUserModule.self
    
    // MARK: Register operator
    
    /// The module for registering operators for group channels. The default is `SBURegisterOperatorModule` type.
    /// ```swift
    /// SBUModuleSet.GroupRegisterOperatorModule = SBURegisterOperatorModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupRegisterOperatorModule: SBURegisterOperatorModule.Type = SBURegisterOperatorModule.self
    
    /// The module for registering operators for open channels. The default is `SBURegisterOperatorModule` type.
    /// ```swift
    /// SBUModuleSet.OpenRegisterOperatorModule = SBURegisterOperatorModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenRegisterOperatorModule: SBURegisterOperatorModule.Type = SBURegisterOperatorModule.self
    
    // MARK: User list
    
    /// The module for displaying a list of users in a group channel. The default is `SBUUserListModule` type.
    /// ```swift
    /// SBUModuleSet.GroupUserListModule = SBUUserListModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupUserListModule: SBUUserListModule.Type = SBUUserListModule.self
    
    /// The module for displaying a list of users in an open channel. The default is `SBUUserListModule` type.
    /// ```swift
    /// SBUModuleSet.OpenUserListModule = SBUUserListModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenUserListModule: SBUUserListModule.Type = SBUUserListModule.self
    
    // MARK: Group Channel Push Settings
    
    /// The module for the push settings of group channels. The default is ``SBUGroupChannelPushSettingsModule`` type.
    /// ```swift
    /// SBUModuleSet.GroupChannelPushSettingsModule = SBUGroupChannelPushSettingsModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule.Type = SBUGroupChannelPushSettingsModule.self
    
    // MARK: Create Channel
    
    /// The module for creating channels. The default is ``SBUCreateChannelModule`` type.
    /// ```swift
    /// SBUModuleSet.CreateGroupChannelModule = SBUCreateChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var CreateGroupChannelModule: SBUCreateChannelModule.Type = SBUCreateChannelModule.self
    
    /// The module for creating open channels. The default is ``SBUCreateOpenChannelModule`` type.
    /// ```swift
    /// SBUModuleSet.CreateOpenChannelModule = SBUCreateOpenChannelModule.self
    /// ```
    /// - Since: 3.6.0
    public static var CreateOpenChannelModule: SBUCreateOpenChannelModule.Type = SBUCreateOpenChannelModule.self
    
    // MARK: Channel settings
    
    /// The module for the settings of group channels. The default is ``SBUGroupChannelSettingsModule`` type.
    /// ```swift
    /// SBUModuleSet.GroupChannelSettingsModule = SBUGroupChannelSettingsModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupChannelSettingsModule: SBUGroupChannelSettingsModule.Type = SBUGroupChannelSettingsModule.self
    
    /// The module for the settings of open channels. The default is ``SBUOpenChannelSettingsModule`` type.
    /// ```swift
    /// SBUModuleSet.OpenChannelSettingsModule = SBUOpenChannelSettingsModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenChannelSettingsModule: SBUOpenChannelSettingsModule.Type = SBUOpenChannelSettingsModule.self
    
    // MARK: Moderations
    
    /// The module for the moderations of group channels. The default is ``SBUModerationsModule`` type.
    /// ```swift
    /// SBUModuleSet.GroupModerationsModule = SBUModerationsModule.self
    /// ```
    /// - Since: 3.6.0
    public static var GroupModerationsModule: SBUModerationsModule.Type = SBUModerationsModule.self
    
    /// The module for the moderations of open channels. The default is ``SBUModerationsModule`` type.
    /// ```swift
    /// SBUModuleSet.OpenModerationsModule = SBUModerationsModule.self
    /// ```
    /// - Since: 3.6.0
    public static var OpenModerationsModule: SBUModerationsModule.Type = SBUModerationsModule.self
    
    // MARK: Message search
    
    /// The module for searching messages. The default is ``SBUMessageSearchModule`` type.
    /// ```swift
    /// SBUModuleSet.MessageSearchModule = SBUMessageSearchModule.self
    /// ```
    /// - Since: 3.6.0
    public static var MessageSearchModule: SBUMessageSearchModule.Type = SBUMessageSearchModule.self
    
    // MARK: Message Thread
    
    /// The module for the message thread. The default is ``SBUMessageThreadModule`` type.
    /// ```swift
    /// SBUModuleSet.MessageThreadModule = SBUMessageThreadModule.self
    /// ```
    /// - Since: 3.6.0
    public static var MessageThreadModule: SBUMessageThreadModule.Type = SBUMessageThreadModule.self
}
