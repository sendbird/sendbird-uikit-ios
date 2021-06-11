//
//  SBUBaseChannelListViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/**
 - Note: When you create channel list for open channels, please inherit `SBUBaseChannelListViewController`
 
 - Important: You have to avoid using extension because of non-@objc issue
 
 ```swift
 class CustomizedOpenChannelListViewController: SBUBaseChannelListViewController, UITableViewDataSource, UITableViewDelegate
 ```
 */
@objcMembers
open class SBUBaseChannelListViewController: SBUBaseViewController {
    
    /// This is a function that shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelUrl: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    open func showChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
    }
}
