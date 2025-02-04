//
//  BusinessMessagingTabBarController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/26/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

enum TabBarType: Int {
    case feedOnly
    case chatAndFeed
}

class BusinessMessagingTabBarController: UITabBarController {
    var channelsViewController: ChannelListViewController?
    let feedChannelsViewController = FeedChannelListViewController()
    let settingsViewController = MySettingsViewController()
    
    var channelsNavigationController = UINavigationController()
    var feedChannelsNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false
    
    var tabBarType: TabBarType = .feedOnly
    
    /// When the channel URL is set by the push notificaion, the channel will be opened.
    var channelURLforPushNotification: String?
    var channelType: ChannelType?
    
    // Tab index
    // - Feed only
    //     0: Feed Channel List
    //     1: Settings
    //
    // - Chat and Feed
    //     0: Group Channel List
    //     1: Feed Channel List
    //     2: Settings
    var chatChannelTabIndex: Int {
        return tabBarType == .feedOnly ? -1 : 0
    }
    
    var feedChannelTabIndex: Int {
        return tabBarType == .feedOnly ? 0 : 1
    }
    
    var settingsTabIndex: Int {
        return tabBarType == .feedOnly ? 1 : 2
    }
    
    init(tabBarType: TabBarType, channelURLForPushNotification: String?, channelType: ChannelType?) {
        self.tabBarType = tabBarType
        self.channelURLforPushNotification = channelURLForPushNotification
        self.channelType = channelType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.tabBarType != .feedOnly {
            let vc = ChannelListViewController()
            self.channelsViewController = vc
            self.channelsNavigationController = UINavigationController(rootViewController: vc)
        }

        self.feedChannelsNavigationController = UINavigationController(
            rootViewController: feedChannelsViewController
        )
        
        self.settingsViewController.sampleAppType = .businessMessagingSample
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        self.channelsViewController?.headerComponent?.titleView = UIView()
        self.channelsViewController?.headerComponent?.leftBarButton = self.createLeftTitleItem(text: "Channels")
        self.feedChannelsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Feed Channels")
        self.settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Settings")
        
        self.channelsViewController?.tabBarItem = self.createTabItem(type: .channels)
        self.feedChannelsViewController.tabBarItem = self.createTabItem(type: .feedChannels)
        self.mySettingsNavigationController.tabBarItem = self.createTabItem(type: .settings)
        
        self.tabBar.barTintColor = UIColor(named: "Background-50")
        self.tabBar.tintColor = UIColor(named: "Primary-300")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        var tabbarItems: [UIViewController] = []
        if self.tabBarType == .chatAndFeed {
            tabbarItems.append(self.channelsNavigationController)
        }
        tabbarItems.append(self.feedChannelsNavigationController)
        tabbarItems.append(self.mySettingsNavigationController)
        self.viewControllers = tabbarItems
        
        self.openFeedChannelIfNeeded()
    }

    func createTabItem(type: TabType) -> UITabBarItem {
        let iconSize = CGSize(width: 24, height: 24)
        
        var title: String?
        var icon: UIImage?
        var tag: Int = 0
        switch type {
        case .channels:
            title = "Channels"
            icon = UIImage(named: "iconChatFilled")?.sbu_resize(with: iconSize)
            tag = 0
        case .feedChannels:
            title = "Feed Channels"
            icon = UIImage(named: "iconNotificationsFilled")?.sbu_resize(with: iconSize)
            tag = 1
        case .settings:
            title = "Settings"
            icon = UIImage(named: "iconSettingsFilled")?.sbu_resize(with: iconSize)
            tag = 2
        }

        let item = UITabBarItem(title: title, image: icon, tag: tag)
        return item
    }
    
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = theme.titleColor
        return UIBarButtonItem.init(customView: titleLabel)
    }

    func openFeedChannelIfNeeded() {
        if let channelURL = self.channelURLforPushNotification, let channelType = self.channelType {
            self.channelURLforPushNotification = nil
            switch channelType {
            case .feed:
                if self.selectedIndex != self.feedChannelTabIndex {
                    self.selectedIndex = self.feedChannelTabIndex
                }
                
                let vc = NotificationChannelViewController(
                    channelURL: channelURL,
                    displaysLocalCachedListFirst: true
                )
                self.feedChannelsNavigationController.pushViewController(vc, animated: true)
            default:
                break
            }
        }
    }
    
    func openChatChannelIfNeeded() {
        if let channelURL = self.channelURLforPushNotification, let channelType = self.channelType {
            self.channelURLforPushNotification = nil
            switch channelType {
            case .feed:
                if self.selectedIndex != self.feedChannelTabIndex {
                    self.selectedIndex = self.feedChannelTabIndex
                }
                
                let vc = NotificationChannelViewController(
                    channelURL: channelURL,
                    displaysLocalCachedListFirst: true
                )
                self.feedChannelsNavigationController.pushViewController(vc, animated: true)
            case .group:
                if self.selectedIndex != self.chatChannelTabIndex {
                    self.selectedIndex = self.chatChannelTabIndex
                }
                SendbirdUI.moveToChannel(channelURL: channelURL, basedOnChannelList: true)
            default:
                break
            }
        }
    }
}
