//
//  MainOpenChannelTabbarController.swift
//  SendbirdUIKit-Sample
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
    lazy var liveStreamingListVC: LiveStreamChannelListViewController = {
        let vc = LiveStreamChannelListViewController()
        vc.headerComponent?.titleView = UIView()
        vc.headerComponent?.leftBarButton = self.createLeftTitleItem(type: .liveStreaming)
        vc.headerComponent?.rightBarButton = .init()
        vc.listComponent = LiveStreamChannelListModule.List()
        vc.viewModel = LiveStreamChannelListViewModel(
            delegate: vc,
            channelListQuery: nil
        )
        vc.tabBarItem = self.createTabItem(type: .liveStreaming)
        return vc
    }()
    
    lazy var communityChannelListVC: CommunityChannelListViewController = {
        let vc = CommunityChannelListViewController()
        vc.headerComponent?.titleView = UIView()
        vc.headerComponent?.leftBarButton = self.createLeftTitleItem(type: .community)
        vc.tabBarItem = self.createTabItem(type: .community)
        return vc
    }()
    lazy var settingsVC: MyOpenChannelSettingsViewController = {
        let vc = MyOpenChannelSettingsViewController()
        vc.navigationItem.leftBarButtonItem = self.createLeftTitleItem(type: .mySettings)
        vc.tabBarItem = self.createTabItem(type: .mySettings)
        return vc
    }()
    
    var liveStreamingChannelsNavigationController = UINavigationController()
    var communityChannelsNavigationController = UINavigationController()
    var mySettingsNavigationController = UINavigationController()
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    var isDarkMode: Bool = false

    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.liveStreamingChannelsNavigationController = UINavigationController(
            rootViewController: liveStreamingListVC
        )
        self.communityChannelsNavigationController = UINavigationController(
            rootViewController: communityChannelListVC
        )
        self.mySettingsNavigationController = UINavigationController(
            rootViewController: settingsVC
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
        [
            self.liveStreamingChannelsNavigationController,
            self.communityChannelsNavigationController,
            self.mySettingsNavigationController
        ]
            .forEach { $0.navigationBar.barStyle = self.isDarkMode ? .black : .default }
        self.liveStreamingListVC.navigationItem.leftBarButtonItem = self.createLeftTitleItem(type: .liveStreaming)
        self.communityChannelListVC.navigationItem.leftBarButtonItem = self.createLeftTitleItem(type: .community)
        self.settingsVC.navigationItem.leftBarButtonItem = self.createLeftTitleItem(type: .mySettings)
    }
    
    
    // MARK: - Create items
    func createLeftTitleItem(type: OpenChannelTabType) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = type.rawValue
        titleLabel.font = SBUFontSet.h1
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
            icon = UIImage(named: "iconStreaming")?.sbu_resize(with: iconSize) ?? UIImage()
            tag = 0
        case .community:
            title = OpenChannelTabType.community.rawValue
            icon = UIImage(named: "iconChannels")?.sbu_resize(with: iconSize) ?? UIImage()
            tag = 1
        case .mySettings:
            title = OpenChannelTabType.mySettings.rawValue
            icon = UIImage(named: "iconSettingsFilled")?.sbu_resize(with: iconSize) ?? UIImage()
            tag = 2
        }
        
        let item = UITabBarItem(title: title, image: icon, tag: tag)
        return item
    }
    
    
    // MARK: - Common
    func updateTheme(isDarkMode: Bool) {
        self.isDarkMode = isDarkMode
        
        self.liveStreamingListVC.updateStyles()
        self.communityChannelListVC.updateStyles()
        self.settingsVC.setupStyles()
        
        self.setupStyles()
    }
}
