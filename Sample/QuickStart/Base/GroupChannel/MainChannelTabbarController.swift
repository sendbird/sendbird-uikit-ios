//
//  MainChannelTabbarController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

enum TabType {
    case channels
    case feedChannels
    case settings
}

class MainChannelTabbarController: UITabBarController {
    let channelsViewController = ChannelListViewController()
    let settingsViewController = MySettingsViewController()
    
    var channelsNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false
    
    /// When the channel URL is set by the push notificaion, the channel will be opened.
    var channelURLforPushNotification: String?

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsViewController.headerComponent?.titleView = UIView()
        channelsViewController.headerComponent?.leftBarButton = self.createLeftTitleItem(text: "Channels")
        
        self.channelsNavigationController = UINavigationController(
            rootViewController: channelsViewController
        )
        self.settingsViewController.sampleAppType = .basicUsage
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        let tabbarItems = [self.channelsNavigationController, self.mySettingsNavigationController]
        self.viewControllers = tabbarItems
        
        self.setupStyles()

        // Liquid Glass appearance sample. Uncomment one of the two cases below,
        // whichever matches how the app supplies its theme colors. See
        // `LiquidGlassAppearanceCustomManager`.
        //
        // Both belong here, on the container that hosts the Sendbird screens,
        // rather than at launch. QuickStart's home screen runs
        // `SBUTheme.set(theme:)` and `GlobalSetCustomManager.setDefault()` every
        // time it appears, and those two replace every component theme, so colors
        // assigned before them are dropped.
        //
        // Case 1. The app themes SendbirdUIKit with trait-based dynamic
        // `UIColor`s. Apply once, here. Liquid Glass and the ordinary components
        // then both follow the device: no appearance observer, and no
        // `SBUTheme.set(colorScheme:)` call.
        //
        // LiquidGlassAppearanceCustomManager.applyDynamicColorTheme()
        //
        // Case 2. The app themes SendbirdUIKit with static colors, one per color
        // scheme. `SBUTheme.liquidGlassAppearance` stays at its default `.theme`,
        // so the app owns the sync: every appearance change re-applies the colors
        // and restyles the screen on display. Register once, here, so the handler
        // stays alive for as long as the Sendbird screens do.
        //
        // if #available(iOS 17.0, *) {
        //     _ = registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
        //         LiquidGlassAppearanceCustomManager.applyStaticColorTheme(
        //             isDark: self.traitCollection.userInterfaceStyle == .dark,
        //             visibleViewController: (self.selectedViewController as? UINavigationController)?
        //                 .visibleViewController as? SBUBaseViewController
        //         )
        //     }
        // }
        //
        // The Dark theme switch in My settings runs `SBUTheme.set(theme:)` and
        // `updateTheme(isDarkMode:)`, which fight both cases. Leave that switch
        // alone while trying either one.

        SendbirdChat.addUserEventDelegate(self, identifier: self.sbu_className)
        
        self.loadTotalUnreadMessageCount()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let channelURL = self.channelURLforPushNotification {
            self.channelURLforPushNotification = nil
            SendbirdUI.moveToChannel(channelURL: channelURL, basedOnChannelList: true)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        SendbirdChat.removeUserEventDelegate(forIdentifier: self.sbu_className)
    }
    
    public func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.tabBar.barTintColor = self.isDarkMode
            ? SBUColorSet.background600
            : .white
        self.tabBar.tintColor = self.isDarkMode
            ? SBUColorSet.primary200
            : SBUColorSet.primary300
        channelsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Channels"
        )
        channelsViewController.tabBarItem = self.createTabItem(type: .channels)
        
        settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "My settings"
        )
        settingsViewController.tabBarItem = self.createTabItem(type: .settings)
        
        self.channelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
    }
    
    
    // MARK: - SDK related
    func loadTotalUnreadMessageCount() {
        SendbirdChat.getTotalUnreadMessageCount { (totalCount, error) in
            self.setUnreadMessagesCount(totalCount)
        }
    }
    
    // MARK: - Create items
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = theme.titleColor
        return UIBarButtonItem.init(customView: titleLabel)
    }
    
    func createTabItem(type: TabType) -> UITabBarItem {
        let iconSize = CGSize(width: 24, height: 24)
        let title = type == .channels ? "Channels" : "My settings"
        let icon = type == .channels
            ? UIImage(named: "iconChatFilled")?.sbu_resize(with: iconSize)
            : UIImage(named: "iconSettingsFilled")?.sbu_resize(with: iconSize)
        let tag = type == .channels ? 0 : 1
        
        let item = UITabBarItem(title: title, image: icon, tag: tag)
        return item
    }
    
    
    // MARK: - Common
    func setUnreadMessagesCount(_ totalCount: UInt) {
        var badgeValue: String?
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
        self.channelsViewController.tabBarItem.badgeColor = SBUColorSet.error300
        self.channelsViewController.tabBarItem.badgeValue = badgeValue
        self.channelsViewController.tabBarItem.setBadgeTextAttributes(
            [
                NSAttributedString.Key.foregroundColor : isDarkMode
                    ? SBUColorSet.onlight01
                    : SBUColorSet.ondark01,
                NSAttributedString.Key.font : SBUFontSet.caption4
            ],
            for: .normal
        )
        
    }
    
    func updateTheme(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        
        self.setupStyles()
        self.channelsViewController.setupStyles()
        self.settingsViewController.setupStyles()

        self.channelsViewController.listComponent?.reloadTableView()
        
        self.loadTotalUnreadMessageCount()
    }
}

extension MainChannelTabbarController: UserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : Int]?) {
        self.setUnreadMessagesCount(UInt(totalCount))
    }
}
