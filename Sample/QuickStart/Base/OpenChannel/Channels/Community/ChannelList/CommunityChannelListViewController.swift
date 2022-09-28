//
//  CommunityChannelListViewController.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/18.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This page shows how to create a view model to use a customized channel list query.
///
/// There are *2 ways* to customize the view model:
/// - **Customize channel list query only** (Recommended)
///     override ``SBUOpenChannelListViewController/createViewModel(channelListQuery:)`` method
/// - **Customize view model**
///     You can also use customized view model by overriding ``SBUOpenChannelListViewModel`` and  ``SBUOpenChannelListViewController/createViewModel(channelListQuery:)`` like below:
///     ```swift
///     open func createViewModel(channelListQuery: OpenChannelListQuery?) {
///         self.viewModel = MyChannelListViewModel(delegate: self, channelListQuery: channelListQuery)
///     }
///     ```
///     Please refer to ``LiveStreamChannelListViewModel``.
class CommunityChannelListViewController: SBUOpenChannelListViewController {
    // MARK: - Constant
    static let queryLimit: UInt = 20
    static let customType: String = "SB_COMMUNITY_TYPE"
    
    // MARK: - (Customization) View Model
    /// Override the below method to use a customized channel list query.
    override func createViewModel(channelListQuery: OpenChannelListQuery?) {
        let params = OpenChannelListQueryParams {
            $0.limit = Self.queryLimit
            $0.customTypeFilter = Self.customType
        }
        let communityChannelListQuery = OpenChannel.createOpenChannelListQuery(params: params)
        super.createViewModel(channelListQuery: communityChannelListQuery)
    }
    
    // MARK: - (Customization) Show Create Channel View
    
    /// - NOTE: **(Method 1)** You can customize *right bar button action* by overriding `baseChannelListModule(_:didTapRightItem:)` delegate method.
    override func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        let createOpenChannelVC = CreateCommunityChannelViewController()
        self.navigationController?.pushViewController(createOpenChannelVC, animated: true)
    }
    
    /// - NOTE: **(Method 2)** Override `showCreateChannel()` to use customized your own `SBUCreateOpenChannelViewController` instead of using the default view controller.
    override func showCreateChannel() {
        let createOpenChannelVC = CreateCommunityChannelViewController()
        self.navigationController?.pushViewController(createOpenChannelVC, animated: true)
    }
}


// MARK: - Tab bar controller
extension CommunityChannelListViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.setNeedsStatusBarAppearanceUpdate()
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
}
