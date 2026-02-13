//
//  SBUBaseChannelListViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/**
 - Note: When you create channel list for open channels, please inherit `SBUBaseChannelListViewController`
 
 - Important: You have to avoid using extension because of non-@objc issue
 
 ```swift
 class CustomizedOpenChannelListViewController: SBUBaseChannelListViewController, UITableViewDataSource, UITableViewDelegate
 ```
 */

open class SBUBaseChannelListViewController: SBUBaseViewController {
    
    // MARK: - UI Properties (Public)
    public var baseHeaderComponent: SBUBaseChannelListModule.Header?
    public var baseListComponent: SBUBaseChannelListModule.List?
    
    // MARK: - Logic properties (Public)
    public var baseViewModel: SBUBaseChannelListViewModel?
    
    // MARK: - Life cycle
    deinit {
        SBULog.info("")
        self.baseViewModel = nil
        self.baseHeaderComponent = nil
        self.baseListComponent = nil
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        self.navigationItem.titleView = self.baseHeaderComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.baseHeaderComponent?.leftBarButton

        if let rightBarButton = self.baseHeaderComponent?.rightBarButton, !rightBarButton.isEmpty {
            self.navigationItem.rightBarButtonItem = rightBarButton
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }

        self.navigationItem.leftBarButtonItems = self.baseHeaderComponent?.leftBarButtons

        if let rightBarButtons = self.baseHeaderComponent?.rightBarButtons,
           !rightBarButtons.allSatisfy({ $0.isEmpty }) {
            self.navigationItem.rightBarButtonItems = rightBarButtons
        } else {
            self.navigationItem.rightBarButtonItems = nil
        }
        
        if let listComponent = self.baseListComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    open override func setupLayouts() {
        let useSafeArea: Bool
        if SendbirdUI.config.common.shouldApplyLiquidGlass {
            useSafeArea = false
        } else {
            useSafeArea = true
        }
        
        self.baseListComponent?.sbu_constraint(
            equalTo: self.view,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            useSafeArea: useSafeArea
        )
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.baseListComponent?.reloadTableView()
    }
    
    /// This is a function that shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelURL: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    open func showChannel(channelURL: String, messageListParams: MessageListParams? = nil) {
    }
}
