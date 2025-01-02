//
//  SBUOpenChannelListViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if SWIFTUI
import SwiftUI
#endif

#if SWIFTUI
protocol OpenChannelListViewEventDelegate: AnyObject {
    func openChannelListView(didSelectRowAt indexPath: IndexPath)
}
#endif

open class SBUOpenChannelListViewController: SBUBaseChannelListViewController, SBUOpenChannelListModuleHeaderDelegate, SBUOpenChannelListModuleListDelegate, SBUOpenChannelListModuleListDataSource, SBUCommonViewModelDelegate, SBUOpenChannelListViewModelDelegate {
    
    // MARK: - UI Properties (Public)
    public var headerComponent: SBUOpenChannelListModule.Header? {
        get { self.baseHeaderComponent as? SBUOpenChannelListModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUOpenChannelListModule.List? {
        get { self.baseListComponent as? SBUOpenChannelListModule.List }
        set { self.baseListComponent = newValue }
    }
    
    @SBUThemeWrapper(theme: SBUTheme.openChannelListTheme)
    public var theme: SBUOpenChannelListTheme
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUOpenChannelListViewModel? {
        get { self.baseViewModel as? SBUOpenChannelListViewModel }
        set { self.baseViewModel = newValue }
    }
    
    /// This object has a list of all channels.
    public var channelList: [OpenChannel] { self.viewModel?.channelList ?? [] }
    
    // MARK: - SwiftUI
    #if SWIFTUI
    var openChannelViewBuilder: OpenChannelViewBuilder?
    var createChannelViewBuilder: CreateOpenChannelViewBuilder?
    
    weak var swiftUIDelegate: (SBUOpenChannelListViewModelDelegate & OpenChannelListViewEventDelegate)? {
        didSet {
            self.viewModel?.baseDelegates.addDelegate(self.swiftUIDelegate, type: .swiftui)
        }
    }
    #endif
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUOpenChannelListViewController()")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        fatalError()
    }
    
    @available(*, unavailable, renamed: "SBUOpenChannelListViewController()")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        fatalError()
    }
    
    /// This function initialize the class without `channelListQuery`.
    public init() {
        super.init(nibName: nil, bundle: nil)
        
        self.createViewModel(channelListQuery: nil)
        self.headerComponent = SBUModuleSet.OpenChannelListModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.OpenChannelListModule.ListComponent.init()
    }
    
    /// You can initialize the class through this function.
    /// If you have `channelListQuery`, please set it. If not set, it is used as default value.
    ///
    /// See the example below for query generation.
    /// ```
    ///     let params = OpenChannelListQueryParams()
    ///     params.includeEmptyChannel = false
    ///     params.includeFrozenChannel = true
    ///     let query = OpenChannel.createMyOpenChannelListQuery(params: params)
    ///     ...
    /// ```
    /// - Parameter channelListQuery: Your own `OpenChannelListQuery` object
    /// - Since: 1.0.11
    required public init(channelListQuery: OpenChannelListQuery? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.createViewModel(channelListQuery: channelListQuery)
        self.headerComponent = SBUModuleSet.OpenChannelListModule.HeaderComponent.init()
        self.listComponent = SBUModuleSet.OpenChannelListModule.ListComponent.init()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.viewModel?.initChannelList()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateStyles()
        
        #if INSPECTION
        NotificationCenter.default.post(name: Notification.Name.bringInspectionViewToFront, object: nil)
        #endif
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.statusBarStyle
    }
    
    deinit {
        SBULog.info("")
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    // MARK: - ViewModel
    /// Creates the view model.
    /// - Parameter channelListQuery: Customer's own `OpenChannelListQuery` object
    /// - Since: 3.0.0
    open func createViewModel(channelListQuery: OpenChannelListQuery?) {
        self.viewModel = SBUViewModelSet.OpenChannelListViewModel.init(
            delegate: self,
            channelListQuery: channelListQuery
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        // Header component
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        // List component
        self.listComponent?.configure(delegate: self, dataSource: self, theme: self.theme)
        
        super.setupViews()
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
    }
    
    open override func setupStyles() {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.headerComponent?.setupStyles(theme: self.theme)
        self.listComponent?.setupStyles(theme: self.theme)
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        super.updateStyles()
    }
    
    // MARK: - Actions (Show)
    
    open func reloadChannelList() {
        self.viewModel?.loadNextChannelList(reset: true)
    }
    
    /// This is a function that shows the channelViewController.
    ///
    /// If you want to use a custom channelViewController, override it and implement it.
    /// - Parameters:
    ///   - channelURL: channel url for use in channelViewController.
    ///   - messageListParams: If there is a messageListParams set directly for use in Channel, set it up here
    open override func showChannel(channelURL: String, messageListParams: MessageListParams? = nil) {
        #if SWIFTUI
        if let openChannelViewBuilder = self.openChannelViewBuilder {
            let view = openChannelViewBuilder(channelURL, messageListParams)
            let channelVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(channelVC, animated: true)
            return
        }
        #endif
        let channelVC = SBUViewControllerSet.OpenChannelViewController.init(
            channelURL: channelURL,
            messageListParams: messageListParams
        )
        self.navigationController?.pushViewController(channelVC, animated: true)
    }
    
    /// This is a function that shows the channel creation viewController.
    ///
    /// If you want to use a custom createChannelViewController, override it and implement it.
    open func showCreateChannel() {
        #if SWIFTUI
        if let createChannelViewBuilder = self.createChannelViewBuilder {
            let view = createChannelViewBuilder()
            let createOpenChannelVC = UIHostingController(rootView: view)
            self.navigationController?.pushViewControllerNonFlickering(createOpenChannelVC, animated: true)
            return
        }
        #endif
        let createOpenChannelVC = SBUViewControllerSet.CreateOpenChannelViewController.init()
        self.navigationController?.pushViewController(createOpenChannelVC, animated: true)
    }
    
    // MARK: - Error handling
    private func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }

    // MARK: - SBUOpenChannelListModuleHeaderDelegate
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didUpdateTitleView titleView: UIView?
    ) {
        self.navigationItem.titleView = titleView
    }
    
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didUpdateLeftItem leftItem: UIBarButtonItem?
    ) {
        self.navigationItem.leftBarButtonItem = leftItem
    }
    
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didUpdateRightItem rightItem: UIBarButtonItem?
    ) {
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    /// 3.28.0
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    /// 3.28.0
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    ) {
        self.onClickBack()
    }
    
    open func baseChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    ) {
        self.showCreateChannel()
    }
    
    // MARK: - SBUOpenChannelListModuleListDelegate
    open func baseChannelListModule(
        _ listComponent: SBUBaseChannelListModule.List,
        didSelectRowAt indexPath: IndexPath
    ) {
        guard let channel = self.viewModel?.channelList[indexPath.row] else { return }
        self.showChannel(channelURL: channel.channelURL)
        
        #if SWIFTUI
        self.swiftUIDelegate?.openChannelListView(didSelectRowAt: indexPath)
        #endif
    }
    
    open func baseChannelListModule(
        _ listComponent: SBUBaseChannelListModule.List,
        didDetectPreloadingPosition indexPath: IndexPath
    ) {
        self.viewModel?.loadNextChannelList(reset: false)
    }
    
    open func baseChannelListModuleDidSelectRetry(_ listComponent: SBUBaseChannelListModule.List) {
        self.viewModel?.initChannelList()
    }
    
    public func baseChannelListModuleDidSelectRefresh(_ listComponent: SBUBaseChannelListModule.List) {
        self.viewModel?.loadNextChannelList(reset: true)
    }
    
    // MARK: - SBUOpenChannelListModuleListDataSource
    open func baseChannelListModule(
        _ listComponent: SBUBaseChannelListModule.List,
        channelsInTableView tableView: UITableView
    ) -> [BaseChannel]? {
        return self.viewModel?.channelList
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func connectionStateDidChange(_ isConnected: Bool) {
        if isConnected {
            
        }
    }
    
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SBError?, isBlocker: Bool) {
        self.showLoading(false)
        self.errorHandler(error?.description ?? "")
        
        if isBlocker {
            self.viewModel?.reset()
            
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
    }
    
    // MARK: - SBUOpenChannelListViewModelDelegate
    open func openChannelListViewModel(
        _ viewModel: SBUOpenChannelListViewModel,
        didChangeChannelList channels: [OpenChannel]?,
        needsToReload: Bool
    ) {
        if let channelList = channels {
            self.listComponent?.updateEmptyView(type: (channelList.count == 0) ? .noChannels : .none)
        }
        
        guard needsToReload else { return }
        
        self.listComponent?.reloadTableView()
    }
    
    open func openChannelListViewModel(
        _ viewModel: SBUOpenChannelListViewModel,
        didUpdateChannel channel: OpenChannel
    ) { }
}
