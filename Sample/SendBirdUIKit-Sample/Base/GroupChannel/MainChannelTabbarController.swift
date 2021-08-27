//
//  MainChannelTabbarController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/11.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

enum TabType {
    case channels, mySettings
}

class MainChannelTabbarController: UITabBarController {
    let channelsViewController = ChannelListViewController()
    let settingsViewController = MySettingsViewController()
    
    var channelsNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channelsViewController.titleView = UIView()
        channelsViewController.leftBarButton = self.createLeftTitleItem(text: "Channels")
        
        self.channelsNavigationController = UINavigationController(
            rootViewController: channelsViewController
        )
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        let tabbarItems = [self.channelsNavigationController, self.mySettingsNavigationController]
        self.viewControllers = tabbarItems
        
        self.setupStyles()
        
        SBDMain.add(self, identifier: self.sbu_className)
        
        self.loadTotalUnreadMessageCount()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    deinit {
        SBDMain.removeUserEventDelegate(forIdentifier: self.sbu_className)
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
        settingsViewController.tabBarItem = self.createTabItem(type: .mySettings)
        
        self.channelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
    }
    
    
    // MARK: - SDK related
    func loadTotalUnreadMessageCount() {
        SBDMain.getTotalUnreadMessageCount { (totalCount, error) in
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
            ? UIImage(named: "iconChatFilled")?.resize(with: iconSize)
            : UIImage(named: "iconSettingsFilled")?.resize(with: iconSize)
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

        self.channelsViewController.reloadTableView()
        
        self.loadTotalUnreadMessageCount()
    }
}

extension MainChannelTabbarController: SBDUserEventDelegate {
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32,
                                          totalCountByCustomType: [String : NSNumber]?)
    {
        self.setUnreadMessagesCount(UInt(totalCount))
    }
}
