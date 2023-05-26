//
//  SBUChatNotificationChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/03/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
import AVKit
import SafariServices

/// - Since: 3.5.0
@objcMembers
open class SBUChatNotificationChannelViewController: SBUBaseViewController,
    SBUChatNotificationChannelViewModelDelegate, SBUChatNotificationChannelViewModelDataSource,
    SBUChatNotificationChannelModuleListDelegate, SBUChatNotificationChannelModuleListDataSource,
    SBUChatNotificationChannelModuleHeaderDelegate,
    SBUCommonViewModelDelegate {
    
    // MARK: - Module components (Public)
    public var headerComponent: SBUChatNotificationChannelModule.Header?
    public var listComponent: SBUChatNotificationChannelModule.List?
    
    var theme: SBUNotificationTheme {
        switch SBUTheme.colorScheme {
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    /// The boolean value that allows to update the read status of ``channel``. If it's `false`, ``channel`` doesn't update the read status of a new notification.
    /// - IMPORTANT: As a default, it updates  to `true` when ``viewWillAppear(_:)`` is called and  to `false` when ``viewWillDisappear(_:)`` is called.
    public var allowsReadStatusUpdate: Bool {
        get { self.viewModel?.allowsReadStatusUpdate ?? false }
        set { self.viewModel?.allowsReadStatusUpdate = newValue }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.header.statusBarStyle
    }
    
    // MARK: - View model (Public)
    var viewModel: SBUChatNotificationChannelViewModel?
    
    public var channelName: String? {
        (self.viewModel?.channel as? GroupChannel)?.name
    }
    
    public var channel: GroupChannel? {
        self.viewModel?.channel as? GroupChannel
    }

    // MARK: - Logic properties (Public)
    public private(set) var newNotificationsCount: Int = 0
    
    // MARK: - Logic properties (Private)
    var scrollToInitialPositionHandler: (() -> Void)?
    var lastSeenIndexPath: IndexPath?
    
    var createViewModelHandler: (() -> Void)?
    
    // MARK: - Lifecycle
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("Cannot use `init(coder:)`")
    }
    
    /// Initializes ``SBUChatNotificationChannelViewController`` with channel
    required public init(
        channel: GroupChannel,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        displaysLocalCachedListFirst: Bool = false
    ) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        self.createViewModelHandler = { [weak self] in
            guard let self = self else { return }
            self.createViewModel(
                channel: channel,
                notificationListParams: notificationListParams,
                startingPoint: startingPoint,
                displaysLocalCachedListFirst: displaysLocalCachedListFirst
            )
        }
        
        self.headerComponent = SBUModuleSet.chatNotificationChannelModule.headerComponent
        self.listComponent = SBUModuleSet.chatNotificationChannelModule.listComponent
    }
    
    /// Initializes ``SBUFeedNotificationChannelViewController`` with channelURL
    required public init(
        channelURL: String,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        displaysLocalCachedListFirst: Bool = false
    ) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        self.createViewModelHandler = { [weak self] in
            guard let self = self else { return }
            self.createViewModel(
                channelURL: channelURL,
                notificationListParams: notificationListParams,
                startingPoint: startingPoint,
                displaysLocalCachedListFirst: displaysLocalCachedListFirst
            )
        }
        
        self.headerComponent = SBUModuleSet.chatNotificationChannelModule.headerComponent
        self.listComponent = SBUModuleSet.chatNotificationChannelModule.listComponent
    }
    
    open override func loadView() {
        super.loadView()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
        
        self.createViewModelHandler?()
        self.createViewModelHandler = nil
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        self.view.endEditing(true)
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.allowsReadStatusUpdate == false {
            allowsReadStatusUpdate = true
            // Update read status when it appear (UITabBarController case)
            viewModel?.markAsRead()
        }
        
        self.updateStyles()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewModel?.updateLastSeenAt()
        self.allowsReadStatusUpdate = false
    }
    
    deinit {
        SBULog.info("")
        
        self.viewModel = nil
        self.headerComponent = nil
        self.listComponent = nil
    }
    
    // MARK: - Channel
    /// This function reloads channel information and notification list.
    /// - Parameter channelURL: ChannelURL String (Default: ChannelURL currently in use)
    /// - Since: 3.5.0
    public func reloadChannel(channelURL: String?) {
        if let channelURL = channelURL ?? self.viewModel?.channelURL {
            self.viewModel?.loadChannel(channelURL: channelURL)
        }
    }
    
    /// Update the timestamp when the channel was seen last at.
    /// - Parameter timestamp: If it's `nil`, it updates to `channel.myLastRead`.
    /// - Since: 3.5.0
    public func updateLastSeenAt(timestamp: Int64? = nil) {
        self.viewModel?.updateLastSeenAt(timestamp)
    }
    
    /// Called when unread message count did update.
    /// - Parameter unreadMessageCount: unread message count
    /// - Since: 3.5.0
    open func didUpdateUnreadMessageCount(_ unreadMessageCount: UInt) {
        SBULog.info("Unread message count: \(unreadMessageCount)")
    }
    
    // MARK: - Header
    
    /// Updates channelTitle with channel and channelName
    /// - Since: 3.5.0
    public func updateChannelTitle() {
        if let titleView = (self.headerComponent?.titleView as? SBUChannelTitleView) {
            titleView.configure(
                channel: self.viewModel?.channel,
                title: self.viewModel?.channel?.name
            )
        }
        
        self.headerComponent?.updateStyles()
    }
    
    // MARK: - Action handling
    /// Called when there’s a tap gesture on a notification that includes a web URL. e.g., `"https://www.sendbird.com"`
    /// ```swift
    /// print(action.data) // "https://www.sendbird.com"
    /// ```
    /// - Since: 3.5.0
    open func handleWebAction(_
        action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        if let url = URL(string: action.data) {
            url.open()
        } else if let urlString = action.alterData, let url = URL(string: urlString) {
            url.open()
        }
    }
    
    /// Called when there’s a tap gesture on a notification that includes a custom URL scheme. e.g., `"myapp://someaction"`
    /// ```swift
    /// print(action.data) // "myapp://someaction"
    /// ```
    /// - Since: 3.5.0
    open func handleCustomAction(
        _ action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        if let urlScehem = URL(string: action.data) {
            urlScehem.open()
        } else if let urlString = action.alterData, let url = URL(string: urlString) {
            url.open()
        }
    }
    
    // MARK: - ViewModel
    func createViewModel(
        channel: GroupChannel? = nil,
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        showIndicator: Bool = true,
        displaysLocalCachedListFirst: Bool = false
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.viewModel = SBUChatNotificationChannelViewModel(
            channel: channel,
            channelURL: channelURL,
            notificationListParams: notificationListParams,
            startingPoint: startingPoint,
            delegate: self,
            dataSource: self,
            displaysLocalCachedListFirst: displaysLocalCachedListFirst
        )
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        super.setupViews()
        
        // Header
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.navigationItem.rightBarButtonItems = self.headerComponent?.rightBarButtons
        self.headerComponent?.configure(delegate: self)
        
        // List
        if let listComponent = listComponent {
            self.view.addSubview(listComponent)
            listComponent.configure(delegate: self, dataSource: self)
        }
        
        self.scrollToInitialPositionHandler = { [weak self] in
            if Thread.isMainThread {
                self?.listComponent?.tableView.layoutIfNeeded()
                self?.listComponent?.scrollToInitialPosition()
            } else {
                DispatchQueue.main.async {
                    self?.listComponent?.tableView.layoutIfNeeded()
                    self?.listComponent?.scrollToInitialPosition()
                }
            }
        }
    }
    
    open override func setupLayouts() {
        super.setupLayouts()

        self.listComponent?
            .sbu_constraint(
                equalTo: self.view,
                left: 0,
                right: 0,
                top: 0
            )
            .sbu_constraint_equalTo(
                bottomAnchor: self.view.safeAreaLayoutGuide.bottomAnchor,
                bottom: 0
            )
    }
    
    open override func setupStyles() {
        super.setupStyles()

        self.setupNavigationBar(
            backgroundColor: self.theme.header.backgroundColor,
            shadowColor: self.theme.header.lineColor
        )
        
        self.view.backgroundColor = self.theme.list.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        super.updateStyles()
        
        self.headerComponent?.updateStyles()
        self.listComponent?.updateStyles()
        
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - Error handling
    func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a notification is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - TableView
    
    // MARK: - New notification info
    func updateNewNotificationInfo(hidden: Bool) {
        guard let newNotificationInfoView = self.listComponent?.newNotificationInfoView else { return }
        guard hidden != newNotificationInfoView.isHidden else { return }
        guard let viewModel = self.viewModel else { return }
        
        newNotificationInfoView.isHidden = hidden && !viewModel.hasNext
    }

    // MARK: - New notification count
    @discardableResult
    func increaseNewNotificationCount() -> Bool {
        guard let tableView = self.listComponent?.tableView,
              tableView.contentOffset != .zero,
              self.viewModel?.isLoadingNext == false
        else {
            self.lastSeenIndexPath = nil
            return false
        }
        
        let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first
        ?? IndexPath(row: 0, section: 0)
        self.lastSeenIndexPath = IndexPath(row: firstVisibleIndexPath.row + 1, section: 0)
        
        guard self.listComponent?.isScrollNearByBottom == false else { return false }
        
        self.updateNewNotificationInfo(hidden: false)
        self.newNotificationsCount += 1
        
        if let newNotificationInfoView = self.listComponent?.newNotificationInfoView as? SBUNewNotificationInfo {
            newNotificationInfoView.updateCount(count: self.newNotificationsCount) { [weak self] in
                guard let self = self else { return }
                guard let listComponent = self.listComponent else { return }
                self.chatNotificationChannelModuleDidTapScrollToButton(listComponent, animated: true)
            }
        }

        return true
    }
    
    // MARK: - SBUChatNotificationChannelViewModelDelegate
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didChangeChannel channel: GroupChannel?,
        withContext context: MessageContext
    ) {
        guard channel != nil else {
            // channel deleted
            if self.navigationController?.viewControllers.last == self {
                // If leave is called in the ChannelSettingsViewController, this logic needs to be prevented.
                self.onClickBack()
            }
            return
        }
        
        // channel changed
        switch context.source {
        case .eventReadStatusUpdated, .eventDeliveryStatusUpdated:
            self.listComponent?.reloadTableView()
        case .channelChangelog:
            self.updateChannelTitle()
            self.listComponent?.reloadTableView()
        case .eventChannelChanged:
            self.updateChannelTitle()
        default: break
        }
        
        self.didUpdateUnreadMessageCount(channel?.unreadMessageCount ?? 0)
    }
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didReceiveNewNotification notification: BaseMessage,
        forChannel channel: GroupChannel
    ) {
        self.increaseNewNotificationCount()
        self.didUpdateUnreadMessageCount(channel.unreadMessageCount)
    }
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        shouldDismissForChannel channel: GroupChannel?
    ) {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didChangeNotificationList notifications: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    ) {
        guard let listComponent = self.listComponent else { return }
        let emptyViewType: EmptyViewType = (!initialLoad && viewModel.notifications.isEmpty) ? .noNotifications : .none
        listComponent.updateEmptyView(type: emptyViewType)
        
        guard needsToReload else { return }
        
        listComponent.reloadTableView()
        
        guard let lastSeenIndexPath = self.lastSeenIndexPath else { return }
        
        listComponent.scrollTableView(to: lastSeenIndexPath.row)
    }
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        deletedNotifications notifications: [BaseMessage]
    ) {}
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        shouldUpdateScrollInNotificationList notifications: [BaseMessage],
        forContext context: MessageContext?,
        keepsScroll: Bool
    ) {
        SBULog.info("Fetched : \(notifications.count), keepScroll : \(keepsScroll)")
        guard let listComponent = listComponent else { return }
        
        guard !notifications.isEmpty else {
            SBULog.info("Fetched empty notifications.")
            return
        }
        
        if context?.source == .eventMessageSent {
            if !keepsScroll {
                self.chatNotificationChannelModuleDidTapScrollToButton(
                    listComponent,
                    animated: false
                )
            }
        } else if context?.source != .eventMessageReceived {
            // follow keepScroll flag if context is not `eventMessageReceived`.
            if keepsScroll, !listComponent.isScrollNearByBottom {
                self.lastSeenIndexPath = listComponent.keepCurrentScroll(for: notifications)
            }
        } else {
            if !chatNotificationChannelViewModel(
                viewModel,
                isScrollNearBottomInChannel: viewModel.channel
            ) {
                self.lastSeenIndexPath = listComponent.keepCurrentScroll(for: notifications)
            }
        }
    }
    
    // MARK: - SBUChatNotificationChannelViewModelDataSource
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: GroupChannel?
    ) -> [IndexPath]? {
        self.listComponent?.tableView.indexPathsForVisibleRows ?? []
    }
    
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        isScrollNearBottomInChannel channel: GroupChannel?
    ) -> Bool {
        self.listComponent?.isScrollNearByBottom ?? true
    }
    
    // MARK: - SBUChatNotificationChannelModuleHeaderDelegate
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    ) {
        self.navigationItem.titleView = titleView
    }
    
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapTitleView titleView: UIView?
    ) {
        // Nothing
    }
    
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    ) {
        self.onClickBack()
    }
    
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    ) {
        // Nothing
    }
    
    // MARK: - SBUChatNotificationChannelModuleListDelegate
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandleWebAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleWebAction(action, notification: notification, forRowAt: indexPath)
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandleCustomAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleCustomAction(action, notification: notification, forRowAt: indexPath)
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let viewModel = self.viewModel else { return }
        guard viewModel.notifications.count > 0 else { return }
        
        let notificationList = viewModel.notifications
        let notificationListParams = viewModel.notificationListParams
        
        if viewModel.hasPrevious,
           indexPath.row >= (notificationList.count - notificationListParams.previousResultSize / 2) {
            viewModel.loadPrevNotifications()
        } else if viewModel.hasNext, indexPath.row < 5 {
            viewModel.loadNextNotifications()
        }
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        didScroll scrollView: UIScrollView
    ) {
        self.lastSeenIndexPath = nil
        
        if listComponent.isScrollNearByBottom {
            self.newNotificationsCount = 0
            self.updateNewNotificationInfo(hidden: true)
        }
    }
    
    func chatNotificationChannelModuleDidTapScrollToButton(
        _ listComponent: SBUChatNotificationChannelModule.List,
        animated: Bool
    ) {
        guard self.viewModel?.notifications.isEmpty == false else { return }
        self.newNotificationsCount = 0
        
        self.lastSeenIndexPath = nil
        
        DispatchQueue.main.async { [weak self, listComponent, animated] in
            guard let self = self else { return }
            
            if self.viewModel?.hasNext ?? false {
                listComponent.tableView.setContentOffset(
                    listComponent.tableView.contentOffset,
                    animated: false
                )
                self.viewModel?.reloadNotificationList()
                self.listComponent?.scrollTableView(to: 0)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.listComponent?.scrollTableView(to: indexPath.row, animated: animated)
                self.updateNewNotificationInfo(hidden: true)
            }
        }
    }
    
    func chatNotificationChannelModuleDidSelectRetry(
        _ listComponent: SBUChatNotificationChannelModule.List
    ) {
        if let channelURL = self.viewModel?.channelURL {
            self.viewModel?.loadChannel(channelURL: channelURL)
        }
    }
    
    // MARK: - SBUChatNotificationChannelModuleListDataSource
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> GroupChannel? {
        self.viewModel?.channel
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        notificationInTableView tableView: UITableView
    ) -> [BaseMessage] {
        self.viewModel?.notifications ?? []
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        lastSeenForTableView tableView: UITableView
    ) -> Int64 {
        self.viewModel?.lastSeenAt ?? 0
    }
    
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        hasNextInTableView tableView: UITableView
    ) -> Bool {
        self.viewModel?.hasNext ?? false
    }
 
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        startingPointIn tableView: UITableView
    ) -> Int64? {
        self.viewModel?.startingPoint
    }
    
    // MARK: - SBUCommonViewModelDelegate
    open func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    open func didReceiveError(_ error: SendbirdChatSDK.SBError?, isBlocker: Bool) {
        if self.viewModel?.notifications.isEmpty == true, isBlocker {
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
        
        self.errorHandler(error?.localizedDescription)
    }
    
}
