//
//  SBUModerationsViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


open class SBUModerationsViewController: SBUBaseViewController, SBUModerationsModuleHeaderDelegate, SBUModerationsModuleListDelegate, SBUModerationsModuleListDataSource, SBUCommonViewModelDelegate, SBUModerationsViewModelDelegate {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUModerationsModule.Header?
    public var listComponent: SBUModerationsModule.List?
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.channelSettingsTheme)
    public var theme: SBUChannelSettingsTheme
    
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUModerationsViewModel?
    
    public var channel: GroupChannel? { viewModel?.channel }
    public var channelURL: String? { viewModel?.channelURL }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUModerationsViewController(channel:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUModerationsViewController(channel:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    required public init(channel: GroupChannel) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channel: channel)
        self.headerComponent = SBUModuleSet.moderationsModule.headerComponent
        self.listComponent = SBUModuleSet.moderationsModule.listComponent
    }
    
    /// If you don't have channel object and have channelURL, use this initialize function.
    /// - Parameter channelURL: Channel url string
    required public init(channelURL: String) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelURL: channelURL)
        self.headerComponent = SBUModuleSet.moderationsModule.headerComponent
        self.listComponent = SBUModuleSet.moderationsModule.listComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    
    // MARK: - ViewModel
    open func createViewModel(channel: GroupChannel? = nil,
                              channelURL: String? = nil) {
        self.viewModel = SBUModerationsViewModel(
            channel: channel,
            channelURL: channelURL,
            delegate: self
        )
    }
    
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItem = self.headerComponent?.leftBarButton
        self.navigationItem.rightBarButtonItem = self.headerComponent?.rightBarButton
        
        // List component
        self.listComponent?.configure(
            delegate: self,
            dataSource: self,
            theme: self.theme
        )
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
    }
    
    open override func setupLayouts() {
        self.listComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.listComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.listComponent?.reloadTableView()
    }

    
    // MARK: - Actions
    
    /// Changes freeze status on channel.
    /// - Parameter freeze: freeze status
    /// - Parameter completionHandler: completion handler of freeze status change
    public func changeFreeze(_ freeze: Bool, _ completionHandler: ((Bool) -> Void)? = nil) {
        if freeze {
            self.viewModel?.freezeChannel(completionHandler)
        } else {
            self.viewModel?.unfreezeChannel(completionHandler)
        }
    }
    
    /// This is a function that shows the operator List.
    /// If you want to use a custom UserListViewController, override it and implement it.
    open func showOperatorList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        
        let operatorListVC = SBUViewControllerSet.UserListViewController.init(
            channel: channel,
            userListType: .operators
        )
        self.navigationController?.pushViewController(operatorListVC, animated: true)
    }
    
    /// This is a function that shows the muted member List.
    /// If you want to use a custom UserListViewController, override it and implement it.
    open func showMutedMemberList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        
        let mutedMemberListVC = SBUViewControllerSet.UserListViewController.init(
            channel: channel,
            userListType: .muted
        )
        self.navigationController?.pushViewController(mutedMemberListVC, animated: true)
    }
    
    /// This is a function that shows the banned member List.
    /// If you want to use a custom UserListViewController, override it and implement it.
    open func showBannedUserList() {
        guard let channel = self.channel else {
            SBULog.error("[Failed] Channel object is nil")
            return
        }
        
        let bannedUserListVC = SBUViewControllerSet.UserListViewController.init(
            channel: channel,
            userListType: .banned
        )
        self.navigationController?.pushViewController(bannedUserListVC, animated: true)
    }
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    
    
    // MARK: SBUModerationsModuleHeaderDelegate
    open func moderationsModule(_ headerComponent: SBUModerationsModule.Header,
                                didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func moderationsModule(_ headerComponent: SBUModerationsModule.Header,
                                didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func moderationsModule(_ headerComponent: SBUModerationsModule.Header,
                                didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func moderationsModule(_ headerComponent: SBUModerationsModule.Header,
                                didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    
    // MARK: SBUModerationsModuleListDelegate
    open func moderationsModule(_ listComponent: SBUModerationsModule.List,
                                didChangeFreezeMode state: Bool) {
        self.changeFreeze(state)
    }
    
    open func moderationsModule(_ listComponent: SBUModerationsModule.List,
                                didSelectRowAt indexPath: IndexPath) {
        let isBroadcast = self.channel?.isBroadcast ?? false
        let type = ModerationItemType.allTypes(isBroadcast: isBroadcast)[indexPath.row]
        switch type {
        case .operators:
            self.showOperatorList()
        case .mutedMembers:
            self.showMutedMemberList()
        case .bannedUsers:
            self.showBannedUserList()
        case .freezeChannel:
            break
        default:
            break
        }
    }
    
    
    // MARK: SBUModerationsModuleListDataSource
    open func moderationsModule(_ listComponent: SBUModerationsModule.List,
                                  channelForTableView tableView: UITableView) -> BaseChannel? {
        return self.viewModel?.channel
    }
    
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
    }
    
    
    // MARK: - SBUModerationsViewModelDelegate
    open func moderationsViewModel(_ viewModel: SBUModerationsViewModel,
                                   didChangeChannel channel: BaseChannel?,
                                   withContext context: MessageContext) {
        self.updateStyles()
    }
}

