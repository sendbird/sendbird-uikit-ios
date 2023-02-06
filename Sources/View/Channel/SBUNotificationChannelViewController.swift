//
//  SBUNotificationChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUNotificationChannelViewController:
    SBUBaseViewController,
    SBUNotificationChannelViewModelDelegate, SBUNotificationChannelViewModelDataSource,
    SBUNotificationChannelModuleListDelegate, SBUNotificationChannelModuleListDataSource,
    SBUNotificationChannelModuleHeaderDelegate
{
    
    
    // MARK: - Module components (Public)
    public var headerComponent: SBUNotificationChannelModule.Header?
    public var listComponent: SBUNotificationChannelModule.List?
    
    @SBUThemeWrapper(theme: SBUTheme.channelTheme)
    public var theme: SBUChannelTheme
    
    /// The boolean value that allows to update the read status of ``channel``. If it's `false`, ``channel`` doesn't update the read status of a new message.
    /// - IMPORTANT: As a default, it updates  to `true` when ``viewWillAppear(_:)`` is called and  to `false` when ``viewWillDisappear(_:)`` is called.
    public var allowsReadStatusUpdate: Bool {
        get { self.viewModel?.allowsReadStatusUpdate ?? false }
        set { self.viewModel?.allowsReadStatusUpdate = newValue }
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        self.theme.statusBarStyle
    }
    
    // MARK: - View model (Public)
    public var viewModel: SBUNotificationChannelViewModel?
    
    public var channelName: String? = nil
    
    public var channel: GroupChannel? {
        self.viewModel?.channel as? GroupChannel
    }
    
    
    // MARK: - Lifecycle
    @available(*, unavailable)
    required public init?(coder: NSCoder) {
        fatalError("Cannot use `init(coder:)`")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    /// Initializes ``SBUNotificationChannelViewController`` with channel using channel URL as ``SBUStringSet/Notification_Channel_URL
    /// - Since: [NEXT_VERSION]
    /// ```swift
    /// let notificationChannelVC = SBUNotificationChannelViewController()
    /// navigationController?.pushViewController(notificationChannelVC, animated: true)
    /// ```
    required public convenience init() {
        self.init(messageListParams: nil)
    }
    
    required public init(channel: GroupChannel? = nil, messageListParams: MessageListParams? = nil) {
        super.init(nibName: nil, bundle: nil)
        
        SBULog.info(#function)
        
        self.createViewModel(channel: channel, messageListParams: messageListParams)
        
        self.headerComponent = SBUModuleSet.notificationChannelModule.headerComponent
        self.listComponent = SBUModuleSet.notificationChannelModule.listComponent
    }
 
    open override func loadView() {
        super.loadView()
        
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
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
    
    // MARK: - ViewModel
    /// Creates the view model, loading initial messages.
    /// - Note: If you want to customize the view model, override this function
    /// - Parameter channel: The notification channel that is type of `GroupChannel`
    /// - Since: [NEXT_VERSION]
    open func createViewModel(channel: GroupChannel? = nil, messageListParams: MessageListParams? = nil) {
        self.viewModel = SBUNotificationChannelViewModel(
            channel: channel,
            messageListParams: messageListParams,
            delegate: self,
            dataSource: self
        )
    }
    
    /// Update the timestamp when the channel was seen last at.
    /// - Parameter timestamp: If it's `nil`, it updates to `channel.myLastRead`.
    /// - Since: [NEXT_VERSION]
    public func updateLastSeenAt(timestamp: Int64? = nil) {
        self.viewModel?.updateLastSeenAt(timestamp)
    }
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        super.setupViews()
        
        // Header
        self.navigationItem.titleView = self.headerComponent?.titleView
        self.navigationItem.leftBarButtonItems = self.headerComponent?.leftBarButtons
        self.navigationItem.rightBarButtonItems = self.headerComponent?.rightBarButtons
        self.headerComponent?.configure(delegate: self, theme: self.theme)
        
        // List
        if let listComponent = listComponent {
            self.view.addSubview(listComponent)
            listComponent.configure(delegate: self, dataSource: self, theme: self.theme)
        }
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.listComponent?
            .sbu_constraint(
                equalTo: self.view,
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            )
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.setupStyles(theme: self.theme)
    }
    
    func setupStyles(theme: SBUChannelTheme) {
        self.setupNavigationBar(
            backgroundColor: self.theme.navigationBarTintColor,
            shadowColor: self.theme.navigationBarShadowColor
        )
        
        self.view.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        self.setupStyles()
        super.updateStyles()
        
        self.headerComponent?.updateStyles(theme: self.theme)
        self.listComponent?.updateStyles(theme: self.theme)
        
        self.listComponent?.reloadTableView()
    }
    
    // MARK: - Error handling
    func errorHandler(_ error: SBError) {
        self.errorHandler(error.localizedDescription, error.code)
    }
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open override func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - Header
    /// Updates ``SBUNotificationChannelModule/Header/titleView``with `title` when it's ``SBUNavigationTitleView``.
    /// - Since: [NEXT_VERSION]
    public func updateNavigationlTitle(_ title: String? = nil) {
        if let titleView = self.headerComponent?.titleView as? SBUNavigationTitleView {
            titleView.text = title ?? SBUStringSet.Notification_Channel_Name_Default
        }
    }
    
    // MARK: - SBUNotificationChannelViewModelDelegate
    
    open func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
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
        case .channelChangelog, .eventChannelChanged:
            self.updateNavigationlTitle()
            self.listComponent?.reloadTableView()
        default: break
        }
    }
    
    open func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        didReceiveNewMessage message: BaseMessage,
        forChannel channel: GroupChannel
    ) {
        // Received new message
    }
    
    open func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        shouldDismissForChannel channel: GroupChannel?
    ) {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popToRootViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    /// Called when the messages has been changed. If they're the first loaded messages, `initialLoad` is `true`.
    /// ```swift
    /// // If you use view controller with tab bar, you can use tabBarItem like this:
    /// self.navigationController?.tabBarItem.badgeValue = "\(channel?.unreadMessageCount ?? 0)"
    /// ```
    open func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        didChangeMessageList messages: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    ) {
        guard let listComponent = self.listComponent else { return }
        let emptyViewType: EmptyViewType = viewModel.messages.isEmpty ? .noNotifications : .none
        listComponent.updateEmptyView(type: emptyViewType)
        
        guard needsToReload else { return }
        
        listComponent.reloadTableView()
    }
    
    
    public func shouldUpdateLoadingState(_ isLoading: Bool) {
        self.showLoading(isLoading)
    }
    
    public func didReceiveError(_ error: SendbirdChatSDK.SBError?, isBlocker: Bool) {
        self.showLoading(false)
        if self.viewModel?.messages.isEmpty == true, isBlocker {
            self.listComponent?.updateEmptyView(type: .error)
            self.listComponent?.reloadTableView()
        }
        
        self.errorHandler(error?.localizedDescription)
    }
    
    
    // MARK: - SBUNotificationChannelModuleDataSource
    public func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: GroupChannel
    ) -> [IndexPath] {
        self.listComponent?.tableView.indexPathsForVisibleRows ?? []
    }
    
    // MARK: - SBUNotificationchannelModuleHeaderDelegate
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didUpdateTitleView titleView: UIView?) {
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
    
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]) {
        self.navigationItem.leftBarButtonItems = leftItems
    }
    
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]) {
        self.navigationItem.rightBarButtonItems = rightItems
    }
    
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didTapTitleView titleView: UIView?) {
        // Nothing
    }
    
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open func notificationChannelModule(_ headerComponent: SBUNotificationChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        // Nothing
    }
    
    
    // MARK: - SBUNotificationChannelModuleListDelegate
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandleWebAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        if let url = URL(string: action.data) {
            url.open()
            return
        } else if let urlString = action.alterData, let url = URL(string: urlString) {
            url.open()
            return
        }
    }
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandleCustomAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        if let urlScehem = URL(string: action.data) {
            urlScehem.open()
            return
        } else if let urlString = action.alterData, let url = URL(string: urlString) {
            url.open()
            return
        }
    }
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandlePreDefinedAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        if action.data.lowercased().contains("delete") {
            self.listComponent?.showDeleteMessageAlert(on: message)
            return
        }
    }
    
    open func notificationChannelModule(_ listComponent: SBUNotificationChannelModule.List, didTapDeleteMessage message: BaseMessage) {
        self.viewModel?.deleteMessage(message)
    }
    
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let viewModel = self.viewModel else { return }
        guard viewModel.messages.count > 0 else { return }
        
        let messageList = viewModel.messages
        let messageListParams = viewModel.messageListParams
        
        if viewModel.hasPrevious,
           indexPath.row >= (messageList.count - messageListParams.previousResultSize / 2) {
            viewModel.loadPrevMessages()
        } else if viewModel.hasNext, indexPath.row < 5 {
            viewModel.loadNextMessages()
        }
    }
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        didScroll scrollView: UIScrollView
    ) {
        // on scrolled
    }
    
    open func notificationChannelModuleDidSelectRetry(
        _ listComponent: SBUNotificationChannelModule.List
    ) {
        if let channelURL = self.viewModel?.channelURL {
            self.viewModel?.loadChannel(channelURL: channelURL)
        }
    }
    
    // MARK: - SBUNotificationChannelModuleListDataSource
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> GroupChannel? {
        self.viewModel?.channel
    }
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        notificationMessageInTableView tableView: UITableView
    ) -> [BaseMessage] {
        self.viewModel?.messages ?? []
    }
    
    open func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        lastSeenForTableView tableView: UITableView
    ) -> Int64 {
        self.viewModel?.lastSeenAt ?? .max
    }
}
