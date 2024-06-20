//
//  NotificationChannelViewController.swift
//  QuickStart
//
//  Created by Jed Gyeong on 4/30/24.
//  Copyright © 2024 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class NotificationChannelViewController: SBUFeedNotificationChannelViewController {
    override func setupViews() {
        super.setupViews()
    }

    /// **NOTIFICATION CHANNEL**
    /// Customize the new notification badge
    override func didUpdateUnreadMessageCount(_ unreadMessageCount: UInt) {
        super.didUpdateUnreadMessageCount(unreadMessageCount)

        self.navigationController?.tabBarItem.badgeValue = unreadMessageCount != 0
        ? "\(unreadMessageCount)"
        : nil
    }

    // MARK: - Tab bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }

    required public init(
        channelURL: String,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        displaysLocalCachedListFirst: Bool = false,
        viewParams: SBUFeedNotificationChannelViewParams? = nil
    ) {
        super.init(
            channelURL: channelURL,
            viewParams: viewParams
        )
    }
    
    required public init(channel: FeedChannel, notificationListParams: MessageListParams? = nil, startingPoint: Int64? = nil, displaysLocalCachedListFirst: Bool = false) {
        fatalError("init(channel:notificationListParams:startingPoint:displaysLocalCachedListFirst:) has not been implemented")
    }
}
