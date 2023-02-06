//
//  MainChannelTabbarController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// TODO: mysettings -> settings
enum TabType {
    case channels, notifications, settings
}

class MainChannelTabbarController: UITabBarController {
    let channelsViewController = ChannelListViewController()
    let notificationChannelViewController = NotificationChannelViewController()
    let settingsViewController = MySettingsViewController()
    
    var channelsNavigationController = UINavigationController()
    var notificationChannelNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsViewController.headerComponent?.titleView = UIView()
        channelsViewController.headerComponent?.leftBarButton = self.createLeftTitleItem(text: "Channels")
        
        self.channelsNavigationController = UINavigationController(
            rootViewController: channelsViewController
        )
        self.notificationChannelNavigationController = UINavigationController(
            rootViewController: notificationChannelViewController
        )
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        let tabbarItems = [self.channelsNavigationController, self.notificationChannelNavigationController, self.mySettingsNavigationController]
        self.viewControllers = tabbarItems
        
        self.setupStyles()
        
        SendbirdChat.addUserEventDelegate(self, identifier: self.sbu_className)
        
        self.loadTotalUnreadMessageCount()
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
        
        notificationChannelViewController.tabBarItem = self.createTabItem(type: .notifications)
        
        settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: "Settings"
        )
        settingsViewController.tabBarItem = self.createTabItem(type: .settings)
        
        self.channelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.notificationChannelNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
    }
    
    
    // MARK: - SDK related
    
    /// **NOTIFICATION CHANNEL**
    /// Total unread message count
    func loadTotalUnreadMessageCount() {
        let params = GroupChannelTotalUnreadChannelCountParams()
        // set notification channel custom type
        params.customTypesFilter = [""]
        SendbirdChat.getTotalUnreadChannelCount(params: params) { totalCount, error in
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
        let title: String
        let icon: UIImage?
        let tag: Int
        switch type {
        case .channels:
            title = "Channels"
            icon = UIImage(named: "iconChatFilled")
            tag = 0
        case .notifications:
            title = "Notifications"
            icon = UIImage(named: "iconNotificationsFilled")
            tag = 1
        case .settings:
            title = "Settings"
            icon = UIImage(named: "iconSettingsFilled")
            tag = 2
        }
        
        let item = UITabBarItem(title: title, image: icon?.resize(with: iconSize), tag: tag)
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
        self.notificationChannelViewController.updateStyles()

        self.channelsViewController.listComponent?.reloadTableView()
        
        self.loadTotalUnreadMessageCount()
    }
}

extension MainChannelTabbarController: UserEventDelegate {
    /// **NOTIFICATION CHANNEL**
    /// Total unread message count
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32, totalCountByCustomType: [String : Int]?) {
        let notificationChannelCount = totalCountByCustomType?[SBUStringSet.Notification_Channel_CustomType] ?? 0
        let chatCount = Int(totalCount) - notificationChannelCount
        self.setUnreadMessagesCount(UInt(chatCount))
    }
}
