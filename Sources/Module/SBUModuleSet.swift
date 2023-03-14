//
//  SBUModuleSet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit


public class SBUModuleSet {
    // MARK: - Properties
    private static var shared: SBUModuleSet = SBUModuleSet()
    
    
    // MARK: - Modules
    
    // Channel list
    /// The module for the list of group channels.
    public static var groupChannelListModule: SBUGroupChannelListModule {
        get { return shared.groupChannelListModule }
        set { shared.groupChannelListModule = newValue }
    }
    /// The module for the list of open channels.
    public static var openChannelListModule: SBUOpenChannelListModule {
        get { return shared.openChannelListModule }
        set { shared.openChannelListModule = newValue }
    }
    
    
    // Channel
    /// The module for base channel.
    public static var baseChannelModule: SBUBaseChannelModule {
        get { return shared.baseChannelModule }
        set { shared.baseChannelModule = newValue }
    }
    /// The module for group channel.
    public static var groupChannelModule: SBUGroupChannelModule {
        get { return shared.groupChannelModule }
        set { shared.groupChannelModule = newValue }
    }
    /// The module for open channel.
    public static var openChannelModule: SBUOpenChannelModule {
        get { return shared.openChannelModule }
        set { shared.openChannelModule = newValue }
    }
    
    /// The module for feed notification channel.
    public static var feedNotificationChannelModule: SBUFeedNotificationChannelModule {
        get { shared.feedNotificationChannelModule }
        set { shared.feedNotificationChannelModule = newValue }
    }
    /// The module for chat notification channel.
    public static var chatNotificationChannelModule: SBUChatNotificationChannelModule {
        get { shared.chatNotificationChannelModule }
        set { shared.chatNotificationChannelModule = newValue }
    }
    
    // Select user
    /// The module for inviting users.
    public static var inviteUserModule: SBUInviteUserModule {
        get { shared.inviteUserModule }
        set { shared.inviteUserModule = newValue }
    }
    
    
    // Register operator
    /// The module for promoting members.
    public static var groupRegisterOperatorModule: SBURegisterOperatorModule {
        get { shared.groupRegisterOperatorModule }
        set { shared.groupRegisterOperatorModule = newValue }
    }
    /// The module for promoting members.
    public static var openRegisterOperatorModule: SBURegisterOperatorModule {
        get { shared.openRegisterOperatorModule }
        set { shared.openRegisterOperatorModule = newValue }
    }
    
    
    // User list
    /// The module for the list of users.
    public static var groupUserListModule: SBUUserListModule {
        get { shared.groupUserListModule }
        set { shared.groupUserListModule = newValue }
    }
    /// The module for the list of users.
    public static var openUserListModule: SBUUserListModule {
        get { shared.openUserListModule }
        set { shared.openUserListModule = newValue }
    }
    
    
    // Group Channel Push Settings
    /// The module for the notification settings.
    public static var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule {
        get { shared.groupChannelPushSettingsModule }
        set { shared.groupChannelPushSettingsModule = newValue }
    }
    
    
    // Create channel
    /// The module for creating a new channel.
    public static var createChannelModule: SBUCreateChannelModule {
        get { shared.createChannelModule }
        set { shared.createChannelModule = newValue }
    }
    
    public static var createOpenChannelModule: SBUCreateOpenChannelModule {
        get { shared.createOpenChannelModule }
        set { shared.createOpenChannelModule = newValue }
    }
    
    
    // Channel settings
    /// The module for a group channel settings.
    public static var groupChannelSettingsModule: SBUGroupChannelSettingsModule {
        get { shared.groupChannelSettingsModule }
        set { shared.groupChannelSettingsModule = newValue }
    }
    /// The module for an open channel settings.
    public static var openChannelSettingsModule: SBUOpenChannelSettingsModule {
        get { shared.openChannelSettingsModule }
        set { shared.openChannelSettingsModule = newValue }
    }
    
    
    // Moderations
    /// The module for the moderations.
    public static var groupModerationsModule: SBUModerationsModule {
        get { shared.groupModerationsModule }
        set { shared.groupModerationsModule = newValue }
    }
    
    public static var openModerationsModule: SBUModerationsModule {
        get { shared.openModerationsModule }
        set { shared.openModerationsModule = newValue }
    }
    
    
    // Message search
    /// The module for searching the messages.
    public static var messageSearchModule: SBUMessageSearchModule {
        get { shared.messageSearchModule }
        set { shared.messageSearchModule = newValue }
    }
    
    
    // Message Thread
    /// The module for the message thread list.
    public static var messageThreadModule: SBUMessageThreadModule {
        get { shared.messageThreadModule }
        set { shared.messageThreadModule = newValue }
    }
    
    
    // MARK: - Initialize
    public init(groupChannelListModule: SBUGroupChannelListModule = SBUGroupChannelListModule(),
                openChannelListModule: SBUOpenChannelListModule = SBUOpenChannelListModule(),
                baseChannelModule: SBUBaseChannelModule = SBUBaseChannelModule(),
                groupChannelModule: SBUGroupChannelModule = SBUGroupChannelModule(),
                openChannelModule: SBUOpenChannelModule = SBUOpenChannelModule(),
                feedNotificationChannelModule: SBUFeedNotificationChannelModule = SBUFeedNotificationChannelModule(),
                chatNotificationChannelModule: SBUChatNotificationChannelModule = SBUChatNotificationChannelModule(),
                inviteUserModule: SBUInviteUserModule = SBUInviteUserModule(),
                groupRegisterOperatorModule: SBURegisterOperatorModule = SBURegisterOperatorModule(),
                openRegisterOperatorModule: SBURegisterOperatorModule = SBURegisterOperatorModule(),
                groupUserListModule: SBUUserListModule = SBUUserListModule(),
                openUserListModule: SBUUserListModule = SBUUserListModule(),
                groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule = SBUGroupChannelPushSettingsModule(),
                createChannelModule: SBUCreateChannelModule = SBUCreateChannelModule(),
                createOpenChannelModule: SBUCreateOpenChannelModule = SBUCreateOpenChannelModule(),
                groupChannelSettingsModule: SBUGroupChannelSettingsModule = SBUGroupChannelSettingsModule(),
                openChannelSettingsModule: SBUOpenChannelSettingsModule = SBUOpenChannelSettingsModule(),
                groupModerationsModule: SBUModerationsModule = SBUModerationsModule(),
                openModerationsModule: SBUModerationsModule = SBUModerationsModule(),
                messageSearchModule: SBUMessageSearchModule = SBUMessageSearchModule(),
                messageThreadModule: SBUMessageThreadModule = SBUMessageThreadModule()) {
        self.groupChannelListModule = groupChannelListModule
        self.openChannelListModule = openChannelListModule
        
        self.baseChannelModule = baseChannelModule
        self.groupChannelModule = groupChannelModule
        self.openChannelModule = openChannelModule
        
        self.feedNotificationChannelModule = feedNotificationChannelModule
        self.chatNotificationChannelModule = chatNotificationChannelModule
        
        self.inviteUserModule = inviteUserModule
        
        self.groupRegisterOperatorModule = groupRegisterOperatorModule
        self.openRegisterOperatorModule = openRegisterOperatorModule
        
        self.groupUserListModule = groupUserListModule
        self.openUserListModule = openUserListModule

        self.groupChannelPushSettingsModule = groupChannelPushSettingsModule
        
        self.createChannelModule = createChannelModule
        self.createOpenChannelModule = createOpenChannelModule
        
        self.groupChannelSettingsModule = groupChannelSettingsModule
        self.openChannelSettingsModule = openChannelSettingsModule
        
        self.groupModerationsModule = groupModerationsModule
        self.openModerationsModule = openModerationsModule
        
        self.messageSearchModule = messageSearchModule
        
        self.messageThreadModule = messageThreadModule
    }
    
    
    // MARK: - Category
    private var groupChannelListModule: SBUGroupChannelListModule
    private var openChannelListModule: SBUOpenChannelListModule
    
    private var baseChannelModule: SBUBaseChannelModule
    private var groupChannelModule: SBUGroupChannelModule
    private var openChannelModule: SBUOpenChannelModule
    
    private var feedNotificationChannelModule: SBUFeedNotificationChannelModule
    private var chatNotificationChannelModule: SBUChatNotificationChannelModule
    
    private var inviteUserModule: SBUInviteUserModule
    
    private var groupRegisterOperatorModule: SBURegisterOperatorModule
    private var openRegisterOperatorModule: SBURegisterOperatorModule
    
    private var groupUserListModule: SBUUserListModule
    private var openUserListModule: SBUUserListModule

    private var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule
    
    private var createChannelModule: SBUCreateChannelModule
    private var createOpenChannelModule: SBUCreateOpenChannelModule
    
    private var groupChannelSettingsModule: SBUGroupChannelSettingsModule
    private var openChannelSettingsModule: SBUOpenChannelSettingsModule
    
    private var groupModerationsModule: SBUModerationsModule
    private var openModerationsModule: SBUModerationsModule
    
    private var messageSearchModule: SBUMessageSearchModule
    
    private var messageThreadModule: SBUMessageThreadModule
}


extension SBUModuleSet {
    @available(*, unavailable, renamed: "init(groupChannelListModule:openChannelListModule:baseChannelModule:groupChannelModule:openChannelModule:inviteUserModule:groupRegisterOperatorModule:openRegisterOperatorModule:groupUserListModule:openUserListModule:groupChannelPushSettingsModule:createChannelModule:groupChannelSettingsModule:openChannelSettingsModule:groupModerationsModule:openModerationsModule:messageSearchModule:)") // 3.1.0
    public convenience init(channelListModule: SBUGroupChannelListModule = SBUGroupChannelListModule(),
                baseChannelModule: SBUBaseChannelModule = SBUBaseChannelModule(),
                groupChannelModule: SBUGroupChannelModule = SBUGroupChannelModule(),
                openChannelModule: SBUOpenChannelModule = SBUOpenChannelModule(),
                inviteUserModule: SBUInviteUserModule = SBUInviteUserModule(),
                registerOperatorModule: SBURegisterOperatorModule = SBURegisterOperatorModule(),
                userListModule: SBUUserListModule = SBUUserListModule(),
                groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule = SBUGroupChannelPushSettingsModule(),
                createChannelModule: SBUCreateChannelModule = SBUCreateChannelModule(),
                groupChannelSettingsModule: SBUGroupChannelSettingsModule = SBUGroupChannelSettingsModule(),
                openChannelSettingsModule: SBUOpenChannelSettingsModule = SBUOpenChannelSettingsModule(),
                moderationsModule: SBUModerationsModule = SBUModerationsModule(),
                messageSearchModule: SBUMessageSearchModule = SBUMessageSearchModule()) {
        
        self.init(
            groupChannelListModule: SBUGroupChannelListModule(),
            openChannelListModule: SBUOpenChannelListModule(),
            baseChannelModule: SBUBaseChannelModule(),
            groupChannelModule: SBUGroupChannelModule(),
            openChannelModule: SBUOpenChannelModule(),
            inviteUserModule: SBUInviteUserModule(),
            groupRegisterOperatorModule: SBURegisterOperatorModule(),
            openRegisterOperatorModule: SBURegisterOperatorModule(),
            groupUserListModule: SBUUserListModule(),
            openUserListModule: SBUUserListModule(),
            groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule(),
            createChannelModule: SBUCreateChannelModule(),
            createOpenChannelModule: SBUCreateOpenChannelModule(),
            groupChannelSettingsModule: SBUGroupChannelSettingsModule(),
            openChannelSettingsModule: SBUOpenChannelSettingsModule(),
            groupModerationsModule: SBUModerationsModule(),
            openModerationsModule: SBUModerationsModule(),
            messageSearchModule: SBUMessageSearchModule()
        )
    }
    
    @available(*, deprecated, renamed: "groupRegisterOperatorModule") // 3.1.0
    public static var registerOperatorModule: SBURegisterOperatorModule {
        get { shared.groupRegisterOperatorModule }
        set { shared.groupRegisterOperatorModule = newValue }
    }

    @available(*, deprecated, message: "This property had been seperated to `groupRegisterOperatorModule` and `openRegisterOperatorModule`") // 3.1.0
    private var registerOperatorModule: SBURegisterOperatorModule {
        get { self.groupRegisterOperatorModule }
        set { self.groupRegisterOperatorModule = newValue }
    }

   
    @available(*, unavailable, message: "This property had been seperated to `groupUserListModule` and `openUserListModule`") // 3.1.0
    public static var userListModule: SBUUserListModule { SBUUserListModule() }
    
    @available(*, unavailable, message: "This property had been seperated to `groupUserListModule` and `openUserListModule`") // 3.1.0
    private var userListModule: SBUUserListModule { SBUUserListModule() }

    
    @available(*, deprecated, renamed: "groupModerationsModule") // 3.1.0
    public static var moderationsModule: SBUModerationsModule {
        get { shared.groupModerationsModule }
        set { shared.groupModerationsModule = newValue }
    }
    
    @available(*, deprecated, message: "This property had been seperated to `groupModerationsModule` and `openModerationsModule`") // 3.1.0
    private var moderationsModule: SBUModerationsModule {
        get { self.groupModerationsModule }
        set { self.groupModerationsModule = newValue }
    }
}
