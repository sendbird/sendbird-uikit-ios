//
//  GlobalSetCustomManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class GlobalSetCustomManager: NSObject {
    static func startSample(naviVC: UINavigationController, type: GlobalCustomType?) {
        var isThemeChanged = false
        
        switch type {
        case .colorSet:
            setCustomGlobalColorSet()
        case .fontSet:
            setCustomGlobalFontSet()
        case .iconSet:
            setCustomGlobalIconSet()
        case .stringSet:
            setCustomGlobalStringSet()
        case .theme:
            setCustomGlobalTheme()
            isThemeChanged = true
        case .moduleSet:
            setDefaultModuleSet()
        default:
            break
        }

        // The values ​​set in globalset are used and reflected when setting the theme.
        // If the theme is changed, it should not be set to light or dark type because it was already set during the change process.
        if !isThemeChanged {
            SBUTheme.set(theme: .light)
        }
        let channelListVC = SBUGroupChannelListViewController()
        naviVC.pushViewController(channelListVC, animated: true)
    }
    
    static func setDefault() {
        SBUTheme.set(theme: .light)
        
        setDefaultGlobalColorSet()
        setDefaultGlobalFontSet()
        setDefaultGlobalIconSet()
        setDefaultGlobalStringSet()
        setDefaultGlobalTheme()
        setDefaultModuleSet()
    }
}


// MARK: - GlobalSet to custom
extension GlobalSetCustomManager {
    /// This is an example of customizing the global color set. You can change the required values ​​one by one.
    static func setCustomGlobalColorSet() {
        SBUColorSet.primary100 = UIColor(hex: "#006BBD")
        SBUColorSet.primary200 = UIColor(hex: "#007CDB")
        SBUColorSet.primary300 = UIColor(hex: "#0091FF")
        SBUColorSet.primary400 = UIColor(hex: "#35A8FF")
        SBUColorSet.primary500 = UIColor(hex: "#85CAFF")
    }

    /// This is an example of customizing the global font set. You can change the required values ​​one by one.
    static func setCustomGlobalFontSet() {
        SBUFontSet.h1 = UIFont.init(name: "AmericanTypewriter-Medium", size: 18.0) ?? UIFont()
        SBUFontSet.h2 = UIFont.init(name: "AmericanTypewriter-Bold", size: 16.0) ?? UIFont()
        SBUFontSet.subtitle1 = UIFont.init(name: "AmericanTypewriter", size: 16.0) ?? UIFont()
        SBUFontSet.subtitle2 = UIFont.init(name: "AmericanTypewriter", size: 14.0) ?? UIFont()
        SBUFontSet.body1 = UIFont.init(name: "AmericanTypewriter", size: 14.0) ?? UIFont()
        SBUFontSet.body2 = UIFont.init(name: "AmericanTypewriter", size: 14.0) ?? UIFont()
        SBUFontSet.button1 = UIFont.init(name: "AmericanTypewriter-Semibold", size: 20.0) ?? UIFont()
        SBUFontSet.button2 = UIFont.init(name: "AmericanTypewriter", size: 16.0) ?? UIFont()
        SBUFontSet.button3 = UIFont.init(name: "AmericanTypewriter", size: 14.0) ?? UIFont()
        SBUFontSet.caption1 = UIFont.init(name: "AmericanTypewriter-Bold", size: 12.0) ?? UIFont()
        SBUFontSet.caption2 = UIFont.init(name: "AmericanTypewriter", size: 12.0) ?? UIFont()
        SBUFontSet.caption3 = UIFont.init(name: "AmericanTypewriter", size: 11.0) ?? UIFont()
    }
    
    /// This is an example of customizing the global icon set. You can change the required values ​​one by one.
    static func setCustomGlobalIconSet() {
        SBUIconSet.iconCreate = UIImage(named: "iconCreateCustom")!
        SBUIconSet.iconInfo = UIImage(named: "iconInfoCustom")!
        SBUIconSet.iconAdd = UIImage(named: "iconAddCustom")!
        SBUIconSet.iconSend = UIImage(named: "iconSendCustom")!
        SBUIconSet.iconNotifications = UIImage(named: "iconNotificationsCustom")!
        SBUIconSet.iconMembers = UIImage(named: "iconMembersCustom")!
        SBUIconSet.iconPlus = UIImage(named: "iconAddMemberCustom")!
    }
    
    /// This is an example of customizing the global string set. You can change the required values ​​one by one.
    static func setCustomGlobalStringSet() {
        SBUStringSet.ChannelList_Header_Title = "Chat list"
        SBUStringSet.ChannelSettings_Header_Title = "Settings"
        SBUStringSet.CreateChannel_Header_Title = "Create Chat"
    }
    
    /// This is an example of customizing the global theme.
    static func setCustomGlobalTheme() {
        // This is a sample to change the theme of the channel list.
        
        let customBaseColor = UIColor(hex: "#0091FF")
        
        let channelListTheme = SBUGroupChannelListTheme()
        channelListTheme.leftBarButtonTintColor = customBaseColor
        channelListTheme.rightBarButtonTintColor = customBaseColor
        channelListTheme.notificationOnBackgroundColor = customBaseColor
        // ... In this way, you can add theme attributes.
        
        let channelCellTheme = SBUGroupChannelCellTheme()
        channelCellTheme.unreadCountBackgroundColor = UIColor(hex: "#E53157")
        channelCellTheme.titleFont = UIFont.init(
            name: "AmericanTypewriter",
            size: 16.0
            ) ?? UIFont()
        channelCellTheme.memberCountFont = UIFont.init(
            name: "AmericanTypewriter-Bold",
            size: 12.0
            ) ?? UIFont()
        channelCellTheme.lastUpdatedTimeFont = UIFont.init(
            name: "AmericanTypewriter",
            size: 12.0
            ) ?? UIFont()
        channelCellTheme.messageFont = UIFont.init(
            name: "AmericanTypewriter",
            size: 14.0
            ) ?? UIFont()
        // ... In this way, you can add theme attributes.
        
        let componentTheme = SBUComponentTheme()
        componentTheme.titleFont = UIFont.init(
            name: "AmericanTypewriter-Bold",
            size: 16.0
            ) ?? UIFont()
        // ... In this way, you can add theme attributes.
        
        let customTheme = SBUTheme(groupChannelListTheme: channelListTheme,
                                   groupChannelCellTheme: channelCellTheme,
                                   componentTheme: componentTheme)
        SBUTheme.set(theme: customTheme)
    }
}


// MARK: - GlobalSet to Default
extension GlobalSetCustomManager {
    /// This is an function of changing the global primary colors to default.
    static func setDefaultGlobalColorSet() {
        SBUColorSet.primary100 = UIColor(
            red: 219.0 / 255.0,
            green: 209.0 / 255.0,
            blue: 1.0,
            alpha: 1.0
        )
        SBUColorSet.primary200 = UIColor(
            red: 194.0 / 255.0,
            green: 169.0 / 255.0,
            blue: 250.0 / 255.0,
            alpha: 1.0
        )
        SBUColorSet.primary300 = UIColor(
            red: 116.0 / 255.0,
            green: 45.0 / 255.0,
            blue: 221.0 / 255.0,
            alpha: 1.0
        )
        SBUColorSet.primary400 = UIColor(
            red: 98.0 / 255.0,
            green: 17.0 / 255.0,
            blue: 200.0 / 255.0,
            alpha: 1.0
        )
        SBUColorSet.primary500 = UIColor(
            red: 73.0 / 255.0,
            green: 19.0 / 255.0,
            blue: 137.0 / 255.0,
            alpha: 1.0
        )
    }
    
    /// This is an function of changing the global font set to default.
    static func setDefaultGlobalFontSet() {
        SBUFontSet.h1 = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        SBUFontSet.h2 = UIFont.systemFont(ofSize: 18.0, weight: .medium)
        SBUFontSet.subtitle1 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        SBUFontSet.subtitle2 = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        SBUFontSet.body1 = UIFont.systemFont(ofSize: 16.0, weight: .regular)
        SBUFontSet.body2 = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
        SBUFontSet.button1 = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
        SBUFontSet.button2 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
        SBUFontSet.button3 = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        SBUFontSet.caption1 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
        SBUFontSet.caption2 = UIFont.systemFont(ofSize: 12.0, weight: .regular)
        SBUFontSet.caption3 = UIFont.systemFont(ofSize: 11.0, weight: .medium)
    }
    
    /// This is an function of changing the global icon set to default.
    static func setDefaultGlobalIconSet() {
        SBUIconSet.restoreDefaultIcons()
    }
    
    /// This is an function of changing the global string set to default.
    static func setDefaultGlobalStringSet() {
        SBUStringSet.ChannelList_Header_Title = "Channels"
        SBUStringSet.ChannelSettings_Header_Title = "Channel information"
        SBUStringSet.CreateChannel_Header_Title = "New Channel"
    }
    
    /// This is an function of changing the global theme to default.
    static func setDefaultGlobalTheme() {
        SBUTheme.set(theme: .light)
    }
    
    static func setDefaultModuleSet() {
        SBUModuleSet.GroupChannelListModule.HeaderComponent = SBUGroupChannelListModule.Header.self
        SBUModuleSet.GroupChannelListModule.ListComponent = SBUGroupChannelListModule.List.self
        
        SBUModuleSet.GroupChannelModule.HeaderComponent = SBUGroupChannelModule.Header.self
        SBUModuleSet.GroupChannelModule.ListComponent = SBUGroupChannelModule.List.self
        SBUModuleSet.GroupChannelModule.InputComponent = SBUGroupChannelModule.Input.self
    }
}
