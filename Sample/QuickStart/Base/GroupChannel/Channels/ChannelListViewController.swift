//
//  ChannelListViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/09/14.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class ChannelListViewController: SBUGroupChannelListViewController {
    // MARK: Tab bar controller
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    /// **NOTIFICATION CHANNEL**
    /// Filtering channels (or override ``baseChannelListModule(_:channelsInTableView:)``)
    override func createViewModel(channelListQuery: GroupChannelListQuery?) {
        /// To fetch notification center channel, set `includeEmptyChannel` as `true`
        let channelListQuery = GroupChannel.createMyGroupChannelListQuery {
            $0.includeEmptyChannel = true
            $0.customTypesFilter = [""]
        }
        super.createViewModel(channelListQuery: channelListQuery)
    }
    
    /// **NOTIFICATION CHANNEL**
    /// Filtering channels
    override func baseChannelListModule(_ listComponent: SBUBaseChannelListModule.List, channelsInTableView tableView: UITableView) -> [BaseChannel]? {
        return self.viewModel?.channelList.filter {
            !$0.channelURL.hasPrefix(SBUStringSet.Notification_Channel_URL(""))
        }
    }
}
