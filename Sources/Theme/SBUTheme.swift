//
//  SBUTheme.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/05.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//
//  swiftlint:disable missing_docs

import UIKit

// MARK: - Channel List Theme

/// SBUTheme color scheme
/// - Note: light, dark
/// - Since: 3.5.0
public enum SBUThemeColorScheme {
    case light
    case dark
}

public class SBUTheme {
    public init(groupChannelListTheme: SBUGroupChannelListTheme = .light,
                groupChannelCellTheme: SBUGroupChannelCellTheme = .light,
                openChannelListTheme: SBUOpenChannelListTheme = .light,
                openChannelCellTheme: SBUOpenChannelCellTheme = .light,
                channelTheme: SBUChannelTheme = .light,
                messageInputTheme: SBUMessageInputTheme = .light,
                messageCellTheme: SBUMessageCellTheme = .light,
                messageTemplateTheme: SBUMessageTemplateTheme = .light,
                userListTheme: SBUUserListTheme = .light,
                userCellTheme: SBUUserCellTheme = .light,
                channelSettingsTheme: SBUChannelSettingsTheme = .light,
                userProfileTheme: SBUUserProfileTheme = .light,
                componentTheme: SBUComponentTheme = .light,
                overlayTheme: SBUOverlayTheme = .init(),
                messageSearchTheme: SBUMessageSearchTheme = .light,
                messageSearchResultCellTheme: SBUMessageSearchResultCellTheme = .light,
                createOpenChannelTheme: SBUCreateOpenChannelTheme = .light,
                voiceMessageInputTheme: SBUVoiceMessageInputTheme = .light
                ) {
        
        self.groupChannelListTheme = groupChannelListTheme
        self.groupChannelCellTheme = groupChannelCellTheme
        self.openChannelListTheme = openChannelListTheme
        self.openChannelCellTheme = openChannelCellTheme
        self.channelTheme = channelTheme
        self.messageInputTheme = messageInputTheme
        self.messageCellTheme = messageCellTheme
        self.messageTemplateTheme = messageTemplateTheme
        self.userListTheme = userListTheme
        self.userCellTheme = userCellTheme
        self.channelSettingsTheme = channelSettingsTheme
        self.userProfileTheme = userProfileTheme
        self.componentTheme = componentTheme
        self.overlayTheme = overlayTheme
        self.messageSearchTheme = messageSearchTheme
        self.messageSearchResultCellTheme = messageSearchResultCellTheme
        self.createOpenChannelTheme = createOpenChannelTheme
        self.voiceMessageInputTheme = voiceMessageInputTheme
        self.notificationTheme = .light
    }
    
    public static func set(theme: SBUTheme) {
        self.colorScheme = theme.colorScheme
        self.shared = theme
    }
    
    /// Sets color scheme of UIKit
    /// - Parameter colorScheme: colorScheme type
    ///
    /// - Since: 3.5.0
    public static func set(colorScheme: SBUThemeColorScheme) {
        self.colorScheme = colorScheme
        
        switch colorScheme {
        case .light:
            self.shared = .light
        case .dark:
            self.shared = .dark
        }
    }
    
    public static func setGroupChannelList(
        channelListTheme: SBUGroupChannelListTheme,
        channelCellTheme: SBUGroupChannelCellTheme
    ) {
        self.groupChannelListTheme = channelListTheme
        self.groupChannelCellTheme = channelCellTheme
    }
    
    public static func setOpenChannelList(
        channelListTheme: SBUOpenChannelListTheme,
        channelCellTheme: SBUOpenChannelCellTheme
    ) {
        self.openChannelListTheme = openChannelListTheme
        self.openChannelCellTheme = openChannelCellTheme
    }
    
    public static func setChannel(
        channelTheme: SBUChannelTheme,
        messageCellTheme: SBUMessageCellTheme,
        messageInputTheme: SBUMessageInputTheme,
        componentTheme: SBUComponentTheme,
        messageTemplateTheme: SBUMessageTemplateTheme
    ) {
        
        self.channelTheme = channelTheme
        self.messageCellTheme = messageCellTheme
        self.messageInputTheme = messageInputTheme
        self.componentTheme = componentTheme
        self.messageTemplateTheme = messageTemplateTheme
    }
    
    public static func setUserList(
        userListTheme: SBUUserListTheme,
        userCellTheme: SBUUserCellTheme
    ) {
        
        self.userListTheme = userListTheme
        self.userCellTheme = userCellTheme
    }
    
    public static func setChannelSettings(channelSettingsTheme: SBUChannelSettingsTheme) {
        self.channelSettingsTheme = channelSettingsTheme
    }
    
    public static func setUserProfile(userProfileTheme: SBUUserProfileTheme) {
        self.userProfileTheme = userProfileTheme
    }
    
    public static func setCreateOpenChannel(createOpenChannelTheme: SBUCreateOpenChannelTheme) {
        self.createOpenChannelTheme = createOpenChannelTheme
    }
    
    public static var dark: SBUTheme {
        let theme = SBUTheme(
            groupChannelListTheme: .dark,
            groupChannelCellTheme: .dark,
            openChannelListTheme: .dark,
            openChannelCellTheme: .dark,
            channelTheme: .dark,
            messageInputTheme: .dark,
            messageCellTheme: .dark,
            messageTemplateTheme: .dark,
            userListTheme: .dark,
            userCellTheme: .dark,
            channelSettingsTheme: .dark,
            userProfileTheme: .dark,
            componentTheme: .dark,
            overlayTheme: .init(),
            messageSearchTheme: .dark,
            messageSearchResultCellTheme: .dark,
            createOpenChannelTheme: .dark,
            voiceMessageInputTheme: .dark
        )
        
        theme.colorScheme = .dark
        theme.notificationTheme = .dark
        theme.notificationTheme.header = .dark
        theme.notificationTheme.list = .dark
        theme.notificationTheme.notificationCell = .dark
        
        return theme
    }
    
    public static var light: SBUTheme {
        let theme = SBUTheme(
            groupChannelListTheme: .light,
            groupChannelCellTheme: .light,
            openChannelListTheme: .light,
            openChannelCellTheme: .light,
            channelTheme: .light,
            messageInputTheme: .light,
            messageCellTheme: .light,
            messageTemplateTheme: .light,
            userListTheme: .light,
            userCellTheme: .light,
            channelSettingsTheme: .light,
            userProfileTheme: .light,
            componentTheme: .light,
            overlayTheme: .init(),
            messageSearchTheme: .light,
            messageSearchResultCellTheme: .light,
            createOpenChannelTheme: .light,
            voiceMessageInputTheme: .light
        )
        
        theme.colorScheme = .light
        theme.notificationTheme = .light
        theme.notificationTheme.header = .light
        theme.notificationTheme.list = .light
        theme.notificationTheme.notificationCell = .light
        
        return theme
    }
    
    // MARK: - Public property
    
    // Channel List
    public static var groupChannelListTheme: SBUGroupChannelListTheme {
        get { shared.groupChannelListTheme }
        set { shared.groupChannelListTheme = newValue }
    }
    
    public static var groupChannelCellTheme: SBUGroupChannelCellTheme {
        get { shared.groupChannelCellTheme }
        set { shared.groupChannelCellTheme = newValue }
    }
    
    public static var openChannelListTheme: SBUOpenChannelListTheme {
        get { shared.openChannelListTheme }
        set { shared.openChannelListTheme = newValue }
    }
    
    public static var openChannelCellTheme: SBUOpenChannelCellTheme {
        get { shared.openChannelCellTheme }
        set { shared.openChannelCellTheme = newValue }
    }
    
    // Channel & Message
    public static var channelTheme: SBUChannelTheme {
        get { shared.channelTheme }
        set { shared.channelTheme = newValue }
    }
    
    public static var messageInputTheme: SBUMessageInputTheme {
        get { shared.messageInputTheme }
        set { shared.messageInputTheme = newValue }
    }
    
    public static var messageCellTheme: SBUMessageCellTheme {
        get { shared.messageCellTheme }
        set { shared.messageCellTheme = newValue }
    }
    
    // User List
    public static var userListTheme: SBUUserListTheme {
        get { shared.userListTheme }
        set { shared.userListTheme = newValue }
    }
    
    public static var userCellTheme: SBUUserCellTheme {
        get { shared.userCellTheme }
        set { shared.userCellTheme = newValue }
    }
    
    // Setting
    public static var channelSettingsTheme: SBUChannelSettingsTheme {
        get { shared.channelSettingsTheme }
        set { shared.channelSettingsTheme = newValue }
    }
    
    // User profile
    public static var userProfileTheme: SBUUserProfileTheme {
        get { shared.userProfileTheme }
        set { shared.userProfileTheme = newValue }
    }
    
    // Component
    public static var componentTheme: SBUComponentTheme {
        get { shared.componentTheme }
        set { shared.componentTheme = newValue }
    }
    
    // Overlay Specific
    public static var overlayTheme: SBUOverlayTheme {
        get { shared.overlayTheme }
        set { shared.overlayTheme = newValue }
    }
    
    // Message search
    public static var messageSearchTheme: SBUMessageSearchTheme {
        get { shared.messageSearchTheme }
        set { shared.messageSearchTheme = newValue }
    }
    
    public static var messageSearchResultCellTheme: SBUMessageSearchResultCellTheme {
        get { shared.messageSearchResultCellTheme }
        set { shared.messageSearchResultCellTheme = newValue }
    }
    
    // Create open channel
    public static var createOpenChannelTheme: SBUCreateOpenChannelTheme {
        get { shared.createOpenChannelTheme }
        set { shared.createOpenChannelTheme = newValue }
    }
    
    // Message template
    public static var messageTemplateTheme: SBUMessageTemplateTheme {
        get { shared.messageTemplateTheme }
        set { shared.messageTemplateTheme = newValue }
    }
    
    // Voice message input
    public static var voiceMessageInputTheme: SBUVoiceMessageInputTheme {
        get { shared.voiceMessageInputTheme }
        set { shared.voiceMessageInputTheme = newValue }
    }
    
    // Notification template
    static var notificationTheme: SBUNotificationTheme {
        get { shared.notificationTheme }
        set { shared.notificationTheme = newValue }
    }
    
    // MARK: - Private property
    
    private static var shared: SBUTheme = SBUTheme()
    
    /// Color scheme of Sendbird UIKit (read-only class property)
    /// To update, use `set(colorScheme:)`.
    /// ```swift
    /// SBUTheme.set(colorScheme: .dark)
    /// print(SBUTheme.colorScheme) // "SBUThemeColorScheme.dark"
    /// ```
    /// - Since: 3.5.0
    public internal(set) static var colorScheme: SBUThemeColorScheme = .light
    
    /// Color scheme of Sendbird UIKit (internal property)
    var colorScheme: SBUThemeColorScheme = .light
    
    // Channel List
    private var groupChannelListTheme: SBUGroupChannelListTheme
    private var groupChannelCellTheme: SBUGroupChannelCellTheme
    
    private var openChannelListTheme: SBUOpenChannelListTheme
    private var openChannelCellTheme: SBUOpenChannelCellTheme
    
    // Channel & Message
    private var channelTheme: SBUChannelTheme
    private var messageInputTheme: SBUMessageInputTheme
    private var messageCellTheme: SBUMessageCellTheme
    
    // User List
    private var userListTheme: SBUUserListTheme
    private var userCellTheme: SBUUserCellTheme
    
    // Setting
    private var channelSettingsTheme: SBUChannelSettingsTheme
    
    // User profile
    private var userProfileTheme: SBUUserProfileTheme
    
    // Component
    private var componentTheme: SBUComponentTheme
    
    // Overlay Specific
    private var overlayTheme: SBUOverlayTheme
    
    // Message Search
    private var messageSearchTheme: SBUMessageSearchTheme
    private var messageSearchResultCellTheme: SBUMessageSearchResultCellTheme
    
    // Create open channel
    private var createOpenChannelTheme: SBUCreateOpenChannelTheme
    
    // Message Template
    private var messageTemplateTheme: SBUMessageTemplateTheme = SBUMessageTemplateTheme()

    // Voice message input
    private var voiceMessageInputTheme: SBUVoiceMessageInputTheme

    // Notification
    private var notificationTheme: SBUNotificationTheme = SBUNotificationTheme()
}

// MARK: - Overlay Theme

public class SBUOverlayTheme {
    
    public init(channelTheme: SBUChannelTheme = .overlay,
                messageInputTheme: SBUMessageInputTheme = .overlay,
                messageCellTheme: SBUMessageCellTheme = .overlay,
                componentTheme: SBUComponentTheme = .overlay) {
        self.channelTheme = channelTheme
        self.messageInputTheme = messageInputTheme
        self.messageCellTheme = messageCellTheme
        self.componentTheme = componentTheme
    }
    
    // Channel & Message
    public var channelTheme: SBUChannelTheme
    public var messageInputTheme: SBUMessageInputTheme
    public var messageCellTheme: SBUMessageCellTheme

    // Component
    public var componentTheme: SBUComponentTheme
}

// MARK: - Group Channel List Theme

public class SBUGroupChannelListTheme {
    
    public static var light: SBUGroupChannelListTheme {
        let theme = SBUGroupChannelListTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.primaryMain
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onLightTextDisabled
        
        theme.backgroundColor = SBUColorSet.background50
        theme.notificationOnBackgroundColor = SBUColorSet.primaryMain
        theme.notificationOnTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.notificationOffBackgroundColor = SBUColorSet.background200
        theme.notificationOffTintColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.leaveBackgroundColor = SBUColorSet.errorMain
        theme.leaveTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.alertBackgroundColor = SBUColorSet.background50
        
        return theme
    }
    
    public static var dark: SBUGroupChannelListTheme {
        let theme = SBUGroupChannelListTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        
        theme.backgroundColor = SBUColorSet.background600
        theme.notificationOnBackgroundColor = SBUColorSet.primaryLight
        theme.notificationOnTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.notificationOffBackgroundColor = SBUColorSet.background400
        theme.notificationOffTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.leaveBackgroundColor = SBUColorSet.errorLight
        theme.leaveTintColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.alertBackgroundColor = SBUColorSet.background600
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                backgroundColor: UIColor = SBUColorSet.background50,
                notificationOnBackgroundColor: UIColor = SBUColorSet.primaryMain,
                notificationOnTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                notificationOffBackgroundColor: UIColor = SBUColorSet.background200,
                notificationOffTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                leaveBackgroundColor: UIColor = SBUColorSet.errorMain,
                leaveTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                alertBackgroundColor: UIColor = SBUColorSet.background50) {
        
        self.statusBarStyle = statusBarStyle
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.backgroundColor = backgroundColor
        self.notificationOnBackgroundColor = notificationOnBackgroundColor
        self.notificationOnTintColor = notificationOnTintColor
        self.notificationOffBackgroundColor = notificationOffBackgroundColor
        self.notificationOffTintColor = notificationOffTintColor
        self.leaveBackgroundColor = leaveBackgroundColor
        self.leaveTintColor = leaveTintColor
        self.alertBackgroundColor = alertBackgroundColor
        
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor
    
    public var backgroundColor: UIColor
    
    public var notificationOnBackgroundColor: UIColor
    public var notificationOnTintColor: UIColor
    public var notificationOffBackgroundColor: UIColor
    public var notificationOffTintColor: UIColor
    
    public var leaveBackgroundColor: UIColor
    public var leaveTintColor: UIColor
    
    public var alertBackgroundColor: UIColor
}

// MARK: - Group Channel Cell Theme

public class SBUGroupChannelCellTheme {
    public static var light: SBUGroupChannelCellTheme {
        let theme = SBUGroupChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background50
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.memberCountFont = SBUFontSet.caption1
        theme.memberCountTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.lastUpdatedTimeFont = SBUFontSet.caption2
        theme.lastUpdatedTimeTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.messageFont = SBUFontSet.body3
        theme.messageTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.fileIconBackgroundColor = SBUColorSet.background100
        theme.fileIconTintColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.broadcastMarkTintColor = SBUColorSet.secondaryMain
        
        theme.freezeStateTintColor = SBUColorSet.primaryMain
        
        theme.unreadCountBackgroundColor = SBUColorSet.primaryMain
        theme.unreadCountTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.unreadCountFont = SBUFontSet.caption1
        
        theme.succeededStateColor = SBUColorSet.onLightTextLowEmphasis
        theme.deliveryReceiptStateColor = SBUColorSet.onLightTextLowEmphasis
        theme.readReceiptStateColor = SBUColorSet.secondaryMain
        
        theme.unreadMentionTextFont = SBUFontSet.h3
        theme.unreadMentionTextColor = SBUColorSet.primaryMain
        
        theme.separatorLineColor = SBUColorSet.onLightTextDisabled
        return theme
    }
    public static var dark: SBUGroupChannelCellTheme {
        let theme = SBUGroupChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.memberCountFont = SBUFontSet.caption1
        theme.memberCountTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.lastUpdatedTimeFont = SBUFontSet.caption2
        theme.lastUpdatedTimeTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.messageFont = SBUFontSet.body3
        theme.messageTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.fileIconBackgroundColor = SBUColorSet.background500
        theme.fileIconTintColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.broadcastMarkTintColor = SBUColorSet.secondaryLight
        
        theme.freezeStateTintColor = SBUColorSet.primaryLight
        
        theme.unreadCountBackgroundColor = SBUColorSet.primaryLight
        theme.unreadCountTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.unreadCountFont = SBUFontSet.caption1
        
        theme.succeededStateColor = SBUColorSet.onDarkTextLowEmphasis
        theme.deliveryReceiptStateColor = SBUColorSet.onDarkTextLowEmphasis
        theme.readReceiptStateColor = SBUColorSet.secondaryLight
        
        theme.unreadMentionTextFont = SBUFontSet.h3
        theme.unreadMentionTextColor = SBUColorSet.primaryLight
        
        theme.separatorLineColor = SBUColorSet.onDarkTextDisabled
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                titleFont: UIFont = SBUFontSet.subtitle1,
                titleTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                memberCountFont: UIFont = SBUFontSet.caption1,
                memberCountTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                lastUpdatedTimeFont: UIFont = SBUFontSet.caption2,
                lastUpdatedTimeTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                messageFont: UIFont = SBUFontSet.body3,
                messageTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                fileIconBackgroundColor: UIColor = SBUColorSet.background100,
                fileIconTintColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                broadcastMarkTintColor: UIColor = SBUColorSet.secondaryMain,
                freezeStateTintColor: UIColor = SBUColorSet.primaryMain,
                unreadCountBackgroundColor: UIColor = SBUColorSet.primaryMain,
                unreadCountTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                unreadCountFont: UIFont = SBUFontSet.caption1,
                unreadMentionFont: UIFont = SBUFontSet.h3,
                unreadMentionColor: UIColor = SBUColorSet.primaryMain,
                succeededStateColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                deliveryReceiptStateColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                readReceiptStateColor: UIColor = SBUColorSet.secondaryMain,
                separatorLineColor: UIColor = SBUColorSet.onLightTextDisabled
    ) {
        
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleTextColor = titleTextColor
        self.memberCountFont = memberCountFont
        self.memberCountTextColor = memberCountTextColor
        self.lastUpdatedTimeFont = lastUpdatedTimeFont
        self.lastUpdatedTimeTextColor = lastUpdatedTimeTextColor
        self.messageFont = messageFont
        self.messageTextColor = messageTextColor
        self.fileIconBackgroundColor = fileIconBackgroundColor
        self.fileIconTintColor = fileIconTintColor
        self.broadcastMarkTintColor = broadcastMarkTintColor
        self.freezeStateTintColor = freezeStateTintColor
        self.unreadCountBackgroundColor = unreadCountBackgroundColor
        self.unreadCountTextColor = unreadCountTextColor
        self.unreadCountFont = unreadCountFont
        self.succeededStateColor = succeededStateColor
        self.deliveryReceiptStateColor = deliveryReceiptStateColor
        self.readReceiptStateColor = readReceiptStateColor
        self.unreadMentionTextFont = unreadMentionFont
        self.unreadMentionTextColor = unreadMentionColor
        self.separatorLineColor = separatorLineColor
    }
    
    public var backgroundColor: UIColor
    
    public var titleFont: UIFont
    public var titleTextColor: UIColor
    
    public var memberCountFont: UIFont
    public var memberCountTextColor: UIColor
    
    public var lastUpdatedTimeFont: UIFont
    public var lastUpdatedTimeTextColor: UIColor
    
    public var messageFont: UIFont
    public var messageTextColor: UIColor
    /// The background color of the file icon representing last message
    public var fileIconBackgroundColor: UIColor
    /// The foreground color of the file icon representing last message
    public var fileIconTintColor: UIColor
    
    public var broadcastMarkTintColor: UIColor
    
    public var freezeStateTintColor: UIColor
    
    public var unreadCountBackgroundColor: UIColor
    public var unreadCountTextColor: UIColor
    public var unreadCountFont: UIFont
    
    /// The color represent a succeeded(sent) state of delivery/read receipt.
    public var succeededStateColor: UIColor
    /// The color represent a delivered state of delivery/read receipt.
    public var deliveryReceiptStateColor: UIColor
    /// The color represent a read state of delivery/read receipt.
    public var readReceiptStateColor: UIColor
    
    public var unreadMentionTextFont: UIFont
    public var unreadMentionTextColor: UIColor
    
    public var separatorLineColor: UIColor
}

// MARK: - Open Channel List Theme
public class SBUOpenChannelListTheme {
    
    public static var light: SBUOpenChannelListTheme {
        let theme = SBUOpenChannelListTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.primaryMain
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onLightTextDisabled
        
        theme.backgroundColor = SBUColorSet.background50
        
        theme.refreshIndicatorColor = SBUColorSet.primaryMain
        theme.refreshBackgroundColor = SBUColorSet.background100
        
        return theme
    }
    
    public static var dark: SBUOpenChannelListTheme {
        let theme = SBUOpenChannelListTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        
        theme.backgroundColor = SBUColorSet.background600
        
        theme.refreshIndicatorColor = SBUColorSet.primaryLight
        theme.refreshBackgroundColor = SBUColorSet.background700
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                backgroundColor: UIColor = SBUColorSet.background50,
                refreshIndicatorColor: UIColor = SBUColorSet.primaryMain,
                refreshBackgroundColor: UIColor = SBUColorSet.background100) {
        
        self.statusBarStyle = statusBarStyle
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.backgroundColor = backgroundColor
        self.refreshIndicatorColor = refreshIndicatorColor
        self.refreshBackgroundColor = refreshBackgroundColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor
    
    public var backgroundColor: UIColor
    
    public var refreshIndicatorColor: UIColor
    public var refreshBackgroundColor: UIColor
}

// MARK: - Open Channel Cell Theme

public class SBUOpenChannelCellTheme {
    public static var light: SBUOpenChannelCellTheme {
        let theme = SBUOpenChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background50
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.participantMarkTint = SBUColorSet.onLightTextMidEmphasis
        theme.participantCountFont = SBUFontSet.caption2
        theme.participantCountTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.freezeStateTintColor = SBUColorSet.primaryMain
        
        theme.separatorLineColor = SBUColorSet.onLightTextDisabled

        // TODO: need to remove (not used)
        theme.channelPlaceholderBackgroundColor = SBUColorSet.background300
        theme.channelPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        return theme
    }
    
    public static var dark: SBUOpenChannelCellTheme {
        let theme = SBUOpenChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.participantMarkTint = SBUColorSet.onDarkTextMidEmphasis
        theme.participantCountFont = SBUFontSet.caption2
        theme.participantCountTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.freezeStateTintColor = SBUColorSet.primaryLight
        
        theme.separatorLineColor = SBUColorSet.onDarkTextDisabled

        // TODO: need to remove (not used)
        theme.channelPlaceholderBackgroundColor = SBUColorSet.background300
        theme.channelPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                channelPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                channelPlaceholderTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                titleFont: UIFont = SBUFontSet.subtitle1,
                titleTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                participantMarkTint: UIColor = SBUColorSet.onLightTextMidEmphasis,
                participantCountFont: UIFont = SBUFontSet.caption2,
                participantCountTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                freezeStateTintColor: UIColor = SBUColorSet.primaryMain,
                separatorLineColor: UIColor = SBUColorSet.onLightTextDisabled) {
        
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleTextColor = titleTextColor
        self.participantMarkTint = participantMarkTint
        self.participantCountFont = participantCountFont
        self.participantCountTextColor = participantCountTextColor
        self.freezeStateTintColor = freezeStateTintColor
        self.separatorLineColor = separatorLineColor
        
        // TODO: need to remove (not used)
        self.channelPlaceholderBackgroundColor = channelPlaceholderBackgroundColor
        self.channelPlaceholderTintColor = channelPlaceholderTintColor
    }
    
    public var backgroundColor: UIColor
    
    public var titleFont: UIFont
    public var titleTextColor: UIColor
    
    public var participantMarkTint: UIColor
    public var participantCountFont: UIFont
    public var participantCountTextColor: UIColor
    
    public var freezeStateTintColor: UIColor
    
    public var separatorLineColor: UIColor
    
    // TODO: need to remove (not used)
    public var channelPlaceholderBackgroundColor: UIColor
    public var channelPlaceholderTintColor: UIColor
}

// MARK: - Channel Theme

public class SBUChannelTheme {
    
    public static var light: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onLightTextDisabled
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.primaryMain
        theme.backgroundColor = SBUColorSet.background50
        
        // Alert
        theme.removeItemColor = SBUColorSet.errorMain
        theme.deleteItemColor = SBUColorSet.errorMain
        theme.cancelItemColor = SBUColorSet.primaryMain
        
        theme.alertRemoveColor = SBUColorSet.errorMain
        theme.alertCancelColor = SBUColorSet.primaryMain
        
        // Menu
        theme.menuTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.menuItemTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.menuItemDisabledColor = SBUColorSet.onLightTextDisabled
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.channelStateBannerBackgroundColor = SBUColorSet.informationLight
        
        // Mention Limitation
        theme.mentionLimitGuideTextFont = SBUFontSet.body3
        theme.mentionLimitGuideTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.separatorColor = SBUColorSet.onLightTextDisabled
        
        // Message Thread Header
        theme.messageThreadTitleColor = SBUColorSet.onLightTextHighEmphasis
        theme.messageThreadTitleFont = SBUFontSet.h3
        theme.messageThreadTitleChannelNameColor = SBUColorSet.primaryMain
        theme.messageThreadTitleChannelNameFont = SBUFontSet.caption2
        
        return theme
    }
    
    public static var dark: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.backgroundColor = SBUColorSet.background600
        
        // Alert
        theme.removeItemColor = SBUColorSet.errorMain
        theme.deleteItemColor = SBUColorSet.errorMain
        theme.cancelItemColor = SBUColorSet.primaryLight
        
        theme.alertRemoveColor = SBUColorSet.errorMain
        theme.alertCancelColor = SBUColorSet.primaryLight
        
        // Menu
        theme.menuTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.menuItemTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.menuItemDisabledColor = SBUColorSet.onDarkTextDisabled
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.channelStateBannerBackgroundColor = SBUColorSet.informationLight
        
        // Mention Limitation
        theme.mentionLimitGuideTextFont = SBUFontSet.body1
        theme.mentionLimitGuideTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.separatorColor = SBUColorSet.background500
        
        // Message Thread Header
        theme.messageThreadTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.messageThreadTitleFont = SBUFontSet.h3
        theme.messageThreadTitleChannelNameColor = SBUColorSet.primaryLight
        theme.messageThreadTitleChannelNameFont = SBUFontSet.caption2
        
        return theme
    }
    
    public static var overlay: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.backgroundColor = SBUColorSet.onLightTextMidEmphasis
        
        // Alert
        theme.removeItemColor = SBUColorSet.errorMain
        theme.deleteItemColor = SBUColorSet.errorMain
        theme.cancelItemColor = SBUColorSet.primaryLight
        
        theme.alertRemoveColor = SBUColorSet.errorMain
        theme.alertCancelColor = SBUColorSet.primaryLight
        
        // Menu
        theme.menuTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.menuItemTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.menuItemDisabledColor = SBUColorSet.onDarkTextDisabled
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.channelStateBannerBackgroundColor = SBUColorSet.informationLight
        
        // Mention Limitation
        theme.mentionLimitGuideTextFont = SBUFontSet.body1
        theme.mentionLimitGuideTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.separatorColor = SBUColorSet.background500
        
        // Message Thread Header
        theme.messageThreadTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.messageThreadTitleFont = SBUFontSet.h3
        theme.messageThreadTitleChannelNameColor = SBUColorSet.primaryLight
        theme.messageThreadTitleChannelNameFont = SBUFontSet.caption2
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                backgroundColor: UIColor = SBUColorSet.background50,
                removeItemColor: UIColor = SBUColorSet.errorMain,
                deleteItemColor: UIColor = SBUColorSet.errorMain,
                cancelItemColor: UIColor = SBUColorSet.primaryMain,
                alertRemoveColor: UIColor = SBUColorSet.errorMain,
                alertCancelColor: UIColor = SBUColorSet.primaryMain,
                menuTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                menuItemTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                menuItemDisabledColor: UIColor = SBUColorSet.onLightTextDisabled,
                channelStateBannerFont: UIFont = SBUFontSet.caption2,
                channelStateBannerTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                channelStateBannerBackgroundColor: UIColor = SBUColorSet.informationLight,
                mentionLimitGuideTextFont: UIFont = SBUFontSet.body3,
                mentionLimitGuideTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                separatorColor: UIColor = SBUColorSet.onLightTextDisabled,
                messageThreadTitleColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                messageThreadTitleFont: UIFont = SBUFontSet.h3,
                messageThreadTitleChannelNameColor: UIColor = SBUColorSet.primaryMain,
                messageThreadTitleChannelNameFont: UIFont = SBUFontSet.caption2
    ) {
        
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.backgroundColor = backgroundColor
        self.removeItemColor = removeItemColor
        self.deleteItemColor = deleteItemColor
        self.cancelItemColor = cancelItemColor
        self.alertRemoveColor = alertRemoveColor
        self.alertCancelColor = alertCancelColor
        self.menuTextColor = menuTextColor
        self.menuItemTintColor = menuItemTintColor
        self.menuItemDisabledColor = menuItemDisabledColor
        self.channelStateBannerFont = channelStateBannerFont
        self.channelStateBannerTextColor = channelStateBannerTextColor
        self.channelStateBannerBackgroundColor = channelStateBannerBackgroundColor
        self.mentionLimitGuideTextFont = mentionLimitGuideTextFont
        self.mentionLimitGuideTextColor = mentionLimitGuideTextColor
        self.separatorColor = separatorColor
        
        // Message Thread Header
        self.messageThreadTitleColor = messageThreadTitleColor
        self.messageThreadTitleFont = messageThreadTitleFont
        self.messageThreadTitleChannelNameColor = messageThreadTitleChannelNameColor
        self.messageThreadTitleChannelNameFont = messageThreadTitleChannelNameFont
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var backgroundColor: UIColor
    
    // Alert
    public var removeItemColor: UIColor
    public var deleteItemColor: UIColor
    public var cancelItemColor: UIColor
    
    public var alertRemoveColor: UIColor
    public var alertCancelColor: UIColor
    
    // Menu
    public var menuTextColor: UIColor
    public var menuItemTintColor: UIColor
    public var menuItemDisabledColor: UIColor
    
    // State Banner
    public var channelStateBannerFont: UIFont
    public var channelStateBannerTextColor: UIColor
    public var channelStateBannerBackgroundColor: UIColor
    
    // Mention Limitation
    public var mentionLimitGuideTextFont: UIFont
    public var mentionLimitGuideTextColor: UIColor
    
    public var separatorColor: UIColor
    
    // Message Thread Header
    public var messageThreadTitleColor: UIColor
    public var messageThreadTitleFont: UIFont
    public var messageThreadTitleChannelNameColor: UIColor
    public var messageThreadTitleChannelNameFont: UIFont
}

// MARK: - Message Input Theme

public class SBUMessageInputTheme {
    
    public static var light: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        
        theme.backgroundColor = SBUColorSet.background50
        theme.textFieldBackgroundColor = SBUColorSet.background100
        theme.textFieldPlaceholderColor = SBUColorSet.onLightTextLowEmphasis
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.onLightTextDisabled
        theme.textFieldTintColor = SBUColorSet.primaryMain
        theme.textFieldTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.textFieldBorderColor = SBUColorSet.background100
        theme.textFieldFont = SBUFontSet.body3
        
        theme.buttonTintColor = SBUColorSet.primaryMain
        theme.buttonDisabledTintColor = SBUColorSet.onLightTextDisabled
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Quoted message
        theme.channelViewDividerColor = SBUColorSet.onLightTextDisabled
        theme.quotedFileMessageThumbnailBackgroundColor = SBUColorSet.background200
        theme.quotedFileMessageThumbnailTintColor = SBUColorSet.onLightTextMidEmphasis
        theme.replyToTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.replyToTextFont = SBUFontSet.caption1
        theme.quotedMessageTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.quotedMessageTextFont = SBUFontSet.caption2
        theme.closeReplyButtonColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.mentionTextFont = SBUFontSet.body2
        theme.mentionTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.mentionTextBackgroundColor = .clear
        
        return theme
    }
    public static var dark: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        theme.backgroundColor = SBUColorSet.background600
        theme.textFieldBackgroundColor = SBUColorSet.background400
        theme.textFieldPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.onDarkTextDisabled
        theme.textFieldTintColor = SBUColorSet.primaryLight
        theme.textFieldTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.textFieldBorderColor = SBUColorSet.background400
        theme.textFieldFont = SBUFontSet.body3
        
        theme.buttonTintColor = SBUColorSet.primaryLight
        theme.buttonDisabledTintColor = SBUColorSet.onDarkTextDisabled
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.channelViewDividerColor = SBUColorSet.onDarkTextDisabled
        theme.quotedFileMessageThumbnailBackgroundColor = SBUColorSet.background500
        theme.quotedFileMessageThumbnailTintColor = SBUColorSet.onDarkTextMidEmphasis
        theme.replyToTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.replyToTextFont = SBUFontSet.caption1
        theme.quotedMessageTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.quotedMessageTextFont = SBUFontSet.caption2
        theme.closeReplyButtonColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.mentionTextFont = SBUFontSet.body2
        theme.mentionTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mentionTextBackgroundColor = .clear
        
        return theme
    }
    public static var overlay: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        theme.backgroundColor = SBUColorSet.onLightTextMidEmphasis
        theme.textFieldBackgroundColor = SBUColorSet.background400
        theme.textFieldPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.onDarkTextDisabled
        theme.textFieldTintColor = SBUColorSet.primaryLight
        theme.textFieldTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.textFieldBorderColor = SBUColorSet.background400
        theme.textFieldFont = SBUFontSet.body3
        
        theme.buttonTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.buttonDisabledTintColor = SBUColorSet.background400
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.mentionTextFont = SBUFontSet.body2
        theme.mentionTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mentionTextBackgroundColor = .clear
        
        return theme
    }

    // swiftlint:disable identifier_name
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                textFieldBackgroundColor: UIColor = SBUColorSet.background100,
                textFieldPlaceholderColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                textFieldPlaceholderFont: UIFont = SBUFontSet.body3,
                textFieldDisabledColor: UIColor = SBUColorSet.onLightTextDisabled,
                textFieldTintColor: UIColor = SBUColorSet.primaryMain,
                textFieldTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                textFieldBorderColor: UIColor = SBUColorSet.background100,
                textFieldFont: UIFont = SBUFontSet.body3,
                buttonTintColor: UIColor = SBUColorSet.primaryMain,
                buttonDisabledTintColor: UIColor = SBUColorSet.onLightTextDisabled,
                cancelButtonFont: UIFont = SBUFontSet.button2,
                saveButtonFont: UIFont = SBUFontSet.button2,
                saveButtonTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                channelViewDividerColor: UIColor = SBUColorSet.onLightTextDisabled,
                quotedFileMessageThumbnailBackgroundColor: UIColor = SBUColorSet.background200,
                quotedFileMessageThumbnailTintColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                replyToTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                replyToTextFont: UIFont = SBUFontSet.caption1,
                quotedMessageTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                quotedMessageTextFont: UIFont = SBUFontSet.caption2,
                closeReplyButtonColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                mentionTextFont: UIFont = SBUFontSet.body2,
                mentionTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                mentionTextBackgroundColor: UIColor = .clear
                
    ) {
        
        self.backgroundColor = backgroundColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
        self.textFieldPlaceholderFont = textFieldPlaceholderFont
        self.textFieldDisabledColor = textFieldDisabledColor
        self.textFieldTintColor = textFieldTintColor
        self.textFieldTextColor = textFieldTextColor
        self.textFieldBorderColor = textFieldBorderColor
        self.textFieldFont = textFieldFont
        self.buttonTintColor = buttonTintColor
        self.buttonDisabledTintColor = buttonDisabledTintColor
        self.cancelButtonFont = cancelButtonFont
        self.saveButtonFont = saveButtonFont
        self.saveButtonTextColor = saveButtonTextColor
        
        // Quoted message
        self.channelViewDividerColor = channelViewDividerColor
        self.quotedFileMessageThumbnailBackgroundColor = quotedFileMessageThumbnailBackgroundColor
        self.quotedFileMessageThumbnailTintColor = quotedFileMessageThumbnailTintColor
        self.replyToTextColor = replyToTextColor
        self.replyToTextFont = replyToTextFont
        self.quotedMessageTextColor = quotedMessageTextColor
        self.quotedMessageTextFont = quotedMessageTextFont
        self.closeReplyButtonColor = closeReplyButtonColor
        self.mentionTextFont = mentionTextFont
        self.mentionTextColor = mentionTextColor
        self.mentionTextBackgroundColor = mentionTextBackgroundColor
    }
    // swiftlint:enable identifier_name
    
    public var backgroundColor: UIColor
    public var textFieldBackgroundColor: UIColor
    public var textFieldPlaceholderColor: UIColor
    public var textFieldPlaceholderFont: UIFont
    public var textFieldDisabledColor: UIColor
    public var textFieldTintColor: UIColor
    public var textFieldTextColor: UIColor
    public var textFieldBorderColor: UIColor
    public var textFieldFont: UIFont
    
    public var buttonTintColor: UIColor
    public var buttonDisabledTintColor: UIColor
    
    public var cancelButtonFont: UIFont
    public var saveButtonFont: UIFont
    public var saveButtonTextColor: UIColor
    
    // MARK: Quoted message
    /// The color of divider between message input view and table view of channel view.
    public var channelViewDividerColor: UIColor
    
    // swiftlint:disable identifier_name
    /// The background color of thumbnail image of the quoted message
    public var quotedFileMessageThumbnailBackgroundColor: UIColor
    // swiftlint:enable identifier_name
    
    /// The tint color of thumbnail image of the quoted message such as file icon.
    public var quotedFileMessageThumbnailTintColor: UIColor
    /// The text color of `replyToLabel`
    public var replyToTextColor: UIColor
    /// The font of `replyToLabel` text.
    public var replyToTextFont: UIFont
    /// The color of the quoted message text.
    public var quotedMessageTextColor: UIColor
    /// The font of the quoted message text.
    public var quotedMessageTextFont: UIFont
    /// The color of the `closeReplyButton` as normal state.
    public var closeReplyButtonColor: UIColor
    
    // MARK: Mention
    /// The text font of the mention.
    public var mentionTextFont: UIFont
    /// The text color of the mention.
    public var mentionTextColor: UIColor
    /// The background color of the mention.
    public var mentionTextBackgroundColor: UIColor
}

// MARK: - Message Cell Theme

public class SBUMessageCellTheme {
    
    public static var light: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = .clear
        
        theme.leftBackgroundColor = SBUColorSet.background100
        theme.leftPressedBackgroundColor = SBUColorSet.primaryExtraLight
        theme.rightBackgroundColor = SBUColorSet.primaryMain
        theme.rightPressedBackgroundColor = SBUColorSet.primaryDark
        
        theme.openChannelBackgroundColor = .clear
        theme.openChannelPressedBackgroundColor = SBUColorSet.background100
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.dateBackgroundColor = SBUColorSet.overlayLight
        
        // User name
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.currentUserNameTextColor = SBUColorSet.secondaryMain
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.onLightTextLowEmphasis
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primaryMain
        theme.failedStateColor = SBUColorSet.errorMain
        theme.succeededStateColor = SBUColorSet.onLightTextLowEmphasis
        theme.readReceiptStateColor = SBUColorSet.secondaryMain
        theme.deliveryReceiptStateColor = SBUColorSet.onLightTextLowEmphasis
        
        // Message addition container background
        theme.contentBackgroundColor = SBUColorSet.background100
        theme.pressedContentBackgroundColor = SBUColorSet.primaryExtraLight
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.userMessageLeftEditTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.userMessageRightTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userMessageRightEditTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background50
        theme.fileIconColor = SBUColorSet.primaryMain
        theme.fileImageBackgroundColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileImageIconColor = SBUColorSet.onLightTextMidEmphasis
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.fileMessageRightTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileMessagePlaceholderColor = SBUColorSet.onLightTextMidEmphasis
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.onLightTextMidEmphasis
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescLeftTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.unknownMessageDescRightTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.messageRightHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        
        // webView OG
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.onLightTextHighEmphasis
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.onLightTextHighEmphasis
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.onLightTextMidEmphasis
        theme.openChannelOGTitleColor = SBUColorSet.primaryMain
        
        theme.linkColor = SBUColorSet.primaryMain
        
        // Quoted Message
        theme.quotedMessageLeftBackgroundColor = SBUColorSet.background100.withAlphaComponent(0.5)
        theme.quotedMessageRightBackgroundColor = SBUColorSet.background100
        theme.quotedFileMessageThumbnailColor = SBUColorSet.onLightTextMidEmphasis
        theme.quotedMessageTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.quotedMessageTextFont = SBUFontSet.body3
        theme.repliedIconColor = SBUColorSet.onLightTextLowEmphasis
        theme.repliedToTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.repliedToTextFont = SBUFontSet.caption1
        
        // Thread info
        theme.repliedCountTextColor = SBUColorSet.primaryMain
        theme.repliedCountTextFont = SBUFontSet.caption3
        theme.repliedUsersMoreIconBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.64)
        theme.repliedUsersMoreIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Mention
        theme.mentionTextFont = SBUFontSet.body4
        theme.mentionLeftTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.mentionRightTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mentionLeftTextBackgroundColor = .clear
        theme.mentionRightTextBackgroundColor = .clear
        
        // Button
        theme.buttonBackgroundColor = SBUColorSet.background200
        theme.buttonTitleColor = SBUColorSet.primaryMain
        theme.sideButtonIconColor = SBUColorSet.onLightTextLowEmphasis
        theme.newMessageBadgeColor = SBUColorSet.secondaryMain
        
        // Parent info
        theme.parentInfoBackgroundColor = SBUColorSet.background50
        
        theme.parentInfoUserNameTextFont = SBUFontSet.h3
        theme.parentInfoUserNameTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.parentInfoDateFont = SBUFontSet.caption2
        theme.parentInfoDateTextColor = SBUColorSet.onLightTextLowEmphasis
        
        theme.parentInfoMoreButtonTintColor = SBUColorSet.onLightTextMidEmphasis
        theme.parentInfoSeparateBarColor = SBUColorSet.onLightTextDisabled

        theme.parentInfoReplyCountTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.parentInfoReplyCountTextFont = SBUFontSet.body3
        
        theme.parentInfoProgressBackgroundColor = SBUColorSet.background100
        
        // Voice note
        theme.progressTrackTintColor = SBUColorSet.onLightTextLowEmphasis
        theme.progressTimeFont = SBUFontSet.body3
        theme.progressTimeRightTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.progressTimeLeftTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.playerStatusButtonBackgroundColor = SBUColorSet.background50
        theme.playerLoadingButtonTintColor = SBUColorSet.primaryLight
        theme.playerPlayButtonTintColor = SBUColorSet.primaryMain
        theme.playerPauseButtonTintColor = SBUColorSet.primaryMain
        
        // suggested reply
        theme.suggestedReplyTitleColor = SBUColorSet.primaryMain
        theme.suggestedReplyBorderColor = SBUColorSet.primaryMain
        theme.suggestedReplyBackgroundColor = SBUColorSet.background50
        theme.suggestedReplyBackgroundSelectedColor = SBUColorSet.background100
        
        // form
        theme.formBackgroundColor = SBUColorSet.background100
        theme.formTitleColor = SBUColorSet.onLightTextMidEmphasis
        theme.formOptionalTitleColor = SBUColorSet.onLightTextLowEmphasis
        theme.formInputBackgroundColor = SBUColorSet.background50
        theme.formInputBackgroundDoneColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formInputTitleColor = SBUColorSet.onLightTextHighEmphasis
        theme.formInputIconColor = SBUColorSet.secondaryMain
        theme.formInputBorderNormalColor = SBUColorSet.onLightTextDisabled
        theme.formInputBorderActiveColor = SBUColorSet.primaryMain
        theme.formInputBorderErrorColor = SBUColorSet.errorMain
        theme.formInputErrorColor = SBUColorSet.errorMain
        theme.formInputPlaceholderColor = SBUColorSet.onLightTextLowEmphasis
        theme.formSubmitButtonBackgroundColor = SBUColorSet.primaryMain
        theme.formSubmitButtonBackgroundDisabledColor = SBUColorSet.background100
        theme.formSubmitButtonTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.formSubmitButtonTitleDisabledColor = SBUColorSet.onLightTextDisabled
        
        theme.formChipBackgroundNormalColor = SBUColorSet.background50
        theme.formChipBackgroundSelectColor = SBUColorSet.primaryExtraLight
        theme.formChipBackgroundDisableColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formChipBackgroundSubmittedColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formChipTitleNormalColor = SBUColorSet.onLightTextMidEmphasis
        theme.formChipTitleSelectColor = SBUColorSet.primaryMain
        theme.formChipTitleDisableColor = SBUColorSet.onLightTextMidEmphasis
        theme.formChipTitleSubmittedColor = SBUColorSet.onLightTextHighEmphasis
        theme.formChipBorderNormalColor = SBUColorSet.onLightTextDisabled
        theme.formChipBorderSelectColor = SBUColorSet.primaryMain
        theme.formChipBorderDisableColor = SBUColorSet.onDarkTextDisabled
        theme.formChipBorderSubmittedColor = UIColor.clear
        theme.formTitleFont = SBUFontSet.caption3
        theme.formOptionalTitleFont = SBUFontSet.caption3
        theme.formErrorTitleFont = SBUFontSet.caption4
        theme.formInputTextFont = SBUFontSet.body3
        theme.formChipTextFont = SBUFontSet.caption1
        theme.formSubmittButtonFont = SBUFontSet.button3
        
        // Typing message
        theme.typingMessageProfileBorderColor = SBUColorSet.background50
        theme.typingMessageDotColor = SBUColorSet.onLightTextDisabled
        theme.typingMessageDotTransformColor = SBUColorSet.onLightTextLowEmphasis
        
        theme.feedbackRadius = 18
        theme.feedbackIconColor = SBUColorSet.onLightTextMidEmphasis
        theme.feedbackIconSelectColor = SBUColorSet.onDarkTextHighEmphasis
        theme.feedbackIconDeselectColor = SBUColorSet.onLightTextDisabled
        theme.feedbackBorderColor = SBUColorSet.onLightTextDisabled
        theme.feedbackBorderSelectColor = SBUColorSet.primaryMain
        theme.feedbackBorderDeselectColor = SBUColorSet.onLightTextDisabled
        theme.feedbackBackgroundNormalColor = SBUColorSet.background50
        theme.feedbackBackgroundSelectColor = SBUColorSet.primaryMain
        theme.feedbackBackgroundDeselectColor = SBUColorSet.background50
        
        return theme
    }
    
    public static var dark: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = .clear
        
        theme.leftBackgroundColor = SBUColorSet.background400
        theme.leftPressedBackgroundColor = SBUColorSet.primaryExtraDark
        theme.rightBackgroundColor = SBUColorSet.primaryLight
        theme.rightPressedBackgroundColor = SBUColorSet.primaryDark
        
        theme.openChannelBackgroundColor = .clear
        theme.openChannelPressedBackgroundColor = SBUColorSet.background500
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.dateBackgroundColor = SBUColorSet.overlayDark
        
        // User
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.currentUserNameTextColor = SBUColorSet.secondaryLight
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.onDarkTextLowEmphasis
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primaryLight
        theme.failedStateColor = SBUColorSet.errorMain
        theme.succeededStateColor = SBUColorSet.onDarkTextLowEmphasis
        theme.readReceiptStateColor = SBUColorSet.secondaryLight
        theme.deliveryReceiptStateColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.contentBackgroundColor = SBUColorSet.background500
        theme.pressedContentBackgroundColor = SBUColorSet.primaryExtraDark
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userMessageLeftEditTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.userMessageRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.userMessageRightEditTextColor = SBUColorSet.onLightTextMidEmphasis
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background600
        theme.fileIconColor = SBUColorSet.primaryLight
        theme.fileImageBackgroundColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileImageIconColor = SBUColorSet.onLightTextMidEmphasis
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileMessageRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.fileMessagePlaceholderColor = SBUColorSet.onDarkTextMidEmphasis
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescLeftTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.unknownMessageDescRightTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.messageRightHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.onDarkTextHighEmphasis
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.onDarkTextMidEmphasis
        theme.openChannelOGTitleColor = SBUColorSet.primaryLight
        
        theme.linkColor = SBUColorSet.primaryLight
        
        // Quoted Message
        theme.quotedMessageLeftBackgroundColor = SBUColorSet.background500.withAlphaComponent(0.5)
        theme.quotedMessageRightBackgroundColor = SBUColorSet.background500
        theme.quotedFileMessageThumbnailColor = SBUColorSet.onDarkTextMidEmphasis
        theme.quotedMessageTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.quotedMessageTextFont = SBUFontSet.body3
        theme.repliedIconColor = SBUColorSet.onDarkTextLowEmphasis
        theme.repliedToTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.repliedToTextFont = SBUFontSet.caption1
        
        // Thread info
        theme.repliedCountTextColor = SBUColorSet.primaryLight
        theme.repliedCountTextFont = SBUFontSet.caption3
        theme.repliedUsersMoreIconBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.64)
        theme.repliedUsersMoreIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Mention
        theme.mentionTextFont = SBUFontSet.body4
        theme.mentionLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mentionRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.mentionLeftTextBackgroundColor = .clear
        theme.mentionRightTextBackgroundColor = .clear
        
        // Button
        theme.buttonBackgroundColor = SBUColorSet.background400
        theme.buttonTitleColor = SBUColorSet.primaryLight
        theme.sideButtonIconColor = SBUColorSet.onDarkTextLowEmphasis
        theme.newMessageBadgeColor = SBUColorSet.secondaryLight
        
        // Parent info
        theme.parentInfoBackgroundColor = SBUColorSet.background600
        
        theme.parentInfoUserNameTextFont = SBUFontSet.h3
        theme.parentInfoUserNameTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.parentInfoDateFont = SBUFontSet.caption2
        theme.parentInfoDateTextColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.parentInfoMoreButtonTintColor = SBUColorSet.onDarkTextMidEmphasis
        theme.parentInfoSeparateBarColor = SBUColorSet.onDarkTextDisabled

        theme.parentInfoReplyCountTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.parentInfoReplyCountTextFont = SBUFontSet.body3
        
        theme.parentInfoProgressBackgroundColor = SBUColorSet.background400
        
        theme.playerStatusButtonBackgroundColor = SBUColorSet.background600
        theme.playerLoadingButtonTintColor = SBUColorSet.primaryMain
        theme.playerPlayButtonTintColor = SBUColorSet.primaryLight
        theme.playerPauseButtonTintColor = SBUColorSet.primaryLight
        
        // Voice note
        theme.progressTrackTintColor = SBUColorSet.onDarkTextLowEmphasis
        theme.progressTimeFont = SBUFontSet.body3
        theme.progressTimeRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.progressTimeLeftTextColor = SBUColorSet.onDarkTextHighEmphasis

        // suggested reply
        theme.suggestedReplyTitleColor = SBUColorSet.primaryLight
        theme.suggestedReplyBorderColor = SBUColorSet.primaryLight
        theme.suggestedReplyBackgroundColor = SBUColorSet.background600
        theme.suggestedReplyBackgroundSelectedColor = SBUColorSet.background500

        // form
        theme.formBackgroundColor = SBUColorSet.background400
        theme.formTitleColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formOptionalTitleColor = SBUColorSet.onDarkTextLowEmphasis
        theme.formInputBackgroundColor = SBUColorSet.onLightTextLowEmphasis
        theme.formInputBackgroundDoneColor = SBUColorSet.onLightTextDisabled
        theme.formInputTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.formInputIconColor = SBUColorSet.secondaryLight
        theme.formInputBorderNormalColor = SBUColorSet.onDarkTextDisabled
        theme.formInputBorderActiveColor = SBUColorSet.primaryLight
        theme.formInputBorderErrorColor = SBUColorSet.errorMain
        theme.formInputErrorColor = SBUColorSet.errorLight
        theme.formInputPlaceholderColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formSubmitButtonBackgroundColor = SBUColorSet.primaryLight
        theme.formSubmitButtonBackgroundDisabledColor = SBUColorSet.background500
        theme.formSubmitButtonTitleColor = SBUColorSet.onLightTextHighEmphasis
        theme.formSubmitButtonTitleDisabledColor = SBUColorSet.onDarkTextDisabled
        
        theme.formChipBackgroundNormalColor = SBUColorSet.onLightTextLowEmphasis
        theme.formChipBackgroundSelectColor = SBUColorSet.background600
        theme.formChipBackgroundDisableColor = SBUColorSet.background500
        theme.formChipBackgroundSubmittedColor = SBUColorSet.onLightTextDisabled
        theme.formChipTitleNormalColor = SBUColorSet.onDarkTextMidEmphasis
        theme.formChipTitleSelectColor = SBUColorSet.primaryLight
        theme.formChipTitleDisableColor = SBUColorSet.onDarkTextDisabled
        theme.formChipTitleSubmittedColor = SBUColorSet.onDarkTextHighEmphasis
        theme.formChipBorderNormalColor = SBUColorSet.onDarkTextDisabled
        theme.formChipBorderSelectColor = SBUColorSet.primaryLight
        theme.formChipBorderDisableColor = SBUColorSet.background500
        theme.formChipBorderSubmittedColor = UIColor.clear
        
        theme.formTitleFont = SBUFontSet.caption3
        theme.formOptionalTitleFont = SBUFontSet.caption3
        theme.formErrorTitleFont = SBUFontSet.caption4
        theme.formInputTextFont = SBUFontSet.body3
        theme.formChipTextFont = SBUFontSet.caption1
        theme.formSubmittButtonFont = SBUFontSet.button3

        // Typing message
        theme.typingMessageProfileBorderColor = SBUColorSet.background600
        theme.typingMessageDotColor = SBUColorSet.onDarkTextDisabled
        theme.typingMessageDotTransformColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.feedbackRadius = 18
        theme.feedbackIconColor = SBUColorSet.onDarkTextMidEmphasis
        theme.feedbackIconSelectColor = SBUColorSet.onDarkTextHighEmphasis
        theme.feedbackIconDeselectColor = SBUColorSet.onDarkTextDisabled
        theme.feedbackBorderColor = SBUColorSet.onDarkTextDisabled
        theme.feedbackBorderSelectColor = SBUColorSet.primaryLight
        theme.feedbackBorderDeselectColor = SBUColorSet.onDarkTextDisabled
        theme.feedbackBackgroundNormalColor = SBUColorSet.background600
        theme.feedbackBackgroundSelectColor = SBUColorSet.primaryLight
        theme.feedbackBackgroundDeselectColor = SBUColorSet.background600
        
        return theme
    }
    
    public static var overlay: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = .clear
        
        theme.leftBackgroundColor = .clear
        theme.leftPressedBackgroundColor = .clear
        theme.rightBackgroundColor = .clear
        theme.rightPressedBackgroundColor = .clear
        
        theme.openChannelBackgroundColor = .clear
        theme.openChannelPressedBackgroundColor = SBUColorSet.onLightTextLowEmphasis
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.dateBackgroundColor = SBUColorSet.overlayDark
        
        // User
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.currentUserNameTextColor = SBUColorSet.secondaryLight
        
        // TimeLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.onDarkTextLowEmphasis
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primaryLight
        theme.failedStateColor = SBUColorSet.errorMain
        theme.succeededStateColor = SBUColorSet.onDarkTextLowEmphasis
        theme.readReceiptStateColor = SBUColorSet.secondaryMain
        theme.deliveryReceiptStateColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.contentBackgroundColor = SBUColorSet.background500
        theme.pressedContentBackgroundColor = SBUColorSet.primaryExtraDark
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userMessageLeftEditTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        theme.userMessageRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.userMessageRightEditTextColor = SBUColorSet.onLightTextMidEmphasis
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background600
        theme.fileIconColor = SBUColorSet.primaryLight
        theme.fileImageBackgroundColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileImageIconColor = SBUColorSet.onLightTextMidEmphasis
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileMessageRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.fileMessagePlaceholderColor = SBUColorSet.onDarkTextMidEmphasis
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.onDarkTextMidEmphasis
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescLeftTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.unknownMessageDescRightTextColor = SBUColorSet.onLightTextMidEmphasis
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.messageRightHighlightTextColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.onDarkTextHighEmphasis
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.onDarkTextMidEmphasis
        theme.openChannelOGTitleColor = SBUColorSet.primaryLight
        
        theme.linkColor = SBUColorSet.primaryLight
        
        // Quoted Message
        theme.quotedMessageLeftBackgroundColor = SBUColorSet.background500.withAlphaComponent(0.5)
        theme.quotedMessageRightBackgroundColor = SBUColorSet.background500
        theme.quotedFileMessageThumbnailColor = SBUColorSet.onDarkTextMidEmphasis
        theme.quotedMessageTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.quotedMessageTextFont = SBUFontSet.body3
        theme.repliedIconColor = SBUColorSet.onDarkTextLowEmphasis
        theme.repliedToTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.repliedToTextFont = SBUFontSet.caption1
        
        // Thread info
        theme.repliedCountTextColor = SBUColorSet.primaryLight
        theme.repliedCountTextFont = SBUFontSet.caption3
        theme.repliedUsersMoreIconBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.64)
        theme.repliedUsersMoreIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Mention
        theme.mentionTextFont = SBUFontSet.body4
        theme.mentionLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mentionRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.mentionLeftTextBackgroundColor = .clear
        theme.mentionRightTextBackgroundColor = .clear
        
        // Button
        theme.buttonBackgroundColor = SBUColorSet.background400
        theme.buttonTitleColor = SBUColorSet.primaryLight
        theme.sideButtonIconColor = SBUColorSet.onDarkTextLowEmphasis
        theme.newMessageBadgeColor = SBUColorSet.secondaryLight
        
        // Parent info
        theme.parentInfoBackgroundColor = SBUColorSet.background600
        
        theme.parentInfoUserNameTextFont = SBUFontSet.h3
        theme.parentInfoUserNameTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.parentInfoDateFont = SBUFontSet.caption2
        theme.parentInfoDateTextColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.parentInfoMoreButtonTintColor = SBUColorSet.onDarkTextMidEmphasis
        theme.parentInfoSeparateBarColor = SBUColorSet.onDarkTextDisabled

        theme.parentInfoReplyCountTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.parentInfoReplyCountTextFont = SBUFontSet.body3
        
        theme.parentInfoProgressBackgroundColor = SBUColorSet.background400
        
        // Voice note
        theme.progressTrackTintColor = SBUColorSet.onDarkTextLowEmphasis
        theme.progressTimeFont = SBUFontSet.body3
        theme.progressTimeRightTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.progressTimeLeftTextColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.playerStatusButtonBackgroundColor = SBUColorSet.background600
        theme.playerLoadingButtonTintColor = SBUColorSet.primaryMain
        theme.playerPlayButtonTintColor = SBUColorSet.primaryLight
        theme.playerPauseButtonTintColor = SBUColorSet.primaryLight
        
        // suggested reply
        theme.suggestedReplyTitleColor = SBUColorSet.primaryMain
        theme.suggestedReplyBorderColor = SBUColorSet.primaryMain
        theme.suggestedReplyBackgroundColor = SBUColorSet.background50
        theme.suggestedReplyBackgroundSelectedColor = SBUColorSet.background100
        
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                leftBackgroundColor: UIColor = SBUColorSet.background100,
                leftPressedBackgroundColor: UIColor = SBUColorSet.primaryExtraLight,
                rightBackgroundColor: UIColor = SBUColorSet.primaryMain,
                rightPressedBackgroundColor: UIColor = SBUColorSet.primaryDark,
                openChannelBackgroundColor: UIColor = .clear,
                openChannelPressedBackgroundColor: UIColor = SBUColorSet.background100,
                dateFont: UIFont = SBUFontSet.caption1,
                dateTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                dateBackgroundColor: UIColor = SBUColorSet.overlayLight,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                userNameFont: UIFont = SBUFontSet.caption1,
                userNameTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                currentUserNameTextColor: UIColor = SBUColorSet.secondaryMain,
                timeFont: UIFont = SBUFontSet.caption4,
                timeTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                pendingStateColor: UIColor = SBUColorSet.primaryMain,
                failedStateColor: UIColor = SBUColorSet.errorMain,
                succeededStateColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                readReceiptStateColor: UIColor = SBUColorSet.secondaryMain,
                deliveryReceiptStateColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                userMessageFont: UIFont = SBUFontSet.body3,
                userMessageLeftTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                userMessageLeftEditTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                userMessageLeftHighlightTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                userMessageRightTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                userMessageRightEditTextColor: UIColor = SBUColorSet.onDarkTextMidEmphasis,
                userMessageRightHighlightTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                fileIconBackgroundColor: UIColor = SBUColorSet.background50,
                fileImageBackgroundColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                fileImageIconColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                fileIconColor: UIColor = SBUColorSet.primaryMain,
                fileMessageNameFont: UIFont = SBUFontSet.body3,
                fileMessageLeftTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                fileMessageRightTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                fileMessagePlaceholderColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                adminMessageFont: UIFont = SBUFontSet.caption2,
                adminMessageTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                unknownMessageDescFont: UIFont  = SBUFontSet.body3,
                unknownMessageDescLeftTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                unknownMessageDescRightTextColor: UIColor = SBUColorSet.onDarkTextMidEmphasis,
                ogTitleFont: UIFont = SBUFontSet.body2,
                ogTitleColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                ogDescriptionFont: UIFont = SBUFontSet.caption2,
                ogDescriptionColor: UIColor  = SBUColorSet.onLightTextHighEmphasis,
                ogURLAddressFont: UIFont = SBUFontSet.caption2,
                ogURLAddressColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                openChannelOGTitleColor: UIColor = SBUColorSet.primaryMain,
                linkColor: UIColor = SBUColorSet.primaryMain,
                contentBackgroundColor: UIColor = SBUColorSet.background100,
                pressedContentBackgroundColor: UIColor = SBUColorSet.background300,
                quotedMessageLeftBackgroundColor: UIColor = SBUColorSet.background100.withAlphaComponent(0.5),
                quotedMessageRightBackgroundColor: UIColor = SBUColorSet.background100,
                quotedFileMessageThumbnailColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                quotedMessageTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                quotedMessageTextFont: UIFont = SBUFontSet.body3,
                repliedIconColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                repliedToTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                repliedToTextFont: UIFont = SBUFontSet.caption1,
                repliedCountTextColor: UIColor = SBUColorSet.primaryMain,
                repliedCountTextFont: UIFont = SBUFontSet.caption3,
                repliedUsersMoreIconBackgroundColor: UIColor = SBUColorSet.background700.withAlphaComponent(0.64),
                repliedUsersMoreIconTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                mentionTextFont: UIFont = SBUFontSet.body4,
                mentionLeftTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                mentionRightTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                mentionLeftTextBackgroundColor: UIColor = .clear,
                mentionRightTextBackgroundColor: UIColor = .clear,
                buttonBackgroundColor: UIColor = SBUColorSet.background200,
                buttonTitleColor: UIColor = SBUColorSet.primaryMain,
                sideButtonIconColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                newMessageBadgeColor: UIColor = SBUColorSet.secondaryMain,
                parentInfoBackgroundColor: UIColor = SBUColorSet.background50,
                parentInfoUserNameTextFont: UIFont = SBUFontSet.h3,
                parentInfoUserNameTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                parentInfoDateFont: UIFont = SBUFontSet.caption2,
                parentInfoDateTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                parentInfoMoreButtonTintColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                parentInfoSeparateBarColor: UIColor = SBUColorSet.onLightTextDisabled,
                parentInfoReplyCountTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                parentInfoReplyCountTextFont: UIFont = SBUFontSet.body3,
                parentInfoProgressBackgroundColor: UIColor = SBUColorSet.background100,
                progressTrackTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                progressTimeFont: UIFont = SBUFontSet.body3,
                progressTimeRightTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                progressTimeLeftTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                statusButtonBackgroundColor: UIColor = SBUColorSet.background50,
                loadingButtonTintColor: UIColor = SBUColorSet.primaryLight,
                playButtonTintColor: UIColor = SBUColorSet.primaryMain,
                pauseButtonTintColor: UIColor = SBUColorSet.primaryMain,
                suggestedReplyTitleColor: UIColor = SBUColorSet.primaryMain,
                suggestedReplyBorderColor: UIColor = SBUColorSet.primaryMain,
                suggestedReplyBackgroundColor: UIColor = SBUColorSet.background50,
                suggestedReplyBackgroundSelectedColor: UIColor = SBUColorSet.background100,
                multipleFilesMessageFileOverlayColor: UIColor = SBUColorSet.overlayLight,
                formBackgroundColor: UIColor = SBUColorSet.background100,
                formTitleColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                formOptionalTitleColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                formInputBackgroundColor: UIColor = SBUColorSet.background50,
                formInputBackgroundDoneColor: UIColor = SBUColorSet.onDarkTextMidEmphasis,
                formInputTitleColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                formInputIconColor: UIColor = SBUColorSet.secondaryMain,
                formInputBorderNormalColor: UIColor = SBUColorSet.onLightTextDisabled,
                formInputBorderActiveColor: UIColor = SBUColorSet.primaryMain,
                formInputBorderErrorColor: UIColor = SBUColorSet.errorMain,
                formInputErrorColor: UIColor = SBUColorSet.errorMain,
                formInputPlaceholderColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                formSubmitButtonBackgroundColor: UIColor = SBUColorSet.primaryMain,
                formSubmitButtonBackgroundDisabledColor: UIColor = SBUColorSet.background100,
                formSubmitButtonTitleColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                formSubmitButtonTitleDisabledColor: UIColor = SBUColorSet.onLightTextDisabled,
                formChipBackgroundNormalColor: UIColor = SBUColorSet.background50,
                formChipBackgroundSelectColor: UIColor = SBUColorSet.primaryExtraLight,
                formChipBackgroundDisableColor: UIColor = SBUColorSet.onDarkTextDisabled,
                formChipBackgroundSubmittedColor: UIColor = SBUColorSet.onDarkTextDisabled,
                formChipTitleNormalColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                formChipTitleSelectColor: UIColor = SBUColorSet.primaryExtraLight,
                formChipTitleDisableColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                formChipTitleSubmittedColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                formChipBorderNormalColor: UIColor = SBUColorSet.onLightTextDisabled,
                formChipBorderSelectColor: UIColor = SBUColorSet.primaryMain,
                formChipBorderDisableColor: UIColor = SBUColorSet.onDarkTextDisabled,
                formChipBorderSubmittedColor: UIColor = UIColor.clear,
                formTitleFont: UIFont = SBUFontSet.caption3,
                formOptionalTitleFont: UIFont = SBUFontSet.caption3,
                formErrorTitleFont: UIFont = SBUFontSet.caption4,
                formInputTextFont: UIFont = SBUFontSet.body3,
                formChipTextFont: UIFont = SBUFontSet.caption1,
                formSubmittButtonFont: UIFont = SBUFontSet.button3,
                typingMessageProfileBorderColor: UIColor = SBUColorSet.background50,
                typingMessageDotColor: UIColor = SBUColorSet.onLightTextDisabled,
                typingMessageDotTransformColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                feedbackRadius: CGFloat = 18,
                feedbackIconColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                feedbackIconSelectColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                feedbackIconDeselectColor: UIColor = SBUColorSet.onLightTextDisabled,
                feedbackBorderColor: UIColor = SBUColorSet.onLightTextDisabled,
                feedbackBorderSelectColor: UIColor = SBUColorSet.primaryMain,
                feedbackBorderDeselectColor: UIColor = SBUColorSet.onLightTextDisabled,
                feedbackBackgroundNormalColor: UIColor = SBUColorSet.background50,
                feedbackBackgroundSelectColor: UIColor = SBUColorSet.primaryMain,
                feedbackBackgroundDeselectColor: UIColor = SBUColorSet.background50
    ) {
        
        self.backgroundColor = backgroundColor
        self.leftBackgroundColor = leftBackgroundColor
        self.leftPressedBackgroundColor = leftPressedBackgroundColor
        self.rightBackgroundColor = rightBackgroundColor
        self.rightPressedBackgroundColor = rightPressedBackgroundColor
        self.openChannelBackgroundColor = openChannelBackgroundColor
        self.openChannelPressedBackgroundColor = openChannelPressedBackgroundColor
        self.dateFont = dateFont
        self.dateTextColor = dateTextColor
        self.dateBackgroundColor = dateBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userNameFont = userNameFont
        self.userNameTextColor = userNameTextColor
        self.currentUserNameTextColor = currentUserNameTextColor
        self.timeFont = timeFont
        self.timeTextColor = timeTextColor
        self.pendingStateColor = pendingStateColor
        self.failedStateColor = failedStateColor
        self.succeededStateColor = succeededStateColor
        self.readReceiptStateColor = readReceiptStateColor
        self.deliveryReceiptStateColor = deliveryReceiptStateColor
        self.userMessageFont = userMessageFont
        self.userMessageLeftTextColor = userMessageLeftTextColor
        self.userMessageLeftEditTextColor = userMessageLeftEditTextColor
        self.userMessageRightTextColor = userMessageRightTextColor
        self.userMessageRightEditTextColor = userMessageRightEditTextColor
        self.fileIconBackgroundColor = fileIconBackgroundColor
        self.fileImageBackgroundColor = fileImageBackgroundColor
        self.fileImageIconColor = fileImageIconColor
        self.fileIconColor = fileIconColor
        self.fileMessageNameFont = fileMessageNameFont
        self.fileMessageLeftTextColor = fileMessageLeftTextColor
        self.fileMessageRightTextColor = fileMessageRightTextColor
        self.fileMessagePlaceholderColor = fileMessagePlaceholderColor
        
        self.adminMessageFont = adminMessageFont
        self.adminMessageTextColor = adminMessageTextColor
        
        self.unknownMessageDescFont = unknownMessageDescFont
        self.unknownMessageDescLeftTextColor = unknownMessageDescLeftTextColor
        self.unknownMessageDescRightTextColor = unknownMessageDescRightTextColor
        
        self.messageLeftHighlightTextColor = userMessageLeftHighlightTextColor
        self.messageRightHighlightTextColor = userMessageRightHighlightTextColor
        self.ogTitleFont = ogTitleFont
        self.ogTitleColor = ogTitleColor
        self.ogDescriptionFont = ogDescriptionFont
        self.ogDescriptionColor = ogDescriptionColor
        self.ogURLAddressFont = ogURLAddressFont
        self.ogURLAddressColor = ogURLAddressColor
        self.openChannelOGTitleColor = openChannelOGTitleColor
        self.linkColor = linkColor
        self.contentBackgroundColor = contentBackgroundColor
        self.pressedContentBackgroundColor = pressedContentBackgroundColor
        
        self.quotedMessageLeftBackgroundColor = quotedMessageLeftBackgroundColor
        self.quotedMessageRightBackgroundColor = quotedMessageRightBackgroundColor
        self.quotedFileMessageThumbnailColor = quotedFileMessageThumbnailColor
        self.quotedMessageTextColor = quotedMessageTextColor
        self.quotedMessageTextFont = quotedMessageTextFont
        self.repliedIconColor = repliedIconColor
        self.repliedToTextColor = repliedToTextColor
        self.repliedToTextFont = repliedToTextFont
        
        self.repliedCountTextColor = repliedCountTextColor
        self.repliedCountTextFont = repliedCountTextFont
        self.repliedUsersMoreIconBackgroundColor = repliedUsersMoreIconBackgroundColor
        self.repliedUsersMoreIconTintColor = repliedUsersMoreIconTintColor
        
        self.mentionTextFont = mentionTextFont
        self.mentionLeftTextColor = mentionLeftTextColor
        self.mentionRightTextColor = mentionRightTextColor
        self.mentionLeftTextBackgroundColor = mentionLeftTextBackgroundColor
        self.mentionRightTextBackgroundColor = mentionRightTextBackgroundColor
        
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonTitleColor = buttonTitleColor
        self.sideButtonIconColor = sideButtonIconColor
        self.newMessageBadgeColor = newMessageBadgeColor
        
        self.parentInfoBackgroundColor = parentInfoBackgroundColor
        self.parentInfoUserNameTextFont = parentInfoUserNameTextFont
        self.parentInfoUserNameTextColor = parentInfoUserNameTextColor
        self.parentInfoDateFont = parentInfoDateFont
        self.parentInfoDateTextColor = parentInfoDateTextColor
        self.parentInfoMoreButtonTintColor = parentInfoMoreButtonTintColor
        self.parentInfoSeparateBarColor = parentInfoSeparateBarColor
        self.parentInfoReplyCountTextColor = parentInfoReplyCountTextColor
        self.parentInfoReplyCountTextFont = parentInfoReplyCountTextFont
        
        self.parentInfoProgressBackgroundColor = parentInfoProgressBackgroundColor
        
        // MARK: Voice message
        self.progressTrackTintColor = progressTrackTintColor
        self.progressTimeFont = progressTimeFont
        self.progressTimeRightTextColor = progressTimeRightTextColor
        self.progressTimeLeftTextColor = progressTimeLeftTextColor
        
        self.playerStatusButtonBackgroundColor = statusButtonBackgroundColor
        self.playerLoadingButtonTintColor = loadingButtonTintColor
        self.playerPlayButtonTintColor = playButtonTintColor
        self.playerPauseButtonTintColor = pauseButtonTintColor
        
        self.suggestedReplyTitleColor = suggestedReplyTitleColor
        self.suggestedReplyBorderColor = suggestedReplyBorderColor
        self.suggestedReplyBackgroundColor = suggestedReplyBackgroundColor
        self.suggestedReplyBackgroundSelectedColor = suggestedReplyBackgroundSelectedColor
        
        self.multipleFilesMessageFileOverlayColor = multipleFilesMessageFileOverlayColor

        self.formBackgroundColor = formBackgroundColor
        self.formTitleColor = formTitleColor
        self.formOptionalTitleColor = formOptionalTitleColor
        self.formInputBackgroundColor = formInputBackgroundColor
        self.formInputBackgroundDoneColor = formInputBackgroundDoneColor
        self.formInputTitleColor = formInputTitleColor
        self.formInputIconColor = formInputIconColor
        self.formInputBorderNormalColor = formInputBorderNormalColor
        self.formInputBorderActiveColor = formInputBorderActiveColor
        self.formInputBorderErrorColor = formInputBorderErrorColor
        self.formInputErrorColor = formInputErrorColor
        self.formInputPlaceholderColor = formInputPlaceholderColor
        self.formSubmitButtonBackgroundColor = formSubmitButtonBackgroundColor
        self.formSubmitButtonBackgroundDisabledColor = formSubmitButtonBackgroundDisabledColor
        self.formSubmitButtonTitleColor = formSubmitButtonTitleColor
        self.formSubmitButtonTitleDisabledColor = formSubmitButtonTitleDisabledColor
        self.formChipBackgroundNormalColor = formChipBackgroundNormalColor
        self.formChipBackgroundSelectColor = formChipBackgroundSelectColor
        self.formChipBackgroundDisableColor = formChipBackgroundDisableColor
        self.formChipBackgroundSubmittedColor = formChipBackgroundSubmittedColor
        self.formChipTitleNormalColor = formChipTitleNormalColor
        self.formChipTitleSelectColor = formChipTitleSelectColor
        self.formChipTitleDisableColor = formChipTitleDisableColor
        self.formChipTitleSubmittedColor = formChipTitleSubmittedColor
        self.formChipBorderNormalColor = formChipBorderNormalColor
        self.formChipBorderSelectColor = formChipBorderSelectColor
        self.formChipBorderDisableColor = formChipBorderDisableColor
        self.formChipBorderSubmittedColor = formChipBorderSubmittedColor
        
        self.formTitleFont = formTitleFont
        self.formOptionalTitleFont = formOptionalTitleFont
        self.formErrorTitleFont = formErrorTitleFont
        self.formInputTextFont = formInputTextFont
        self.formChipTextFont = formChipTextFont
        self.formSubmittButtonFont = formSubmittButtonFont
        
        self.typingMessageProfileBorderColor = typingMessageProfileBorderColor
        self.typingMessageDotColor = typingMessageDotColor
        self.typingMessageDotTransformColor = typingMessageDotTransformColor
        
        self.feedbackRadius = feedbackRadius
        self.feedbackIconColor = feedbackIconColor
        self.feedbackIconSelectColor = feedbackIconSelectColor
        self.feedbackIconDeselectColor = feedbackIconDeselectColor
        self.feedbackBorderColor = feedbackBorderColor
        self.feedbackBorderSelectColor = feedbackBorderSelectColor
        self.feedbackBorderDeselectColor = feedbackBorderDeselectColor
        self.feedbackBackgroundNormalColor = feedbackBackgroundNormalColor
        self.feedbackBackgroundSelectColor = feedbackBackgroundSelectColor
        self.feedbackBackgroundDeselectColor = feedbackBackgroundDeselectColor
    }
    
    public var backgroundColor: UIColor
    
    public var leftBackgroundColor: UIColor
    public var leftPressedBackgroundColor: UIColor
    public var rightBackgroundColor: UIColor
    public var rightPressedBackgroundColor: UIColor
    
    public var openChannelBackgroundColor: UIColor
    public var openChannelPressedBackgroundColor: UIColor
    
    // Date Label
    public var dateFont: UIFont
    public var dateTextColor: UIColor
    public var dateBackgroundColor: UIColor
    
    // User
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var userNameFont: UIFont
    public var userNameTextColor: UIColor
    public var currentUserNameTextColor: UIColor
    
    // TitleLabel
    public var timeFont: UIFont
    public var timeTextColor: UIColor
    
    // Message state
    public var pendingStateColor: UIColor
    public var failedStateColor: UIColor
    public var succeededStateColor: UIColor
    public var readReceiptStateColor: UIColor
    public var deliveryReceiptStateColor: UIColor
    
    public var contentBackgroundColor: UIColor
    public var pressedContentBackgroundColor: UIColor
    
    // User messgae
    public var userMessageFont: UIFont
    public var userMessageLeftTextColor: UIColor
    public var userMessageLeftEditTextColor: UIColor
    
    public var userMessageRightTextColor: UIColor
    public var userMessageRightEditTextColor: UIColor
    
    // File message
    public var fileIconBackgroundColor: UIColor
    public var fileIconColor: UIColor
    public var fileImageBackgroundColor: UIColor
    public var fileImageIconColor: UIColor
    public var fileMessageNameFont: UIFont
    public var fileMessageLeftTextColor: UIColor
    public var fileMessageRightTextColor: UIColor
    public var fileMessagePlaceholderColor: UIColor
    
    // Multiple Files Message
    public var multipleFilesMessageFileOverlayColor: UIColor
    
    // Admin message
    public var adminMessageFont: UIFont
    public var adminMessageTextColor: UIColor
    
    // Unknown message
    
    public var unknownMessageDescFont: UIFont
    public var unknownMessageDescLeftTextColor: UIColor
    public var unknownMessageDescRightTextColor: UIColor
    
    // Message highlight
    public var messageLeftHighlightTextColor: UIColor
    public var messageRightHighlightTextColor: UIColor
    
    // User message with og tag
    public var ogTitleFont: UIFont
    public var ogTitleColor: UIColor
    public var ogDescriptionFont: UIFont
    public var ogDescriptionColor: UIColor
    public var ogURLAddressFont: UIFont
    public var ogURLAddressColor: UIColor
    
    public var openChannelOGTitleColor: UIColor
    
    public var linkColor: UIColor
    
    // MARK: Quoted message
    // Font
    /// The text font of the quoted message view
    public var quotedMessageTextFont: UIFont
    /// The text font of `repliedToLabel` of the  quoted message view.
    public var repliedToTextFont: UIFont
    
    // Color
    /// The background color of the quoted message view.
    @available(*, deprecated, message: "This property has been separated as the `quotedMessageLeftBackgroundColor` and `quotedMessageRightBackgroundColor`") // 3.5.4
    public var quotedMessageBackgroundColor: UIColor {
        get {
            self.quotedMessageRightBackgroundColor
        }
        set {
            self.quotedMessageLeftBackgroundColor = newValue.withAlphaComponent(0.5)
            self.quotedMessageRightBackgroundColor = newValue
        }
    }
    /// The background color of the left quoted message view.
    /// - Since: 3.5.4
    public var quotedMessageLeftBackgroundColor: UIColor
    /// The background color of the right quoted message view.
    /// - Since: 3.5.4
    public var quotedMessageRightBackgroundColor: UIColor
    
    /// The tint color of thumbnail image of the quoted file message.
    public var quotedFileMessageThumbnailColor: UIColor
    /// The text color of the quoted message view
    public var quotedMessageTextColor: UIColor
    /// The tint color of `SBUIconSet.iconReplied`
    public var repliedIconColor: UIColor
    /// The text color of `repliedToLabel` of the quoted message view.
    public var repliedToTextColor: UIColor
    
    // MARK: Thread info
    // Font
    /// The text font of the replied users count label in thread info view.
    public var repliedCountTextFont: UIFont
    // Color
    /// The text color of the replied users count label in thread info view.
    public var repliedCountTextColor: UIColor
    /// The background color of the replied users more icon.
    public var repliedUsersMoreIconBackgroundColor: UIColor
    /// The tint color of the replied users more icon.
    public var repliedUsersMoreIconTintColor: UIColor
    
    // MARK: Mention
    /// The text font of the mention.
    public var mentionTextFont: UIFont
    /// The text color of the mention on the left message.
    public var mentionLeftTextColor: UIColor
    /// The text color of the mention on the right message.
    public var mentionRightTextColor: UIColor
    /// The background color of the mention on the left message.
    public var mentionLeftTextBackgroundColor: UIColor
    /// The background color of the mention on the right message.
    public var mentionRightTextBackgroundColor: UIColor
    
    // MARK: Button
    /// The background color of the message button.
    public var buttonBackgroundColor: UIColor
    /// The tint color of the message button.
    public var buttonTitleColor: UIColor
    /// The tint color of the additional button.
    public var sideButtonIconColor: UIColor
    
    // MARK: New Message badge
    /// The tint color of new message badge.
    public var newMessageBadgeColor: UIColor
    
    // MARK: Parent info
    public var parentInfoBackgroundColor: UIColor
    public var parentInfoUserNameTextFont: UIFont
    public var parentInfoUserNameTextColor: UIColor
    public var parentInfoDateFont: UIFont
    public var parentInfoDateTextColor: UIColor
    public var parentInfoMoreButtonTintColor: UIColor
    public var parentInfoSeparateBarColor: UIColor
    public var parentInfoReplyCountTextColor: UIColor
    public var parentInfoReplyCountTextFont: UIFont
    
    public var parentInfoProgressBackgroundColor: UIColor
    
    // MARK: Voice message
    public var progressTrackTintColor: UIColor
    public var progressTimeFont: UIFont
    public var progressTimeRightTextColor: UIColor
    public var progressTimeLeftTextColor: UIColor
    
    public var playerStatusButtonBackgroundColor: UIColor
    public var playerLoadingButtonTintColor: UIColor
    public var playerPlayButtonTintColor: UIColor
    public var playerPauseButtonTintColor: UIColor
    
    // suggested replies
    public var suggestedReplyTitleColor: UIColor // 3.11.0
    public var suggestedReplyBorderColor: UIColor // 3.11.0
    public var suggestedReplyBackgroundColor: UIColor // 3.11.0
    public var suggestedReplyBackgroundSelectedColor: UIColor // 3.11.0
    
    // MARK: form
    public var formBackgroundColor: UIColor // 3.11.0
    public var formTitleColor: UIColor // 3.11.0
    public var formOptionalTitleColor: UIColor // 3.11.0
    public var formInputBackgroundColor: UIColor // 3.11.0
    public var formInputBackgroundDoneColor: UIColor // 3.11.0
    public var formInputTitleColor: UIColor // 3.11.0
    public var formInputIconColor: UIColor // 3.11.0
    public var formInputBorderNormalColor: UIColor // 3.11.0
    public var formInputBorderActiveColor: UIColor // 3.27.0
    public var formInputBorderErrorColor: UIColor // 3.27.0
    public var formInputErrorColor: UIColor // 3.11.0
    public var formInputPlaceholderColor: UIColor // 3.11.0
    public var formSubmitButtonBackgroundColor: UIColor // 3.11.0
    public var formSubmitButtonBackgroundDisabledColor: UIColor // 3.11.0
    public var formSubmitButtonTitleColor: UIColor // 3.11.0
    public var formSubmitButtonTitleDisabledColor: UIColor // 3.27.0
    public var formChipBackgroundNormalColor: UIColor // 3.27.0
    public var formChipBackgroundSelectColor: UIColor // 3.27.0
    public var formChipBackgroundDisableColor: UIColor // 3.27.0
    public var formChipBackgroundSubmittedColor: UIColor // 3.27.0
    public var formChipTitleNormalColor: UIColor // 3.27.0
    public var formChipTitleSelectColor: UIColor // 3.27.0
    public var formChipTitleDisableColor: UIColor // 3.27.0    
    public var formChipTitleSubmittedColor: UIColor // 3.27.0
    public var formChipBorderNormalColor: UIColor // 3.27.0
    public var formChipBorderSelectColor: UIColor // 3.27.0
    public var formChipBorderDisableColor: UIColor // 3.27.0
    public var formChipBorderSubmittedColor: UIColor // 3.27.0
    
    public var formTitleFont: UIFont // 3.27.0
    public var formOptionalTitleFont: UIFont // 3.27.0
    public var formErrorTitleFont: UIFont // 3.27.0
    public var formInputTextFont: UIFont // 3.27.0
    public var formChipTextFont: UIFont // 3.27.0
    public var formSubmittButtonFont: UIFont // 3.27.0
    
    // MARK: Typing Message
    public var typingMessageProfileBorderColor: UIColor // 3.12.0
    public var typingMessageDotColor: UIColor // 3.12.0
    public var typingMessageDotTransformColor: UIColor // 3.12.0
    
    // MARK: Feedback
    public var feedbackRadius: CGFloat // 3.15.0
    public var feedbackIconColor: UIColor // 3.15.0
    public var feedbackIconSelectColor: UIColor // 3.15.0
    public var feedbackIconDeselectColor: UIColor // 3.15.0
    public var feedbackBorderColor: UIColor // 3.15.0
    public var feedbackBorderSelectColor: UIColor // 3.15.0
    public var feedbackBorderDeselectColor: UIColor // 3.15.0
    public var feedbackBackgroundNormalColor: UIColor // 3.15.0
    public var feedbackBackgroundSelectColor: UIColor // 3.15.0
    public var feedbackBackgroundDeselectColor: UIColor // 3.15.0
}

// MARK: - User List Theme

public class SBUUserListTheme {
    
    public static var light: SBUUserListTheme {
        let theme = SBUUserListTheme()
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationShadowColor = SBUColorSet.onLightTextDisabled
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.onLightTextDisabled // TODO: need to replace
        theme.rightBarButtonSelectedTintColor = SBUColorSet.primaryMain // TODO: need to replace
        theme.barButtonTintColor = SBUColorSet.primaryMain
        theme.barButtonDisabledTintColor = SBUColorSet.onLightTextDisabled
        theme.backgroundColor = SBUColorSet.background50
        theme.coverImageTintColor = SBUColorSet.onDarkTextHighEmphasis // TODO: need to remove (sample only)
        theme.coverImageBackgroundColor = SBUColorSet.background300 // TODO: need to remove (sample only)
        theme.placeholderTintColor = SBUColorSet.onLightTextLowEmphasis // TODO: need to remove (sample only)
        theme.textfieldTextColor = SBUColorSet.onLightTextHighEmphasis // TODO: need to remove (sample only)
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onLightTextHighEmphasis // TODO: need to remove (sample only)
        theme.itemColor = SBUColorSet.primaryMain // TODO: need to remove (sample only)
        theme.removeColor = SBUColorSet.errorMain // TODO: need to remove (sample only)
        return theme
    }
    public static var dark: SBUUserListTheme {
        let theme = SBUUserListTheme()
        theme.statusBarStyle = .lightContent
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.onDarkTextDisabled // TODO: need to replace
        theme.rightBarButtonSelectedTintColor = SBUColorSet.primaryLight // TODO: need to replace
        theme.barButtonTintColor = SBUColorSet.primaryLight
        theme.barButtonDisabledTintColor = SBUColorSet.onDarkTextDisabled
        theme.backgroundColor = SBUColorSet.background600
        theme.coverImageTintColor = SBUColorSet.onLightTextHighEmphasis // TODO: need to remove (sample only)
        theme.coverImageBackgroundColor = SBUColorSet.background400 // TODO: need to remove (sample only)
        theme.placeholderTintColor = SBUColorSet.onDarkTextLowEmphasis // TODO: need to remove (sample only)
        theme.textfieldTextColor = SBUColorSet.onDarkTextLowEmphasis // TODO: need to remove (sample only)
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onDarkTextHighEmphasis // TODO: need to remove (sample only)
        theme.itemColor = SBUColorSet.primaryLight // TODO: need to remove (sample only)
        theme.removeColor = SBUColorSet.errorMain // TODO: need to remove (sample only)
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.onLightTextDisabled,
                rightBarButtonSelectedTintColor: UIColor = SBUColorSet.primaryMain,
                barButtonTintColor: UIColor = SBUColorSet.primaryMain,
                barButtonDisabledTintColor: UIColor = SBUColorSet.onLightTextDisabled,
                backgroundColor: UIColor = SBUColorSet.background50,
                coverImageTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                coverImageBackgroundColor: UIColor = SBUColorSet.background300,
                itemTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                itemColor: UIColor = SBUColorSet.primaryMain,
                removeColor: UIColor = SBUColorSet.errorMain,
                placeholderTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                textfieldTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis) {
        
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationShadowColor = navigationShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.rightBarButtonSelectedTintColor = rightBarButtonSelectedTintColor
        self.barButtonTintColor = barButtonTintColor
        self.barButtonDisabledTintColor = barButtonDisabledTintColor
        self.backgroundColor = backgroundColor
        self.coverImageTintColor = coverImageTintColor
        self.coverImageBackgroundColor = coverImageBackgroundColor
        self.placeholderTintColor = placeholderTintColor
        self.textfieldTextColor = textfieldTextColor
        self.itemTextColor = itemTextColor
        self.itemColor = itemColor
        self.removeColor = removeColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    public var navigationBarTintColor: UIColor
    // TODO: Rename from `navigationShadowColor` to `navigationBarShadowColor`
    public var navigationShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor // TODO: need to replace
    public var rightBarButtonSelectedTintColor: UIColor // TODO: need to replace
    public var barButtonTintColor: UIColor
    public var barButtonDisabledTintColor: UIColor
    public var backgroundColor: UIColor
    public var coverImageTintColor: UIColor // TODO: need to remove (sample only)
    public var coverImageBackgroundColor: UIColor // TODO: need to remove (sample only)
    public var placeholderTintColor: UIColor // TODO: need to remove (sample only)
    public var textfieldTextColor: UIColor // TODO: need to remove (sample only)
    public var itemTextColor: UIColor // TODO: need to remove (sample only)
    public var itemColor: UIColor // TODO: need to remove (sample only)
    public var removeColor: UIColor // TODO: need to remove (sample only)
}

// MARK: - User Cell Theme

public class SBUUserCellTheme {
    public static var light: SBUUserCellTheme {
        let theme = SBUUserCellTheme()
        theme.backgroundColor = SBUColorSet.background50
        theme.checkboxOnColor = SBUColorSet.primaryMain
        theme.checkboxOffColor = SBUColorSet.onLightTextLowEmphasis
        theme.nicknameTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.nicknameTextFont = SBUFontSet.subtitle2
        theme.nonameTextColor = SBUColorSet.onLightTextDisabled
        theme.userIdTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.userIdTextFont = SBUFontSet.body3
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.mutedStateBackgroundColor = SBUColorSet.primaryMain.withAlphaComponent(0.5)
        theme.mutedStateIconColor = SBUColorSet.onDarkTextHighEmphasis
        theme.subInfoTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.subInfoFont = SBUFontSet.body2
        theme.moreButtonColor = SBUColorSet.onLightTextHighEmphasis
        theme.moreButtonDisabledColor = SBUColorSet.onLightTextDisabled
        theme.separateColor = SBUColorSet.onLightTextDisabled
        return theme
    }
    
    public static var dark: SBUUserCellTheme {
        let theme = SBUUserCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        theme.checkboxOnColor = SBUColorSet.primaryLight
        theme.checkboxOffColor = SBUColorSet.onDarkTextLowEmphasis
        theme.nicknameTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.nicknameTextFont = SBUFontSet.subtitle2
        theme.nonameTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.userIdTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.userIdTextFont = SBUFontSet.body3
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.mutedStateBackgroundColor = SBUColorSet.primaryMain.withAlphaComponent(0.5)
        theme.mutedStateIconColor = SBUColorSet.onDarkTextHighEmphasis
        theme.subInfoTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.subInfoFont = SBUFontSet.body2
        theme.moreButtonColor = SBUColorSet.onDarkTextHighEmphasis
        theme.moreButtonDisabledColor = SBUColorSet.onDarkTextDisabled
        theme.separateColor = SBUColorSet.onDarkTextDisabled
        return theme
    }
    
    public init(
        backgroundColor: UIColor = SBUColorSet.background50,
        checkboxOnColor: UIColor = SBUColorSet.primaryMain,
        checkboxOffColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
        nicknameTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        nicknameFont: UIFont = SBUFontSet.subtitle2,
        nonameTextColor: UIColor = SBUColorSet.onLightTextDisabled,
        userIdTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
        userIdFont: UIFont = SBUFontSet.body3,
        userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
        userPlaceholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
        mutedStateBackgroundColor: UIColor = SBUColorSet.primaryMain.withAlphaComponent(0.5),
        mutedStateIconColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
        subInfoTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
        subInfoFont: UIFont = SBUFontSet.body2,
        moreButtonColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        moreButtonDisabledColor: UIColor = SBUColorSet.onLightTextDisabled,
        separateColor: UIColor = SBUColorSet.onLightTextDisabled
    ) {
        
        self.backgroundColor = backgroundColor
        self.checkboxOnColor = checkboxOnColor
        self.checkboxOffColor = checkboxOffColor
        self.nicknameTextColor = nicknameTextColor
        self.nicknameTextFont = nicknameFont
        self.nonameTextColor = nonameTextColor
        self.userIdTextColor = userIdTextColor
        self.userIdTextFont = userIdFont
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.mutedStateBackgroundColor = mutedStateBackgroundColor
        self.mutedStateIconColor = mutedStateIconColor
        self.subInfoTextColor = subInfoTextColor
        self.subInfoFont = subInfoFont
        self.moreButtonColor = moreButtonColor
        self.moreButtonDisabledColor = moreButtonDisabledColor
        self.separateColor = separateColor
    }
    
    public var backgroundColor: UIColor
    public var checkboxOnColor: UIColor
    public var checkboxOffColor: UIColor
    public var nicknameTextColor: UIColor
    public var nicknameTextFont: UIFont
    public var nonameTextColor: UIColor
    public var userIdTextColor: UIColor
    public var userIdTextFont: UIFont
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var mutedStateBackgroundColor: UIColor
    public var mutedStateIconColor: UIColor
    public var subInfoTextColor: UIColor
    public var subInfoFont: UIFont
    public var moreButtonColor: UIColor
    public var moreButtonDisabledColor: UIColor
    public var separateColor: UIColor
    
    @available(*, unavailable, renamed: "nicknameTextColor")
    public var userNameTextColor: UIColor { self.nicknameTextColor }
    @available(*, unavailable, renamed: "nicknameFont")
    public var userNameFont: UIFont { self.nicknameTextFont }
}

// MARK: - Channel Setting Theme

public class SBUChannelSettingsTheme {
    
    public static var light: SBUChannelSettingsTheme {
        let theme = SBUChannelSettingsTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationShadowColor = SBUColorSet.onLightTextDisabled
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.primaryMain
        theme.backgroundColor = SBUColorSet.background50
        
        // Cell
        theme.cellTextFont = SBUFontSet.subtitle2
        theme.cellTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.cellSubTextFont = SBUFontSet.subtitle2
        theme.cellSubTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.cellDescriptionTextFont = SBUFontSet.body3
        theme.cellDescriptionTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.cellSwitchColor = SBUColorSet.primaryMain
        theme.cellSeparateColor = SBUColorSet.onLightTextDisabled
        theme.cellRadioButtonSelectedColor = SBUColorSet.primaryMain
        theme.cellRadioButtonDeselectedColor = SBUColorSet.onLightTextLowEmphasis
        
        // Cell image
        theme.cellTypeIconTintColor = SBUColorSet.primaryMain
        theme.cellArrowIconTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.cellLeaveIconColor = SBUColorSet.errorMain
        theme.cellDeleteIconColor = SBUColorSet.errorMain
        
        // User Info View // TODO: userName -> channelName
        theme.userNameFont = SBUFontSet.h1
        theme.userNameTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.userPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.itemColor = SBUColorSet.primaryMain
        
        // Alert
        theme.itemDeleteTextColor = SBUColorSet.errorMain
        
        // Url Info
        theme.urlTitleFont = SBUFontSet.body2
        theme.urlTitleColor = SBUColorSet.onLightTextMidEmphasis
        theme.urlFont = SBUFontSet.body1
        theme.urlColor = SBUColorSet.onLightTextHighEmphasis
        
        return theme
    }
    public static var dark: SBUChannelSettingsTheme {
        let theme = SBUChannelSettingsTheme()
        theme.statusBarStyle = .lightContent
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.backgroundColor = SBUColorSet.background600
        
        // Cell
        theme.cellTextFont = SBUFontSet.subtitle2
        theme.cellTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.cellSubTextFont = SBUFontSet.subtitle2
        theme.cellSubTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.cellDescriptionTextFont = SBUFontSet.body3
        theme.cellDescriptionTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.cellSwitchColor = SBUColorSet.primaryLight
        theme.cellSeparateColor = SBUColorSet.onDarkTextDisabled
        theme.cellRadioButtonSelectedColor = SBUColorSet.primaryLight
        theme.cellRadioButtonDeselectedColor = SBUColorSet.onDarkTextLowEmphasis
        
        // Cell image
        theme.cellTypeIconTintColor = SBUColorSet.primaryLight
        theme.cellArrowIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.cellLeaveIconColor = SBUColorSet.errorLight
        theme.cellDeleteIconColor = SBUColorSet.errorLight
        
        // User Info View // TODO: userName -> channelName
        theme.userNameFont = SBUFontSet.h1
        theme.userNameTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.itemColor = SBUColorSet.primaryLight
        
        // Alert
        theme.itemDeleteTextColor = SBUColorSet.errorLight
        
        // Url Info
        theme.urlTitleFont = SBUFontSet.body2
        theme.urlTitleColor = SBUColorSet.onDarkTextMidEmphasis
        theme.urlFont = SBUFontSet.body1
        theme.urlColor = SBUColorSet.onDarkTextHighEmphasis
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                backgroundColor: UIColor = SBUColorSet.background50,
                cellTextFont: UIFont = SBUFontSet.subtitle2,
                cellTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                cellSubTextFont: UIFont = SBUFontSet.subtitle2,
                cellSubTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                cellDescriptionTextFont: UIFont = SBUFontSet.body3,
                cellDescriptionTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                cellSwitchColor: UIColor = SBUColorSet.primaryMain,
                cellSeparateColor: UIColor = SBUColorSet.onLightTextDisabled,
                cellRadioButtonSelectedColor: UIColor = SBUColorSet.primaryMain,
                cellRadioButtonDeselectedColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                cellTypeIconTintColor: UIColor = SBUColorSet.primaryMain,
                cellArrowIconTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                cellLeaveIconColor: UIColor = SBUColorSet.errorMain,
                cellDeleteIconColor: UIColor = SBUColorSet.errorMain,
                userNameFont: UIFont = SBUFontSet.h1,
                userNameTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                userPlaceholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                itemTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                itemColor: UIColor = SBUColorSet.primaryMain,
                itemDeleteTextColor: UIColor = SBUColorSet.errorMain,
                urlTitleFont: UIFont = SBUFontSet.body2,
                urlTitleColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                urlFont: UIFont = SBUFontSet.body1,
                urlColor: UIColor = SBUColorSet.onLightTextHighEmphasis
                ) {
        
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationShadowColor = navigationShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.backgroundColor = backgroundColor
        self.cellTextFont = cellTextFont
        self.cellTextColor = cellTextColor
        self.cellSubTextFont = cellSubTextFont
        self.cellSubTextColor = cellSubTextColor
        self.cellDescriptionTextFont = cellDescriptionTextFont
        self.cellDescriptionTextColor = cellDescriptionTextColor
        self.cellSwitchColor = cellSwitchColor
        self.cellSeparateColor = cellSeparateColor
        self.cellRadioButtonSelectedColor = cellRadioButtonSelectedColor
        self.cellRadioButtonDeselectedColor = cellRadioButtonDeselectedColor
        self.cellTypeIconTintColor = cellTypeIconTintColor
        self.cellArrowIconTintColor = cellArrowIconTintColor
        self.cellLeaveIconColor = cellLeaveIconColor
        self.cellDeleteIconColor = cellDeleteIconColor
        self.userNameFont = userNameFont
        self.userNameTextColor = userNameTextColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.itemTextColor = itemTextColor
        self.itemColor = itemColor
        self.itemDeleteTextColor = itemDeleteTextColor
        self.urlTitleFont = urlTitleFont
        self.urlTitleColor = urlTitleColor
        self.urlFont = urlFont
        self.urlColor = urlColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var navigationBarTintColor: UIColor
    // TODO: Rename from `navigationShadowColor` to `navigationBarShadowColor`
    public var navigationShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var backgroundColor: UIColor
    
    // Cell
    public var cellTextFont: UIFont
    public var cellTextColor: UIColor
    public var cellSubTextFont: UIFont
    public var cellSubTextColor: UIColor
    public var cellDescriptionTextFont: UIFont // 3.0.0
    public var cellDescriptionTextColor: UIColor // 3.0.0
    public var cellSwitchColor: UIColor
    public var cellSeparateColor: UIColor
    public var cellRadioButtonSelectedColor: UIColor
    public var cellRadioButtonDeselectedColor: UIColor
    
    // Cell image
    public var cellTypeIconTintColor: UIColor
    public var cellArrowIconTintColor: UIColor
    public var cellLeaveIconColor: UIColor
    public var cellDeleteIconColor: UIColor
    
    // User Info View
    public var userNameFont: UIFont
    public var userNameTextColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var userPlaceholderBackgroundColor: UIColor
    
    // ActionSheet
    public var itemTextColor: UIColor
    public var itemColor: UIColor
    
    // Alert
    public var itemDeleteTextColor: UIColor
    
    // Url info
    public var urlTitleFont: UIFont
    public var urlTitleColor: UIColor
    public var urlFont: UIFont
    public var urlColor: UIColor
}

public class SBUUserProfileTheme {
    public static var light: SBUUserProfileTheme {
        let theme = SBUUserProfileTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        
        theme.overlayColor = SBUColorSet.overlayLight
        theme.backgroundColor = SBUColorSet.background50
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.usernameTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.usernameFont = SBUFontSet.h1
        theme.largeItemTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.largeItemFont = SBUFontSet.button2
        theme.largeItemBackgroundColor = SBUColorSet.background50
        theme.largeItemHighlightedColor = SBUColorSet.background100
        theme.separatorColor = SBUColorSet.onLightTextDisabled
        theme.informationTitleColor = SBUColorSet.onLightTextMidEmphasis
        theme.informationTitleFont = SBUFontSet.body2
        theme.informationDesctiptionColor = SBUColorSet.onLightTextHighEmphasis
        theme.informationDesctiptionFont = SBUFontSet.body3
        
        // TODO: need to remove (not used)
        theme.userRoleTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.userRoleFont = SBUFontSet.body3
        theme.itemFont = SBUFontSet.caption1
        theme.itemBackgroundColor = SBUColorSet.background100
        theme.itemSelectedBackgroundColor = SBUColorSet.primaryMain
        theme.itemTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.itemSelectedTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.itemHighlightedTintColor = SBUColorSet.errorMain
        
        return theme
    }
    
    public static var dark: SBUUserProfileTheme {
        let theme = SBUUserProfileTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.overlayColor = SBUColorSet.overlayLight
        theme.backgroundColor = SBUColorSet.background500
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.usernameTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.usernameFont = SBUFontSet.h1
        theme.largeItemTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.largeItemFont = SBUFontSet.button2
        theme.largeItemBackgroundColor = SBUColorSet.background500
        theme.largeItemHighlightedColor = SBUColorSet.background400
        theme.separatorColor = SBUColorSet.onDarkTextDisabled
        theme.informationTitleColor = SBUColorSet.onDarkTextMidEmphasis
        theme.informationTitleFont = SBUFontSet.body2
        theme.informationDesctiptionColor = SBUColorSet.onDarkTextHighEmphasis
        theme.informationDesctiptionFont = SBUFontSet.body3
        
        // TODO: need to remove (not used)
        theme.userRoleTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.userRoleFont = SBUFontSet.body3
        theme.itemFont = SBUFontSet.caption1
        theme.itemBackgroundColor = SBUColorSet.background400
        theme.itemSelectedBackgroundColor = SBUColorSet.primaryLight
        theme.itemTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.itemSelectedTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.itemHighlightedTintColor = SBUColorSet.errorMain

        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                overlayColor: UIColor = SBUColorSet.overlayLight,
                backgroundColor: UIColor = SBUColorSet.background50,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                usernameTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                usernameFont: UIFont = SBUFontSet.h1,
                userRoleTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                userRoleFont: UIFont = SBUFontSet.body3,
                largeItemTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                largeItemFont: UIFont = SBUFontSet.button2,
                largeItemBackgroundColor: UIColor = SBUColorSet.background50,
                largeItemHighlightedColor: UIColor = SBUColorSet.background100,
                itemFont: UIFont = SBUFontSet.caption1,
                itemBackgroundColor: UIColor = SBUColorSet.background400,
                itemSelectedBackgroundColor: UIColor = SBUColorSet.primaryMain,
                itemTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                itemSelectedTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                itemHighlightedTintColor: UIColor = SBUColorSet.errorMain,
                separatorColor: UIColor = SBUColorSet.onLightTextDisabled,
                informationTitleColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                informationTitleFont: UIFont = SBUFontSet.body2,
                informationDesctiptionColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                informationDesctiptionFont: UIFont = SBUFontSet.body3) {
        
        self.statusBarStyle = statusBarStyle
        self.overlayColor = overlayColor
        self.backgroundColor = backgroundColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.usernameTextColor = usernameTextColor
        self.usernameFont = usernameFont
        self.largeItemTintColor = largeItemTintColor
        self.largeItemFont = largeItemFont
        self.largeItemBackgroundColor = largeItemBackgroundColor
        self.largeItemHighlightedColor = largeItemHighlightedColor
        self.separatorColor = separatorColor
        self.informationTitleColor = informationTitleColor
        self.informationTitleFont = informationTitleFont
        self.informationDesctiptionColor = informationDesctiptionColor
        self.informationDesctiptionFont = informationDesctiptionFont
        
        // TODO: need to remove (not used)
        self.userRoleTextColor = userRoleTextColor
        self.userRoleFont = userRoleFont
        self.itemFont = itemFont
        self.itemBackgroundColor = itemBackgroundColor
        self.itemSelectedBackgroundColor = itemSelectedBackgroundColor
        self.itemTintColor = itemTintColor
        self.itemSelectedTintColor = itemSelectedTintColor
        self.itemHighlightedTintColor = itemHighlightedTintColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    public var overlayColor: UIColor
    public var backgroundColor: UIColor
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var usernameTextColor: UIColor
    public var usernameFont: UIFont
    public var largeItemTintColor: UIColor
    public var largeItemFont: UIFont
    public var largeItemBackgroundColor: UIColor
    public var largeItemHighlightedColor: UIColor
    public var separatorColor: UIColor
    public var informationTitleColor: UIColor
    public var informationTitleFont: UIFont
    public var informationDesctiptionColor: UIColor
    public var informationDesctiptionFont: UIFont
    
    // TODO: need to remove (not used)
    public var userRoleTextColor: UIColor
    public var userRoleFont: UIFont
    public var itemFont: UIFont
    public var itemBackgroundColor: UIColor
    public var itemSelectedBackgroundColor: UIColor
    public var itemTintColor: UIColor
    public var itemSelectedTintColor: UIColor
    public var itemHighlightedTintColor: UIColor
}

// MARK: - Component

public class SBUComponentTheme {
    public static var light: SBUComponentTheme {
        let theme = SBUComponentTheme()
        theme.emptyViewBackgroundColor = SBUColorSet.background50
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.onLightTextLowEmphasis
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primaryMain
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlayDark
        theme.backgroundColor = SBUColorSet.background50
        theme.highlightedColor = SBUColorSet.background100
        theme.buttonTextColor = SBUColorSet.primaryMain
        theme.separatorColor = SBUColorSet.onLightTextDisabled
        theme.shadowColor = SBUColorSet.background700.withAlphaComponent(0.12)
        theme.closeBarButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        
        // Alert
        theme.alertTitleColor = SBUColorSet.onLightTextHighEmphasis
        theme.alertTitleFont = SBUFontSet.h3
        theme.alertDetailColor = SBUColorSet.onLightTextMidEmphasis
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.onLightTextLowEmphasis
        theme.alertButtonColor = SBUColorSet.primaryMain
        theme.alertErrorColor = SBUColorSet.errorMain
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background100
        theme.alertTextFieldTintColor = SBUColorSet.primaryMain
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.actionSheetItemColor = SBUColorSet.primaryMain
        theme.actionSheetErrorColor = SBUColorSet.errorMain
        theme.actionSheetButtonFont = SBUFontSet.button1
        theme.actionSheetDisabledColor = SBUColorSet.onLightTextDisabled
        
        // New Message
        theme.newMessageFont = SBUFontSet.body2
        theme.newMessageTintColor = SBUColorSet.primaryMain
        theme.newMessageBackground = SBUColorSet.background50
        theme.newMessageHighlighted = SBUColorSet.background100
        theme.newMessageButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.newMessageButtonBackground = SBUColorSet.primaryMain
        theme.newMessageButtonHighlighted = SBUColorSet.primaryDark
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.primaryMain
        theme.scrollBottomButtonBackground = SBUColorSet.background50
        theme.scrollBottomButtonHighlighted = SBUColorSet.background100
        
        // Title View
        theme.titleOnlineStateColor = SBUColorSet.secondaryMain
        theme.titleColor = SBUColorSet.onLightTextHighEmphasis
        theme.titleFont = SBUFontSet.h3
        theme.titleStatusColor = SBUColorSet.onLightTextLowEmphasis
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.placeholderBackgroundColor = SBUColorSet.background300
        theme.placeholderTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background50
        theme.reactionBoxBorderLineColor = SBUColorSet.background100
        theme.reactionBoxEmojiCountColor = SBUColorSet.onLightTextHighEmphasis
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background100
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primaryExtraLight
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.onLightTextLowEmphasis
        theme.emojiSelectedCountColor = SBUColorSet.primaryMain
        theme.emojiSelectedUnderlineColor = SBUColorSet.primaryMain
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.onLightTextDisabled
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primaryExtraLight
        
        theme.addReactionTintColor = SBUColorSet.onLightTextLowEmphasis
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primaryMain
        theme.channelTypeSelectorItemTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondaryMain
        theme.broadcastIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.barItemTintColor = SBUColorSet.primaryMain
        
        // Loading
        theme.loadingBackgroundColor = .clear
        theme.loadingPopupBackgroundColor = .clear
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.loadingSpinnerColor = SBUColorSet.primaryMain
        
        // Toast
        theme.toastContainerColor = SBUColorSet.background700 // 3.15.0
        theme.toastTitleColor = SBUColorSet.onDarkTextHighEmphasis // 3.15.0

        // Feedback
        theme.feedbackToastUpdateDoneColor = SBUColorSet.secondaryLight // 3.15.0
        
        return theme
    }
    
    public static var dark: SBUComponentTheme {
        let theme = SBUComponentTheme()
        
        theme.emptyViewBackgroundColor = SBUColorSet.background600
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primaryLight
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlayLight
        theme.backgroundColor = SBUColorSet.background500
        theme.highlightedColor = SBUColorSet.background400
        theme.buttonTextColor = SBUColorSet.primaryLight
        theme.separatorColor = SBUColorSet.onDarkTextDisabled
        theme.shadowColor = SBUColorSet.background700.withAlphaComponent(0.36)
        theme.closeBarButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Alert
        theme.alertTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.alertTitleFont = SBUFontSet.h3
        
        theme.alertDetailColor = SBUColorSet.onDarkTextMidEmphasis
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.alertButtonColor = SBUColorSet.primaryLight
        theme.alertErrorColor = SBUColorSet.errorLight
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background400
        theme.alertTextFieldTintColor = SBUColorSet.primaryLight
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.actionSheetItemColor = SBUColorSet.primaryLight
        theme.actionSheetErrorColor = SBUColorSet.errorLight
        theme.actionSheetButtonFont = SBUFontSet.button1
        theme.actionSheetDisabledColor = SBUColorSet.onDarkTextDisabled
        
        // New Message
        theme.newMessageFont = SBUFontSet.body2
        theme.newMessageTintColor = SBUColorSet.primaryLight
        theme.newMessageBackground = SBUColorSet.background400
        theme.newMessageHighlighted = SBUColorSet.background500
        theme.newMessageButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.newMessageButtonBackground = SBUColorSet.primaryLight
        theme.newMessageButtonHighlighted = SBUColorSet.primaryMain
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.primaryLight
        theme.scrollBottomButtonBackground = SBUColorSet.background400
        theme.scrollBottomButtonHighlighted = SBUColorSet.background500
        
        // Title View
        theme.titleOnlineStateColor = SBUColorSet.secondaryLight
        theme.titleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.titleFont = SBUFontSet.h3
        theme.titleStatusColor = SBUColorSet.onDarkTextLowEmphasis
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.placeholderBackgroundColor = SBUColorSet.background400
        theme.placeholderTintColor = SBUColorSet.onLightTextHighEmphasis
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background600
        theme.reactionBoxBorderLineColor = SBUColorSet.background400
        theme.reactionBoxEmojiCountColor = SBUColorSet.onDarkTextHighEmphasis
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background400
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primaryExtraDark
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.onDarkTextLowEmphasis
        theme.emojiSelectedCountColor = SBUColorSet.primaryLight
        theme.emojiSelectedUnderlineColor = SBUColorSet.primaryLight
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.onDarkTextDisabled
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primaryDark
        
        theme.addReactionTintColor = SBUColorSet.onDarkTextLowEmphasis
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primaryLight
        theme.channelTypeSelectorItemTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondaryLight
        theme.broadcastIconTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.barItemTintColor = SBUColorSet.primaryLight
        
        // Loading
        theme.loadingBackgroundColor = .clear
        theme.loadingPopupBackgroundColor = .clear
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.loadingSpinnerColor = SBUColorSet.primaryLight
        
        // Toast
        theme.toastContainerColor = SBUColorSet.onDarkTextHighEmphasis // 3.15.0
        theme.toastTitleColor = SBUColorSet.onLightTextHighEmphasis // 3.15.0
        
        theme.feedbackToastUpdateDoneColor = SBUColorSet.secondaryMain // 3.15.0
        
        return theme
    }
    
    public static var overlay: SBUComponentTheme {
        let theme = SBUComponentTheme()
        
        theme.emptyViewBackgroundColor = .clear
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.onDarkTextLowEmphasis
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primaryLight
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlayLight
        theme.backgroundColor = SBUColorSet.onLightTextLowEmphasis
        theme.highlightedColor = SBUColorSet.background400
        theme.buttonTextColor = SBUColorSet.primaryLight
        theme.separatorColor = SBUColorSet.onDarkTextDisabled
        theme.shadowColor = SBUColorSet.background700.withAlphaComponent(0.36)
        theme.closeBarButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Alert
        theme.alertTitleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.alertTitleFont = SBUFontSet.h3
        
        theme.alertDetailColor = SBUColorSet.onDarkTextMidEmphasis
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.alertButtonColor = SBUColorSet.primaryLight
        theme.alertErrorColor = SBUColorSet.errorMain
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background400
        theme.alertTextFieldTintColor = SBUColorSet.primaryLight
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.actionSheetItemColor = SBUColorSet.primaryLight
        theme.actionSheetErrorColor = SBUColorSet.errorMain
        theme.actionSheetButtonFont = SBUFontSet.button1
        theme.actionSheetDisabledColor = SBUColorSet.onDarkTextDisabled
        
        // New Message
        theme.newMessageFont = SBUFontSet.body2
        theme.newMessageTintColor = SBUColorSet.primaryLight
        theme.newMessageBackground = SBUColorSet.background400
        theme.newMessageHighlighted = SBUColorSet.background500
        theme.newMessageButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.newMessageButtonBackground = SBUColorSet.primaryLight
        theme.newMessageButtonHighlighted = SBUColorSet.primaryMain
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.onDarkTextHighEmphasis
        theme.scrollBottomButtonBackground = SBUColorSet.background400
        theme.scrollBottomButtonHighlighted = SBUColorSet.background500
        
        // Title View
        theme.titleOnlineStateColor = SBUColorSet.secondaryLight
        theme.titleColor = SBUColorSet.onDarkTextHighEmphasis
        theme.titleFont = SBUFontSet.h3
        theme.titleStatusColor = SBUColorSet.onDarkTextLowEmphasis
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.placeholderBackgroundColor = SBUColorSet.background400
        theme.placeholderTintColor = SBUColorSet.onLightTextHighEmphasis
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background600
        theme.reactionBoxBorderLineColor = SBUColorSet.background400
        theme.reactionBoxEmojiCountColor = SBUColorSet.onDarkTextHighEmphasis
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background400
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primaryExtraDark
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.onDarkTextLowEmphasis
        theme.emojiSelectedCountColor = SBUColorSet.primaryLight
        theme.emojiSelectedUnderlineColor = SBUColorSet.primaryLight
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.onDarkTextDisabled
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primaryDark
        
        theme.addReactionTintColor = SBUColorSet.onDarkTextLowEmphasis
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primaryLight
        theme.channelTypeSelectorItemTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondaryLight
        theme.broadcastIconTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.barItemTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        // Loading
        theme.loadingBackgroundColor = .clear
        theme.loadingPopupBackgroundColor = .clear
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.loadingSpinnerColor = SBUColorSet.primaryLight
        
        // Toast
        theme.toastContainerColor = SBUColorSet.onDarkTextHighEmphasis // 3.15.0
        theme.toastTitleColor = SBUColorSet.onLightTextHighEmphasis // 3.15.0
        
        theme.feedbackToastUpdateDoneColor = SBUColorSet.secondaryLight // 3.15.0
        
        return theme
    }
    
    public init(emptyViewBackgroundColor: UIColor = SBUColorSet.background50,
                emptyViewStatusFont: UIFont = SBUFontSet.body3,
                emptyViewStatusTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                emptyViewRetryButtonTintColor: UIColor = SBUColorSet.primaryMain,
                emptyViewRetryButtonFont: UIFont = SBUFontSet.button2,
                overlayColor: UIColor = SBUColorSet.overlayDark,
                backgroundColor: UIColor = SBUColorSet.background50,
                highlightedColor: UIColor = SBUColorSet.background100,
                buttonTextColor: UIColor = SBUColorSet.primaryMain,
                separatorColor: UIColor = SBUColorSet.onLightTextDisabled,
                shadowColor: UIColor = SBUColorSet.background700.withAlphaComponent(0.12),
                closeBarButtonTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                alertTitleColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                alertTitleFont: UIFont = SBUFontSet.h3,
                alertDetailColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                alertDetailFont: UIFont = SBUFontSet.body3,
                alertPlaceholderColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                alertButtonColor: UIColor = SBUColorSet.primaryMain,
                alertErrorColor: UIColor = SBUColorSet.errorMain,
                alertButtonFont: UIFont = SBUFontSet.button2,
                alertTextFieldBackgroundColor: UIColor = SBUColorSet.background100,
                alertTextFieldTintColor: UIColor = SBUColorSet.primaryMain,
                alertTextFieldFont: UIFont = SBUFontSet.body3,
                actionSheetTextFont: UIFont = SBUFontSet.subtitle1,
                actionSheetTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                actionSheetSubTextFont: UIFont = SBUFontSet.body2,
                actionSheetSubTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                actionSheetItemColor: UIColor = SBUColorSet.primaryMain,
                actionSheetErrorColor: UIColor = SBUColorSet.errorMain,
                actionSheetButtonFont: UIFont = SBUFontSet.button1,
                actionSheetDisabledColor: UIColor = SBUColorSet.onLightTextDisabled,
                newMessageFont: UIFont = SBUFontSet.body2,
                newMessageTintColor: UIColor = SBUColorSet.primaryMain,
                newMessageBackground: UIColor = SBUColorSet.background50,
                newMessageHighlighted: UIColor = SBUColorSet.background100,
                newMessageButtonTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                newMessageButtonBackground: UIColor = SBUColorSet.primaryMain,
                newMessageButtonHighlighted: UIColor = SBUColorSet.primaryDark,
                scrollBottomButtonIconColor: UIColor = SBUColorSet.primaryMain,
                scrollBottomButtonBackground: UIColor = SBUColorSet.background50,
                scrollBottomButtonHighlighted: UIColor = SBUColorSet.background100,
                titleOnlineStateColor: UIColor = SBUColorSet.secondaryMain,
                titleColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                titleFont: UIFont = SBUFontSet.h3,
                titleStatusColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                titleStatusFont: UIFont = SBUFontSet.caption2,
                menuTitleFont: UIFont = SBUFontSet.subtitle2,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                placeholderBackgroundColor: UIColor = SBUColorSet.background300,
                placeholderTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                reactionBoxBackgroundColor: UIColor = SBUColorSet.background50,
                reactionBoxBorderLineColor: UIColor = SBUColorSet.background100,
                reactionBoxEmojiCountColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                reactionBoxEmojiBackgroundColor: UIColor = SBUColorSet.background100,
                reactionBoxSelectedEmojiBackgroundColor: UIColor = SBUColorSet.primaryExtraLight,
                reactionBoxEmojiCountFont: UIFont = SBUFontSet.caption4,
                emojiCountColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                emojiSelectedCountColor: UIColor = SBUColorSet.primaryMain,
                emojiSelectedUnderlineColor: UIColor = SBUColorSet.primaryMain,
                emojiCountFont: UIFont = SBUFontSet.button3,
                reactionMenuLineColor: UIColor = SBUColorSet.onDarkTextDisabled,
                emojiListSelectedBackgroundColor: UIColor = SBUColorSet.primaryExtraLight,
                addReactionTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                channelTypeSelectorItemTintColor: UIColor = SBUColorSet.primaryMain,
                channelTypeSelectorItemTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                channelTypeSelectorItemFont: UIFont = SBUFontSet.caption2,
                broadcastIconBackgroundColor: UIColor = SBUColorSet.secondaryMain,
                broadcastIconTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                barItemTintColor: UIColor = SBUColorSet.primaryMain,
                loadingBackgroundColor: UIColor = .clear,
                loadingPopupBackgroundColor: UIColor = .clear,
                loadingFont: UIFont = SBUFontSet.subtitle2,
                loadingTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
                loadingSpinnerColor: UIColor = SBUColorSet.primaryMain,
                toastContainerColor: UIColor = SBUColorSet.background700, // 3.15.0
                toastTitleColor: UIColor = SBUColorSet.onDarkTextHighEmphasis, // 3.15.0
                feedbackToastUpdateDoneColor: UIColor = SBUColorSet.secondaryLight // 3.15.0
    ) {
        
        self.emptyViewBackgroundColor = emptyViewBackgroundColor
        self.emptyViewStatusFont = emptyViewStatusFont
        self.emptyViewStatusTintColor = emptyViewStatusTintColor
        self.emptyViewRetryButtonTintColor = emptyViewRetryButtonTintColor
        self.emptyViewRetryButtonFont = emptyViewRetryButtonFont
        self.overlayColor = overlayColor
        self.backgroundColor = backgroundColor
        self.highlightedColor = highlightedColor
        self.buttonTextColor = buttonTextColor
        self.separatorColor = separatorColor
        self.shadowColor = shadowColor
        self.closeBarButtonTintColor = closeBarButtonTintColor
        self.alertTitleColor = alertTitleColor
        self.alertTitleFont = alertTitleFont
        self.alertDetailColor = alertDetailColor
        self.alertDetailFont = alertDetailFont
        self.alertPlaceholderColor = alertPlaceholderColor
        self.alertButtonColor = alertButtonColor
        self.alertErrorColor = alertErrorColor
        self.alertButtonFont = alertButtonFont
        self.alertTextFieldBackgroundColor = alertTextFieldBackgroundColor
        self.alertTextFieldTintColor = alertTextFieldTintColor
        self.alertTextFieldFont = alertTextFieldFont
        self.actionSheetTextFont = actionSheetTextFont
        self.actionSheetTextColor = actionSheetTextColor
        self.actionSheetSubTextFont = actionSheetSubTextFont
        self.actionSheetSubTextColor = actionSheetSubTextColor
        self.actionSheetItemColor = actionSheetItemColor
        self.actionSheetErrorColor = actionSheetErrorColor
        self.actionSheetButtonFont = actionSheetButtonFont
        self.actionSheetDisabledColor = actionSheetDisabledColor
        self.newMessageFont = newMessageFont
        self.newMessageTintColor = newMessageTintColor
        self.newMessageBackground = newMessageBackground
        self.newMessageHighlighted = newMessageHighlighted
        self.newMessageButtonTintColor = newMessageButtonTintColor
        self.newMessageButtonBackground = newMessageButtonBackground
        self.newMessageButtonHighlighted = newMessageButtonHighlighted
        self.scrollBottomButtonIconColor = scrollBottomButtonIconColor
        self.scrollBottomButtonBackground = scrollBottomButtonBackground
        self.scrollBottomButtonHighlighted = scrollBottomButtonHighlighted
        self.titleOnlineStateColor = titleOnlineStateColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleStatusColor = titleStatusColor
        self.titleStatusFont = titleStatusFont
        self.menuTitleFont = menuTitleFont
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.placeholderTintColor = placeholderTintColor
        self.placeholderBackgroundColor = placeholderBackgroundColor
        
        // Reaction
        self.reactionBoxBackgroundColor = reactionBoxBackgroundColor
        self.reactionBoxBorderLineColor = reactionBoxBorderLineColor
        self.reactionBoxEmojiCountColor = reactionBoxEmojiCountColor
        self.reactionBoxEmojiBackgroundColor = reactionBoxEmojiBackgroundColor
        self.reactionBoxSelectedEmojiBackgroundColor = reactionBoxSelectedEmojiBackgroundColor
        self.reactionBoxEmojiCountFont = reactionBoxEmojiCountFont
        self.emojiCountColor = emojiCountColor
        self.emojiSelectedCountColor = emojiSelectedCountColor
        self.emojiSelectedUnderlineColor = emojiSelectedUnderlineColor
        self.emojiCountFont = emojiCountFont
        self.reactionMenuLineColor = reactionMenuLineColor
        self.emojiListSelectedBackgroundColor = emojiListSelectedBackgroundColor
        self.addReactionTintColor = addReactionTintColor
        
        // Create channel type
        self.channelTypeSelectorItemTintColor = channelTypeSelectorItemTintColor
        self.channelTypeSelectorItemTextColor = channelTypeSelectorItemTextColor
        self.channelTypeSelectorItemFont = channelTypeSelectorItemFont
        
        // Icon
        self.broadcastIconBackgroundColor = broadcastIconBackgroundColor
        self.broadcastIconTintColor = broadcastIconTintColor
        self.barItemTintColor = barItemTintColor
        
        // Loading
        self.loadingBackgroundColor = loadingBackgroundColor
        self.loadingPopupBackgroundColor = loadingPopupBackgroundColor
        self.loadingFont = loadingFont
        self.loadingTextColor = loadingTextColor
        self.loadingSpinnerColor = loadingSpinnerColor
        
        // Toast
        self.toastContainerColor = toastContainerColor // 3.15.0
        self.toastTitleColor = toastTitleColor // 3.15.0
        
        // Feedback toast
        self.feedbackToastUpdateDoneColor = feedbackToastUpdateDoneColor // 3.15.0
    }
    
    // EmptyView
    public var emptyViewBackgroundColor: UIColor
    public var emptyViewStatusFont: UIFont
    public var emptyViewStatusTintColor: UIColor
    public var emptyViewRetryButtonTintColor: UIColor
    public var emptyViewRetryButtonFont: UIFont
    
    // Alert
    public var alertTitleColor: UIColor
    public var alertTitleFont: UIFont
    public var alertDetailColor: UIColor
    public var alertDetailFont: UIFont
    public var alertPlaceholderColor: UIColor
    public var alertButtonColor: UIColor
    public var alertErrorColor: UIColor
    public var alertButtonFont: UIFont
    public var alertTextFieldBackgroundColor: UIColor
    public var alertTextFieldTintColor: UIColor
    public var alertTextFieldFont: UIFont
    
    // Action Sheet
    public var actionSheetTextFont: UIFont
    public var actionSheetTextColor: UIColor
    public var actionSheetSubTextFont: UIFont
    public var actionSheetSubTextColor: UIColor
    public var actionSheetItemColor: UIColor
    public var actionSheetErrorColor: UIColor
    public var actionSheetButtonFont: UIFont
    public var actionSheetDisabledColor: UIColor
    
    // New Message
    public var newMessageFont: UIFont
    public var newMessageTintColor: UIColor
    public var newMessageBackground: UIColor
    public var newMessageHighlighted: UIColor
    public var newMessageButtonTintColor: UIColor
    public var newMessageButtonBackground: UIColor
    public var newMessageButtonHighlighted: UIColor
    
    // Scroll Bottom
    public var scrollBottomButtonIconColor: UIColor
    public var scrollBottomButtonBackground: UIColor
    public var scrollBottomButtonHighlighted: UIColor
    
    // Title View
    public var titleOnlineStateColor: UIColor
    public var titleColor: UIColor
    public var titleFont: UIFont
    public var titleStatusColor: UIColor
    public var titleStatusFont: UIFont
    
    // Menu
    public var menuTitleFont: UIFont
    
    // Common
    public var overlayColor: UIColor
    public var backgroundColor: UIColor
    public var highlightedColor: UIColor
    public var buttonTextColor: UIColor
    public var separatorColor: UIColor
    public var shadowColor: UIColor
    public var closeBarButtonTintColor: UIColor
    
    // placeholder
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    
    public var placeholderBackgroundColor: UIColor
    public var placeholderTintColor: UIColor
    
    // Emoji reaction box
    public var reactionBoxBackgroundColor: UIColor
    public var reactionBoxBorderLineColor: UIColor
    
    // Emoji Common
    public var reactionBoxEmojiCountColor: UIColor
    public var reactionBoxEmojiBackgroundColor: UIColor
    public var reactionBoxSelectedEmojiBackgroundColor: UIColor
    public var reactionBoxEmojiCountFont: UIFont
    
    public var emojiCountColor: UIColor
    public var emojiSelectedCountColor: UIColor
    public var emojiSelectedUnderlineColor: UIColor
    public var emojiCountFont: UIFont
    
    public var emojiListSelectedBackgroundColor: UIColor
    
    // Reacted user list
    public var reactionMenuLineColor: UIColor
    
    // Add reaction
    public var addReactionTintColor: UIColor
    
    // Create channel type
    public var channelTypeSelectorItemTintColor: UIColor
    public var channelTypeSelectorItemTextColor: UIColor
    public var channelTypeSelectorItemFont: UIFont
    
    // Icon
    public var broadcastIconBackgroundColor: UIColor
    public var broadcastIconTintColor: UIColor
    public var barItemTintColor: UIColor
    
    // Loading
    public var loadingBackgroundColor: UIColor
    public var loadingPopupBackgroundColor: UIColor
    public var loadingFont: UIFont
    public var loadingTextColor: UIColor
    public var loadingSpinnerColor: UIColor
    
    // Toast
    public var toastContainerColor: UIColor // 3.15.0
    public var toastTitleColor: UIColor // 3.15.0
    
    // Feedback
    public var feedbackToastUpdateDoneColor: UIColor // 3.15.0
}

// MARK: - Message Search Theme

public class SBUMessageSearchTheme {
    
    public static var light: SBUMessageSearchTheme {
        let theme = SBUMessageSearchTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarStyle = .default
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onLightTextDisabled
        theme.backgroundColor = SBUColorSet.background50
        
        theme.searchTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.searchTextFont = SBUFontSet.body3
        theme.searchTextBackgroundColor = SBUColorSet.background100
        theme.searchPlaceholderColor = SBUColorSet.onLightTextLowEmphasis
        theme.searchIconTintColor = SBUColorSet.onLightTextLowEmphasis
        theme.clearIconTintColor = SBUColorSet.onLightTextLowEmphasis
        theme.cancelButtonTintColor = SBUColorSet.primaryDark
        
        return theme
    }
    
    public static var dark: SBUMessageSearchTheme {
        let theme = SBUMessageSearchTheme()
        
        theme.statusBarStyle = .lightContent
        theme.navigationBarStyle = .black
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.backgroundColor = SBUColorSet.background600
        
        theme.searchTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.searchTextFont = SBUFontSet.body3
        theme.searchTextBackgroundColor = SBUColorSet.background400
        theme.searchPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.searchIconTintColor = SBUColorSet.onDarkTextLowEmphasis
        theme.clearIconTintColor = SBUColorSet.onDarkTextLowEmphasis
        theme.cancelButtonTintColor = SBUColorSet.primaryLight
        
        return theme
    }
    
    public var statusBarStyle: UIStatusBarStyle
    public var navigationBarStyle: UIBarStyle
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor
    
    public var backgroundColor: UIColor
    
    public var searchTextColor: UIColor
    public var searchTextFont: UIFont
    public var searchTextBackgroundColor: UIColor
    public var searchPlaceholderColor: UIColor
    
    public var searchIconTintColor: UIColor
    public var clearIconTintColor: UIColor
    public var cancelButtonTintColor: UIColor
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarStyle: UIBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                backgroundColor: UIColor = SBUColorSet.background50,
                searchTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                searchTextFont: UIFont = SBUFontSet.body3,
                searchTextBackgroundColor: UIColor = SBUColorSet.background100,
                searchPlaceholderColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                searchIconTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                clearIconTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                cancelButtonTintColor: UIColor = SBUColorSet.primaryDark) {
        
        self.statusBarStyle = statusBarStyle
        self.navigationBarStyle = navigationBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.backgroundColor = backgroundColor
        self.searchTextColor = searchTextColor
        self.searchTextFont = searchTextFont
        self.searchTextBackgroundColor = searchTextBackgroundColor
        self.searchPlaceholderColor = searchPlaceholderColor
        self.searchIconTintColor = searchIconTintColor
        self.clearIconTintColor = clearIconTintColor
        self.cancelButtonTintColor = cancelButtonTintColor
    }
}

// MARK: - Message Search Result Theme

public class SBUMessageSearchResultCellTheme {
    
    public static var light: SBUMessageSearchResultCellTheme {
        let theme = SBUMessageSearchResultCellTheme()
        
        theme.backgroundColor = SBUColorSet.background50
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.descriptionFont = SBUFontSet.body3
        theme.descriptionTextColor = SBUColorSet.onLightTextLowEmphasis
        theme.updatedAtFont = SBUFontSet.caption2
        theme.updatedAtTextColor = SBUColorSet.onLightTextMidEmphasis
        theme.fileMessageFont = SBUFontSet.body3
        theme.fileMessageTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.fileMessageIconBackgroundColor = SBUColorSet.background100
        theme.fileMessageIconTintColor = SBUColorSet.onLightTextMidEmphasis
        theme.separatorLineColor = SBUColorSet.onLightTextDisabled
        
        return theme
    }
    
    public static var dark: SBUMessageSearchResultCellTheme {
        let theme = SBUMessageSearchResultCellTheme()
        
        theme.backgroundColor = SBUColorSet.background600
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.descriptionFont = SBUFontSet.body3
        theme.descriptionTextColor = SBUColorSet.onDarkTextLowEmphasis
        theme.updatedAtFont = SBUFontSet.caption2
        theme.updatedAtTextColor = SBUColorSet.onDarkTextMidEmphasis
        theme.fileMessageFont = SBUFontSet.body3
        theme.fileMessageTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.fileMessageIconBackgroundColor = SBUColorSet.background500
        theme.fileMessageIconTintColor = SBUColorSet.onDarkTextMidEmphasis
        theme.separatorLineColor = SBUColorSet.onDarkTextDisabled
        
        return theme
    }
    
    public var backgroundColor: UIColor
    public var titleFont: UIFont
    public var titleTextColor: UIColor
    public var descriptionFont: UIFont
    public var descriptionTextColor: UIColor
    public var updatedAtFont: UIFont
    public var updatedAtTextColor: UIColor
    public var fileMessageFont: UIFont
    public var fileMessageTextColor: UIColor
    public var fileMessageIconBackgroundColor: UIColor
    public var fileMessageIconTintColor: UIColor
    public var separatorLineColor: UIColor
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                titleFont: UIFont = SBUFontSet.subtitle1,
                titleTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                descriptionFont: UIFont = SBUFontSet.body3,
                descriptionTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                updatedAtFont: UIFont = SBUFontSet.caption2,
                updatedAtTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                fileMessageFont: UIFont = SBUFontSet.body3,
                fileMessageTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                fileMessageIconBackgroundColor: UIColor = SBUColorSet.background100,
                fileMessageIconTintColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
                separatorLineColor: UIColor = SBUColorSet.onLightTextDisabled) {
        
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleTextColor = titleTextColor
        self.descriptionFont = descriptionFont
        self.descriptionTextColor = descriptionTextColor
        self.updatedAtFont = updatedAtFont
        self.updatedAtTextColor = updatedAtTextColor
        self.fileMessageFont = fileMessageFont
        self.fileMessageTextColor = fileMessageTextColor
        self.fileMessageIconBackgroundColor = fileMessageIconBackgroundColor
        self.fileMessageIconTintColor = fileMessageIconTintColor
        self.separatorLineColor = separatorLineColor
    }
}

// MARK: - Create open channel Theme

public class SBUCreateOpenChannelTheme {
    
    public static var light: SBUCreateOpenChannelTheme {
        let theme = SBUCreateOpenChannelTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        
        theme.leftBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonTintColor = SBUColorSet.primaryMain
        theme.rightBarButtonDisabledTintColor = SBUColorSet.onLightTextDisabled
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onLightTextDisabled
        
        theme.backgroundColor = SBUColorSet.background50
        theme.textFieldPlaceholderColor = SBUColorSet.onLightTextLowEmphasis
        theme.textFieldTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.textFieldFont = SBUFontSet.subtitle1
        theme.textFieldUnderlineColor = SBUColorSet.onLightTextDisabled
        
        theme.actionSheetItemColor = SBUColorSet.primaryMain
        theme.actionSheetTextColor = SBUColorSet.onLightTextHighEmphasis
        theme.actionSheetRemoveTextColor = SBUColorSet.errorMain
        theme.actionSheetCancelTextColor = SBUColorSet.primaryMain
        
        return theme
    }
    public static var dark: SBUCreateOpenChannelTheme {
        let theme = SBUCreateOpenChannelTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.leftBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonTintColor = SBUColorSet.primaryLight
        theme.rightBarButtonDisabledTintColor = SBUColorSet.onDarkTextDisabled
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        
        theme.backgroundColor = SBUColorSet.background600
        theme.textFieldPlaceholderColor = SBUColorSet.onDarkTextLowEmphasis
        theme.textFieldTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.textFieldFont = SBUFontSet.subtitle1
        theme.textFieldUnderlineColor = SBUColorSet.onLightTextDisabled
        
        theme.actionSheetItemColor = SBUColorSet.primaryLight
        theme.actionSheetTextColor = SBUColorSet.onDarkTextHighEmphasis
        theme.actionSheetRemoveTextColor = SBUColorSet.errorLight
        theme.actionSheetCancelTextColor = SBUColorSet.primaryLight
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                leftBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonTintColor: UIColor = SBUColorSet.primaryMain,
                rightBarButtonDisabledTintColor: UIColor = SBUColorSet.onLightTextDisabled,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onLightTextDisabled,
                backgroundColor: UIColor = SBUColorSet.background50,
                textFieldPlaceholderColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
                textFieldTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                textFieldFont: UIFont = SBUFontSet.subtitle1,
                textFieldUnderlineColor: UIColor = SBUColorSet.onLightTextDisabled,
                actionSheetItemColor: UIColor = SBUColorSet.primaryMain,
                actionSheetTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
                actionSheetRemoveTextColor: UIColor = SBUColorSet.errorMain,
                actionSheetCancelTextColor: UIColor = SBUColorSet.primaryMain
    ) {
        self.statusBarStyle = statusBarStyle
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.rightBarButtonDisabledTintColor = rightBarButtonDisabledTintColor
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.backgroundColor = backgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
        self.textFieldTextColor = textFieldTextColor
        self.textFieldFont = textFieldFont
        self.textFieldUnderlineColor = textFieldUnderlineColor
        self.actionSheetItemColor = actionSheetItemColor
        self.actionSheetTextColor = actionSheetTextColor
        self.actionSheetRemoveTextColor = actionSheetRemoveTextColor
        self.actionSheetCancelTextColor = actionSheetCancelTextColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var rightBarButtonDisabledTintColor: UIColor
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor

    public var backgroundColor: UIColor
    public var textFieldPlaceholderColor: UIColor
    public var textFieldTextColor: UIColor
    public var textFieldFont: UIFont
    public var textFieldUnderlineColor: UIColor
    
    public var actionSheetItemColor: UIColor
    public var actionSheetTextColor: UIColor
    public var actionSheetRemoveTextColor: UIColor
    public var actionSheetCancelTextColor: UIColor
}

// MARK: - VoiceMessageInputTheme

public class SBUVoiceMessageInputTheme {
    
    public static var light: SBUVoiceMessageInputTheme {
        let theme = SBUVoiceMessageInputTheme()
        
        theme.backgroundColor = SBUColorSet.background50
        theme.overlayColor = SBUColorSet.overlayDark
        
        theme.cancelTitleColor = SBUColorSet.primaryMain
        theme.cancelTitleFont = SBUFontSet.button2
        
        theme.progressTintColor = SBUColorSet.onLightTextLowEmphasis
        theme.progressTrackTintColor = SBUColorSet.primaryMain
        theme.progressTrackDeactivatedTintColor = SBUColorSet.background100
        theme.progressTimeFont = SBUFontSet.caption1
        theme.progressTimeColor = SBUColorSet.onDarkTextHighEmphasis
        theme.progressDeactivatedTimeColor = SBUColorSet.onLightTextLowEmphasis
        theme.progressRecordingIconTintColor = SBUColorSet.errorMain
        
        theme.statusButtonBackgroundColor = SBUColorSet.background100
        theme.recordingButtonTintColor = SBUColorSet.errorMain
        theme.stopButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.playButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.pauseButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        
        theme.sendButtonBackgroundColor = SBUColorSet.primaryMain
        theme.sendButtonDisabledBackgroundColor = SBUColorSet.background100
        theme.sendButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.sendButtonDisabledTintColor = SBUColorSet.onLightTextDisabled
        
        return theme
    }

    public static var dark: SBUVoiceMessageInputTheme {
        let theme = SBUVoiceMessageInputTheme()
        
        theme.backgroundColor = SBUColorSet.background600
        theme.overlayColor = SBUColorSet.overlayDark
        
        theme.cancelTitleColor = SBUColorSet.primaryLight
        theme.cancelTitleFont = SBUFontSet.button2
        
        theme.progressTintColor = SBUColorSet.onDarkTextLowEmphasis
        theme.progressTrackTintColor = SBUColorSet.primaryLight
        theme.progressTrackDeactivatedTintColor = SBUColorSet.background400
        theme.progressTimeFont = SBUFontSet.caption1
        theme.progressTimeColor = SBUColorSet.onLightTextHighEmphasis
        theme.progressDeactivatedTimeColor = SBUColorSet.onDarkTextLowEmphasis
        theme.progressRecordingIconTintColor = SBUColorSet.errorLight

        theme.statusButtonBackgroundColor = SBUColorSet.background500
        theme.recordingButtonTintColor = SBUColorSet.errorLight
        theme.stopButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.playButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        theme.pauseButtonTintColor = SBUColorSet.onDarkTextHighEmphasis
        
        theme.sendButtonBackgroundColor = SBUColorSet.primaryLight
        theme.sendButtonDisabledBackgroundColor = SBUColorSet.background500
        theme.sendButtonTintColor = SBUColorSet.onLightTextHighEmphasis
        theme.sendButtonDisabledTintColor = SBUColorSet.onDarkTextDisabled

        return theme
    }
    
    public var backgroundColor: UIColor
    public var overlayColor: UIColor

    public var cancelTitleColor: UIColor
    public var cancelTitleFont: UIFont
    
    public var progressTintColor: UIColor
    public var progressTrackTintColor: UIColor
    public var progressTrackDeactivatedTintColor: UIColor
    public var progressTimeFont: UIFont
    public var progressTimeColor: UIColor
    public var progressDeactivatedTimeColor: UIColor
    public var progressRecordingIconTintColor: UIColor
    
    public var statusButtonBackgroundColor: UIColor
    public var recordingButtonTintColor: UIColor
    public var stopButtonTintColor: UIColor
    public var playButtonTintColor: UIColor
    public var pauseButtonTintColor: UIColor
    
    public var sendButtonBackgroundColor: UIColor
    public var sendButtonDisabledBackgroundColor: UIColor
    public var sendButtonTintColor: UIColor
    public var sendButtonDisabledTintColor: UIColor
    
    public init(
        backgroundColor: UIColor = SBUColorSet.background50,
        overlayColor: UIColor = SBUColorSet.overlayDark,
        cancelTitleColor: UIColor = SBUColorSet.primaryMain,
        cancelTitleFont: UIFont = SBUFontSet.button2,
        progressTintColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
        progressTrackTintColor: UIColor = SBUColorSet.primaryMain,
        progressTrackDeactivatedTintColor: UIColor = SBUColorSet.background100,
        progressTimeFont: UIFont = SBUFontSet.caption1,
        progressTimeColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
        progressDeactivatedTimeColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
        progressRecordingIconTintColor: UIColor = SBUColorSet.errorMain,
        statusButtonBackgroundColor: UIColor = SBUColorSet.background100,
        recordingButtonTintColor: UIColor = SBUColorSet.errorMain,
        stopButtonTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        playButtonTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        pauseButtonTintColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        sendButtonBackgroundColor: UIColor = SBUColorSet.primaryMain,
        sendButtonDisabledBackgroundColor: UIColor = SBUColorSet.background100,
        sendButtonTintColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
        sendButtonDisabledTintColor: UIColor = SBUColorSet.onLightTextDisabled
    ) {
        
        self.backgroundColor = backgroundColor
        self.overlayColor = overlayColor
        
        self.cancelTitleColor = cancelTitleColor
        self.cancelTitleFont = cancelTitleFont
        
        self.progressTintColor = progressTintColor
        self.progressTrackTintColor = progressTrackTintColor
        self.progressTrackDeactivatedTintColor = progressTrackDeactivatedTintColor
        self.progressTimeFont = progressTimeFont
        self.progressTimeColor = progressTimeColor
        self.progressDeactivatedTimeColor = progressDeactivatedTimeColor
        self.progressRecordingIconTintColor = progressRecordingIconTintColor
        
        self.statusButtonBackgroundColor = statusButtonBackgroundColor
        self.recordingButtonTintColor = recordingButtonTintColor
        self.stopButtonTintColor = stopButtonTintColor
        self.playButtonTintColor = playButtonTintColor
        self.pauseButtonTintColor = pauseButtonTintColor
        
        self.sendButtonBackgroundColor = sendButtonBackgroundColor
        self.sendButtonDisabledBackgroundColor = sendButtonDisabledBackgroundColor
        self.sendButtonTintColor = sendButtonTintColor
        self.sendButtonDisabledTintColor = sendButtonDisabledTintColor
    }
}

// MARK: - Message template theme
public class SBUMessageTemplateTheme {
    
    /**
     case1:
         ```
        SBUMessageTemplateTheme.light.textButtonBackgroundColor = .blue
         ```
     case2:
         ```
         SBUTheme.templateMessageTheme.setDefaultTheme(
             light: SBUMessageTemplateTheme(
                 textFont: .systemFont(ofSize: 12),
                 textColor: .red,
                 textButtonFont: .systemFont(ofSize: 25),
                 textButtonTitleColor: .orange,
                 textButtonBackgroundColor: .blue,
                 viewBackgroundColor: .brown
             ),
             dark: nil
         )
         ```
     */
    
    public static var light: SBUMessageTemplateTheme = SBUMessageTemplateTheme.defaultLight
    public static var dark: SBUMessageTemplateTheme = SBUMessageTemplateTheme.defaultDark
    
    static var defaultLight: SBUMessageTemplateTheme {
        let theme = SBUMessageTemplateTheme()
        
        theme.textFont = SBUFontSet.body3
        theme.textColor = SBUColorSet.onLightTextHighEmphasis
        theme.textButtonFont = SBUFontSet.button4
        theme.textButtonTitleColor = SBUColorSet.primaryMain
        theme.textButtonBackgroundColor = SBUColorSet.background200
        theme.viewBackgroundColor = SBUColorSet.background100
        
        return theme
    }
    
    static var defaultDark: SBUMessageTemplateTheme {
        let theme = SBUMessageTemplateTheme()
        
        theme.textFont = SBUFontSet.body3
        theme.textColor = SBUColorSet.onDarkTextHighEmphasis
        theme.textButtonFont = SBUFontSet.button4
        theme.textButtonTitleColor = SBUColorSet.primaryLight
        theme.textButtonBackgroundColor = SBUColorSet.background400
        theme.viewBackgroundColor = SBUColorSet.background500
        
        return theme
    }
    
    public func setTheme(light: SBUMessageTemplateTheme?, dark: SBUMessageTemplateTheme?) {
        if let light = light {
            SBUMessageTemplateTheme.light = light
        }
        
        if let dark = dark {
            SBUMessageTemplateTheme.dark = dark
        }
    }
    
    public init(
        textFont: UIFont = SBUFontSet.body3,
        textColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
        textButtonFont: UIFont = SBUFontSet.button4,
        textButtonTitleColor: UIColor = SBUColorSet.primaryMain,
        textButtonBackgroundColor: UIColor = SBUColorSet.background200,
        viewBackgroundColor: UIColor = SBUColorSet.background100
    ) {
        self.textFont = textFont
        self.textColor = textColor
        self.textButtonFont = textButtonFont
        self.textButtonTitleColor = textButtonTitleColor
        self.textButtonBackgroundColor = textButtonBackgroundColor
        self.viewBackgroundColor = viewBackgroundColor
    }
    
    public var textFont: UIFont = SBUFontSet.body3
    public var textColor: UIColor = SBUColorSet.onLightTextHighEmphasis // SBUColorSet.onDarkTextLowEmphasis
    public var textButtonFont: UIFont = SBUFontSet.button4
    public var textButtonTitleColor: UIColor = SBUColorSet.primaryMain // SBUColorSet.primaryLight
    public var textButtonBackgroundColor: UIColor = SBUColorSet.background200 // SBUColorSet.background400
    public var viewBackgroundColor: UIColor = SBUColorSet.background100 // SBUColorSet.background500
    
}

/**
    How to set with all sub theme?
        case 1:
            ```
                SBUTheme.notificationTheme = .light
            ```
         case 2:
             ```
                SBUTheme.notificationTheme = SBUNotificationTheme()
             ```
        case 3:
            ```
                SBUTheme.notificationTheme = SBUNotificationTheme(notification: .light, header: .light, list: .light)
            ```
        case 4:
             ```
                SBUTheme.notificationTheme = SBUNotificationTheme(
                    notification: SBUNotificationTheme.Notification(),
                    header: SBUNotificationTheme.Header(),
                    list: SBUNotificationTheme.List()
                )
             ```
         case 5:
              ```
                  SBUTheme.notificationTheme.header = .light
                  SBUTheme.notificationTheme.list = .light
              ```
 */
/// - Since: 3.5.0
class SBUNotificationTheme {
    static var light: SBUNotificationTheme {
        get { self.baseLight }
        set {
            self.baseLight = newValue
            SBUNotificationTheme.Header.light = newValue.header
            SBUNotificationTheme.List.light = newValue.list
            SBUNotificationTheme.NotificationCell.light = newValue.notificationCell
            SBUNotificationTheme.CategoryFilter.light = newValue.categoryFilter
        }
    }
    static var dark: SBUNotificationTheme {
        get { self.baseDark }
        set {
            self.baseDark = newValue
            SBUNotificationTheme.Header.dark = newValue.header
            SBUNotificationTheme.List.dark = newValue.list
            SBUNotificationTheme.NotificationCell.dark = newValue.notificationCell
            SBUNotificationTheme.CategoryFilter.dark = newValue.categoryFilter
        }
    }
    var header: SBUNotificationTheme.Header = .light
    var list: SBUNotificationTheme.List = .light
    var notificationCell: SBUNotificationTheme.NotificationCell = .light
    var categoryFilter: SBUNotificationTheme.CategoryFilter = .light
    
    init(header: SBUNotificationTheme.Header = .light,
         list: SBUNotificationTheme.List = .light,
         notificationCell: SBUNotificationTheme.NotificationCell = .light,
         categoryFilter: SBUNotificationTheme.CategoryFilter = .light
    ) {
        self.header = header
        self.list = list
        self.notificationCell = notificationCell
        self.categoryFilter = categoryFilter
    }

    // INFO: default 는 유지하기 위해서
    static var baseLight: SBUNotificationTheme = SBUNotificationTheme.defaultLight
    static var baseDark: SBUNotificationTheme = SBUNotificationTheme.defaultDark

    static var defaultLight: SBUNotificationTheme {
        let theme = SBUNotificationTheme()
        theme.header = SBUNotificationTheme.Header.defaultLight
        theme.list = SBUNotificationTheme.List.defaultLight
        theme.notificationCell = SBUNotificationTheme.NotificationCell.defaultLight
        theme.categoryFilter = SBUNotificationTheme.CategoryFilter.defaultLight
        return theme
    }
    
    static var defaultDark: SBUNotificationTheme {
        let theme = SBUNotificationTheme()
        theme.header = SBUNotificationTheme.Header.defaultDark
        theme.list = SBUNotificationTheme.List.defaultDark
        theme.notificationCell = SBUNotificationTheme.NotificationCell.defaultDark
        theme.categoryFilter = SBUNotificationTheme.CategoryFilter.defaultDark
        return theme
    }
}

extension SBUNotificationTheme {
    // Global Notification Theme set
    class Header {
        static var light: SBUNotificationTheme.Header = SBUNotificationTheme.Header.defaultLight
        static var dark: SBUNotificationTheme.Header = SBUNotificationTheme.Header.defaultDark
        
        static var defaultLight: SBUNotificationTheme.Header {
            let theme = SBUNotificationTheme.Header()
            
            if #available(iOS 13.0, *) {
                theme.statusBarStyle = .darkContent
            } else {
                theme.statusBarStyle = .default
            }
            
            theme.buttonIconTintColor = SBUColorSet.primaryMain
            theme.lineColor = SBUColorSet.onLightTextDisabled
            theme.backgroundColor = SBUColorSet.background50
            theme.textColor = SBUColorSet.onLightTextHighEmphasis
            
            return theme
        }
        
        static var defaultDark: SBUNotificationTheme.Header {
            let theme = SBUNotificationTheme.Header()
            
            theme.statusBarStyle = .lightContent
            
            theme.buttonIconTintColor = SBUColorSet.primaryLight
            theme.lineColor = SBUColorSet.background500
            theme.backgroundColor = SBUColorSet.background500
            theme.textColor = SBUColorSet.onDarkTextHighEmphasis

            return theme
        }
        
        init(statusBarStyle: UIStatusBarStyle = .default,
             buttonIconTintColor: UIColor = SBUColorSet.primaryMain,
             lineColor: UIColor = SBUColorSet.onLightTextDisabled,
             backgroundColor: UIColor = SBUColorSet.background50,
             textSize: CGFloat = 18,
             textColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
             fontWeight: SBUFontWeightType = .bold
        ) {
            self.statusBarStyle = statusBarStyle
            self.buttonIconTintColor = buttonIconTintColor
            self.lineColor = lineColor
            self.backgroundColor = backgroundColor
            self.textSize = textSize
            self.textColor = textColor
            self.fontWeight = fontWeight
        }
        
        var statusBarStyle: UIStatusBarStyle
        var buttonIconTintColor: UIColor = SBUColorSet.primaryMain
        var lineColor: UIColor = SBUColorSet.onLightTextDisabled
        var backgroundColor: UIColor = SBUColorSet.background50
        var textSize: CGFloat = 18
        var textColor: UIColor = SBUColorSet.onLightTextHighEmphasis
        var fontWeight: SBUFontWeightType = .bold // 3.5.8
        lazy var textFont: UIFont = SBUFontSet.notificationsFont(
            size: self.textSize,
            weight: self.fontWeight.value
        ) // internal
    }
    
    class List {
        static var light: SBUNotificationTheme.List = SBUNotificationTheme.List.defaultLight
        static var dark: SBUNotificationTheme.List = SBUNotificationTheme.List.defaultDark
        
        static var defaultLight: SBUNotificationTheme.List {
            let theme = SBUNotificationTheme.List(
                backgroundColor: SBUColorSet.background50,
                tooltipBackgroundColor: SBUColorSet.primaryMain,
                tooltipTextColor: SBUColorSet.onDarkTextHighEmphasis,
                timelineBackgroundColor: SBUColorSet.overlayLight,
                timelineTextColor: SBUColorSet.onDarkTextHighEmphasis
            )
            return theme
        }
        
        static var defaultDark: SBUNotificationTheme.List {
            let theme = SBUNotificationTheme.List(
                backgroundColor: SBUColorSet.background500,
                tooltipBackgroundColor: SBUColorSet.primaryLight,
                tooltipTextColor: SBUColorSet.onLightTextHighEmphasis,
                timelineBackgroundColor: SBUColorSet.overlayDark,
                timelineTextColor: SBUColorSet.onDarkTextMidEmphasis
            )
            return theme
        }
        
        init(
            backgroundColor: UIColor = SBUColorSet.background50,
            tooltipBackgroundColor: UIColor = SBUColorSet.primaryMain,
            tooltipTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
            tooltipTextSize: CGFloat = 14,
            tooltipFontWeight: SBUFontWeightType = .bold,
            timelineBackgroundColor: UIColor = SBUColorSet.overlayLight,
            timelineTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis,
            timelineTextSize: CGFloat = 12,
            timelineFontWeight: SBUFontWeightType = .bold
        ) {
            self.backgroundColor = backgroundColor
            self.tooltipBackgroundColor = tooltipBackgroundColor
            self.tooltipTextColor = tooltipTextColor
            self.tooltipTextSize = tooltipTextSize
            self.tooltipFontWeight = tooltipFontWeight
            self.timelineBackgroundColor = timelineBackgroundColor
            self.timelineTextColor = timelineTextColor
            self.timelineTextSize = timelineTextSize
            self.timelineFontWeight = timelineFontWeight
        }
        
        var backgroundColor: UIColor = SBUColorSet.background50
        
        var tooltipBackgroundColor: UIColor = SBUColorSet.primaryMain
        var tooltipTextSize: CGFloat = 14 // 3.5.8
        var tooltipFontWeight: SBUFontWeightType = .bold // 3.5.8
        lazy var tooltipFont: UIFont = SBUFontSet.notificationsFont(
            size: self.tooltipTextSize,
            weight: self.tooltipFontWeight.value
        ) // body2, client only prop
        var tooltipTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis
        
        var timelineBackgroundColor: UIColor = SBUColorSet.overlayLight
        var timelineTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis
        var timelineTextSize: CGFloat = 12 // 3.5.8
        var timelineFontWeight: SBUFontWeightType = .bold // 3.5.8
        lazy var timelineFont: UIFont = SBUFontSet.notificationsFont(
            size: self.timelineTextSize,
            weight: self.timelineFontWeight.value
        ) // caption1, client only prop
    }
    
    class NotificationCell {
        static var light: SBUNotificationTheme.NotificationCell = SBUNotificationTheme.NotificationCell.defaultLight
        static var dark: SBUNotificationTheme.NotificationCell = SBUNotificationTheme.NotificationCell.defaultDark
        
        static var defaultLight: SBUNotificationTheme.NotificationCell {
            let theme = SBUNotificationTheme.NotificationCell(
                backgroundColor: SBUColorSet.background100,
                unreadIndicatorColor: SBUColorSet.secondaryMain,
                categoryTextColor: SBUColorSet.onLightTextMidEmphasis,
                sentAtTextColor: SBUColorSet.onLightTextLowEmphasis,
                pressedColor: SBUColorSet.primaryExtraLight,
                fallbackMessageTitleHexColor: "#e0000000",
                fallbackMessageSubtitleHexColor: "#70000000",
                downloadingBackgroundHexColor: "#e0000000"
            )
            return theme
        }
        
        static var defaultDark: SBUNotificationTheme.NotificationCell {
            let theme = SBUNotificationTheme.NotificationCell(
                backgroundColor: SBUColorSet.background500,
                unreadIndicatorColor: SBUColorSet.secondaryMain,
                categoryTextColor: SBUColorSet.onDarkTextMidEmphasis,
                sentAtTextColor: SBUColorSet.onDarkTextLowEmphasis,
                pressedColor: SBUColorSet.primaryExtraDark,
                fallbackMessageTitleHexColor: "#e0ffffff",
                fallbackMessageSubtitleHexColor: "#70ffffff",
                downloadingBackgroundHexColor: "#e0ffffff"
            )

            return theme
        }
        
        init(
            radius: CGFloat = 8,
            backgroundColor: UIColor = SBUColorSet.background100,
            unreadIndicatorColor: UIColor = SBUColorSet.secondaryMain,
            categoryTextSize: CGFloat = 12,
            categoryFontWeight: SBUFontWeightType = .bold,
            categoryTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis,
            sentAtTextSize: CGFloat = 14,
            sentAtFontWeight: SBUFontWeightType = .normal,
            sentAtTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis,
            pressedColor: UIColor = SBUColorSet.primaryExtraLight,
            fallbackMessageTitleHexColor: String = "#e0000000",
            fallbackMessageSubtitleHexColor: String = "#70000000",
            downloadingBackgroundHexColor: String = "#e0000000"
        ) {
            self.radius = radius
            self.backgroundColor = backgroundColor
            self.unreadIndicatorColor = unreadIndicatorColor
            self.categoryTextSize = categoryTextSize
            self.categoryFontWeight = categoryFontWeight
            self.categoryTextColor = categoryTextColor
            self.sentAtTextSize = sentAtTextSize
            self.sentAtFontWeight = sentAtFontWeight
            self.sentAtTextColor = sentAtTextColor
            self.pressedColor = pressedColor
            self.fallbackMessageTitleHexColor = fallbackMessageTitleHexColor
            self.fallbackMessageSubtitleHexColor = fallbackMessageSubtitleHexColor
            self.downloadingBackgroundHexColor = downloadingBackgroundHexColor
        }
        
        var radius: CGFloat = 8
        var backgroundColor: UIColor = SBUColorSet.background100
        
        var unreadIndicatorColor: UIColor = SBUColorSet.secondaryMain
        
        var categoryTextSize: CGFloat = 12
        var categoryFontWeight: SBUFontWeightType = .bold // 3.5.8
        var categoryTextColor: UIColor = SBUColorSet.onLightTextMidEmphasis
        lazy var categoryTextFont: UIFont = SBUFontSet.notificationsFont(
            size: self.categoryTextSize,
            weight: self.categoryFontWeight.value
        ) // internal
        
        var sentAtTextSize: CGFloat = 14
        var sentAtFontWeight: SBUFontWeightType = .normal // 3.5.8
        var sentAtTextColor: UIColor = SBUColorSet.onLightTextLowEmphasis
        lazy var sentAtTextFont: UIFont = SBUFontSet.notificationsFont(
            size: self.sentAtTextSize,
            weight: self.sentAtFontWeight.value
        ) // internal
        
        // TODO: notification - nice to have
        var pressedColor: UIColor = SBUColorSet.primaryExtraLight
        
        // Internal
        var fallbackMessageTitleHexColor: String = "#e0000000"
        var fallbackMessageSubtitleHexColor: String = "#70000000"
        
        var downloadingBackgroundHexColor: String = "#e0000000"
    }

    class CategoryFilter {
        static var light: SBUNotificationTheme.CategoryFilter = SBUNotificationTheme.CategoryFilter.defaultLight
        static var dark: SBUNotificationTheme.CategoryFilter = SBUNotificationTheme.CategoryFilter.defaultDark

        static var defaultLight: SBUNotificationTheme.CategoryFilter {
            let theme = SBUNotificationTheme.CategoryFilter(
                backgroundColor: SBUColorSet.background50,
                unselectedTextColor: SBUColorSet.onLightTextHighEmphasis,
                selectedCellBackgroundColor: SBUColorSet.primaryMain,
                unselectedBackgroundColor: SBUColorSet.background100,
                selectedTextColor: SBUColorSet.onDarkTextHighEmphasis
            )
            return theme
        }

        static var defaultDark: SBUNotificationTheme.CategoryFilter {
            let theme = SBUNotificationTheme.CategoryFilter(
                backgroundColor: SBUColorSet.onLightTextHighEmphasis,
                unselectedTextColor: SBUColorSet.onDarkTextHighEmphasis,
                selectedCellBackgroundColor: SBUColorSet.primaryLight,
                unselectedBackgroundColor: SBUColorSet.background500,
                selectedTextColor: SBUColorSet.onLightTextHighEmphasis
            )

            return theme
        }
        
        init(
            radius: CGFloat = 15,
            backgroundColor: UIColor = SBUColorSet.background50,
            unselectedTextColor: UIColor = SBUColorSet.onLightTextHighEmphasis,
            fontWeight: SBUFontWeightType = .normal,
            selectedCellBackgroundColor: UIColor = SBUColorSet.primaryMain,
            textSize: CGFloat = 12,
            unselectedBackgroundColor: UIColor = SBUColorSet.background100,
            selectedTextColor: UIColor = SBUColorSet.onDarkTextHighEmphasis
        ) {
            self.radius = radius
            self.backgroundColor = backgroundColor
            self.unselectedTextColor = unselectedTextColor
            self.fontWeight = fontWeight
            self.selectedCellBackgroundColor = selectedCellBackgroundColor
            self.textSize = textSize
            self.unselectedBackgroundColor = unselectedBackgroundColor
            self.selectedTextColor = selectedTextColor
        }
        
        var radius: CGFloat
        var unselectedTextColor: UIColor
        var fontWeight: SBUFontWeightType
        var selectedCellBackgroundColor: UIColor
        var textSize: CGFloat
        var unselectedBackgroundColor: UIColor
        var selectedTextColor: UIColor
        var backgroundColor: UIColor
    }
}
//  swiftlint:enable missing_docs
