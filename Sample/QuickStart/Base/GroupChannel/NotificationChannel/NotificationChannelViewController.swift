//
//  NotificationChannelViewController.swift
//  QuickStart
//
//  Created by Jaesung Lee on 2022/10/11.
//  Copyright © 2022 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class NotificationChannelViewController: SBUNotificationChannelViewController {
    override func setupViews() {
        super.setupViews()
        
        self.headerComponent?.leftBarButtons = []
    }
    
    /// **NOTIFICATION CHANNEL**
    /// Customize the new message badge
    override func notificationChannelViewModel(_ viewModel: SBUNotificationChannelViewModel, didChangeMessageList messages: [BaseMessage], needsToReload: Bool, initialLoad: Bool) {
        super.notificationChannelViewModel(
            viewModel,
            didChangeMessageList: messages,
            needsToReload: needsToReload,
            initialLoad: initialLoad
        )
        guard let channel = viewModel.channel else { return }
        self.navigationController?.tabBarItem.badgeValue = channel.unreadMessageCount != 0
        ? "\(channel.unreadMessageCount)"
        : nil
    }
    
    /// **NOTIFICATION CHANNEL**
    /// Customize the new message badge
    override func notificationChannelViewModel(_ viewModel: SBUNotificationChannelViewModel, didChangeChannel channel: GroupChannel?, withContext context: MessageContext) {
        super.notificationChannelViewModel(viewModel, didChangeChannel: channel, withContext: context)
        
        guard let channel = viewModel.channel else { return }
        self.navigationController?.tabBarItem.badgeValue = channel.unreadMessageCount != 0
        ? "\(channel.unreadMessageCount)"
        : nil
    }
    
    // MARK: - Tab bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
