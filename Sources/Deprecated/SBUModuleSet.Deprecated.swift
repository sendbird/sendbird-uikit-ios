//
//  SBUModuleSet.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUModuleSet {
    // MARK: - Properties
     static var shared: SBUModuleSet = SBUModuleSet()
    
    // MARK: - Modules
    
    // Channel list
    
    /// The module for the list of group channels.  The default type is ``SBUGroupChannelListModule`` type.
    @available(*, deprecated, message: "Use `GroupChannelListModule`")
    public static var groupChannelListModule: SBUGroupChannelListModule {
        get {
            let module = shared.groupChannelListModule ?? Self.GroupChannelListModule.init()
            if shared.groupChannelListModule == nil {
                shared.groupChannelListModule = module
            }
            return module
        }
        set { shared.groupChannelListModule = newValue }
    }
    /// The module for the list of open channels. The default type is ``SBUOpenChannelListModule`` type.
    @available(*, deprecated, message: "Use `OpenChannelListModule`")
    public static var openChannelListModule: SBUOpenChannelListModule {
        get {
            let module = shared.openChannelListModule ?? Self.OpenChannelListModule.init()
            if shared.openChannelListModule == nil {
                shared.openChannelListModule = module
            }
            return module
        }
        set { shared.openChannelListModule = newValue }
    }
    
    // Channel
    
    /// The module for base channel. The default type is ``SBUBaseChannelModule`` type.
    @available(*, deprecated, message: "Use `BaseChannelModule`")
    public static var baseChannelModule: SBUBaseChannelModule {
        get {
            let module = shared.baseChannelModule ?? Self.BaseChannelModule.init()
            if shared.baseChannelModule == nil {
                shared.baseChannelModule = module
            }
            return module
        }
        set { shared.baseChannelModule = newValue }
    }
    /// The module for group channel. The default type is ``SBUGroupChannelModule`` type.
    @available(*, deprecated, message: "Use `GroupChannelModule`")
    public static var groupChannelModule: SBUGroupChannelModule {
        get {
            let module = shared.groupChannelModule ?? Self.GroupChannelModule.init()
            if shared.groupChannelModule == nil {
                shared.groupChannelModule = module
            }
            return module
        }
        set { shared.groupChannelModule = newValue }
    }
    /// The module for open channel. The default type is ``SBUOpenChannelModule`` type.
    @available(*, deprecated, message: "Use `OpenChannelModule`")
    public static var openChannelModule: SBUOpenChannelModule {
        get {
            let module = shared.openChannelModule ?? Self.OpenChannelModule.init()
            if shared.openChannelModule == nil {
                shared.openChannelModule = module
            }
            return module
        }
        set { shared.openChannelModule = newValue }
    }
    
    /// The module for the feed notification channel. The default type is ``SBUFeedNotificationChannelModule`` type.
    @available(*, deprecated, message: "Use `FeedNotificationChannelModule`")
    public static var feedNotificationChannelModule: SBUFeedNotificationChannelModule {
        get {
            let module = shared.feedNotificationChannelModule ?? Self.FeedNotificationChannelModule.init()
            if shared.feedNotificationChannelModule == nil {
                shared.feedNotificationChannelModule = module
            }
            return module
        }
        set { shared.feedNotificationChannelModule = newValue }
    }
    /// The module for the chat notification channel. The default type is ``SBUChatNotificationChannelModule`` type.
    @available(*, deprecated, message: "Use `ChatNotificationChannelModule`")
    public static var chatNotificationChannelModule: SBUChatNotificationChannelModule {
        get {
            let module = shared.chatNotificationChannelModule ?? Self.ChatNotificationChannelModule.init()
            if shared.chatNotificationChannelModule == nil {
                shared.chatNotificationChannelModule = module
            }
            return module
        }
        set { shared.chatNotificationChannelModule = newValue }
    }
    
    // Select user
    /// The module for inviting users. The default type is ``SBUInviteUserModule`` type.
    @available(*, deprecated, message: "Use `InviteUserModule`")
    public static var inviteUserModule: SBUInviteUserModule {
        get {
            let module = shared.inviteUserModule ?? Self.InviteUserModule.init()
            if shared.inviteUserModule == nil {
                shared.inviteUserModule = module
            }
            return module
        }
        set { shared.inviteUserModule = newValue }
    }
    
    // Register operator
    /// The module for promoting members in group channels. The default type is ``SBURegisterOperatorModule`` type.
    @available(*, deprecated, message: "Use `GroupRegisterOperatorModule`")
    public static var groupRegisterOperatorModule: SBURegisterOperatorModule {
        get {
            let module = shared.groupRegisterOperatorModule ?? Self.GroupRegisterOperatorModule.init()
            if shared.groupRegisterOperatorModule == nil {
                shared.groupRegisterOperatorModule = module
            }
            return module
        }
        set { shared.groupRegisterOperatorModule = newValue }
    }
    /// The module for promoting members in open channels. The default type is ``SBURegisterOperatorModule`` type.
    @available(*, deprecated, message: "Use `OpenRegisterOperatorModule`")
    public static var openRegisterOperatorModule: SBURegisterOperatorModule {
        get {
            let module = shared.openRegisterOperatorModule ?? Self.OpenRegisterOperatorModule.init()
            if shared.openRegisterOperatorModule == nil {
                shared.openRegisterOperatorModule = module
            }
            return module
        }
        set { shared.openRegisterOperatorModule = newValue }
    }
    
    // User list
    /// The module for the list of users in group channels. The default type is ``SBUUserListModule`` type.
    @available(*, deprecated, message: "Use `GroupUserListModule`")
    public static var groupUserListModule: SBUUserListModule {
        get {
            let module = shared.groupUserListModule ?? Self.GroupUserListModule.init()
            if shared.groupUserListModule == nil {
                shared.groupUserListModule = module
            }
            return module
        }
        set { shared.groupUserListModule = newValue }
    }
    
    /// The module for the list of users in open channels. The default type is ``SBUUserListModule`` type.
    @available(*, deprecated, message: "Use `OpenUserListModule`")
    public static var openUserListModule: SBUUserListModule {
        get {
            let module = shared.openUserListModule ?? Self.OpenUserListModule.init()
            if shared.openUserListModule == nil {
                shared.openUserListModule = module
            }
            return module
        }
        set { shared.openUserListModule = newValue }
    }
    
    // Group Channel Push Settings
    
    /// The module for the notification settings in group channels. The default type is ``SBUGroupChannelPushSettingsModule`` type.
    @available(*, deprecated, message: "Use `GroupChannelPushSettingsModule`")
    public static var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule {
        get {
            let module = shared.groupChannelPushSettingsModule ?? Self.GroupChannelPushSettingsModule.init()
            if shared.groupChannelPushSettingsModule == nil {
                shared.groupChannelPushSettingsModule = module
            }
            return module
        }
        set { shared.groupChannelPushSettingsModule = newValue }
    }
    
    // Create channel
    
    /// The module for creating a new channel. The default type is ``SBUCreateChannelModule`` type.
    @available(*, deprecated, message: "Use `CreateGroupChannelModule`")
    public static var createChannelModule: SBUCreateChannelModule {
        get {
            let module = shared.createChannelModule ?? Self.CreateGroupChannelModule.init()
            if shared.createChannelModule == nil {
                shared.createChannelModule = module
            }
            return module
        }
        set { shared.createChannelModule = newValue }
    }
    
    /// The module for creating a new open channel. The default type is ``SBUCreateOpenChannelModule`` type.
    @available(*, deprecated, message: "Use `CreateOpenChannelModule`")
    public static var createOpenChannelModule: SBUCreateOpenChannelModule {
        get {
            let module = shared.createOpenChannelModule ?? Self.CreateOpenChannelModule.init()
            if shared.createOpenChannelModule == nil {
                shared.createOpenChannelModule = module
            }
            return module
        }
        set { shared.createOpenChannelModule = newValue }
    }
    
    // Channel settings
    /// The module for the settings of group channels. The default type is ``SBUGroupChannelSettingsModule`` type.
    @available(*, deprecated, message: "Use `GroupChannelSettingsModule`")
    public static var groupChannelSettingsModule: SBUGroupChannelSettingsModule {
        get {
            let module = shared.groupChannelSettingsModule ?? Self.GroupChannelSettingsModule.init()
            if shared.groupChannelSettingsModule == nil {
                shared.groupChannelSettingsModule = module
            }
            return module
        }
        set { shared.groupChannelSettingsModule = newValue }
    }
    /// The module for the settings of open channels. The default type is ``SBUOpenChannelSettingsModule`` type.
    @available(*, deprecated, message: "Use `OpenChannelSettingsModule`")
    public static var openChannelSettingsModule: SBUOpenChannelSettingsModule {
        get {
            let module = shared.openChannelSettingsModule ?? Self.OpenChannelSettingsModule.init()
            if shared.openChannelSettingsModule == nil {
                shared.openChannelSettingsModule = module
            }
            return module
        }
        set { shared.openChannelSettingsModule = newValue }
    }
    
    // Moderations
    
    /// The module for the moderations of a group channel. The default type is ``SBUModerationsModule`` type.
    @available(*, deprecated, message: "Use `GroupModerationsModule`")
    public static var groupModerationsModule: SBUModerationsModule {
        get {
            let module = shared.groupModerationsModule ?? Self.GroupModerationsModule.init()
            if shared.groupModerationsModule == nil {
                shared.groupModerationsModule = module
            }
            return module
        }
        set { shared.groupModerationsModule = newValue }
    }
    
    /// The module for the moderations of an open channel. The default type is ``SBUModerationsModule`` type.
    @available(*, deprecated, message: "Use `OpenModerationsModule`")
    public static var openModerationsModule: SBUModerationsModule {
        get {
            let module = shared.openModerationsModule ?? Self.OpenModerationsModule.init()
            if shared.openModerationsModule == nil {
                shared.openModerationsModule = module
            }
            return module
        }
        set { shared.openModerationsModule = newValue }
    }
    
    // Message search
    
    /// The module for the message thread list. The default type is ``SBUMessageThreadModule`` type.
    @available(*, deprecated, message: "Use `MessageSearchModule")
    public static var messageSearchModule: SBUMessageSearchModule {
        get {
            let module = shared.messageSearchModule ?? Self.MessageSearchModule.init()
            if shared.messageSearchModule == nil {
                shared.messageSearchModule = module
            }
            return module
        }
        set { shared.messageSearchModule = newValue }
    }
    
    // Message Thread
    
    /// The module for the message thread list. The default type is ``SBUMessageThreadModule`` type.
    @available(*, deprecated, message: "Use `MessageThreadModule`")
    public static var messageThreadModule: SBUMessageThreadModule {
        get {
            let module = shared.messageThreadModule ?? Self.MessageThreadModule.init()
            if shared.messageThreadModule == nil {
                shared.messageThreadModule = module
            }
            return module
        }
        set { shared.messageThreadModule = newValue }
    }
    
    // MARK: - Initialize
    public init(
        groupChannelListModule: SBUGroupChannelListModule? = nil,
        openChannelListModule: SBUOpenChannelListModule? = nil,
        baseChannelModule: SBUBaseChannelModule? = nil,
        groupChannelModule: SBUGroupChannelModule? = nil,
        openChannelModule: SBUOpenChannelModule? = nil,
        feedNotificationChannelModule: SBUFeedNotificationChannelModule? = nil,
        chatNotificationChannelModule: SBUChatNotificationChannelModule? = nil,
        inviteUserModule: SBUInviteUserModule? = nil,
        groupRegisterOperatorModule: SBURegisterOperatorModule? = nil,
        openRegisterOperatorModule: SBURegisterOperatorModule? = nil,
        groupUserListModule: SBUUserListModule? = nil,
        openUserListModule: SBUUserListModule? = nil,
        groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule? = nil,
        createChannelModule: SBUCreateChannelModule? = nil,
        createOpenChannelModule: SBUCreateOpenChannelModule? = nil,
        groupChannelSettingsModule: SBUGroupChannelSettingsModule? = nil,
        openChannelSettingsModule: SBUOpenChannelSettingsModule? = nil,
        groupModerationsModule: SBUModerationsModule? = nil,
        openModerationsModule: SBUModerationsModule? = nil,
        messageSearchModule: SBUMessageSearchModule? = nil,
        messageThreadModule: SBUMessageThreadModule? = nil
    ) {
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
    private var groupChannelListModule: SBUGroupChannelListModule?
    private var openChannelListModule: SBUOpenChannelListModule?
    
    private var baseChannelModule: SBUBaseChannelModule?
    private var groupChannelModule: SBUGroupChannelModule?
    private var openChannelModule: SBUOpenChannelModule?
    
    private var feedNotificationChannelModule: SBUFeedNotificationChannelModule?
    private var chatNotificationChannelModule: SBUChatNotificationChannelModule?
    
    private var inviteUserModule: SBUInviteUserModule?
    
    private var groupRegisterOperatorModule: SBURegisterOperatorModule?
    private var openRegisterOperatorModule: SBURegisterOperatorModule?
    
    private var groupUserListModule: SBUUserListModule?
    private var openUserListModule: SBUUserListModule?

    private var groupChannelPushSettingsModule: SBUGroupChannelPushSettingsModule?
    
    private var createChannelModule: SBUCreateChannelModule?
    private var createOpenChannelModule: SBUCreateOpenChannelModule?
    
    private var groupChannelSettingsModule: SBUGroupChannelSettingsModule?
    private var openChannelSettingsModule: SBUOpenChannelSettingsModule?
    
    private var groupModerationsModule: SBUModerationsModule?
    private var openModerationsModule: SBUModerationsModule?
    
    private var messageSearchModule: SBUMessageSearchModule?
    
    private var messageThreadModule: SBUMessageThreadModule?
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
        get { shared.groupRegisterOperatorModule ?? SBURegisterOperatorModule.init() }
        set { shared.groupRegisterOperatorModule = newValue }
    }

    @available(*, deprecated, message: "This property had been seperated to `groupRegisterOperatorModule` and `openRegisterOperatorModule`") // 3.1.0
    private var registerOperatorModule: SBURegisterOperatorModule {
        get { self.groupRegisterOperatorModule ?? SBURegisterOperatorModule.init() }
        set { self.groupRegisterOperatorModule = newValue }
    }
   
    @available(*, unavailable, message: "This property had been seperated to `groupUserListModule` and `openUserListModule`") // 3.1.0
    public static var userListModule: SBUUserListModule { SBUUserListModule() }
    
    @available(*, unavailable, message: "This property had been seperated to `groupUserListModule` and `openUserListModule`") // 3.1.0
    private var userListModule: SBUUserListModule { SBUUserListModule() }
    
    @available(*, deprecated, renamed: "groupModerationsModule") // 3.1.0
    public static var moderationsModule: SBUModerationsModule {
        get { shared.groupModerationsModule ?? SBUModerationsModule.init() }
        set { shared.groupModerationsModule = newValue }
    }
    
    @available(*, deprecated, message: "This property had been seperated to `groupModerationsModule` and `openModerationsModule`") // 3.1.0
    private var moderationsModule: SBUModerationsModule {
        get { self.groupModerationsModule ?? SBUModerationsModule.init() }
        set { self.groupModerationsModule = newValue }
    }
}
