//
//  SBUGroupChannelListViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUGroupChannelListViewController: SBUBaseChannelListViewController, SBUGroupChannelListModuleHeaderDelegate, SBUGroupChannelListModuleListDelegate, SBUGroupChannelListModuleListDataSource, SBUCreateChannelTypeSelectorDelegate, SBUCommonViewModelDelegate, SBUGroupChannelListViewModelDelegate {
    
    // MARK: - UI properties (Public)
    public var headerComponent: SBUGroupChannelListModule.Header?
    public var listComponent: SBUGroupChannelListModule.List?
    public lazy var createChannelTypeSelector: UIView? = nil
    
    // Theme
    @SBUThemeWrapper(theme: SBUTheme.channelListTheme)
    public var theme: SBUChannelListTheme
    
    
    // MARK: - UI properties (Private)
    private lazy var defaultCreateChannelTypeSelector: SBUCreateChannelTypeSelector = {
        let view = SBUCreateChannelTypeSelector(delegate: self)
        view.isHidden = true
        return view
    }()
    
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUGroupChannelListViewModel?
    
    /// This object has a list of all channels.
    public var channelList: [SBDGroupChannel] { self.viewModel?.channelList ?? [] }
    
    /// This is a property that allows you to show the channel type selector when creating a channel. (default: `true`)
    /// - Since: 3.0.0
    public var enableCreateChannelTypeSelector: Bool = true
    
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUGroupChannelListViewController()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUGroupChannelListViewController()")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// This function initialize the class without `channelListQuery`.
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.createViewModel(channelListQuery: nil)
        self.headerComponent = SBUModuleSet.channelListModule.headerComponent
        self.listComponent = SBUModuleSet.channelListModule.listComponent
    }
    
    /// You can initialize the class through this function.
    /// If you have `channelListQuery`, please set it. If not set, it is used as default value.
    ///
    /// See the example below for query generation.
    /// ```
    ///     let query = SBDGroupChannel.createMyGroupChannelListQuery()
    ///     query?.includeEmptyChannel = false
    ///     query?.includeFrozenChannel = true
    ///     ...
    /// ```
    /// - Parameter channelListQuery: Your own `SBDGroupChannelListQuery` object
    /// - Since: 1.0.11
    required public init(channelListQuery: SBDGroupChannelListQuery? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelListQuery: channelListQuery)
        self.headerComponent = SBUModuleSet.channelListModule.headerComponent
        self.listComponent = SBUModuleSet.channelListModule.listComponent
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.viewModel?.initChannelList()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    
    // MARK: - ViewModel
    /// Creates the view model.
    /// - Parameter channelListQuery: Customer's own `SBDGroupChannelListQuery` object
    /// - Since: 3.0.0
    open func createViewModel(channelListQuery: SBDGroupChannelListQuery?) {
        self.viewModel = SBUGroupChannelListViewModel(
            delegate: self,
            channelListQuery: channelListQuery
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
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        if let listComponent = self.listComponent {
            self.view.addSubview(listComponent)
        }
        
        // Channel type selector
        self.loadChannelTypeSelector()
    }
    
    open override func setupLayouts() {
        self.listComponent?.sbu_constraint(equalTo: self.view, left: 0, right: 0, top: 0, bottom: 0)
        
        if let view = self.navigationController?.view,
           let createChannelTypeSelector = self.createChannelTypeSelector {
            createChannelTypeSelector.sbu_constraint(
                equalTo: view,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        }
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.listComponent?.setupStyles(theme: self.theme)
        
        if let createChannelTypeSelector = self.createChannelTypeSelector as? SBUCreateChannelTypeSelector {
            createChannelTypeSelector.setupStyles()
        }
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        
        self.listComponent?.reloadTableView()
    }

    
    // MARK: - Common
    open func loadChannelTypeSelector() {
        if SBUAvailable.isSupportSuperGroupChannel() || SBUAvailable.isSupportBroadcastChannel() {
            if self.createChannelTypeSelector == nil {
                self.createChannelTypeSelector = self.defaultCreateChannelTypeSelector
            }
            
            if let createChannelTypeSelector = self.createChannelTypeSelector {
                self.navigationController?.view.addSubview(createChannelTypeSelector)
            }
        }
    }
    
    
    
    // MARK: - Actions (Show)
    /// This is a function that shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelUrl: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    open override func showChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        let channelVC = SBUViewControllerSet.GroupChannelViewController.init(
            channelUrl: channelUrl,
            messageListParams: messageListParams
        )
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    /// This is a function that shows the channel type selector when a supergroup/broadcast channel can be set.
    /// If it cannot be set, this function shows the channel creation screen.
    /// - Since: 3.0.0
    open func showCreateChannelOrTypeSelector() {
        if (SBUAvailable.isSupportSuperGroupChannel() || SBUAvailable.isSupportBroadcastChannel())
            && self.createChannelTypeSelector != nil
            && self.enableCreateChannelTypeSelector {
            self.showCreateChannelTypeSelector()
        } else {
            self.showCreateChannel(type: .group)
        }
    }
    
    /// This is a function that shows the channel type selector when a supergroup/broadcast channel can be set.
    ///
    /// * If you want to use a custom `createChannelTypeSelector`, override it and implement it.
    /// - note: Type: GroupChannel / SuperGroupChannel / BroadcastChannel
    /// - Since: 1.2.0
    open func showCreateChannelTypeSelector() {
        if let typeSelector = self.createChannelTypeSelector as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.show()
        }
    }
    
    /// This is a function that shows the channel creation viewController with channel type.
    ///
    /// If you want to use a custom createChannelViewController, override it and implement it.
    /// - Parameter type: Using the Specified Type in CreateChannelViewController (default: `.group`)
    open func showCreateChannel(type: ChannelCreationType = .group) {
        let createChannelVC = SBUViewControllerSet.CreateChannelViewController.init(type: type)
        self.navigationController?.pushViewController(createChannelVC, animated: true)
    }
    
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBDError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    

    // MARK: - SBUGroupChannelListModuleHeaderDelegate
    open func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header,
                                didUpdateTitleView titleView: UIView?) {
        self.navigationItem.titleView = titleView
    }
    
    open func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header,
                                didUpdateLeftItem leftItem: UIBarButtonItem?) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header,
                                didUpdateRightItem rightItem: UIBarButtonItem?) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    open func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header,
                                didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header,
                                didTapRightItem rightItem: UIBarButtonItem) {
        self.showCreateChannelOrTypeSelector()
    }
    
    
    // MARK: - SBUGroupChannelListModuleListDelegate
    open func channelListModule(_ listComponent: SBUGroupChannelListModule.List,
                                didSelectRowAt indexPath: IndexPath) {
        guard indexPath.row < self.channelList.count, 
              let channel = self.viewModel?.channelList[indexPath.row] else { return }
        self.showChannel(channelUrl: channel.channelUrl)
    }
    
    open func channelListModule(_ listComponent: SBUGroupChannelListModule.List,
                                didSelectLeave channel: SBDGroupChannel) {
        self.viewModel?.leaveChannel(channel)
    }
    
    open func channelListModule(_ listComponent: SBUGroupChannelListModule.List,
                                didChangePushTriggerOption option: SBDGroupChannelPushTriggerOption,
                                channel: SBDGroupChannel) {
        self.viewModel?.changePushTriggerOption(option: option, channel: channel)
    }
    
    open func channelListModule(_ listComponent: SBUGroupChannelListModule.List,
                                didDetectPreloadingPosition indexPath: IndexPath) {
        self.viewModel?.loadNextChannelList(reset: false)
    }
    
    open func channelListModuleDidSelectRetry(_ listComponent: SBUGroupChannelListModule.List) {
        self.viewModel?.initChannelList()
    }
    
    
    // MARK: - SBUGroupChannelListModuleListDataSource
    open func channelListModule(_ listComponent: SBUGroupChannelListModule.List,
                                channelsInTableView tableView: UITableView) -> [SBDGroupChannel]? {
        return self.viewModel?.channelList
    }
    
    
    // MARK: - SBUCreateChannelTypeSelectorDelegate
    open func didSelectCloseSelector() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
    }
    
    open func didSelectCreateGroupChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .group)
    }
    
    open func didSelectCreateSuperGroupChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .supergroup)
    }
    
    open func didSelectCreateBroadcastChannel() {
        if let typeSelector = self.createChannelTypeSelector
            as? SBUCreateChannelTypeSelectorProtocol {
            typeSelector.dismiss()
        }
        self.showCreateChannel(type: .broadcast)
    }
    
    
    // MARK: - SBUCommonViewModelDelegate
    open func connectionStateDidChange(_ isConnected: Bool) {
        if isConnected {
            self.loadChannelTypeSelector()
        }
    }
    
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBDError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
        
        if isBlocker {
            self.viewModel?.reset()
            
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
    }
    
    
    // MARK: - SBUGroupChannelListViewModelDelegate
    open func groupChannelListViewModel(_ viewModel: SBUGroupChannelListViewModel,
                                        didChangeChannelList channels: [SBDGroupChannel]?,
                                        needsToReload: Bool) {
        if let channelList = channels {
            self.listComponent?.updateEmptyView(type: (channelList.count == 0) ? .noChannels : .none)
        }
        
        guard needsToReload else { return }
        
        self.listComponent?.reloadTableView()
    }
    
    open func groupChannelListViewModel(_ viewModel: SBUGroupChannelListViewModel,
                                        didUpdateChannel channel: SBDGroupChannel) { }
    
    open func groupChannelListViewModel(_ viewModel: SBUGroupChannelListViewModel,
                                        didLeaveChannel channel: SBDGroupChannel) { }
}
