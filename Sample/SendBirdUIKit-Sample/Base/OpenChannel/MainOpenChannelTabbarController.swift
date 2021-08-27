//
//  MainOpenChannelTabbarController.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

enum OpenChannelTabType: String {
    case liveStreaming = "Live streams"
    case community = "Community"
    case mySettings = "My settings"
}


class MainOpenChannelTabbarController: UITabBarController {
    let liveStreamingListViewController = StreamingChannelListViewController()
    let communityChannelListViewController = CommunityChannelListViewController()
    let settingsViewController = MyOpenChannelSettingsViewController()
    
    var liveStreamingChannelsNavigationController = UINavigationController()
    var communityChannelsNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        liveStreamingListViewController.titleView = UIView()
        
        self.liveStreamingChannelsNavigationController = UINavigationController(
            rootViewController: liveStreamingListViewController
        )
        self.communityChannelsNavigationController = UINavigationController(
            rootViewController: communityChannelListViewController
        )
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsViewController
        )
        
        let tabbarItems = [
            self.liveStreamingChannelsNavigationController,
            self.communityChannelsNavigationController,
            self.mySettingsNavigationController
        ]
        self.viewControllers = tabbarItems
        
        self.setupStyles()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    public func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.tabBar.barTintColor = self.isDarkMode
            ? SBUColorSet.background600
            : .white
        self.tabBar.tintColor = self.isDarkMode
            ? SBUColorSet.primary200
            : SBUColorSet.primary300
        
        liveStreamingListViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: OpenChannelTabType.liveStreaming.rawValue
        )
        liveStreamingListViewController.tabBarItem = self.createTabItem(type: .liveStreaming)
        
        communityChannelListViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: OpenChannelTabType.community.rawValue
        )
        communityChannelListViewController.tabBarItem = self.createTabItem(type: .community)
        
        settingsViewController.navigationItem.leftBarButtonItem = self.createLeftTitleItem(
            text: OpenChannelTabType.mySettings.rawValue
        )
        settingsViewController.tabBarItem = self.createTabItem(type: .mySettings)
        
        self.liveStreamingChannelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.communityChannelsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
        self.mySettingsNavigationController.navigationBar.barStyle = self.isDarkMode
            ? .black
            : .default
    }
    
    
    // MARK: - Create items
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: .bold)
        titleLabel.textColor = theme.titleColor
        return UIBarButtonItem.init(customView: titleLabel)
    }
    
    func createTabItem(type: OpenChannelTabType) -> UITabBarItem {
        let iconSize = CGSize(width: 24, height: 24)
        
        var title = ""
        var icon = UIImage()
        var tag = 0
        
        switch type {
        case .liveStreaming:
            title = OpenChannelTabType.liveStreaming.rawValue
            icon = UIImage(named: "iconStreaming")?.resize(with: iconSize) ?? UIImage()
            tag = 0
        case .community:
            title = OpenChannelTabType.community.rawValue
            icon = UIImage(named: "iconChannels")?.resize(with: iconSize) ?? UIImage()
            tag = 1
        case .mySettings:
            title = OpenChannelTabType.mySettings.rawValue
            icon = UIImage(named: "iconSettingsFilled")?.resize(with: iconSize) ?? UIImage()
            tag = 2
        }
        
        let item = UITabBarItem(title: title, image: icon, tag: tag)
        return item
    }
    
    
    // MARK: - Common
    func updateTheme(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        
        self.setupStyles()
        self.liveStreamingListViewController.setupStyles()
        self.communityChannelListViewController.setupStyles()
        self.settingsViewController.setupStyles()

        self.liveStreamingListViewController.reloadTableView()
        self.communityChannelListViewController.reloadTableView()
    }
}
