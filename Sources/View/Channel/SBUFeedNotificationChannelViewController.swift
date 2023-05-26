//
//  SBUFeedNotificationChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// - Since: 3.5.0
open class SBUFeedNotificationChannelViewController: SBUBaseViewController,
    SBUFeedNotificationChannelViewModelDelegate, SBUFeedNotificationChannelViewModelDataSource,
    SBUFeedNotificationChannelModuleListDelegate, SBUFeedNotificationChannelModuleListDataSource,
    SBUFeedNotificationChannelModuleHeaderDelegate, SBUFeedNotificationChannelModuleHeaderDataSource,
    SBUCommonViewModelDelegate {
    
    // MARK: - Module components (Public)
    public var headerComponent: SBUFeedNotificationChannelModule.Header?
    public var listComponent: SBUFeedNotificationChannelModule.List?
    
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
    var viewModel: SBUFeedNotificationChannelViewModel?
    
    public var channelName: String? {
        (self.viewModel?.channel as? FeedChannel)?.name
    }
    
    public var channel: FeedChannel? {
        self.viewModel?.channel as? FeedChannel
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
    
    /// Initializes ``SBUFeedNotificationChannelViewController`` with channel
    required public init(
        channel: FeedChannel,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        displaysLocalCachedListFirst: Bool = false
    ) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        self.initialize(
            channel: channel,
            notificationListParams: notificationListParams,
            displaysLocalCachedListFirst: displaysLocalCachedListFirst
        )
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
        
        self.initialize(
            channelURL: channelURL,
            notificationListParams: notificationListParams,
            displaysLocalCachedListFirst: displaysLocalCachedListFirst
        )
    }
    
    func initialize(
        channel: FeedChannel? = nil,
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = nil,
        displaysLocalCachedListFirst: Bool = false
    ) {
        SBULog.info(#function)
        
        self.createViewModelHandler = { [weak self] in
            guard let self = self else { return }
            self.createViewModel(
                channel: channel,
                channelURL: channelURL,
                notificationListParams: notificationListParams,
                startingPoint: startingPoint,
                displaysLocalCachedListFirst: displaysLocalCachedListFirst
            )
        }
        
        self.headerComponent = SBUModuleSet.feedNotificationChannelModule.headerComponent
        self.listComponent = SBUModuleSet.feedNotificationChannelModule.listComponent
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
    /// Updates channelTitle
    /// - Since: 3.5.0
    public func updateChannelTitle() {
        if let titleView = self.headerComponent?.titleView as? SBUNotificationNavigationTitleView {
            titleView.configure(title: self.channelName ?? "")
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
    /// Creates the view model, loading initial notifications.
    /// - Note: If you want to customize the view model, override this function
    /// - Parameter channel: The notification channel that is type of `FeedChannel`
    func createViewModel( // added docs
        channel: FeedChannel? = nil,
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        displaysLocalCachedListFirst: Bool = false
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.viewModel = SBUFeedNotificationChannelViewModel(
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
        self.headerComponent?.configure(delegate: self, dataSource: self)
        
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
                self.feedNotificationChannelModuleDidTapScrollToButton(listComponent, animated: true)
            }
        }
        
        return true
    }
    
    // MARK: - SBUFeedNotificationChannelViewModelDelegate
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didChangeChannel channel: FeedChannel?,
        withContext context: FeedChannelContext
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
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didReceiveNewNotification notification: BaseMessage,
        forChannel channel: FeedChannel
    ) {
        self.increaseNewNotificationCount()
        self.didUpdateUnreadMessageCount(channel.unreadMessageCount)
    }
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        shouldDismissForChannel channel: FeedChannel?
    ) {
        // TODO: notification - When this function is called while using the tabbar, the present viewcontroller will be dismissed.
        if let navigationController = self.navigationController,
           navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
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
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        deletedNotifications notifications: [BaseMessage]
    ) {}
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        shouldUpdateScrollInNotificationList notifications: [BaseMessage],
        forContext context: NotificationContext?,
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
                self.feedNotificationChannelModuleDidTapScrollToButton(
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
            if !feedNotificationChannelViewModel(
                viewModel,
                isScrollNearBottomInChannel: viewModel.channel
            ) {
                self.lastSeenIndexPath = listComponent.keepCurrentScroll(for: notifications)
            }
        }
    }
    
    // MARK: - SBUFeedNotificationChannelViewModelDataSource
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: FeedChannel?
    ) -> [IndexPath] {
        self.listComponent?.tableView.indexPathsForVisibleRows ?? []
    }
    
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        isScrollNearBottomInChannel channel: FeedChannel?
    ) -> Bool {
        self.listComponent?.isScrollNearByBottom ?? true
    }
    
    // MARK: - SBUNotificationchannelModuleHeaderDelegate
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    ) {
        var titleStackView = UIStackView()
        
        if let titleView = titleView {
            titleStackView = UIStackView(arrangedSubviews: [
                titleView,
                headerComponent.titleSpacer
            ])
            titleStackView.axis = .horizontal
        }
        
        self.navigationItem.titleView = titleStackView
    }
    
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    ) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapTitleView titleView: UIView?
    ) {
        // Nothing
    }
    
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    ) {
        self.onClickBack()
    }
    
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    ) {
        // Nothing
    }
    
    // MARK: - SBUFeedNotificationChannelModuleHeaderDataSource
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        channelNameForTitleView titleView: UIView?
    ) -> String? {
        return self.channel?.name
    }
    
    // MARK: - SBUFeedNotificationChannelModuleListDelegate
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        shouldHandleWebAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleWebAction(action, notification: notification, forRowAt: indexPath)
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        shouldHandleCustomAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        self.handleCustomAction(action, notification: notification, forRowAt: indexPath)
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
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
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        didScroll scrollView: UIScrollView
    ) {
        self.lastSeenIndexPath = nil
        
        if listComponent.isScrollNearByBottom {
            self.newNotificationsCount = 0
            self.updateNewNotificationInfo(hidden: true)
        }
    }
    
    func feedNotificationChannelModuleDidTapScrollToButton(
        _ listComponent: SBUFeedNotificationChannelModule.List,
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
    
    func feedNotificationChannelModuleDidSelectRetry(
        _ listComponent: SBUFeedNotificationChannelModule.List
    ) {
        if let channelURL = self.viewModel?.channelURL {
            self.viewModel?.loadChannel(channelURL: channelURL)
        }
    }
    
    // MARK: - SBUFeedNotificationChannelModuleListDataSource
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> FeedChannel? {
        self.viewModel?.channel
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        notificationInTableView tableView: UITableView
    ) -> [BaseMessage] {
        self.viewModel?.notifications ?? []
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        lastSeenForTableView tableView: UITableView
    ) -> Int64 {
        self.viewModel?.lastSeenAt ?? 0
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
        hasNextInTableView tableView: UITableView
    ) -> Bool {
        self.viewModel?.hasNext ?? false
    }
    
    func feedNotificationChannelModule(
        _ listComponent: SBUFeedNotificationChannelModule.List,
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
