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
    
    public init( channelListTheme: SBUChannelListTheme = .light,
                 channelCellTheme: SBUChannelCellTheme = .light,
                 channelTheme: SBUChannelTheme = .light,
                 messageInputTheme: SBUMessageInputTheme = .light,
                 messageCellTheme: SBUMessageCellTheme = .light,
                 userListTheme: SBUUserListTheme = .light,
                 userCellTheme: SBUUserCellTheme = .light,
                 channelSettingsTheme: SBUChannelSettingsTheme = .light,
                 componentTheme: SBUComponentTheme = .light )
    {
        self._channelListTheme = channelListTheme
        self._channelCellTheme = channelCellTheme
        self._channelTheme = channelTheme
        self._messageInputTheme = messageInputTheme
        self._messageCellTheme = messageCellTheme
        self._userListTheme = userListTheme
        self._userCellTheme = userCellTheme
        self._channelSettingsTheme = channelSettingsTheme
        self._componentTheme = componentTheme
        
    }
    
    public static func set(theme: SBUTheme) {
        self.shared = theme
    }
    
    public static func setChannelList(channelListTheme: SBUChannelListTheme, channelCellTheme: SBUChannelCellTheme) {
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
    
    public static func setUserList(userListTheme: SBUUserListTheme, userCellTheme: SBUUserCellTheme) {
        self.userListTheme = userListTheme
        self.userCellTheme = userCellTheme
    }
    
    public static func setChannelSettings(channelSettingsTheme: SBUChannelSettingsTheme) {
        self.channelSettingsTheme = channelSettingsTheme
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
                         componentTheme: .dark )
        
    }
    
    public static var light: SBUTheme {
        return SBUTheme( channelListTheme: .light,
                         channelCellTheme: .light,
                         channelTheme: .light,
                         messageInputTheme: .light,
                         messageCellTheme: .light,
                         userListTheme: .light,
                         userCellTheme: .light,
                         channelSettingsTheme: .light,
                         componentTheme: .light )
        
    } 

    
    // MARK: - Public property
    
    // Channel List
    public static var channelListTheme: SBUChannelListTheme {
        set { shared._channelListTheme = newValue }
        get { return shared._channelListTheme }
    }
    
    public static var channelCellTheme: SBUChannelCellTheme {
        set { shared._channelCellTheme = newValue }
        get { return shared._channelCellTheme }
    }
    
    // Channel & Message
    public static var channelTheme: SBUChannelTheme {
        set { shared._channelTheme = newValue }
        get { return shared._channelTheme }
    }
    
    public static var messageInputTheme: SBUMessageInputTheme {
        set { shared._messageInputTheme = newValue }
        get { return shared._messageInputTheme }
    }
    public static var messageCellTheme: SBUMessageCellTheme {
        set { shared._messageCellTheme = newValue }
        get { return shared._messageCellTheme }
    }
    
    // User List
    public static var userListTheme: SBUUserListTheme {
        set { shared._userListTheme = newValue }
        get { return shared._userListTheme }
    }
    
    public static var userCellTheme: SBUUserCellTheme {
        set { shared._userCellTheme = newValue }
        get { return shared._userCellTheme }
    }
    
    // Setting
    public static var channelSettingsTheme: SBUChannelSettingsTheme {
        set { shared._channelSettingsTheme = newValue }
        get { return shared._channelSettingsTheme }
    }
    
    // Component
    public static var componentTheme: SBUComponentTheme {
        set { shared._componentTheme = newValue }
        get { return shared._componentTheme }
    }
      
    // MARK: - Private property
    
    private static var shared: SBUTheme = SBUTheme()
    
    // Channel List
    var _channelListTheme: SBUChannelListTheme
    var _channelCellTheme: SBUChannelCellTheme
    
    // Channel & Message
    var _channelTheme: SBUChannelTheme
    var _messageInputTheme: SBUMessageInputTheme
    var _messageCellTheme: SBUMessageCellTheme
    
    // User List
    var _userListTheme: SBUUserListTheme
    var _userCellTheme: SBUUserCellTheme
    
    // Setting
    var _channelSettingsTheme: SBUChannelSettingsTheme
    
    // Component
    var _componentTheme: SBUComponentTheme

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
        theme.navigationBarTintColor = SBUColorSet.background100
        theme.navigationBarShadowColor = SBUColorSet.onlight04

        theme.backgroundColor = SBUColorSet.background100
        theme.notificationOnBackgroundColor = SBUColorSet.primary300
        theme.notificationOnTintColor = SBUColorSet.background100
        theme.notificationOffBackgroundColor = SBUColorSet.background200
        theme.notificationOffTintColor = SBUColorSet.onlight01

        theme.leaveBackgroundColor = SBUColorSet.error
        theme.leaveTintColor = SBUColorSet.background100
        
        theme.alertBackgroundColor = SBUColorSet.background100
        
        return theme
    }
    
    public static var dark: SBUChannelListTheme {
        let theme = SBUChannelListTheme()

        theme.statusBarStyle = .lightContent
        
        theme.leftBarButtonTintColor = SBUColorSet.primary200
        theme.rightBarButtonTintColor = SBUColorSet.primary200
        theme.navigationBarTintColor = SBUColorSet.background500
        theme.navigationBarShadowColor = SBUColorSet.background600

        theme.backgroundColor = SBUColorSet.background600
        theme.notificationOnBackgroundColor = SBUColorSet.primary200
        theme.notificationOnTintColor = SBUColorSet.onlight01
        theme.notificationOffBackgroundColor = SBUColorSet.background400
        theme.notificationOffTintColor = SBUColorSet.background200

        theme.leaveBackgroundColor = SBUColorSet.error
        theme.leaveTintColor = SBUColorSet.ondark01
        
        theme.alertBackgroundColor = SBUColorSet.background600
 
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary200,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary200,
                navigationBarTintColor: UIColor = SBUColorSet.background500,
                navigationBarShadowColor: UIColor = SBUColorSet.background600,
                backgroundColor: UIColor = SBUColorSet.background600,
                notificationOnBackgroundColor: UIColor = SBUColorSet.primary300,
                notificationOnTintColor: UIColor = SBUColorSet.background100,
                notificationOffBackgroundColor: UIColor = SBUColorSet.background200,
                notificationOffTintColor: UIColor = SBUColorSet.onlight01,
                leaveBackgroundColor: UIColor = SBUColorSet.error,
                leaveTintColor: UIColor = SBUColorSet.background100,
                alertBackgroundColor: UIColor = SBUColorSet.background600)
    {

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
        theme.backgroundColor = SBUColorSet.background100
        
        theme.titleFont = SBUFontSet.subtitle1
        theme.titleTextColor = SBUColorSet.onlight01
        
        theme.memberCountFont = SBUFontSet.caption1
        theme.memberCountTextColor = SBUColorSet.onlight02
        
        theme.lastUpdatedTimeFont = SBUFontSet.caption2
        theme.lastUpdatedTimeTextColor = SBUColorSet.onlight02
        
        theme.messageFont = SBUFontSet.body2
        theme.messageTextColor = SBUColorSet.onlight03
        
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
        
        theme.messageFont = SBUFontSet.body2
        theme.messageTextColor = SBUColorSet.ondark03
        
        theme.unreadCountBackgroundColor = SBUColorSet.primary200
        theme.unreadCountTextColor = SBUColorSet.onlight01
        theme.unreadCountFont = SBUFontSet.caption1
        
        theme.separatorLineColor = SBUColorSet.ondark04
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background100,
                titleFont: UIFont = SBUFontSet.subtitle1,
                titleTextColor: UIColor = SBUColorSet.onlight01,
                memberCountFont: UIFont = SBUFontSet.caption1,
                memberCountTextColor: UIColor = SBUColorSet.onlight02,
                lastUpdatedTimeFont: UIFont = SBUFontSet.caption2,
                lastUpdatedTimeTextColor: UIColor = SBUColorSet.onlight02,
                messageFont: UIFont = SBUFontSet.body1,
                messageTextColor: UIColor = SBUColorSet.onlight03,
                unreadCountBackgroundColor: UIColor = SBUColorSet.primary300,
                unreadCountTextColor: UIColor = SBUColorSet.ondark01,
                unreadCountFont: UIFont = SBUFontSet.caption1,
                separatorLineColor: UIColor = SBUColorSet.onlight04)
    {
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.titleTextColor = titleTextColor
        self.memberCountFont = memberCountFont
        self.memberCountTextColor = memberCountTextColor
        self.lastUpdatedTimeFont = lastUpdatedTimeFont
        self.lastUpdatedTimeTextColor = lastUpdatedTimeTextColor
        self.messageFont = messageFont
        self.messageTextColor = messageTextColor
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
        theme.navigationBarTintColor = SBUColorSet.background100
        theme.navigationBarShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.primary300
        theme.backgroundColor = SBUColorSet.background100
        
        // Alert
        theme.removeItemColor = SBUColorSet.error
        theme.cancelItemColor = SBUColorSet.primary300
         
        theme.alertRemoveColor = SBUColorSet.error
        theme.alertCancelColor = SBUColorSet.primary300
        
        // Menu
        theme.menuTextColor = SBUColorSet.onlight01
        
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
        theme.removeItemColor = SBUColorSet.error
        theme.cancelItemColor = SBUColorSet.primary200
         
        theme.alertRemoveColor = SBUColorSet.error
        theme.alertCancelColor = SBUColorSet.primary200
        
        // Menu
        theme.menuTextColor = SBUColorSet.ondark01
        
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background100,
                navigationBarShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary300,
                backgroundColor: UIColor = SBUColorSet.background100,
                removeItemColor: UIColor = SBUColorSet.error,
                cancelItemColor: UIColor = SBUColorSet.primary300,
                alertRemoveColor: UIColor = SBUColorSet.error,
                alertCancelColor: UIColor = SBUColorSet.primary300,
                menuTextColor: UIColor = SBUColorSet.onlight01)
    {

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
    
}

// MARK: - Message Input Theme
@objcMembers
public class SBUMessageInputTheme: NSObject {
    
    public static var light: SBUMessageInputTheme {
        let theme = SBUMessageInputTheme()

        theme.backgroundColor = SBUColorSet.background100
        theme.textFieldBackgroundColor = SBUColorSet.background200
        theme.textFieldPlaceholderColor = SBUColorSet.onlight03
        theme.textFieldTintColor = SBUColorSet.primary300
        theme.textFieldTextColor = SBUColorSet.onlight01
        theme.textFieldBorderColor = SBUColorSet.background200
        
        theme.buttonTintColor = SBUColorSet.primary300
        
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
        theme.textFieldTintColor = SBUColorSet.primary200
        theme.textFieldTextColor = SBUColorSet.ondark01
        theme.textFieldBorderColor = SBUColorSet.background400
        
        theme.buttonTintColor = SBUColorSet.primary200
        
        theme.cancelButtonFont = SBUFontSet.button2
        theme.saveButtonFont = SBUFontSet.button2
        theme.saveButtonTextColor = SBUColorSet.onlight01
        
        return theme
    }
    
    public init(
        backgroundColor: UIColor = SBUColorSet.background100,
        textFieldBackgroundColor: UIColor = SBUColorSet.background200,
        textFieldPlaceholderColor: UIColor = SBUColorSet.onlight03,
        textFieldTintColor: UIColor = SBUColorSet.primary300,
        textFieldTextColor: UIColor = SBUColorSet.onlight01,
        textFieldBorderColor: UIColor = SBUColorSet.background200,
        buttonTintColor: UIColor = SBUColorSet.primary300,
        cancelButtonFont: UIFont = SBUFontSet.button2,
        saveButtonFont: UIFont = SBUFontSet.button2,
        saveButtonTextColor: UIColor = SBUColorSet.ondark01
    )
    {
        self.backgroundColor = backgroundColor
        self.textFieldBackgroundColor = textFieldBackgroundColor
        self.textFieldPlaceholderColor = textFieldPlaceholderColor
        self.textFieldTintColor = textFieldTintColor
        self.textFieldTextColor = textFieldTextColor
        self.textFieldBorderColor = textFieldBorderColor
        self.buttonTintColor = buttonTintColor
        self.cancelButtonFont = cancelButtonFont
        self.saveButtonFont = saveButtonFont
        self.saveButtonTextColor = saveButtonTextColor
    }
     
    public var backgroundColor: UIColor
    public var textFieldBackgroundColor: UIColor
    public var textFieldPlaceholderColor: UIColor
    public var textFieldTintColor: UIColor
    public var textFieldTextColor: UIColor
    public var textFieldBorderColor: UIColor
    
    public var buttonTintColor: UIColor
    
    public var cancelButtonFont: UIFont
    public var saveButtonFont: UIFont
    public var saveButtonTextColor: UIColor
 
}

// MARK: - Message Cell Theme
@objcMembers
public class SBUMessageCellTheme: NSObject {
    
    public static var light: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = SBUColorSet.background100
        
        theme.leftBackgroundColor = SBUColorSet.background200
        theme.leftPressedBackgroundColor = SBUColorSet.primary100
        theme.rightBackgroundColor = SBUColorSet.primary300
        theme.rightPressedBackgroundColor = SBUColorSet.primary400

        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.ondark01
        theme.dateBackgroundColor = SBUColorSet.overlay02
        
        // User name
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.onlight02
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption3
        theme.timeTextColor = SBUColorSet.onlight03
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primary300
        theme.failedStateColor = SBUColorSet.error
        theme.succeededStateColor = SBUColorSet.onlight03
        theme.readReceiptStateColor = SBUColorSet.secondary300
        theme.deliveryReceiptStateColor = SBUColorSet.onlight03
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body1
        theme.userMessageLeftTextColor = SBUColorSet.onlight01
        theme.userMessageLeftEditTextColor = SBUColorSet.onlight02
        
        theme.userMessageRightTextColor = SBUColorSet.ondark01
        theme.userMessageRightEditTextColor = SBUColorSet.ondark02
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background100
        theme.fileIconColor = SBUColorSet.primary300
        theme.fileMessageNameFont = SBUFontSet.body1
        theme.fileMessageLeftTextColor = SBUColorSet.onlight01
        theme.fileMessageRightTextColor = SBUColorSet.ondark01
        theme.fileMessagePlaceholderColor = SBUColorSet.onlight02
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.onlight02
        return theme
    }
    public static var dark: SBUMessageCellTheme {
        let theme = SBUMessageCellTheme()
        theme.backgroundColor = SBUColorSet.background600
        
        theme.leftBackgroundColor = SBUColorSet.background400
        theme.leftPressedBackgroundColor = SBUColorSet.primary500
        theme.rightBackgroundColor = SBUColorSet.primary200
        theme.rightPressedBackgroundColor = SBUColorSet.primary400

        // Date Label
        theme.dateFont = SBUFontSet.caption1
        theme.dateTextColor = SBUColorSet.ondark02
        theme.dateBackgroundColor = SBUColorSet.overlay01
        
        // User
        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01
        theme.userNameFont = SBUFontSet.caption1
        theme.userNameTextColor = SBUColorSet.ondark02
        
        // TitleLabel
        theme.timeFont = SBUFontSet.caption3
        theme.timeTextColor = SBUColorSet.ondark03
        
        // Message state
        theme.pendingStateColor = SBUColorSet.primary200
        theme.failedStateColor = SBUColorSet.error
        theme.succeededStateColor = SBUColorSet.ondark03
        theme.readReceiptStateColor = SBUColorSet.secondary300
        theme.deliveryReceiptStateColor = SBUColorSet.ondark03
        
        
        // User messgae
        theme.userMessageFont = SBUFontSet.body1
        theme.userMessageLeftTextColor = SBUColorSet.ondark01
        theme.userMessageLeftEditTextColor = SBUColorSet.ondark02
        
        theme.userMessageRightTextColor = SBUColorSet.onlight01
        theme.userMessageRightEditTextColor = SBUColorSet.onlight02
        
        // File message
        theme.fileIconBackgroundColor = SBUColorSet.background100
        theme.fileIconColor = SBUColorSet.primary200
        theme.fileMessageNameFont = SBUFontSet.body1
        theme.fileMessageLeftTextColor = SBUColorSet.ondark01
        theme.fileMessageRightTextColor = SBUColorSet.onlight01
        theme.fileMessagePlaceholderColor = SBUColorSet.ondark02
        
        // Admin message
        theme.adminMessageFont = SBUFontSet.caption2
        theme.adminMessageTextColor = SBUColorSet.ondark02
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background100,
                leftBackgroundColor: UIColor = SBUColorSet.background200,
                leftPressedBackgroundColor: UIColor = SBUColorSet.primary100,
                rightBackgroundColor: UIColor = SBUColorSet.primary300,
                rightPressedBackgroundColor: UIColor = SBUColorSet.primary400,
                dateFont: UIFont = SBUFontSet.caption1,
                dateTextColor: UIColor = SBUColorSet.ondark01,
                dateBackgroundColor: UIColor = SBUColorSet.overlay02,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                userNameFont: UIFont = SBUFontSet.caption1,
                userNameTextColor: UIColor = SBUColorSet.onlight02,
                timeFont: UIFont = SBUFontSet.caption3,
                timeTextColor: UIColor = SBUColorSet.onlight03,
                pendingStateColor: UIColor = SBUColorSet.primary300,
                failedStateColor: UIColor = SBUColorSet.error,
                succeededStateColor: UIColor = SBUColorSet.onlight03,
                readReceiptStateColor: UIColor = SBUColorSet.secondary300,
                deliveryReceiptStateColor: UIColor = SBUColorSet.onlight03,
                userMessageFont: UIFont = SBUFontSet.body1,
                userMessageLeftTextColor: UIColor = SBUColorSet.onlight01,
                userMessageLeftEditTextColor: UIColor = SBUColorSet.onlight02,
                userMessageRightTextColor: UIColor = SBUColorSet.ondark01,
                userMessageRightEditTextColor: UIColor = SBUColorSet.ondark02,
                fileIconBackgroundColor: UIColor = SBUColorSet.background100,
                fileIconColor: UIColor = SBUColorSet.primary300,
                fileMessageNameFont: UIFont = SBUFontSet.body1,
                fileMessageLeftTextColor: UIColor = SBUColorSet.onlight01,
                fileMessageRightTextColor: UIColor = SBUColorSet.ondark01,
                fileMessagePlaceholderColor: UIColor = SBUColorSet.onlight02,
                adminMessageFont: UIFont = SBUFontSet.caption2,
                adminMessageTextColor: UIColor = SBUColorSet.onlight02
    )
    {
        self.backgroundColor = backgroundColor
        self.leftBackgroundColor = leftBackgroundColor
        self.leftPressedBackgroundColor = leftPressedBackgroundColor
        self.rightBackgroundColor = rightBackgroundColor
        self.rightPressedBackgroundColor = rightPressedBackgroundColor
        self.dateFont = dateFont
        self.dateTextColor = dateTextColor
        self.dateBackgroundColor = dateBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userNameFont = userNameFont
        self.userNameTextColor = userNameTextColor
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
        self.fileIconColor = fileIconColor
        self.fileMessageNameFont = fileMessageNameFont
        self.fileMessageLeftTextColor = fileMessageLeftTextColor
        self.fileMessageRightTextColor = fileMessageRightTextColor
        self.fileMessagePlaceholderColor = fileMessagePlaceholderColor
        self.adminMessageFont = adminMessageFont
        self.adminMessageTextColor = adminMessageTextColor
    }
    
    public var backgroundColor: UIColor
    
    public var leftBackgroundColor: UIColor
    public var leftPressedBackgroundColor: UIColor
    public var rightBackgroundColor: UIColor
    public var rightPressedBackgroundColor: UIColor
    
    // Date Label
    public var dateFont: UIFont
    public var dateTextColor: UIColor
    public var dateBackgroundColor: UIColor
      
    // User
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
    public var userNameFont: UIFont
    public var userNameTextColor: UIColor
    
    // TitleLabel
    public var timeFont: UIFont
    public var timeTextColor: UIColor
     
    // Message state
    public var pendingStateColor: UIColor
    public var failedStateColor: UIColor
    public var succeededStateColor: UIColor
    public var readReceiptStateColor: UIColor
    public var deliveryReceiptStateColor: UIColor
    
    // User messgae
    public var userMessageFont: UIFont
    public var userMessageLeftTextColor: UIColor
    public var userMessageLeftEditTextColor: UIColor
    
    public var userMessageRightTextColor: UIColor
    public var userMessageRightEditTextColor: UIColor
    
    // File message
    public var fileIconBackgroundColor: UIColor
    public var fileIconColor: UIColor
    public var fileMessageNameFont: UIFont
    public var fileMessageLeftTextColor: UIColor
    public var fileMessageRightTextColor: UIColor
    public var fileMessagePlaceholderColor: UIColor
 
    // Admin message
    public var adminMessageFont: UIFont
    public var adminMessageTextColor: UIColor
     
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
        theme.navigationBarTintColor = SBUColorSet.background100
        theme.navigationShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.onlight04
        theme.rightBarButtonSelectedTintColor = SBUColorSet.primary300
        theme.backgroundColor = SBUColorSet.background100
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
        theme.backgroundColor = SBUColorSet.background600
        return theme
    }
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background100,
                navigationShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.onlight04,
                rightBarButtonSelectedTintColor: UIColor = SBUColorSet.primary300,
                backgroundColor: UIColor = SBUColorSet.background100
        
    )
    {
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationShadowColor = navigationShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.rightBarButtonSelectedTintColor = rightBarButtonSelectedTintColor
        self.backgroundColor = backgroundColor
        
    }

    public var statusBarStyle: UIStatusBarStyle
    public var navigationBarTintColor: UIColor
    public var navigationShadowColor: UIColor
    public var leftBarButtonTintColor: UIColor
    public var rightBarButtonTintColor: UIColor
    public var rightBarButtonSelectedTintColor: UIColor
    public var backgroundColor: UIColor
     
}

// MARK: - User Cell Theme
@objcMembers
public class SBUUserCellTheme: NSObject {
    
    public static var light: SBUUserCellTheme {
        let theme = SBUUserCellTheme()
        theme.backgroundColor = SBUColorSet.background100
        theme.checkboxOnColor = SBUColorSet.primary300
        theme.checkboxOffColor = SBUColorSet.background300
        theme.userNameTextColor = SBUColorSet.onlight01
        theme.userNameFont = SBUFontSet.subtitle2
        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
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
        theme.separateColor = SBUColorSet.onlight04
        return theme
    }
    
    public init(backgroundColor: UIColor = SBUColorSet.background100,
                checkboxOnColor: UIColor = SBUColorSet.primary300,
                checkboxOffColor: UIColor = SBUColorSet.background300,
                userNameTextColor: UIColor = SBUColorSet.onlight01,
                userNameFont: UIFont = SBUFontSet.subtitle2,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01,
                separateColor: UIColor = SBUColorSet.onlight04
    )
    {
        self.backgroundColor = backgroundColor
        self.checkboxOnColor = checkboxOnColor
        self.checkboxOffColor = checkboxOffColor
        self.userNameTextColor = userNameTextColor
        self.userNameFont = userNameFont
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.separateColor = separateColor
    }
    
    public var backgroundColor: UIColor
    public var checkboxOnColor: UIColor
    public var checkboxOffColor: UIColor
    public var userNameTextColor: UIColor
    public var userNameFont: UIFont
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
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

        theme.navigationBarTintColor = SBUColorSet.background100
        theme.navigationShadowColor = SBUColorSet.onlight04
        theme.leftBarButtonTintColor = SBUColorSet.primary300
        theme.rightBarButtonTintColor = SBUColorSet.primary300
        theme.backgroundColor = SBUColorSet.background100
        
        // Cell
        theme.cellTextFont = SBUFontSet.subtitle2
        theme.cellTextColor = SBUColorSet.onlight01
        theme.cellSwitchColor = SBUColorSet.primary300
        theme.cellSeparateColor = SBUColorSet.onlight04
        
        // Cell image
        theme.cellNotificationIconColor = SBUColorSet.primary300
        theme.cellMemberIconColor = SBUColorSet.primary300
        theme.cellMemberButtonColor = SBUColorSet.onlight01
        theme.cellLeaveIconColor = SBUColorSet.error
        
        // User Info View
        theme.userNameFont = SBUFontSet.subtitle1
        theme.userNameTextColor = SBUColorSet.onlight01
        
        // ActionSheet
        theme.itemTextColor = SBUColorSet.onlight01
        theme.itemColor = SBUColorSet.primary300
        
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
        theme.cellSwitchColor = SBUColorSet.primary200
        theme.cellSeparateColor = SBUColorSet.onlight04
        
        // Cell image
        theme.cellNotificationIconColor = SBUColorSet.primary200
        theme.cellMemberIconColor = SBUColorSet.primary200
        theme.cellMemberButtonColor = SBUColorSet.ondark01
        theme.cellLeaveIconColor = SBUColorSet.error
        
        // User Info View
        theme.userNameFont = SBUFontSet.subtitle1
        theme.userNameTextColor = SBUColorSet.ondark01

        // ActionSheet
        theme.itemTextColor = SBUColorSet.ondark01
        theme.itemColor = SBUColorSet.primary200
        
        return theme
    }
    
    
    public init(statusBarStyle: UIStatusBarStyle = .default,
                navigationBarTintColor: UIColor = SBUColorSet.background100,
                navigationShadowColor: UIColor = SBUColorSet.onlight04,
                leftBarButtonTintColor: UIColor = SBUColorSet.primary300,
                rightBarButtonTintColor: UIColor = SBUColorSet.primary300,
                backgroundColor: UIColor = SBUColorSet.background100,
                cellTextFont: UIFont = SBUFontSet.subtitle2,
                cellTextColor: UIColor = SBUColorSet.onlight01,
                cellSwitchColor: UIColor = SBUColorSet.primary300,
                cellSeparateColor: UIColor = SBUColorSet.onlight04,
                cellNotificationIconColor: UIColor = SBUColorSet.primary300,
                cellMemberIconColor: UIColor = SBUColorSet.primary300,
                cellMemberButtonColor: UIColor = SBUColorSet.onlight01,
                cellLeaveIconColor: UIColor = SBUColorSet.error,
                userNameFont: UIFont = SBUFontSet.subtitle1,
                userNameTextColor: UIColor = SBUColorSet.onlight01,
                itemTextColor: UIColor = SBUColorSet.onlight01,
                itemColor: UIColor = SBUColorSet.primary300
    )
    {
        self.statusBarStyle = statusBarStyle
        self.navigationBarTintColor = navigationBarTintColor
        self.navigationShadowColor = navigationShadowColor
        self.leftBarButtonTintColor = leftBarButtonTintColor
        self.rightBarButtonTintColor = rightBarButtonTintColor
        self.backgroundColor = backgroundColor
        self.cellTextFont = cellTextFont
        self.cellTextColor = cellTextColor
        self.cellSwitchColor = cellSwitchColor
        self.cellSeparateColor = cellSeparateColor
        self.cellNotificationIconColor = cellNotificationIconColor
        self.cellMemberIconColor = cellMemberIconColor
        self.cellMemberButtonColor = cellMemberButtonColor
        self.cellLeaveIconColor = cellLeaveIconColor
        self.userNameFont = userNameFont
        self.userNameTextColor = userNameTextColor
        self.itemTextColor = itemTextColor
        self.itemColor = itemColor
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
    public var cellSwitchColor: UIColor
    public var cellSeparateColor: UIColor
    
    // Cell image
    public var cellNotificationIconColor: UIColor
    public var cellMemberIconColor: UIColor
    public var cellMemberButtonColor: UIColor
    public var cellLeaveIconColor: UIColor
    
    // User Info View
    public var userNameFont: UIFont
    public var userNameTextColor: UIColor
    
    // ActionSheet
    public var itemTextColor: UIColor
    public var itemColor: UIColor
 
}


@objcMembers
public class SBUComponentTheme: NSObject {
    
    public static var light: SBUComponentTheme {
        let theme = SBUComponentTheme()
        theme.emptyViewBackgroundColor = SBUColorSet.background100
        
        theme.emptyViewStatusFont = SBUFontSet.body2
        theme.emptyViewStatusTintColor = SBUColorSet.onlight03
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primary300
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background100
        theme.highlightedColor = SBUColorSet.background200
        theme.buttonTextColor = SBUColorSet.primary300
        theme.separatorColor = SBUColorSet.onlight04
        theme.shadowColor = SBUColorSet.background700
        
        // Alert
        theme.alertTitleColor = SBUColorSet.onlight01
        theme.alertTitleFont = SBUFontSet.h2
        theme.alertDetailColor = SBUColorSet.onlight02
        theme.alertDetailFont = SBUFontSet.body2
        theme.alertPlaceholderColor = SBUColorSet.onlight03
        theme.alertButtonColor = SBUColorSet.primary300
        theme.alertErrorColor = SBUColorSet.error
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background200
        theme.alertTextFieldTintColor = SBUColorSet.primary300
        theme.alertTextFieldFont = SBUFontSet.body2
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.onlight01
        theme.actionSheetItemColor = SBUColorSet.primary300
        theme.actionSheetErrorColor = SBUColorSet.error
        theme.actionSheetButtonFont = SBUFontSet.button1
        
        // New Message
        theme.newMessageFont = SBUFontSet.caption1
        theme.newMessageTintColor = SBUColorSet.primary300
        theme.newMessageBackground = SBUColorSet.background100
        theme.newMessageHighlighted = SBUColorSet.background200
        
        // Title View
        theme.titleColor = SBUColorSet.onlight01
        theme.titleFont = SBUFontSet.h2
        theme.titleStatusColor = SBUColorSet.onlight03
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2

        theme.userPlaceholderBackgroundColor = SBUColorSet.background300
        theme.userPlaceholderTintColor = SBUColorSet.ondark01
        
        return theme
    }
    
    public static var dark: SBUComponentTheme {
        let theme = SBUComponentTheme()
        
        theme.emptyViewBackgroundColor = SBUColorSet.background600
        
        theme.emptyViewStatusFont = SBUFontSet.body2
        theme.emptyViewStatusTintColor = SBUColorSet.ondark03
        
        theme.emptyViewRetryButtonTintColor = SBUColorSet.primary200
        theme.emptyViewRetryButtonFont = SBUFontSet.button2
        
        theme.overlayColor = SBUColorSet.overlay02
        theme.backgroundColor = SBUColorSet.background500
        theme.highlightedColor = SBUColorSet.background400
        theme.buttonTextColor = SBUColorSet.primary200
        theme.separatorColor = SBUColorSet.ondark04
        theme.shadowColor = SBUColorSet.background700
        
        // Alert
        theme.alertTitleColor = SBUColorSet.ondark01
        theme.alertTitleFont = SBUFontSet.h2
        theme.alertDetailColor = SBUColorSet.ondark02
        theme.alertDetailFont = SBUFontSet.body2
        theme.alertPlaceholderColor = SBUColorSet.ondark03
        theme.alertButtonColor = SBUColorSet.primary200
        theme.alertErrorColor = SBUColorSet.error
        theme.alertButtonFont = SBUFontSet.button2
        theme.alertTextFieldBackgroundColor = SBUColorSet.background400
        theme.alertTextFieldTintColor = SBUColorSet.primary200
        theme.alertTextFieldFont = SBUFontSet.body2
        
        // Action Sheet
        theme.actionSheetTextFont = SBUFontSet.subtitle1
        theme.actionSheetTextColor = SBUColorSet.ondark01
        theme.actionSheetItemColor = SBUColorSet.primary200
        theme.actionSheetErrorColor = SBUColorSet.error
        theme.actionSheetButtonFont = SBUFontSet.button1
        
        // New Message
        theme.newMessageFont = SBUFontSet.caption1
        theme.newMessageTintColor = SBUColorSet.primary200
        theme.newMessageBackground = SBUColorSet.background400
        theme.newMessageHighlighted = SBUColorSet.background500
        
        // Title View
        theme.titleColor = SBUColorSet.ondark01
        theme.titleFont = SBUFontSet.h2
        theme.titleStatusColor = SBUColorSet.ondark03
        theme.titleStatusFont = SBUFontSet.caption2
        
        // Menu
        theme.menuTitleFont = SBUFontSet.subtitle2

        theme.userPlaceholderBackgroundColor = SBUColorSet.background400
        theme.userPlaceholderTintColor = SBUColorSet.onlight01

        return theme
    }
    
    
    public init(emptyViewBackgroundColor: UIColor = SBUColorSet.background100,
                emptyViewStatusFont: UIFont = SBUFontSet.body2,
                emptyViewStatusTintColor: UIColor = SBUColorSet.onlight03,
                emptyViewRetryButtonTintColor: UIColor = SBUColorSet.primary300,
                emptyViewRetryButtonFont: UIFont = SBUFontSet.button2,
                overlayColor: UIColor = SBUColorSet.overlay02,
                backgroundColor: UIColor = SBUColorSet.background100,
                highlightedColor: UIColor = SBUColorSet.background200,
                buttonTextColor: UIColor = SBUColorSet.primary300,
                separatorColor: UIColor = SBUColorSet.onlight04,
                shadowColor: UIColor = SBUColorSet.background700,
                alertTitleColor: UIColor = SBUColorSet.onlight01,
                alertTitleFont: UIFont = SBUFontSet.h2,
                alertDetailColor: UIColor = SBUColorSet.onlight02,
                alertDetailFont: UIFont = SBUFontSet.body2,
                alertPlaceholderColor: UIColor = SBUColorSet.onlight03,
                alertButtonColor: UIColor = SBUColorSet.primary300,
                alertErrorColor: UIColor = SBUColorSet.error,
                alertButtonFont: UIFont = SBUFontSet.button2,
                alertTextFieldBackgroundColor: UIColor = SBUColorSet.background200,
                alertTextFieldTintColor: UIColor = SBUColorSet.primary300,
                alertTextFieldFont: UIFont = SBUFontSet.body2,
                actionSheetTextFont: UIFont = SBUFontSet.subtitle1,
                actionSheetTextColor: UIColor = SBUColorSet.onlight01,
                actionSheetItemColor: UIColor = SBUColorSet.primary300,
                actionSheetErrorColor: UIColor = SBUColorSet.error,
                actionSheetButtonFont: UIFont = SBUFontSet.button1,
                newMessageFont: UIFont = SBUFontSet.caption1,
                newMessageTintColor: UIColor = SBUColorSet.primary300,
                newMessageBackground: UIColor = SBUColorSet.background100,
                newMessageHighlighted: UIColor = SBUColorSet.background200,
                titleOnlineStateColor: UIColor = SBUColorSet.secondary300,
                titleColor: UIColor = SBUColorSet.onlight01,
                titleFont: UIFont = SBUFontSet.h2,
                titleStatusColor: UIColor = SBUColorSet.onlight03,
                titleStatusFont: UIFont = SBUFontSet.caption2,
                menuTitleFont: UIFont = SBUFontSet.subtitle2,
                userPlaceholderBackgroundColor: UIColor = SBUColorSet.background300,
                userPlaceholderTintColor: UIColor = SBUColorSet.ondark01
    )
    {
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
        self.actionSheetItemColor = actionSheetItemColor
        self.actionSheetErrorColor = actionSheetErrorColor
        self.actionSheetButtonFont = actionSheetButtonFont
        self.newMessageFont = newMessageFont
        self.newMessageTintColor = newMessageTintColor
        self.newMessageBackground = newMessageBackground
        self.newMessageHighlighted = newMessageHighlighted
        self.titleOnlineStateColor = titleOnlineStateColor
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.titleStatusColor = titleStatusColor
        self.titleStatusFont = titleStatusFont
        self.menuTitleFont = menuTitleFont
        self.userPlaceholderTintColor = userPlaceholderTintColor
        self.userPlaceholderBackgroundColor = userPlaceholderBackgroundColor
        
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
    public var actionSheetItemColor: UIColor
    public var actionSheetErrorColor: UIColor
    public var actionSheetButtonFont: UIFont
    
    // New Message
    public var newMessageFont: UIFont
    public var newMessageTintColor: UIColor
    public var newMessageBackground: UIColor
    public var newMessageHighlighted: UIColor
    
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

    // placeholder
    public var userPlaceholderBackgroundColor: UIColor
    public var userPlaceholderTintColor: UIColor
}
