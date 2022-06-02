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
    /// The module for promoting members
    public static var promoteMemberModule: SBUPromoteMemberModule {
        get { shared.promoteMemberModule }
        set { shared.promoteMemberModule = newValue }
    }
    
    // Member list
    /// The module for the list of members
    public static var memberListModule: SBUMemberListModule {
        get { shared.memberListModule }
        set { shared.memberListModule = newValue }
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
    public static var moderationsModule: SBUModerationsModule {
        get { shared.moderationsModule }
        set { shared.moderationsModule = newValue }
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
                promoteMemberModule: SBUPromoteMemberModule = SBUPromoteMemberModule(),
                memberListModule: SBUMemberListModule = SBUMemberListModule(),
                groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule = SBUGroupChannelPushSettingsModule(),
                createChannelModule: SBUCreateChannelModule = SBUCreateChannelModule(),
                groupChannelSettingsModule: SBUGroupChannelSettingsModule = SBUGroupChannelSettingsModule(),
                openChannelSettingsModule: SBUOpenChannelSettingsModule = SBUOpenChannelSettingsModule(),
                moderationsModule: SBUModerationsModule = SBUModerationsModule(),
                messageSearchModule: SBUMessageSearchModule = SBUMessageSearchModule()) {
        self.channelListModule = channelListModule
        
        self.baseChannelModule = baseChannelModule
        self.groupChannelModule = groupChannelModule
        self.openChannelModule = openChannelModule
        
        self.inviteUserModule = inviteUserModule
        self.promoteMemberModule = promoteMemberModule
        
        self.memberListModule = memberListModule

        self.groupChannelPushSettingsModule = groupChannelPushSettingsModule
        
        self.createChannelModule = createChannelModule
        
        self.groupChannelSettingsModule = groupChannelSettingsModule
        self.openChannelSettingsModule = openChannelSettingsModule
        
        self.moderationsModule = moderationsModule
        
        self.messageSearchModule = messageSearchModule
    }
    
    
    // MARK: - Category
    private var channelListModule: SBUGroupChannelListModule
    
    private var baseChannelModule: SBUBaseChannelModule
    private var groupChannelModule: SBUGroupChannelModule
    private var openChannelModule: SBUOpenChannelModule
    
    private var inviteUserModule: SBUInviteUserModule
    private var promoteMemberModule: SBUPromoteMemberModule
    
    private var memberListModule: SBUMemberListModule

    private var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule
    
    private var createChannelModule: SBUCreateChannelModule
    
    private var groupChannelSettingsModule: SBUGroupChannelSettingsModule
    private var openChannelSettingsModule: SBUOpenChannelSettingsModule
    
    private var moderationsModule: SBUModerationsModule
    
    private var messageSearchModule: SBUMessageSearchModule
}
