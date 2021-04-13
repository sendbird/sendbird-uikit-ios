//
//  SBUTheme.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/05.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

// MARK: - Channel List Theme 
@objcMembers
public class SBUTheme: NSObject {
    override convenience init() {
        self.init(channelListTheme: .light)
    }
    
    public init(channelListTheme: SBUChannelListTheme = .light,
                channelCellTheme: SBUChannelCellTheme = .light,
                channelTheme: SBUChannelTheme = .light,
                messageInputTheme: SBUMessageInputTheme = .light,
                messageCellTheme: SBUMessageCellTheme = .light,
                userListTheme: SBUUserListTheme = .light,
                userCellTheme: SBUUserCellTheme = .light,
                channelSettingsTheme: SBUChannelSettingsTheme = .light,
                userProfileTheme: SBUUserProfileTheme = .light,
                componentTheme: SBUComponentTheme = .light,
                overlayTheme: SBUOverlayTheme = .init(),
                messageSearchTheme: SBUMessageSearchTheme = .light,
                messageSearchResultCellTheme: SBUMessageSearchResultCellTheme = .light
                ) {
        
        self.channelListTheme = channelListTheme
        self.channelCellTheme = channelCellTheme
        self.channelTheme = channelTheme
        self.messageInputTheme = messageInputTheme
        self.messageCellTheme = messageCellTheme
        self.userListTheme = userListTheme
        self.userCellTheme = userCellTheme
        self.channelSettingsTheme = channelSettingsTheme
        self.userProfileTheme = userProfileTheme
        self.componentTheme = componentTheme
        self.overlayTheme = overlayTheme
        self.messageSearchTheme = messageSearchTheme
        self.messageSearchResultCellTheme = messageSearchResultCellTheme
    }
    
    public static func set(theme: SBUTheme) {
        self.shared = theme
    }
    
    public static func setChannelList(channelListTheme: SBUChannelListTheme,
                                      channelCellTheme: SBUChannelCellTheme) {
        self.channelListTheme = channelListTheme
        self.channelCellTheme = channelCellTheme
    }
    
    public static func setChannel(channelTheme: SBUChannelTheme,
                                  messageCellTheme: SBUMessageCellTheme,
                                  messageInputTheme: SBUMessageInputTheme,
                                  componentTheme: SBUComponentTheme) {
        
        self.channelTheme = channelTheme
        self.messageCellTheme = messageCellTheme
        self.messageInputTheme = messageInputTheme
        self.componentTheme = componentTheme
    }
    
    public static func setUserList(userListTheme: SBUUserListTheme,
                                   userCellTheme: SBUUserCellTheme) {
        
        self.userListTheme = userListTheme
        self.userCellTheme = userCellTheme
    }
    
    public static func setChannelSettings(channelSettingsTheme: SBUChannelSettingsTheme) {
        self.channelSettingsTheme = channelSettingsTheme
    }
    
    public static func setUserProfile(userProfileTheme: SBUUserProfileTheme) {
        self.userProfileTheme = userProfileTheme
    }
    
    public static var dark: SBUTheme {
        return SBUTheme( channelListTheme: .dark,
                         channelCellTheme: .dark,
                         channelTheme: .dark,
                         messageInputTheme: .dark,
                         messageCellTheme: .dark,
                         userListTheme: .dark,
                         userCellTheme: .dark,
                         channelSettingsTheme: .dark,
                         userProfileTheme: .dark,
                         componentTheme: .dark,
                         overlayTheme: .init(),
                         messageSearchTheme: .dark,
                         messageSearchResultCellTheme: .dark)
        
    }
    
    public static var light: SBUTheme {
        return SBUTheme(channelListTheme: .light,
                        channelCellTheme: .light,
                        channelTheme: .light,
                        messageInputTheme: .light,
                        messageCellTheme: .light,
                        userListTheme: .light,
                        userCellTheme: .light,
                        channelSettingsTheme: .light,
                        userProfileTheme: .light,
                        componentTheme: .light,
                        overlayTheme: .init(),
                        messageSearchTheme: .light,
                        messageSearchResultCellTheme: .light)
    }
    
    
    // MARK: - Public property
    
    // Channel List
    public static var channelListTheme: SBUChannelListTheme {
        set { shared.channelListTheme = newValue }
        get { return shared.channelListTheme }
    }
    
    public static var channelCellTheme: SBUChannelCellTheme {
        set { shared.channelCellTheme = newValue }
        get { return shared.channelCellTheme }
    }
    
    // Channel & Message
    public static var channelTheme: SBUChannelTheme {
        set { shared.channelTheme = newValue }
        get { return shared.channelTheme }
    }
    
    public static var messageInputTheme: SBUMessageInputTheme {
        set { shared.messageInputTheme = newValue }
        get { return shared.messageInputTheme }
    }
    
    public static var messageCellTheme: SBUMessageCellTheme {
        set { shared.messageCellTheme = newValue }
        get { return shared.messageCellTheme }
    }
    
    // User List
    public static var userListTheme: SBUUserListTheme {
        set { shared.userListTheme = newValue }
        get { return shared.userListTheme }
    }
    
    public static var userCellTheme: SBUUserCellTheme {
        set { shared.userCellTheme = newValue }
        get { return shared.userCellTheme }
    }
    
    // Setting
    public static var channelSettingsTheme: SBUChannelSettingsTheme {
        set { shared.channelSettingsTheme = newValue }
        get { return shared.channelSettingsTheme }
    }
    
    // User profile
    public static var userProfileTheme: SBUUserProfileTheme {
        set { shared.userProfileTheme = newValue }
        get { return shared.userProfileTheme }
    }
    
    // Component
    public static var componentTheme: SBUComponentTheme {
        set { shared.componentTheme = newValue }
        get { return shared.componentTheme }
    }
    
    // Overlay Specific
    public static var overlayTheme: SBUOverlayTheme {
        set { shared.overlayTheme = newValue }
        get { return shared.overlayTheme }
    }
    
    public static var messageSearchTheme: SBUMessageSearchTheme {
        set { shared.messageSearchTheme = newValue }
        get { return shared.messageSearchTheme }
    }
    
    public static var messageSearchResultCellTheme: SBUMessageSearchResultCellTheme {
        set { shared.messageSearchResultCellTheme = newValue }
        get { return shared.messageSearchResultCellTheme }
    }
    
    // MARK: - Private property
    
    private static var shared: SBUTheme = SBUTheme()
    
    // Channel List
    private var channelListTheme: SBUChannelListTheme
    private var channelCellTheme: SBUChannelCellTheme
    
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
}

// MARK: - Overlay Theme
@objcMembers
public class SBUOverlayTheme: NSObject {
    
    public init(channelTheme: SBUChannelTheme = .overlay,
                messageInputTheme: SBUMessageInputTheme = .overlay,
                messageCellTheme: SBUMessageCellTheme = .overlay,
                componentTheme: SBUComponentTheme = .overlay) {
        self.channelTheme = channelTheme
        self.messageInputTheme = messageInputTheme
        self.messageCellTheme = messageCellTheme
        self.componentTheme = componentTheme
    }

    public override convenience init() {
        self.init(channelTheme: .overlay)
    }
    
    // Channel & Message
    public var channelTheme: SBUChannelTheme
    public var messageInputTheme: SBUMessageInputTheme
    public var messageCellTheme: SBUMessageCellTheme

    // Component
    public var componentTheme: SBUComponentTheme
}

// MARK: - Channel List Theme
@objcMembers
public class SBUChannelListTheme: NSObject {
    
    public static var light: SBUChannelListTheme {
        let theme = SBUChannelListTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.primary300
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onlight04
        
        theme.backgroundColor = SBUColorSet.background50
        theme.notificationOnBackgroundColor = SBUColorSet.primary300
        theme.notificationOnTintColor = SBUColorSet.ondark01
        theme.notificationOffBackgroundColor = SBUColorSet.background200
        theme.notificationOffTintColor = SBUColorSet.onlight01
        
        theme.leaveBackgroundColor = SBUColorSet.error300
        theme.leaveTintColor = SBUColorSet.ondark01
        
        theme.alertBackgroundColor = SBUColorSet.background50
        
        return theme
    }
    
    public static var dark: SBUChannelListTheme {
        let theme = SBUChannelListTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.primary200
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        
        theme.backgroundColor = SBUColorSet.background600
        theme.notificationOnBackgroundColor = SBUColorSet.primary200
        theme.notificationOnTintColor = SBUColorSet.onlight01
        theme.notificationOffBackgroundColor = SBUColorSet.background400
        theme.notificationOffTintColor = SBUColorSet.ondark01
        
        theme.leaveBackgroundColor = SBUColorSet.error200
        theme.leaveTintColor = SBUColorSet.onlight01
        
        theme.alertBackgroundColor = SBUColorSet.background600
        
        return theme
    }
    
    override convenience init() {
        self.init(statusBarStyle: .default)
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary300,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onlight04,
                backgroundColor: UIColor = SBUColorSet.background50,
                notificationOnBackgroundColor: UIColor = SBUColorSet.primary300,
                notificationOnTintColor: UIColor = SBUColorSet.background50,
                notificationOffBackgroundColor: UIColor = SBUColorSet.background100,
                notificationOffTintColor: UIColor = SBUColorSet.onlight01,
                leaveBackgroundColor: UIColor = SBUColorSet.error300,
                leaveTintColor: UIColor = SBUColorSet.background50,
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

// MARK: - Channel Cell Theme
@objcMembers
public class SBUChannelCellTheme: NSObject {
    public static var light: SBUChannelCellTheme {
        let theme = SBUChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background50
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onlight01
        
        theme.memberCountFont = SBUFontSet.caption1
        theme.memberCountTextColor = SBUColorSet.onlight02
        
        theme.lastUpdatedTimeFont = SBUFontSet.caption2
        theme.lastUpdatedTimeTextColor = SBUColorSet.onlight02
        
        theme.messageFont = SBUFontSet.body3
        theme.messageTextColor = SBUColorSet.onlight03
        
        theme.broadcastMarkTintColor = SBUColorSet.secondary300
        
        theme.freezeStateTintColor = SBUColorSet.primary300
        
        theme.unreadCountBackgroundColor = SBUColorSet.primary300
        theme.unreadCountTextColor = SBUColorSet.ondark01
        theme.unreadCountFont = SBUFontSet.caption1
        
        theme.separatorLineColor = SBUColorSet.onlight04
        return theme
    }
    public static var dark: SBUChannelCellTheme {
        let theme = SBUChannelCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.ondark01
        
        theme.memberCountFont = SBUFontSet.caption1
        theme.memberCountTextColor = SBUColorSet.ondark02
        
        theme.lastUpdatedTimeFont = SBUFontSet.caption2
        theme.lastUpdatedTimeTextColor = SBUColorSet.ondark02
        
        theme.messageFont = SBUFontSet.body3
        theme.messageTextColor = SBUColorSet.ondark03
        
        theme.broadcastMarkTintColor = SBUColorSet.secondary200
        
        theme.freezeStateTintColor = SBUColorSet.primary200
        
        theme.unreadCountBackgroundColor = SBUColorSet.primary200
        theme.unreadCountTextColor = SBUColorSet.onlight01
        theme.unreadCountFont = SBUFontSet.caption1
        
        theme.separatorLineColor = SBUColorSet.ondark04
        return theme
    }
    
    override convenience init() {
        self.init(backgroundColor: SBUColorSet.background50)
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                titleFont: UIFont = SBUFontSet.subtitle1,
                titleTextColor: UIColor = SBUColorSet.onlight01,
                memberCountFont: UIFont = SBUFontSet.caption1,
                memberCountTextColor: UIColor = SBUColorSet.onlight02,
                lastUpdatedTimeFont: UIFont = SBUFontSet.caption2,
                lastUpdatedTimeTextColor: UIColor = SBUColorSet.onlight02,
                messageFont: UIFont = SBUFontSet.body3,
                messageTextColor: UIColor = SBUColorSet.onlight03,
                broadcastMarkTintColor: UIColor = SBUColorSet.secondary300,
                freezeStateTintColor: UIColor = SBUColorSet.primary300,
                unreadCountBackgroundColor: UIColor = SBUColorSet.primary300,
                unreadCountTextColor: UIColor = SBUColorSet.ondark01,
                unreadCountFont: UIFont = SBUFontSet.caption1,
                separatorLineColor: UIColor = SBUColorSet.onlight04) {
        
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleTextColor = titleTextColor
        self.memberCountFont = memberCountFont
        self.memberCountTextColor = memberCountTextColor
        self.lastUpdatedTimeFont = lastUpdatedTimeFont
        self.lastUpdatedTimeTextColor = lastUpdatedTimeTextColor
        self.messageFont = messageFont
        self.messageTextColor = messageTextColor
        self.broadcastMarkTintColor = broadcastMarkTintColor
        self.freezeStateTintColor = freezeStateTintColor
        self.unreadCountBackgroundColor = unreadCountBackgroundColor
        self.unreadCountTextColor = unreadCountTextColor
        self.unreadCountFont = unreadCountFont
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
    
    public var broadcastMarkTintColor: UIColor
    
    public var freezeStateTintColor: UIColor
    
    public var unreadCountBackgroundColor: UIColor
    public var unreadCountTextColor: UIColor
    public var unreadCountFont: UIFont
    
    public var separatorLineColor: UIColor
    
}

// MARK: - Channel Theme
@objcMembers
public class SBUChannelTheme: NSObject {
    
    public static var light: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.primary300
        theme.backgroundColor = SBUColorSet.background50
        
        // Alert
        theme.removeItemColor = SBUColorSet.error300
        theme.cancelItemColor = SBUColorSet.primary300
        
        theme.alertRemoveColor = SBUColorSet.error300
        theme.alertCancelColor = SBUColorSet.primary300
        
        // Menu
        theme.menuTextColor = SBUColorSet.onlight01
        theme.menuItemTintColor = SBUColorSet.onlight01
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onlight01
        theme.channelStateBannerBackgroundColor = SBUColorSet.information
        
        return theme
    }
    
    public static var dark: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.primary200
        theme.backgroundColor = SBUColorSet.background600
        
        // Alert
        theme.removeItemColor = SBUColorSet.error300
        theme.cancelItemColor = SBUColorSet.primary200
        
        theme.alertRemoveColor = SBUColorSet.error300
        theme.alertCancelColor = SBUColorSet.primary200
        
        // Menu
        theme.menuTextColor = SBUColorSet.ondark01
        theme.menuItemTintColor = SBUColorSet.ondark01
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onlight01
        theme.channelStateBannerBackgroundColor = SBUColorSet.information
        
        return theme
    }
    
    public static var overlay: SBUChannelTheme {
        let theme = SBUChannelTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.primary200
        theme.backgroundColor = SBUColorSet.onlight02
        
        // Alert
        theme.removeItemColor = SBUColorSet.error300
        theme.cancelItemColor = SBUColorSet.primary200
        
        theme.alertRemoveColor = SBUColorSet.ondark01
        theme.alertCancelColor = SBUColorSet.primary200
        
        // Menu
        theme.menuTextColor = SBUColorSet.ondark01
        theme.menuItemTintColor = SBUColorSet.ondark01
        
        // State banner
        theme.channelStateBannerFont = SBUFontSet.caption2
        theme.channelStateBannerTextColor = SBUColorSet.onlight01
        theme.channelStateBannerBackgroundColor = SBUColorSet.information
        
        return theme
    }
    
    override convenience init() {
        self.init(statusBarStyle: .default)
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary300,
                backgroundColor: UIColor = SBUColorSet.background50,
                removeItemColor: UIColor = SBUColorSet.error300,
                cancelItemColor: UIColor = SBUColorSet.primary300,
                alertRemoveColor: UIColor = SBUColorSet.error300,
                alertCancelColor: UIColor = SBUColorSet.primary300,
                menuTextColor: UIColor = SBUColorSet.onlight01,
                menuItemTintColor: UIColor = SBUColorSet.onlight01,
                channelStateBannerFont: UIFont = SBUFontSet.caption2,
                channelStateBannerTextColor: UIColor = SBUColorSet.onlight01,
                channelStateBannerBackgroundColor: UIColor = SBUColorSet.information) {
        
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationBarShadowColor = navigationBarShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.backgroundColor = backgroundColor
        self.removeItemColor = removeItemColor
        self.cancelItemColor = cancelItemColor
        self.alertRemoveColor = alertRemoveColor
        self.alertCancelColor = alertCancelColor
        self.menuTextColor = menuTextColor
        self.menuItemTintColor = menuItemTintColor
        self.channelStateBannerFont = channelStateBannerFont
        self.channelStateBannerTextColor = channelStateBannerTextColor
        self.channelStateBannerBackgroundColor = channelStateBannerBackgroundColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var navigationBarTintColor: UIColor
    public var navigationBarShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var backgroundColor: UIColor
    
    // Alert
    public var removeItemColor: UIColor
    public var cancelItemColor: UIColor
    
    public var alertRemoveColor: UIColor
    public var alertCancelColor: UIColor
    
    // Menu
    public var menuTextColor: UIColor
    public var menuItemTintColor: UIColor
    
    // State Banner
    public var channelStateBannerFont: UIFont
    public var channelStateBannerTextColor: UIColor
    public var channelStateBannerBackgroundColor: UIColor
}

// MARK: - Message Input Theme
@objcMembers
public class SBUMessageInputTheme: NSObject {
    
    public static var light: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        
        theme.backgroundColor = SBUColorSet.background50
        theme.textFieldBackgroundColor = SBUColorSet.background100
        theme.textFieldPlaceholderColor = SBUColorSet.onlight03
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.onlight04
        theme.textFieldTintColor = SBUColorSet.primary300
        theme.textFieldTextColor = SBUColorSet.onlight01
        theme.textFieldBorderColor = SBUColorSet.background100
        
        theme.buttonTintColor = SBUColorSet.primary300
        theme.buttonDisabledTintColor = SBUColorSet.onlight04
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.ondark01
        
        return theme
    }
    public static var dark: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        theme.backgroundColor = SBUColorSet.background600
        theme.textFieldBackgroundColor = SBUColorSet.background400
        theme.textFieldPlaceholderColor = SBUColorSet.ondark03
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.ondark04
        theme.textFieldTintColor = SBUColorSet.primary200
        theme.textFieldTextColor = SBUColorSet.ondark01
        theme.textFieldBorderColor = SBUColorSet.background400
        
        theme.buttonTintColor = SBUColorSet.primary200
        theme.buttonDisabledTintColor = SBUColorSet.ondark04
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onlight01
        
        return theme
    }
    public static var overlay: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()
        theme.backgroundColor = SBUColorSet.onlight02
        theme.textFieldBackgroundColor = SBUColorSet.background400
        theme.textFieldPlaceholderColor = SBUColorSet.ondark03
        theme.textFieldPlaceholderFont = SBUFontSet.body3
        theme.textFieldDisabledColor = SBUColorSet.ondark04
        theme.textFieldTintColor = SBUColorSet.primary200
        theme.textFieldTextColor = SBUColorSet.ondark01
        theme.textFieldBorderColor = SBUColorSet.background400
        
        theme.buttonTintColor = SBUColorSet.ondark01
        theme.buttonDisabledTintColor = SBUColorSet.background400
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onlight01
        
        return theme
    }
    
    override convenience init() {
        self.init(backgroundColor: SBUColorSet.background50)
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                textFieldBackgroundColor: UIColor = SBUColorSet.background100,
                textFieldPlaceholderColor: UIColor = SBUColorSet.onlight03,
                textFieldPlaceholderFont: UIFont = SBUFontSet.body3,
                textFieldDisabledColor: UIColor = SBUColorSet.onlight04,
                textFieldTintColor: UIColor = SBUColorSet.primary300,
                textFieldTextColor: UIColor = SBUColorSet.onlight01,
                textFieldBorderColor: UIColor = SBUColorSet.background100,
                buttonTintColor: UIColor = SBUColorSet.primary300,
                buttonDisabledTintColor: UIColor = SBUColorSet.onlight04,
                cancelButtonFont: UIFont = SBUFontSet.button2,
                saveButtonFont: UIFont = SBUFontSet.button2,
                saveButtonTextColor: UIColor = SBUColorSet.ondark01) {
        
        self.backgroundColor = backgroundColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
        self.textFieldPlaceholderFont = textFieldPlaceholderFont
        self.textFieldDisabledColor = textFieldDisabledColor
        self.textFieldTintColor = textFieldTintColor
        self.textFieldTextColor = textFieldTextColor
        self.textFieldBorderColor = textFieldBorderColor
        self.buttonTintColor = buttonTintColor
        self.buttonDisabledTintColor = buttonDisabledTintColor
        self.cancelButtonFont = cancelButtonFont
        self.saveButtonFont = saveButtonFont
        self.saveButtonTextColor = saveButtonTextColor
    }
    
    public var backgroundColor: UIColor
    public var textFieldBackgroundColor: UIColor
    public var textFieldPlaceholderColor: UIColor
    public var textFieldPlaceholderFont: UIFont
    public var textFieldDisabledColor: UIColor
    public var textFieldTintColor: UIColor
    public var textFieldTextColor: UIColor
    public var textFieldBorderColor: UIColor
    
    public var buttonTintColor: UIColor
    public var buttonDisabledTintColor: UIColor
    
    public var cancelButtonFont: UIFont
    public var saveButtonFont: UIFont
    public var saveButtonTextColor: UIColor
    
}

// MARK: - Message Cell Theme
@objcMembers
public class SBUMessageCellTheme: NSObject {
    
    public static var light: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = .clear
        
        theme.leftBackgroundColor = SBUColorSet.background100
        theme.leftPressedBackgroundColor = SBUColorSet.primary100
        theme.rightBackgroundColor = SBUColorSet.primary300
        theme.rightPressedBackgroundColor = SBUColorSet.primary400
        
        theme.openChannelBackgroundColor = .clear
        theme.openChannelPressedBackgroundColor = SBUColorSet.background100
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.ondark01
        theme.dateBackgroundColor = SBUColorSet.overlay02
        
        // User name
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.onlight02
        theme.currentUserNameTextColor = SBUColorSet.secondary300
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.onlight03
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primary300
        theme.failedStateColor = SBUColorSet.error300
        theme.succeededStateColor = SBUColorSet.onlight03
        theme.readReceiptStateColor = SBUColorSet.secondary300
        theme.deliveryReceiptStateColor = SBUColorSet.onlight03
        
        // Message addition container background
        theme.contentBackgroundColor = SBUColorSet.background100
        theme.pressedContentBackgroundColor = SBUColorSet.primary100
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.onlight01
        theme.userMessageLeftEditTextColor = SBUColorSet.onlight02
        
        theme.userMessageRightTextColor = SBUColorSet.ondark01
        theme.userMessageRightEditTextColor = SBUColorSet.ondark02
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background50
        theme.fileIconColor = SBUColorSet.primary300
        theme.fileImageBackgroundColor = SBUColorSet.ondark01
        theme.fileImageIconColor = SBUColorSet.onlight02
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.onlight01
        theme.fileMessageRightTextColor = SBUColorSet.ondark01
        theme.fileMessagePlaceholderColor = SBUColorSet.onlight02
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.onlight02
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescTextColor = SBUColorSet.ondark02
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onlight01
        theme.messageRightHighlightTextColor = SBUColorSet.onlight01
        
        // webView OG
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.onlight01
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.onlight01
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.onlight02
        
        theme.linkColor = SBUColorSet.primary300
        
        return theme
    }
    
    public static var dark: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = .clear
        
        theme.leftBackgroundColor = SBUColorSet.background400
        theme.leftPressedBackgroundColor = SBUColorSet.primary500
        theme.rightBackgroundColor = SBUColorSet.primary200
        theme.rightPressedBackgroundColor = SBUColorSet.primary400
        
        theme.openChannelBackgroundColor = .clear
        theme.openChannelPressedBackgroundColor = SBUColorSet.background500
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.ondark02
        theme.dateBackgroundColor = SBUColorSet.overlay01
        
        // User
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.ondark02
        theme.currentUserNameTextColor = SBUColorSet.secondary200
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.ondark03
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primary200
        theme.failedStateColor = SBUColorSet.error300
        theme.succeededStateColor = SBUColorSet.ondark03
        theme.readReceiptStateColor = SBUColorSet.secondary300
        theme.deliveryReceiptStateColor = SBUColorSet.ondark03
        
        theme.contentBackgroundColor = SBUColorSet.background500
        theme.pressedContentBackgroundColor = SBUColorSet.primary500
        
        theme.contentBackgroundColor = SBUColorSet.background500
        theme.pressedContentBackgroundColor = SBUColorSet.primary500
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.ondark01
        theme.userMessageLeftEditTextColor = SBUColorSet.ondark02
        
        theme.userMessageRightTextColor = SBUColorSet.onlight01
        theme.userMessageRightEditTextColor = SBUColorSet.onlight02
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background600
        theme.fileIconColor = SBUColorSet.primary200
        theme.fileImageBackgroundColor = SBUColorSet.ondark01
        theme.fileImageIconColor = SBUColorSet.onlight02
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.ondark01
        theme.fileMessageRightTextColor = SBUColorSet.onlight01
        theme.fileMessagePlaceholderColor = SBUColorSet.ondark02
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.ondark02
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescTextColor = SBUColorSet.onlight02
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onlight01
        theme.messageRightHighlightTextColor = SBUColorSet.onlight01
        
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.ondark01
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.ondark01
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.ondark02
        
        theme.linkColor = SBUColorSet.primary200
        
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
        theme.openChannelPressedBackgroundColor = SBUColorSet.onlight03
        
        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.ondark02
        theme.dateBackgroundColor = SBUColorSet.overlay01
        
        // User
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.ondark02
        theme.currentUserNameTextColor = SBUColorSet.secondary200
        
        // TimeLabel
        theme.timeFont = SBUFontSet.caption4
        theme.timeTextColor = SBUColorSet.ondark03
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primary200
        theme.failedStateColor = SBUColorSet.error300
        theme.succeededStateColor = SBUColorSet.ondark03
        theme.readReceiptStateColor = SBUColorSet.secondary300
        theme.deliveryReceiptStateColor = SBUColorSet.ondark03
        
        theme.contentBackgroundColor = SBUColorSet.background500
        theme.pressedContentBackgroundColor = SBUColorSet.primary500
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body3
        theme.userMessageLeftTextColor = SBUColorSet.ondark01
        theme.userMessageLeftEditTextColor = SBUColorSet.ondark02
        
        theme.userMessageRightTextColor = SBUColorSet.onlight01
        theme.userMessageRightEditTextColor = SBUColorSet.onlight02
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background600
        theme.fileIconColor = SBUColorSet.primary200
        theme.fileImageBackgroundColor = SBUColorSet.ondark01
        theme.fileImageIconColor = SBUColorSet.onlight02
        theme.fileMessageNameFont = SBUFontSet.body3
        theme.fileMessageLeftTextColor = SBUColorSet.ondark01
        theme.fileMessageRightTextColor = SBUColorSet.onlight01
        theme.fileMessagePlaceholderColor = SBUColorSet.ondark02
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.ondark02
        
        // Unknown message
        theme.unknownMessageDescFont = SBUFontSet.body3
        theme.unknownMessageDescTextColor = SBUColorSet.onlight02
        
        theme.messageLeftHighlightTextColor = SBUColorSet.onlight01
        theme.messageRightHighlightTextColor = SBUColorSet.onlight01
        
        theme.ogTitleFont = SBUFontSet.body2
        theme.ogTitleColor = SBUColorSet.ondark01
        theme.ogDescriptionFont = SBUFontSet.caption2
        theme.ogDescriptionColor = SBUColorSet.ondark01
        theme.ogURLAddressFont = SBUFontSet.caption2
        theme.ogURLAddressColor = SBUColorSet.ondark02
        
        theme.linkColor = SBUColorSet.primary200
        
        return theme
    }
    
    override convenience init() {
        self.init(backgroundColor: SBUColorSet.background50)
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                leftBackgroundColor: UIColor = SBUColorSet.background100,
                leftPressedBackgroundColor: UIColor = SBUColorSet.primary100,
                rightBackgroundColor: UIColor = SBUColorSet.primary300,
                rightPressedBackgroundColor: UIColor = SBUColorSet.primary400,
                openChannelBackgroundColor: UIColor = .clear,
                openChannelPressedBackgroundColor: UIColor = SBUColorSet.background100,
                dateFont: UIFont = SBUFontSet.caption1,
                dateTextColor: UIColor = SBUColorSet.ondark01,
                dateBackgroundColor: UIColor = SBUColorSet.overlay02,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                userNameFont: UIFont = SBUFontSet.caption1,
                userNameTextColor: UIColor = SBUColorSet.onlight02,
                currentUserNameTextColor: UIColor = SBUColorSet.secondary300,
                timeFont: UIFont = SBUFontSet.caption4,
                timeTextColor: UIColor = SBUColorSet.onlight03,
                pendingStateColor: UIColor = SBUColorSet.primary300,
                failedStateColor: UIColor = SBUColorSet.error300,
                succeededStateColor: UIColor = SBUColorSet.onlight03,
                readReceiptStateColor: UIColor = SBUColorSet.secondary300,
                deliveryReceiptStateColor: UIColor = SBUColorSet.onlight03,
                userMessageFont: UIFont = SBUFontSet.body3,
                userMessageLeftTextColor: UIColor = SBUColorSet.onlight01,
                userMessageLeftEditTextColor: UIColor = SBUColorSet.onlight02,
                userMessageLeftHighlightTextColor: UIColor = SBUColorSet.onlight01,
                userMessageRightTextColor: UIColor = SBUColorSet.ondark01,
                userMessageRightEditTextColor: UIColor = SBUColorSet.ondark02,
                userMessageRightHighlightTextColor: UIColor = SBUColorSet.onlight01,
                fileIconBackgroundColor: UIColor = SBUColorSet.background50,
                fileImageBackgroundColor: UIColor = SBUColorSet.ondark01,
                fileImageIconColor: UIColor = SBUColorSet.onlight02,
                fileIconColor: UIColor = SBUColorSet.primary300,
                fileMessageNameFont: UIFont = SBUFontSet.body3,
                fileMessageLeftTextColor: UIColor = SBUColorSet.onlight01,
                fileMessageRightTextColor: UIColor = SBUColorSet.ondark01,
                fileMessagePlaceholderColor: UIColor = SBUColorSet.onlight02,
                adminMessageFont: UIFont = SBUFontSet.caption2,
                adminMessageTextColor: UIColor = SBUColorSet.onlight02,
                unknownMessageDescFont: UIFont  = SBUFontSet.body3,
                unknownMessageDescTextColor: UIColor = SBUColorSet.onlight03,
                ogTitleFont:UIFont = SBUFontSet.body2,
                ogTitleColor:UIColor = SBUColorSet.onlight01,
                ogDescriptionFont:UIFont = SBUFontSet.caption2,
                ogDescriptionColor: UIColor  = SBUColorSet.onlight01,
                ogURLAddressFont: UIFont = SBUFontSet.caption2,
                ogURLAddressColor: UIColor = SBUColorSet.onlight02,
                linkColor: UIColor = SBUColorSet.primary300,
                contentBackgroundColor: UIColor = SBUColorSet.background100,
                pressedContentBackgroundColor: UIColor = SBUColorSet.background300) {
        
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
        self.unknownMessageDescTextColor = unknownMessageDescTextColor
        self.messageLeftHighlightTextColor = userMessageLeftHighlightTextColor
        self.messageRightHighlightTextColor = userMessageRightHighlightTextColor
        self.ogTitleFont = ogTitleFont
        self.ogTitleColor = ogTitleColor
        self.ogDescriptionFont = ogDescriptionFont
        self.ogDescriptionColor = ogDescriptionColor
        self.ogURLAddressFont = ogURLAddressFont
        self.ogURLAddressColor = ogURLAddressColor
        self.linkColor = linkColor
        self.contentBackgroundColor = contentBackgroundColor
        self.pressedContentBackgroundColor = pressedContentBackgroundColor
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
    
    // Admin message
    public var adminMessageFont: UIFont
    public var adminMessageTextColor: UIColor
    
    // Unknown message
    public var unknownMessageDescFont: UIFont
    public var unknownMessageDescTextColor: UIColor
    
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
    
    public var linkColor: UIColor
}


// MARK: - User List Theme
@objcMembers
public class SBUUserListTheme: NSObject {
    
    public static var light: SBUUserListTheme {
        let theme = SBUUserListTheme()
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.onlight04
        theme.rightBarButtonSelectedTintColor = SBUColorSet.primary300
        theme.barButtonTintColor = SBUColorSet.primary300
        theme.barButtonDisabledTintColor = SBUColorSet.onlight04
        theme.backgroundColor = SBUColorSet.background50
        theme.coverImageTintColor = SBUColorSet.ondark01
        theme.coverImageBackgroundColor = SBUColorSet.background300
        theme.placeholderTintColor = SBUColorSet.onlight03
        theme.textfieldTextColor = SBUColorSet.onlight01
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onlight01
        theme.itemColor = SBUColorSet.primary300
        theme.removeColor = SBUColorSet.error300
        return theme
    }
    public static var dark: SBUUserListTheme {
        let theme = SBUUserListTheme()
        theme.statusBarStyle = .lightContent
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.ondark04
        theme.rightBarButtonSelectedTintColor = SBUColorSet.primary200
        theme.barButtonTintColor = SBUColorSet.primary200
        theme.barButtonDisabledTintColor = SBUColorSet.ondark04
        theme.backgroundColor = SBUColorSet.background600
        theme.coverImageTintColor = SBUColorSet.onlight01
        theme.coverImageBackgroundColor = SBUColorSet.background400
        theme.placeholderTintColor = SBUColorSet.ondark03
        theme.textfieldTextColor = SBUColorSet.ondark03
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.ondark01
        theme.itemColor = SBUColorSet.primary200
        theme.removeColor = SBUColorSet.error300
        return theme
    }
    
    override convenience init() {
        self.init(statusBarStyle: .default)
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.onlight04,
                rightBarButtonSelectedTintColor: UIColor = SBUColorSet.primary300,
                barButtonTintColor: UIColor = SBUColorSet.primary300,
                barButtonDisabledTintColor: UIColor = SBUColorSet.onlight04,
                backgroundColor: UIColor = SBUColorSet.background50,
                coverImageTintColor: UIColor = SBUColorSet.ondark01,
                coverImageBackgroundColor: UIColor = SBUColorSet.background300,
                itemTextColor: UIColor = SBUColorSet.onlight01,
                itemColor: UIColor = SBUColorSet.primary300,
                removeColor: UIColor = SBUColorSet.error300,
                placeholderTintColor: UIColor = SBUColorSet.onlight03,
                textfieldTextColor: UIColor = SBUColorSet.onlight01) {
        
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
        self.itemTextColor = itemTextColor
        self.itemColor = itemColor
        self.removeColor = removeColor
        self.placeholderTintColor = placeholderTintColor
        self.textfieldTextColor = textfieldTextColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    public var navigationBarTintColor: UIColor
    public var navigationShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var rightBarButtonSelectedTintColor: UIColor
    public var barButtonTintColor: UIColor
    public var barButtonDisabledTintColor: UIColor
    public var backgroundColor: UIColor
    public var coverImageTintColor: UIColor
    public var coverImageBackgroundColor: UIColor
    public var itemTextColor: UIColor
    public var itemColor: UIColor
    public var removeColor: UIColor
    public var placeholderTintColor: UIColor
    public var textfieldTextColor: UIColor
}

// MARK: - User Cell Theme
@objcMembers
public class SBUUserCellTheme: NSObject {
    public static var light: SBUUserCellTheme {
        let theme = SBUUserCellTheme()
        theme.backgroundColor = SBUColorSet.background50
        theme.checkboxOnColor = SBUColorSet.primary300
        theme.checkboxOffColor = SBUColorSet.background300
        theme.userNameTextColor = SBUColorSet.onlight01
        theme.userNameFont = SBUFontSet.subtitle2
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        theme.mutedStateBackgroundColor = SBUColorSet.primary300.withAlphaComponent(0.6)
        theme.mutedStateIconColor = SBUColorSet.ondark01
        theme.subInfoTextColor = SBUColorSet.onlight02
        theme.subInfoFont = SBUFontSet.body2
        theme.moreButtonColor = SBUColorSet.onlight01
        theme.moreButtonDisabledColor = SBUColorSet.onlight04
        theme.separateColor = SBUColorSet.onlight04
        return theme
    }
    
    public static var dark: SBUUserCellTheme {
        let theme = SBUUserCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        theme.checkboxOnColor = SBUColorSet.primary200
        theme.checkboxOffColor = SBUColorSet.ondark03
        theme.userNameTextColor = SBUColorSet.ondark01
        theme.userNameFont = SBUFontSet.subtitle2
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        theme.mutedStateBackgroundColor = SBUColorSet.primary400.withAlphaComponent(0.6)
        theme.mutedStateIconColor = SBUColorSet.ondark01
        theme.subInfoTextColor = SBUColorSet.ondark02
        theme.subInfoFont = SBUFontSet.body2
        theme.moreButtonColor = SBUColorSet.ondark01
        theme.moreButtonDisabledColor = SBUColorSet.ondark04
        theme.separateColor = SBUColorSet.ondark04
        return theme
    }
    
    override convenience init() {
        self.init(backgroundColor: SBUColorSet.background50)
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background50,
                checkboxOnColor: UIColor = SBUColorSet.primary300,
                checkboxOffColor: UIColor = SBUColorSet.background300,
                userNameTextColor: UIColor = SBUColorSet.onlight01,
                userNameFont: UIFont = SBUFontSet.subtitle2,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                mutedStateBackgroundColor: UIColor = SBUColorSet.primary300.withAlphaComponent(0.6),
                mutedStateIconColor: UIColor = SBUColorSet.ondark01,
                subInfoTextColor: UIColor = SBUColorSet.onlight02,
                subInfoFont: UIFont = SBUFontSet.body2,
                moreButtonColor: UIColor = SBUColorSet.onlight01,
                moreButtonDisabledColor: UIColor = SBUColorSet.onlight04,
                separateColor: UIColor = SBUColorSet.onlight04) {
        
        self.backgroundColor = backgroundColor
        self.checkboxOnColor = checkboxOnColor
        self.checkboxOffColor = checkboxOffColor
        self.userNameTextColor = userNameTextColor
        self.userNameFont = userNameFont
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
    public var userNameTextColor: UIColor
    public var userNameFont: UIFont
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var mutedStateBackgroundColor: UIColor
    public var mutedStateIconColor: UIColor
    public var subInfoTextColor: UIColor
    public var subInfoFont: UIFont
    public var moreButtonColor: UIColor
    public var moreButtonDisabledColor: UIColor
    public var separateColor: UIColor
}

// MARK: - Channel Setting Theme
@objcMembers
public class SBUChannelSettingsTheme: NSObject {
    
    public static var light: SBUChannelSettingsTheme {
        let theme = SBUChannelSettingsTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.primary300
        theme.backgroundColor = SBUColorSet.background50
        
        // Cell
        theme.cellTextFont = SBUFontSet.subtitle2
        theme.cellTextColor = SBUColorSet.onlight01
        theme.cellSubTextFont = SBUFontSet.subtitle2
        theme.cellSubTextColor = SBUColorSet.onlight02
        theme.cellSwitchColor = SBUColorSet.primary300
        theme.cellSeparateColor = SBUColorSet.onlight04
        
        // Cell image
        theme.cellTypeIconTintColor = SBUColorSet.primary300
        theme.cellArrowIconTintColor = SBUColorSet.onlight01
        theme.cellLeaveIconColor = SBUColorSet.error300
        theme.cellDeleteIconColor = SBUColorSet.error300
        
        // User Info View
        theme.userNameFont = SBUFontSet.subtitle1
        theme.userNameTextColor = SBUColorSet.onlight01
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onlight01
        theme.itemColor = SBUColorSet.primary300
        
        // Url Info
        theme.urlTitleFont = SBUFontSet.body2
        theme.urlTitleColor = SBUColorSet.onlight02
        theme.urlFont = SBUFontSet.body3
        theme.urlColor = SBUColorSet.onlight01
        
        return theme
    }
    public static var dark: SBUChannelSettingsTheme {
        let theme = SBUChannelSettingsTheme()
        theme.statusBarStyle = .lightContent
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationShadowColor = SBUColorSet.background500
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.primary200
        theme.backgroundColor = SBUColorSet.background600
        
        // Cell
        theme.cellTextFont = SBUFontSet.subtitle2
        theme.cellTextColor = SBUColorSet.ondark01
        theme.cellSubTextFont = SBUFontSet.subtitle2
        theme.cellSubTextColor = SBUColorSet.ondark02
        theme.cellSwitchColor = SBUColorSet.primary200
        theme.cellSeparateColor = SBUColorSet.ondark04
        
        // Cell image
        theme.cellTypeIconTintColor = SBUColorSet.primary200
        theme.cellArrowIconTintColor = SBUColorSet.ondark01
        theme.cellLeaveIconColor = SBUColorSet.error300
        theme.cellDeleteIconColor = SBUColorSet.error300
        
        // User Info View
        theme.userNameFont = SBUFontSet.subtitle1
        theme.userNameTextColor = SBUColorSet.ondark01
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.ondark01
        theme.itemColor = SBUColorSet.primary200
        
        // Url Info
        theme.urlTitleFont = SBUFontSet.body2
        theme.urlTitleColor = SBUColorSet.ondark02
        theme.urlFont = SBUFontSet.body3
        theme.urlColor = SBUColorSet.ondark01
        
        return theme
    }
    
    override convenience init() {
        self.init(statusBarStyle: .default)
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary300,
                backgroundColor: UIColor = SBUColorSet.background50,
                cellTextFont: UIFont = SBUFontSet.subtitle2,
                cellTextColor: UIColor = SBUColorSet.onlight01,
                cellSubTextFont: UIFont = SBUFontSet.subtitle2,
                cellSubTextColor: UIColor = SBUColorSet.onlight02,
                cellSwitchColor: UIColor = SBUColorSet.primary300,
                cellSeparateColor: UIColor = SBUColorSet.onlight04,
                cellTypeIconTintColor: UIColor = SBUColorSet.primary300,
                cellArrowIconTintColor: UIColor = SBUColorSet.onlight01,
                cellLeaveIconColor: UIColor = SBUColorSet.error300,
                cellDeleteIconColor: UIColor = SBUColorSet.error300,
                userNameFont: UIFont = SBUFontSet.subtitle1,
                userNameTextColor: UIColor = SBUColorSet.onlight01,
                itemTextColor: UIColor = SBUColorSet.onlight01,
                itemColor: UIColor = SBUColorSet.primary300,
                urlTitleFont: UIFont = SBUFontSet.body2,
                urlTitleColor: UIColor = SBUColorSet.onlight02,
                urlFont: UIFont = SBUFontSet.body3,
                urlColor: UIColor = SBUColorSet.onlight01
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
        self.cellSwitchColor = cellSwitchColor
        self.cellSeparateColor = cellSeparateColor
        self.cellTypeIconTintColor = cellTypeIconTintColor
        self.cellArrowIconTintColor = cellArrowIconTintColor
        self.cellLeaveIconColor = cellLeaveIconColor
        self.cellDeleteIconColor = cellDeleteIconColor
        self.userNameFont = userNameFont
        self.userNameTextColor = userNameTextColor
        self.itemTextColor = itemTextColor
        self.itemColor = itemColor
        self.urlTitleFont = urlTitleFont
        self.urlTitleColor = urlTitleColor
        self.urlFont = urlFont
        self.urlColor = urlColor
    }
    
    public var statusBarStyle: UIStatusBarStyle
    
    public var navigationBarTintColor: UIColor
    public var navigationShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var backgroundColor: UIColor
    
    // Cell
    public var cellTextFont: UIFont
    public var cellTextColor: UIColor
    public var cellSubTextFont: UIFont
    public var cellSubTextColor: UIColor
    public var cellSwitchColor: UIColor
    public var cellSeparateColor: UIColor
    
    // Cell image
    public var cellTypeIconTintColor: UIColor
    public var cellArrowIconTintColor: UIColor
    public var cellLeaveIconColor: UIColor
    public var cellDeleteIconColor: UIColor
    
    @available(*, deprecated, message: "deprecated in 1.2.0", renamed: "cellTypeIconTintColor")
    public lazy var cellNotificationIconColor: UIColor = self.cellTypeIconTintColor
    @available(*, deprecated, message: "deprecated in 1.2.0", renamed: "cellTypeIconTintColor")
    public lazy var cellMemberIconColor: UIColor = self.cellTypeIconTintColor
    @available(*, deprecated, message: "deprecated in 1.2.0", renamed: "cellArrowIconTintColor")
    public lazy var cellMemberButtonColor: UIColor = self.cellArrowIconTintColor
    
    // User Info View
    public var userNameFont: UIFont
    public var userNameTextColor: UIColor
    
    // ActionSheet
    public var itemTextColor: UIColor
    public var itemColor: UIColor
    
    // Url info
    public var urlTitleFont: UIFont
    public var urlTitleColor: UIColor
    public var urlFont: UIFont
    public var urlColor: UIColor
}


@objcMembers
public class SBUUserProfileTheme: NSObject {
    public static var light: SBUUserProfileTheme {
        let theme = SBUUserProfileTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background50
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        theme.usernameTextColor = SBUColorSet.onlight01
        theme.usernameFont = SBUFontSet.h1
        theme.userRoleTextColor = SBUColorSet.onlight02
        theme.userRoleFont = SBUFontSet.body3
        theme.largeItemTintColor = SBUColorSet.onlight01
        theme.largeItemFont = SBUFontSet.button2
        theme.largeItemBackgroundColor = SBUColorSet.background50
        theme.largeItemHighlightedColor = SBUColorSet.background100
        theme.itemFont = SBUFontSet.caption1
        theme.itemBackgroundColor = SBUColorSet.background100
        theme.itemSelectedBackgroundColor = SBUColorSet.primary300
        theme.itemTintColor = SBUColorSet.onlight01
        theme.itemSelectedTintColor = SBUColorSet.ondark01
        theme.itemHighlightedTintColor = SBUColorSet.error300
        theme.separatorColor = SBUColorSet.onlight04
        theme.informationTitleColor = SBUColorSet.onlight02
        theme.informationTitleFont = SBUFontSet.body2
        theme.informationDesctiptionColor = SBUColorSet.onlight01
        theme.informationDesctiptionFont = SBUFontSet.body3
        
        return theme
    }
    
    public static var dark: SBUUserProfileTheme {
        let theme = SBUUserProfileTheme()
        
        theme.statusBarStyle = .lightContent
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background500
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        theme.usernameTextColor = SBUColorSet.ondark01
        theme.usernameFont = SBUFontSet.h1
        theme.userRoleTextColor = SBUColorSet.ondark02
        theme.userRoleFont = SBUFontSet.body3
        theme.largeItemTintColor = SBUColorSet.ondark01
        theme.largeItemFont = SBUFontSet.button2
        theme.largeItemBackgroundColor = SBUColorSet.background500
        theme.largeItemHighlightedColor = SBUColorSet.background400
        theme.itemFont = SBUFontSet.caption1
        theme.itemBackgroundColor = SBUColorSet.background400
        theme.itemSelectedBackgroundColor = SBUColorSet.primary200
        theme.itemTintColor = SBUColorSet.ondark01
        theme.itemSelectedTintColor = SBUColorSet.onlight01
        theme.itemHighlightedTintColor = SBUColorSet.error300
        theme.separatorColor = SBUColorSet.ondark04
        theme.informationTitleColor = SBUColorSet.ondark02
        theme.informationTitleFont = SBUFontSet.body2
        theme.informationDesctiptionColor = SBUColorSet.ondark01
        theme.informationDesctiptionFont = SBUFontSet.body3
        
        return theme
    }
    
    override convenience init() {
        self.init(statusBarStyle: .default);
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                overlayColor: UIColor = SBUColorSet.overlay02,
                backgroundColor: UIColor = SBUColorSet.background50,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                usernameTextColor: UIColor = SBUColorSet.onlight01,
                usernameFont: UIFont = SBUFontSet.h1,
                userRoleTextColor: UIColor = SBUColorSet.onlight02,
                userRoleFont: UIFont = SBUFontSet.body3,
                largeItemTintColor: UIColor = SBUColorSet.onlight01,
                largeItemFont: UIFont = SBUFontSet.button2,
                largeItemBackgroundColor: UIColor = SBUColorSet.background50,
                largeItemHighlightedColor: UIColor = SBUColorSet.background100,
                itemFont: UIFont = SBUFontSet.caption1,
                itemBackgroundColor:UIColor = SBUColorSet.background400,
                itemSelectedBackgroundColor:UIColor = SBUColorSet.primary300,
                itemTintColor: UIColor = SBUColorSet.onlight01,
                itemSelectedTintColor: UIColor = SBUColorSet.ondark01,
                itemHighlightedTintColor: UIColor = SBUColorSet.error300,
                separatorColor: UIColor = SBUColorSet.onlight04,
                informationTitleColor: UIColor = SBUColorSet.onlight02,
                informationTitleFont: UIFont = SBUFontSet.body2,
                informationDesctiptionColor: UIColor = SBUColorSet.onlight01,
                informationDesctiptionFont: UIFont = SBUFontSet.body3) {
        
        self.statusBarStyle = statusBarStyle
        self.overlayColor = overlayColor
        self.backgroundColor = backgroundColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.usernameTextColor = usernameTextColor
        self.usernameFont = usernameFont
        self.userRoleTextColor = userRoleTextColor
        self.userRoleFont = userRoleFont
        self.largeItemTintColor = largeItemTintColor
        self.largeItemFont = largeItemFont
        self.largeItemBackgroundColor = largeItemBackgroundColor
        self.largeItemHighlightedColor = largeItemHighlightedColor
        self.itemFont = itemFont
        self.itemBackgroundColor = itemBackgroundColor
        self.itemSelectedBackgroundColor = itemSelectedBackgroundColor
        self.itemTintColor = itemTintColor
        self.itemSelectedTintColor = itemSelectedTintColor
        self.itemHighlightedTintColor = itemHighlightedTintColor
        self.separatorColor = separatorColor
        self.informationTitleColor = informationTitleColor
        self.informationTitleFont = informationTitleFont
        self.informationDesctiptionColor = informationDesctiptionColor
        self.informationDesctiptionFont = informationDesctiptionFont
    }
    
    public var statusBarStyle: UIStatusBarStyle
    public var overlayColor: UIColor
    public var backgroundColor: UIColor
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var usernameTextColor: UIColor
    public var usernameFont: UIFont
    public var userRoleTextColor: UIColor
    public var userRoleFont: UIFont
    public var largeItemTintColor: UIColor
    public var largeItemFont: UIFont
    public var largeItemBackgroundColor: UIColor
    public var largeItemHighlightedColor: UIColor
    public var itemFont: UIFont
    public var itemBackgroundColor: UIColor
    public var itemSelectedBackgroundColor: UIColor
    public var itemTintColor: UIColor
    public var itemSelectedTintColor: UIColor
    public var itemHighlightedTintColor: UIColor
    public var separatorColor: UIColor
    public var informationTitleColor: UIColor
    public var informationTitleFont: UIFont
    public var informationDesctiptionColor: UIColor
    public var informationDesctiptionFont: UIFont
}


// MARK: - Component
@objcMembers
public class SBUComponentTheme: NSObject {
    public static var light: SBUComponentTheme {
        let theme = SBUComponentTheme()
        theme.emptyViewBackgroundColor = SBUColorSet.background50
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.onlight03
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primary300
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background50
        theme.highlightedColor = SBUColorSet.background100
        theme.buttonTextColor = SBUColorSet.primary300
        theme.separatorColor = SBUColorSet.onlight04
        theme.shadowColor = SBUColorSet.background700
        theme.closeBarButtonTintColor = SBUColorSet.onlight01
        
        // Alert
        theme.alertTitleColor = SBUColorSet.onlight01
        theme.alertTitleFont = SBUFontSet.h3
        theme.alertDetailColor = SBUColorSet.onlight02
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.onlight03
        theme.alertButtonColor = SBUColorSet.primary300
        theme.alertErrorColor = SBUColorSet.error300
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background100
        theme.alertTextFieldTintColor = SBUColorSet.primary300
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.onlight01
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.onlight02
        theme.actionSheetItemColor = SBUColorSet.primary300
        theme.actionSheetErrorColor = SBUColorSet.error300
        theme.actionSheetButtonFont = SBUFontSet.button1
        
        // New Message
        theme.newMessageFont = SBUFontSet.caption1
        theme.newMessageTintColor = SBUColorSet.primary300
        theme.newMessageBackground = SBUColorSet.background50.withAlphaComponent(0.96)
        theme.newMessageHighlighted = SBUColorSet.background100.withAlphaComponent(0.96)
        theme.newMessageButtonTintColor = SBUColorSet.ondark01
        theme.newMessageButtonBackground = SBUColorSet.primary300
        theme.newMessageButtonHighlighted = SBUColorSet.primary400
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.primary300
        theme.scrollBottomButtonBackground = SBUColorSet.background50.withAlphaComponent(0.96)
        theme.scrollBottomButtonHighlighted = SBUColorSet.background100.withAlphaComponent(0.96)
        
        // Title View
        theme.titleColor = SBUColorSet.onlight01
        theme.titleFont = SBUFontSet.h2
        theme.titleStatusColor = SBUColorSet.onlight03
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background50
        theme.reactionBoxBorderLineColor = SBUColorSet.background100
        theme.reactionBoxEmojiCountColor = SBUColorSet.onlight01
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background100
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primary100
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.onlight02
        theme.emojiSelectedCountColor = SBUColorSet.primary300
        theme.emojiSelectedUnderlineColor = SBUColorSet.primary300
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.onlight04
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primary100
        
        theme.addReactionTintColor = SBUColorSet.onlight03
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primary300
        theme.channelTypeSelectorItemTextColor = SBUColorSet.onlight01
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondary300
        theme.broadcastIconTintColor = SBUColorSet.ondark01
        theme.barItemTintColor = SBUColorSet.primary300
        
        // Loading
        theme.loadingBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.4)
        theme.loadingPopupBackgroundColor = SBUColorSet.onlight02
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.ondark01
        theme.loadingSpinnerColor = SBUColorSet.ondark01
        
        return theme
    }
    
    public static var dark: SBUComponentTheme {
        let theme = SBUComponentTheme()
        
        theme.emptyViewBackgroundColor = SBUColorSet.background600
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.ondark03
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primary200
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background500
        theme.highlightedColor = SBUColorSet.background400
        theme.buttonTextColor = SBUColorSet.primary200
        theme.separatorColor = SBUColorSet.ondark04
        theme.shadowColor = SBUColorSet.background700
        theme.closeBarButtonTintColor = SBUColorSet.ondark01
        
        // Alert
        theme.alertTitleColor = SBUColorSet.ondark01
        theme.alertTitleFont = SBUFontSet.h3
        
        theme.alertDetailColor = SBUColorSet.ondark02
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.ondark03
        theme.alertButtonColor = SBUColorSet.primary200
        theme.alertErrorColor = SBUColorSet.error300
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background400
        theme.alertTextFieldTintColor = SBUColorSet.primary200
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.ondark01
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.ondark02
        theme.actionSheetItemColor = SBUColorSet.primary200
        theme.actionSheetErrorColor = SBUColorSet.error300
        theme.actionSheetButtonFont = SBUFontSet.button1
        
        // New Message
        theme.newMessageFont = SBUFontSet.caption1
        theme.newMessageTintColor = SBUColorSet.primary200
        theme.newMessageBackground = SBUColorSet.background400.withAlphaComponent(0.96)
        theme.newMessageHighlighted = SBUColorSet.background500.withAlphaComponent(0.96)
        theme.newMessageButtonTintColor = SBUColorSet.onlight01
        theme.newMessageButtonBackground = SBUColorSet.primary200
        theme.newMessageButtonHighlighted = SBUColorSet.primary300
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.primary200
        theme.scrollBottomButtonBackground = SBUColorSet.background400.withAlphaComponent(0.96)
        theme.scrollBottomButtonHighlighted = SBUColorSet.background500.withAlphaComponent(0.96)
        
        // Title View
        theme.titleColor = SBUColorSet.ondark01
        theme.titleFont = SBUFontSet.h2
        theme.titleStatusColor = SBUColorSet.ondark03
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background600
        theme.reactionBoxBorderLineColor = SBUColorSet.background400
        theme.reactionBoxEmojiCountColor = SBUColorSet.ondark01
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background400
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primary500
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.ondark02
        theme.emojiSelectedCountColor = SBUColorSet.primary200
        theme.emojiSelectedUnderlineColor = SBUColorSet.primary200
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.ondark04
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primary400
        
        theme.addReactionTintColor = SBUColorSet.ondark03
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primary200
        theme.channelTypeSelectorItemTextColor = SBUColorSet.ondark01
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondary200
        theme.broadcastIconTintColor = SBUColorSet.onlight01
        theme.barItemTintColor = SBUColorSet.primary200
        
        // Loading
        theme.loadingBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.4)
        theme.loadingPopupBackgroundColor = SBUColorSet.ondark03
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.onlight01
        theme.loadingSpinnerColor = SBUColorSet.background700
        
        return theme
    }
    
    public static var overlay: SBUComponentTheme {
        let theme = SBUComponentTheme()
        
        theme.emptyViewBackgroundColor = .clear
        
        theme.emptyViewStatusFont = SBUFontSet.body3
        theme.emptyViewStatusTintColor = SBUColorSet.ondark03
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primary200
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.onlight03
        theme.highlightedColor = SBUColorSet.background400
        theme.buttonTextColor = SBUColorSet.primary200
        theme.separatorColor = SBUColorSet.ondark04
        theme.shadowColor = SBUColorSet.background700
        theme.closeBarButtonTintColor = SBUColorSet.ondark01
        
        // Alert
        theme.alertTitleColor = SBUColorSet.ondark01
        theme.alertTitleFont = SBUFontSet.h3
        
        theme.alertDetailColor = SBUColorSet.ondark02
        theme.alertDetailFont = SBUFontSet.body3
        theme.alertPlaceholderColor = SBUColorSet.ondark03
        theme.alertButtonColor = SBUColorSet.primary200
        theme.alertErrorColor = SBUColorSet.error300
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background400
        theme.alertTextFieldTintColor = SBUColorSet.primary200
        theme.alertTextFieldFont = SBUFontSet.body3
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.ondark01
        theme.actionSheetSubTextFont = SBUFontSet.body2
        theme.actionSheetSubTextColor = SBUColorSet.ondark02
        theme.actionSheetItemColor = SBUColorSet.primary200
        theme.actionSheetErrorColor = SBUColorSet.error300
        theme.actionSheetButtonFont = SBUFontSet.button1
        
        // New Message
        theme.newMessageFont = SBUFontSet.caption1
        theme.newMessageTintColor = SBUColorSet.primary200
        theme.newMessageBackground = SBUColorSet.background400.withAlphaComponent(0.96)
        theme.newMessageHighlighted = SBUColorSet.background500.withAlphaComponent(0.96)
        theme.newMessageButtonTintColor = SBUColorSet.onlight01
        theme.newMessageButtonBackground = SBUColorSet.primary200
        theme.newMessageButtonHighlighted = SBUColorSet.primary300
        
        // Scroll Bottom
        theme.scrollBottomButtonIconColor = SBUColorSet.ondark01
        theme.scrollBottomButtonBackground = SBUColorSet.background400.withAlphaComponent(0.96)
        theme.scrollBottomButtonHighlighted = SBUColorSet.background500.withAlphaComponent(0.96)
        
        // Title View
        theme.titleColor = SBUColorSet.ondark01
        theme.titleFont = SBUFontSet.h2
        theme.titleStatusColor = SBUColorSet.ondark03
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2
        
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        
        // Reaction
        theme.reactionBoxBackgroundColor = SBUColorSet.background600
        theme.reactionBoxBorderLineColor = SBUColorSet.background400
        theme.reactionBoxEmojiCountColor = SBUColorSet.ondark01
        theme.reactionBoxEmojiBackgroundColor = SBUColorSet.background400
        theme.reactionBoxSelectedEmojiBackgroundColor = SBUColorSet.primary500
        theme.reactionBoxEmojiCountFont = SBUFontSet.caption4
        
        theme.emojiCountColor = SBUColorSet.ondark02
        theme.emojiSelectedCountColor = SBUColorSet.primary200
        theme.emojiSelectedUnderlineColor = SBUColorSet.primary200
        theme.emojiCountFont = SBUFontSet.button3
        theme.reactionMenuLineColor = SBUColorSet.ondark04
        
        theme.emojiListSelectedBackgroundColor = SBUColorSet.primary400
        
        theme.addReactionTintColor = SBUColorSet.ondark03
        
        // Create channel type
        theme.channelTypeSelectorItemTintColor = SBUColorSet.primary200
        theme.channelTypeSelectorItemTextColor = SBUColorSet.ondark01
        theme.channelTypeSelectorItemFont = SBUFontSet.caption2
        
        // Icon
        theme.broadcastIconBackgroundColor = SBUColorSet.secondary200
        theme.broadcastIconTintColor = SBUColorSet.ondark01
        theme.barItemTintColor = SBUColorSet.ondark01
        
        // Loading
        theme.loadingBackgroundColor = SBUColorSet.background700.withAlphaComponent(0.4)
        theme.loadingPopupBackgroundColor = SBUColorSet.ondark03
        theme.loadingFont = SBUFontSet.subtitle2
        theme.loadingTextColor = SBUColorSet.onlight01
        theme.loadingSpinnerColor = SBUColorSet.background700
        
        return theme
    }
    
    override convenience init() {
        self.init(emptyViewBackgroundColor: SBUColorSet.background50)
    }
    
    public init(emptyViewBackgroundColor: UIColor = SBUColorSet.background50,
                emptyViewStatusFont: UIFont = SBUFontSet.body3,
                emptyViewStatusTintColor: UIColor = SBUColorSet.onlight03,
                emptyViewRetryButtonTintColor: UIColor = SBUColorSet.primary300,
                emptyViewRetryButtonFont: UIFont = SBUFontSet.button2,
                overlayColor: UIColor = SBUColorSet.overlay02,
                backgroundColor: UIColor = SBUColorSet.background50,
                highlightedColor: UIColor = SBUColorSet.background100,
                buttonTextColor: UIColor = SBUColorSet.primary300,
                separatorColor: UIColor = SBUColorSet.onlight04,
                shadowColor: UIColor = SBUColorSet.background700,
                closeBarButtonTintColor: UIColor = SBUColorSet.onlight01,
                alertTitleColor: UIColor = SBUColorSet.onlight01,
                alertTitleFont: UIFont = SBUFontSet.h3,
                alertDetailColor: UIColor = SBUColorSet.onlight02,
                alertDetailFont: UIFont = SBUFontSet.body3,
                alertPlaceholderColor: UIColor = SBUColorSet.onlight03,
                alertButtonColor: UIColor = SBUColorSet.primary300,
                alertErrorColor: UIColor = SBUColorSet.error300,
                alertButtonFont: UIFont = SBUFontSet.button2,
                alertTextFieldBackgroundColor: UIColor = SBUColorSet.background100,
                alertTextFieldTintColor: UIColor = SBUColorSet.primary300,
                alertTextFieldFont: UIFont = SBUFontSet.body3,
                actionSheetTextFont: UIFont = SBUFontSet.subtitle1,
                actionSheetTextColor: UIColor = SBUColorSet.onlight01,
                actionSheetSubTextFont: UIFont = SBUFontSet.body2,
                actionSheetSubTextColor: UIColor = SBUColorSet.onlight02,
                actionSheetItemColor: UIColor = SBUColorSet.primary300,
                actionSheetErrorColor: UIColor = SBUColorSet.error300,
                actionSheetButtonFont: UIFont = SBUFontSet.button1,
                newMessageFont: UIFont = SBUFontSet.caption1,
                newMessageTintColor: UIColor = SBUColorSet.primary300,
                newMessageBackground: UIColor = SBUColorSet.background50.withAlphaComponent(0.96),
                newMessageHighlighted: UIColor = SBUColorSet.background100.withAlphaComponent(0.96),
                newMessageButtonTintColor: UIColor = SBUColorSet.ondark01,
                newMessageButtonBackground: UIColor = SBUColorSet.primary300,
                newMessageButtonHighlighted: UIColor = SBUColorSet.primary400,
                scrollBottomButtonIconColor: UIColor = SBUColorSet.primary300,
                scrollBottomButtonBackground: UIColor = SBUColorSet.background50.withAlphaComponent(0.96),
                scrollBottomButtonHighlighted: UIColor = SBUColorSet.background100.withAlphaComponent(0.96),
                titleOnlineStateColor: UIColor = SBUColorSet.secondary300,
                titleColor: UIColor = SBUColorSet.onlight01,
                titleFont: UIFont = SBUFontSet.h2,
                titleStatusColor: UIColor = SBUColorSet.onlight03,
                titleStatusFont: UIFont = SBUFontSet.caption2,
                menuTitleFont: UIFont = SBUFontSet.subtitle2,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                reactionBoxBackgroundColor: UIColor = SBUColorSet.background50,
                reactionBoxBorderLineColor: UIColor = SBUColorSet.background100,
                reactionBoxEmojiCountColor: UIColor = SBUColorSet.onlight01,
                reactionBoxEmojiBackgroundColor: UIColor = SBUColorSet.background100,
                reactionBoxSelectedEmojiBackgroundColor: UIColor = SBUColorSet.primary100,
                reactionBoxEmojiCountFont: UIFont = SBUFontSet.caption4,
                emojiCountColor: UIColor = SBUColorSet.onlight02,
                emojiSelectedCountColor: UIColor = SBUColorSet.primary300,
                emojiSelectedUnderlineColor: UIColor = SBUColorSet.primary300,
                emojiCountFont: UIFont = SBUFontSet.button3,
                reactionMenuLineColor: UIColor = SBUColorSet.ondark04,
                emojiListSelectedBackgroundColor: UIColor = SBUColorSet.primary100,
                addReactionTintColor: UIColor = SBUColorSet.onlight03,
                channelTypeSelectorItemTintColor: UIColor = SBUColorSet.primary300,
                channelTypeSelectorItemTextColor: UIColor = SBUColorSet.onlight01,
                channelTypeSelectorItemFont: UIFont = SBUFontSet.caption2,
                broadcastIconBackgroundColor: UIColor = SBUColorSet.secondary300,
                broadcastIconTintColor: UIColor = SBUColorSet.ondark01,
                barItemTintColor: UIColor = SBUColorSet.primary300,
                loadingBackgroundColor: UIColor = SBUColorSet.background700.withAlphaComponent(0.4),
                loadingPopupBackgroundColor: UIColor = SBUColorSet.onlight02,
                loadingFont: UIFont = SBUFontSet.subtitle2,
                loadingTextColor: UIColor = SBUColorSet.ondark01,
                loadingSpinnerColor: UIColor = SBUColorSet.ondark03) {
        
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
}


// MARK: - Message Search Theme
@objcMembers
public class SBUMessageSearchTheme: NSObject {
    
    public static var light: SBUMessageSearchTheme {
        let theme = SBUMessageSearchTheme()
        
        if #available(iOS 13.0, *) {
            theme.statusBarStyle = .darkContent
        } else {
            theme.statusBarStyle = .default
        }
        theme.navigationBarStyle = .default
        theme.navigationBarTintColor = SBUColorSet.background50
        theme.navigationBarShadowColor = SBUColorSet.onlight04
        theme.backgroundColor = SBUColorSet.background50
        
        theme.searchTextColor = SBUColorSet.onlight01
        theme.searchTextFont = SBUFontSet.body3
        theme.searchTextBackgroundColor = SBUColorSet.background100
        theme.searchPlaceholderColor = SBUColorSet.onlight03
        theme.searchIconTintColor = SBUColorSet.onlight03
        theme.clearIconTintColor = SBUColorSet.onlight03
        theme.cancelButtonTintColor = SBUColorSet.primary300
        
        return theme
    }
    
    public static var dark: SBUMessageSearchTheme {
        let theme = SBUMessageSearchTheme()
        
        theme.statusBarStyle = .lightContent
        theme.navigationBarStyle = .black
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background500
        theme.backgroundColor = SBUColorSet.background600
        
        theme.searchTextColor = SBUColorSet.ondark01
        theme.searchTextFont = SBUFontSet.body3
        theme.searchTextBackgroundColor = SBUColorSet.background400
        theme.searchPlaceholderColor = SBUColorSet.ondark03
        theme.searchIconTintColor = SBUColorSet.ondark03
        theme.clearIconTintColor = SBUColorSet.ondark03
        theme.cancelButtonTintColor = SBUColorSet.primary200
        
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
    
    override convenience init() {
        self.init(statusBarStyle: .default)
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarStyle: UIBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background50,
                navigationBarShadowColor: UIColor = SBUColorSet.onlight04,
                backgroundColor: UIColor = SBUColorSet.background50,
                searchTextColor: UIColor = SBUColorSet.onlight01,
                searchTextFont: UIFont = SBUFontSet.body3,
                searchTextBackgroundColor: UIColor = SBUColorSet.background100,
                searchPlaceholderColor: UIColor = SBUColorSet.onlight03,
                searchIconTintColor: UIColor = SBUColorSet.onlight03,
                clearIconTintColor: UIColor = SBUColorSet.onlight03,
                cancelButtonTintColor: UIColor = SBUColorSet.primary300) {
        
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
@objcMembers
public class SBUMessageSearchResultCellTheme: NSObject {
    
    public static var light: SBUMessageSearchResultCellTheme {
        let theme = SBUMessageSearchResultCellTheme()
        
        theme.backgroundColor = SBUColorSet.background50
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onlight01
        theme.descriptionFont = SBUFontSet.body3
        theme.descriptionTextColor = SBUColorSet.onlight03
        theme.updatedAtFont = SBUFontSet.caption2
        theme.updatedAtTextColor = SBUColorSet.onlight02
        theme.fileMessageFont = SBUFontSet.body3
        theme.fileMessageTextColor = SBUColorSet.onlight01
        theme.fileMessageIconBackgroundColor = SBUColorSet.background100
        theme.fileMessageIconTintColor = SBUColorSet.primary300
        theme.separatorLineColor = SBUColorSet.onlight04
        
        return theme
    }
    
    public static var dark: SBUMessageSearchResultCellTheme {
        let theme = SBUMessageSearchResultCellTheme()
        
        theme.backgroundColor = SBUColorSet.background600
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.ondark01
        theme.descriptionFont = SBUFontSet.body3
        theme.descriptionTextColor = SBUColorSet.ondark03
        theme.updatedAtFont = SBUFontSet.caption2
        theme.updatedAtTextColor = SBUColorSet.ondark02
        theme.fileMessageFont = SBUFontSet.body3
        theme.fileMessageTextColor = SBUColorSet.ondark01
        theme.fileMessageIconBackgroundColor = SBUColorSet.background500
        theme.fileMessageIconTintColor = SBUColorSet.primary200
        theme.separatorLineColor = SBUColorSet.ondark04
        
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
                titleTextColor: UIColor = SBUColorSet.onlight01,
                descriptionFont: UIFont = SBUFontSet.body3,
                descriptionTextColor: UIColor = SBUColorSet.onlight03,
                updatedAtFont: UIFont = SBUFontSet.caption2,
                updatedAtTextColor: UIColor = SBUColorSet.onlight02,
                fileMessageFont: UIFont = SBUFontSet.body3,
                fileMessageTextColor: UIColor = SBUColorSet.onlight01,
                fileMessageIconBackgroundColor: UIColor = SBUColorSet.background100,
                fileMessageIconTinkColor: UIColor = SBUColorSet.primary300,
                separatorLineColor: UIColor = SBUColorSet.onlight04) {
        
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
        self.fileMessageIconTintColor = fileMessageIconTinkColor
        self.separatorLineColor = separatorLineColor
    }
}
