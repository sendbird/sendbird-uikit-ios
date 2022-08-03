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
    public static var channelListModule: SBUGroupChannelListModule {
        get { return shared.channelListModule }
        set { shared.channelListModule = newValue }
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
    
    // Select user
    /// The module for inviting users.
    public static var inviteUserModule: SBUInviteUserModule {
        get { shared.inviteUserModule }
        set { shared.inviteUserModule = newValue }
    }
    
    // Register operator
    /// The module for promoting members
    public static var groupRegisterOperatorModule: SBURegisterOperatorModule {
        get { shared.groupRegisterOperatorModule }
        set { shared.groupRegisterOperatorModule = newValue }
    }
    /// The module for promoting members
    public static var openRegisterOperatorModule: SBURegisterOperatorModule {
        get { shared.openRegisterOperatorModule }
        set { shared.openRegisterOperatorModule = newValue }
    }
    
    // User list
    /// The module for the list of users
    public static var groupUserListModule: SBUUserListModule {
        get { shared.groupUserListModule }
        set { shared.groupUserListModule = newValue }
    }
    /// The module for the list of users
    public static var openUserListModule: SBUUserListModule {
        get { shared.openUserListModule }
        set { shared.openUserListModule = newValue }
    }
    
    // Group Channel Push Settings
    /// The module for the notification settings
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
    
    // Channel settings
    /// The module for a group channel settings
    public static var groupChannelSettingsModule: SBUGroupChannelSettingsModule {
        get { shared.groupChannelSettingsModule }
        set { shared.groupChannelSettingsModule = newValue }
    }
    /// The module for an open channel settings
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
    /// The module for searching the messages
    public static var messageSearchModule: SBUMessageSearchModule {
        get { shared.messageSearchModule }
        set { shared.messageSearchModule = newValue }
    }
    
    
    // MARK: - Initialize
    public init(channelListModule: SBUGroupChannelListModule = SBUGroupChannelListModule(),
                baseChannelModule: SBUBaseChannelModule = SBUBaseChannelModule(),
                groupChannelModule: SBUGroupChannelModule = SBUGroupChannelModule(),
                openChannelModule: SBUOpenChannelModule = SBUOpenChannelModule(),
                inviteUserModule: SBUInviteUserModule = SBUInviteUserModule(),
                groupRegisterOperatorModule: SBURegisterOperatorModule = SBURegisterOperatorModule(),
                openRegisterOperatorModule: SBURegisterOperatorModule = SBURegisterOperatorModule(),
                groupUserListModule: SBUUserListModule = SBUUserListModule(),
                openUserListModule: SBUUserListModule = SBUUserListModule(),
                groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule = SBUGroupChannelPushSettingsModule(),
                createChannelModule: SBUCreateChannelModule = SBUCreateChannelModule(),
                groupChannelSettingsModule: SBUGroupChannelSettingsModule = SBUGroupChannelSettingsModule(),
                openChannelSettingsModule: SBUOpenChannelSettingsModule = SBUOpenChannelSettingsModule(),
                groupModerationsModule: SBUModerationsModule = SBUModerationsModule(),
                openModerationsModule: SBUModerationsModule = SBUModerationsModule(),
                messageSearchModule: SBUMessageSearchModule = SBUMessageSearchModule()) {
        self.channelListModule = channelListModule
        
        self.baseChannelModule = baseChannelModule
        self.groupChannelModule = groupChannelModule
        self.openChannelModule = openChannelModule
        
        self.inviteUserModule = inviteUserModule
        
        self.groupRegisterOperatorModule = groupRegisterOperatorModule
        self.openRegisterOperatorModule = openRegisterOperatorModule
        
        self.groupUserListModule = groupUserListModule
        self.openUserListModule = openUserListModule

        self.groupChannelPushSettingsModule = groupChannelPushSettingsModule
        
        self.createChannelModule = createChannelModule
        
        self.groupChannelSettingsModule = groupChannelSettingsModule
        self.openChannelSettingsModule = openChannelSettingsModule
        
        self.groupModerationsModule = groupModerationsModule
        self.openModerationsModule = openModerationsModule
        
        self.messageSearchModule = messageSearchModule
    }
    
    
    // MARK: - Category
    private var channelListModule: SBUGroupChannelListModule
    
    private var baseChannelModule: SBUBaseChannelModule
    private var groupChannelModule: SBUGroupChannelModule
    private var openChannelModule: SBUOpenChannelModule
    
    private var inviteUserModule: SBUInviteUserModule
    
    private var groupRegisterOperatorModule: SBURegisterOperatorModule
    private var openRegisterOperatorModule: SBURegisterOperatorModule
    
    private var groupUserListModule: SBUUserListModule
    private var openUserListModule: SBUUserListModule

    private var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule
    
    private var createChannelModule: SBUCreateChannelModule
    
    private var groupChannelSettingsModule: SBUGroupChannelSettingsModule
    private var openChannelSettingsModule: SBUOpenChannelSettingsModule
    
    private var groupModerationsModule: SBUModerationsModule
    private var openModerationsModule: SBUModerationsModule
    
    private var messageSearchModule: SBUMessageSearchModule
}


extension SBUModuleSet {
    @available(*, unavailable, renamed: "init(channelListModule:baseChannelModule:groupChannelModule:openChannelModule:inviteUserModule:groupRegisterOperatorModule:openRegisterOperatorModule:groupUserListModule:openUserListModule:groupChannelPushSettingsModule:createChannelModule:groupChannelSettingsModule:openChannelSettingsModule:groupModerationsModule:openModerationsModule:messageSearchModule:)") // 3.1.0
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
            channelListModule: SBUGroupChannelListModule(),
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
