//
//  SBUBaseChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component.
public protocol SBUBaseChannelModuleListDelegate: SBUCommonDelegate {
    /// Called when the `listComponent` is about to draw a cell for a particular row.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - cell: The table view cell that the list component going to use when drawing the row.
    ///    - indexPath: An index path locating the row in table view of `listComponent`
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the message cell was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - message: The message that was tapped.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapMessage message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the message cell was long tapped in the `listComponent`.
    /// - Note: As a default, it shows menu items for `message`. Please refer to ``SBUBaseChannelModule/List/showMessageMenu(on:forRowAt:)``
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - message: The message that was long tapped.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didLongTapMessage message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the user profile was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - user: The `SBUUser` of user profile that was tapped.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapUserProfile user: SBUUser
    )
    
    /// Called when the message cell was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - fileMessage: The message that was tapped.
    ///    - cell: The table view cell that the selected cell.
    ///    - indexPath: An index path locating the row in table view of `listComponent
    ///
    /// - Since: 3.4.0
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapVoiceMessage fileMessage: FileMessage,
        cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the `scrollView` was scrolled.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - scrollView: The `scrollView`.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didScroll scrollView: UIScrollView
    )
    
    /// Called when the `scrollBottomView`was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - animated: if it's `true`, the list component will be scrolled while animating
    func baseChannelModuleDidTapScrollToButton(
        _ listComponent: SBUBaseChannelModule.List,
        animated: Bool
    )
    
    /// Called when the retry button was selected from the `listComponent`.
    /// - Parameter listComponent: `SBUBaseChannelModule.List` object.
    func baseChannelModuleDidSelectRetry(_ listComponent: SBUBaseChannelModule.List)
    
    // MARK: Menu
    
    /// Ccalled when a user selects the *retry* menu item of a `failedMessage` in the `listComponent`
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - failedMessage: The failed message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapRetryFailedMessage failedMessage: BaseMessage)
    
    /// Called when a user selects the *delete* menu item of a `failedMessage` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - failedMessage: The failed message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapDeleteFailedMessage failedMessage: BaseMessage)
    
    /// Called when a user selects the *copy* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapCopyMessage message: BaseMessage)
 
    /// Called when a user selects the *delete* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapDeleteMessage message: BaseMessage)
    
    /// Called when a user selects the *edit* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapEditMessage message: BaseMessage)
    
    /// Called when a user selects the *save* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapSaveMessage message: BaseMessage)
    
    /// Called when a user selects the *reply* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapReplyMessage message: BaseMessage)
    
    /// Called when a user *reacts* to a `message` in the `listComponent` with an emoji.
    /// - Parameters:
    ///    - listComponent: An object of ``SBUBaseChannelModule/List``.
    ///    - message: The message that the user reacted with an emoji to.
    ///    - key: The key value of the emoji.
    ///    - selected: Determines whether the emoji has already been used for the message.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didReactToMessage message: BaseMessage,
        withEmoji key: String,
        selected: Bool
    )
    
    /// Called when the user selects the *more emoji* button on a message in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: An object of ``SBUBaseChannelModule/List``.
    ///    - message: The message that the user wants to react with more emojis.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didTapMoreEmojisOnMessage message: BaseMessage
    )
    
    /// Called when the ``SBUMenuSheetViewController`` instance is dismissed.
    /// - Parameters:
    ///    - listComponent: An object of ``SBUBaseChannelModule/List``.
    ///    - cell: The `UITableViewCell` object that includes the message displayed through ``SBUMenuSheetViewController``.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didDismissMenuForCell cell: UITableViewCell
    )
}

extension SBUBaseChannelModuleListDelegate {
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didLongTapMessage message: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        listComponent.showMessageMenu(on: message, forRowAt: indexPath)
    }
}

/// Methods to get data source for the list component.
public protocol SBUBaseChannelModuleListDataSource: AnyObject {
    /// Ask the data source to return the `BaseChannel` object.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `BaseChannel` object.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, channelForTableView tableView: UITableView) -> BaseChannel?
    
    /// Ask the data source to return the message list sent successfully.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `BaseMessage` object that are sent successfully.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, sentMessagesInTableView tableView: UITableView) -> [BaseMessage]
    
    /// Ask the data source to return the message list includes the sent, the failed and the pending.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The array of `BaseMessage` object including the sent, the failed and the pending.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, fullMessagesInTableView tableView: UITableView) -> [BaseMessage]
    
    /// Ask the data source to return whether the `tableView` has next data.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: Whether the `tableView` has next data.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, hasNextInTableView tableView: UITableView) -> Bool
    
    /// Ask the data source to return the last seen index path
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The last seen `IndexPath`.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, lastSeenIndexPathIn tableView: UITableView) -> IndexPath?
    
    /// Ask the data source to return the starting point
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The starting point.
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, startingPointIn tableView: UITableView) -> Int64?
    
    /// A data source function that returns the parent view controller, which displays the `menuItems` through ``SBUMenuSheetViewController``.
    /// - Parameters:
    ///    - listComponent: An object of ``SBUBaseChannelModule/List``.
    ///    - menuItems: The objects of ``SBUMenuItem`` that are used in ``SBUMenuSheetViewController``.
    func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        parentViewControllerDisplayMenuItems menuItems: [SBUMenuItem]
    ) -> UIViewController?
    
    /// Ask the data source to return the `SBUPendingMessageManager` object.
    /// - Parameters:
    ///    - listComponent: `SBUBaseChannelModule.List` object.
    ///    - cell: `UITableViewCell` object from list component.
    /// - Returns: (`SBUPendingMessageManager` object, `isThreadMessageMode` object of view model)
    /// - Since: 3.3.0
    func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, pendingMessageManagerForCell cell: UITableViewCell) -> (SBUPendingMessageManager?, Bool?)
}

extension SBUBaseChannelModule {
    /// A module component that represent the list of `SBUBaseChannelModule`.
    @objc(SBUBaseChannelModuleList)
    @objcMembers open class List: UIView, UITableViewDelegate, UITableViewDataSource {
        
        // MARK: - UI properties (Public)
        
        /// The table view to show messages in the channel
        public var tableView = UITableView()
        
        /// A view that shows when there is no message in the channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// A view that shows the state of the channel such as frozen state.
        public var channelStateBanner: UIView?
        
        /// A view that indicates a new received message.
        /// If you use a view that inherits `SBUNewMessageInfo`, you can change the button and their action.
        /// - NOTE: You can use the customized view and a view that inherits `SBUNewMessageInfo`.
        public var newMessageInfoView: UIView?
        
        /// A view that scrolls table view to the bottom.
        public var scrollBottomView: UIView?
        
        /// A view that shows profile of the user.
        /// If you do not want to use the user profile feature, please set this value to nil.
        /// - NOTE: To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
        public var userProfileView: UIView?
        
        /// The object that acts as the base delegate of the list component. The base delegate must adopt the `SBUBaseChannelModuleListDelegate`.
        public weak var baseDelegate: SBUBaseChannelModuleListDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the `SBUBaseChannelModuleListDataSource`.
        public weak var baseDataSource: SBUBaseChannelModuleListDataSource?
        
        /// The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        private lazy var defaultChannelStateBanner: UIView? = {
            let label = UILabel()
            label.textAlignment = .center
            label.text = SBUStringSet.Channel_State_Banner_Frozen
            label.layer.masksToBounds = true
            label.layer.cornerRadius = 5
            label.isHidden = true
            return label
        }()
        
        private lazy var defaultScrollBottomView: UIView? = {
            let view: UIView = UIView(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
            let theme = SBUTheme.componentTheme
            
            view.backgroundColor = .clear
            view.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
            view.layer.shadowOffset = CGSize(width: 0, height: 5)
            view.layer.shadowOpacity = 0.5
            view.layer.shadowRadius = 5
            view.layer.masksToBounds = false
            
            let scrollBottomButton = UIButton(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
            scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
            scrollBottomButton.clipsToBounds = true
            
            scrollBottomButton.setImage(
                SBUIconSetType.iconChevronDown.image(
                    with: theme.scrollBottomButtonIconColor,
                    to: SBUIconSetType.Metric.iconChevronDown
                ),
                for: .normal
            )
            scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
            scrollBottomButton.setBackgroundImage(UIImage.from(color: theme.scrollBottomButtonHighlighted), for: .highlighted)
            
            scrollBottomButton.addTarget(self, action: #selector(self.onTapScrollToBottom), for: .touchUpInside)
            view.addSubview(scrollBottomButton)
            
            scrollBottomButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollBottomButton.topAnchor.constraint(equalTo: view.topAnchor),
                scrollBottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                scrollBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
            
            return view
        }()
        
        // MARK: - Logic properties (Public)
        
        /// The current channel object from `baseChannelModule(_:channelForTableView:)` data source method.
        public var baseChannel: BaseChannel? {
            self.baseDataSource?.baseChannelModule(self, channelForTableView: self.tableView)
        }
        
        /// The array of sent messages in the channel. The value is returned by `baseChannelModule(_:sentMessagesInTableView:)` data source method.
        public var sentMessages: [BaseMessage] {
            self.baseDataSource?.baseChannelModule(self, sentMessagesInTableView: self.tableView) ?? []
        }
        
        /// The array of all messages includes the sent, the failed and the pending. The value is returned by `baseChannelModule(_:fullMessagesInTableView:)` data source method.
        public var fullMessageList: [BaseMessage] {
            self.baseDataSource?.baseChannelModule(self, fullMessagesInTableView: self.tableView) ?? []
        }
        
        // MARK: - Logic properties (Private)
        
        /// The object that is used as the cell animation debouncer.
        lazy var cellAnimationDebouncer: SBUDebouncer = SBUDebouncer()
        
        var isTransformedList: Bool = true
        var isTableViewReloading = false
        
        // MARK: - LifeCycle
        required public init?(coder: NSCoder) {
            super.init(coder: coder)
        }
        
        public override init(frame: CGRect) {
            super.init(frame: frame)
        }
        
        deinit {
            SBULog.info(#function)
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            // empty view
            if self.emptyView == nil {
                self.emptyView = self.defaultEmptyView
            }
            
            // table view
            self.tableView.delegate = self
            self.tableView.dataSource = self
            
            self.tableView.separatorStyle = .none
            self.tableView.allowsSelection = false
            self.tableView.keyboardDismissMode = .interactive
            self.tableView.bounces = false
            self.tableView.alwaysBounceVertical = false
            
            self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: -1)
            self.tableView.backgroundView = self.emptyView
            self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.tableView.sectionHeaderHeight = 0
            
            self.addSubview(self.tableView)
            
            // channel state & common
            if self.channelStateBanner == nil {
                self.channelStateBanner = self.defaultChannelStateBanner
            }
            
            if let channelStateBanner = self.channelStateBanner {
                self.addSubview(channelStateBanner)
            }
            
            if self.newMessageInfoView == nil {
                self.newMessageInfoView = SBUNewMessageInfo()
            }
            
            if self.scrollBottomView == nil {
                self.scrollBottomView = self.defaultScrollBottomView
            }
            
            if self.userProfileView == nil {
                self.userProfileView = SBUUserProfileView(delegate: self)
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
        
        /// Sets styles of the views in the list component with the `theme`. If set theme parameter as `nil`, it uses the stored value.
        /// - Parameter theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            if let channelStateBanner = channelStateBanner as? UILabel {
                channelStateBanner.textColor = theme?.channelStateBannerTextColor
                channelStateBanner.font = theme?.channelStateBannerFont
                channelStateBanner.backgroundColor = theme?.channelStateBannerBackgroundColor
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class.
        ///   - componentTheme: The object that is used as the theme of some UI component in the list component such as `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`
        open func updateStyles(theme: SBUChannelTheme? = nil, componentTheme: SBUComponentTheme = SBUTheme.componentTheme) {
            self.setupStyles(theme: theme)
            
            if let userProfileView = self.userProfileView as? SBUUserProfileView {
                userProfileView.setupStyles()
            }
        }
        
        /// Sets the styles of `scrollBottomView`.
        /// - Parameters:
        ///   - scrollBottomView: The `scrollBottomView` object.
        ///   - theme: The object that is used as the theme of the `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`.
        public func setupScrollBottomViewStyle(
            scrollBottomView: UIView,
            theme: SBUComponentTheme = SBUTheme.componentTheme
        ) {
            self.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
            
            guard let scrollBottomButton = scrollBottomView.subviews.first as? UIButton else { return }
            
            scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
            scrollBottomButton.clipsToBounds = true
            
            scrollBottomButton.setImage(
                SBUIconSetType.iconChevronDown.image(
                    with: theme.scrollBottomButtonIconColor,
                    to: SBUIconSetType.Metric.iconChevronDown
                ),
                for: .normal)
            scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
            scrollBottomButton.setBackgroundImage(
                UIImage.from(color: theme.scrollBottomButtonHighlighted),
                for: .highlighted
            )
        }
        
        /// Updates hidden state of the `scrollBottomView`.
        open func setScrollBottomView(hidden: Bool) {
            self.scrollBottomView?.isHidden = hidden
        }
        
        // MARK: - TableView
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            if Thread.isMainThread {
                self.isTableViewReloading = true
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.isTableViewReloading = false

            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.isTableViewReloading = true
                    self?.tableView.reloadData()
                    self?.tableView.layoutIfNeeded()
                    self?.isTableViewReloading = false
                }
            }
        }
        
        // MARK: - EmptyView
        
        /// Update the `emptyView` according its type.
        /// - Parameter type: The value of `EmptyViewType`.
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
        
        // MARK: - Menu
        /// Displays the menu of the message located on the given `indexPath` value.
        /// It internally decides whether to show a *context menu*, a menu for *a failed message*, or a *sheet menu*.
        /// - Parameters:
        ///    - message: The `BaseMessage` object that corresponds to the message of the menu to show.
        ///    - indexPath: The value of the `UITableViewCell` where the `message` is located.
        open func showMessageMenu(on message: BaseMessage, forRowAt indexPath: IndexPath) {
            switch message.sendingStatus {
            case .none, .canceled, .pending:
                break
            case .failed:
                // shows failed message menu
                showFailedMessageMenu(on: message)
            default:
                // succeed, unknown
                guard let cell = self.tableView.cellForRow(at: indexPath) else {
                    SBULog.error("Couldn't find cell for row at \(indexPath)")
                    return
                }
                cell.isSelected = true
                if SBUEmojiManager.isReactionEnabled(channel: self.baseChannel) {
                    // shows menu sheet view controller
                    self.showMessageMenuSheet(for: message, cell: cell)
                } else {
                    self.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
                }
            }
        }
        
        /// Displays the menu of a message that failed to send.
        /// - NOTE: The event delegate methods, ``SBUBaseChannelModuleListDelegate/baseChannelModule(_:didTapRetryFailedMessage:)`` and ``SBUBaseChannelModuleListDelegate/baseChannelModule(_:didTapDeleteFailedMessage:)`` , are called when the items in the menu are tapped.
        /// - Parameter message: The `BaseMessage` object that corresponds to the message of the menu to show.
        open func showFailedMessageMenu(on message: BaseMessage) {
            let retryItem = SBUActionSheetItem(
                title: SBUStringSet.Retry,
                color: self.theme?.menuItemTintColor
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapRetryFailedMessage: message)
                self.baseDelegate?.baseChannelModuleDidTapScrollToButton(self, animated: true)
            }
            let deleteItem = SBUActionSheetItem(
                title: SBUStringSet.Delete,
                color: self.theme?.deleteItemColor
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapDeleteFailedMessage: message)
            }
            let cancelItem = SBUActionSheetItem(
                title: SBUStringSet.Cancel,
                color: self.theme?.cancelItemColor,
                completionHandler: nil
            )
            
            SBUActionSheet.show(
                items: [retryItem, deleteItem],
                cancelItem: cancelItem
            )
        }
        
        /// Displays an alert for deleting a message.
        /// - NOTE: The event delegate method, ``SBUBaseChannelModuleListDelegate/baseChannelModule(_:didTapDeleteMessage:)``, is called when an item in the menu is tapped.
        /// - Parameters:
        ///    - message: The message that is to be deleted.
        ///    - oneTimeTheme: The theme applied to the alert. If there's no set theme, the default theme in Sendbird UIKit is used.
        open func showDeleteMessageAlert(on message: BaseMessage, oneTimeTheme: SBUComponentTheme? = nil) {
            let deleteButton = SBUAlertButtonItem(
                title: SBUStringSet.Delete,
                color: self.theme?.alertRemoveColor
            ) { [weak self, message] _ in
                guard let self = self else { return }
                SBULog.info("[Request] Delete message: \(message.description)")
                self.baseDelegate?.baseChannelModule(self, didTapDeleteMessage: message)
            }
            
            let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) { _ in }
            
            SBUAlertView.show(
                title: SBUStringSet.Alert_Delete,
                oneTimetheme: oneTimeTheme,
                confirmButtonItem: deleteButton,
                cancelButtonItem: cancelButton
            )
        }
        
        /// Calls the ``SBUMenuSheetViewController`` instance in ``UIViewController``, which is returned after ``SBUBaseChannelModuleListDataSource/baseChannelModule(_:parentViewControllerDisplayMenuItems:)`` is called.
        /// - NOTE: To learn about the event delegates in this instance, refer to the event delegate methods in ``SBUBaseChannelModuleListDelegate``.
        /// - Parameters:
        ///    - message: The `BaseMessage` object  that refers to the message of the menu to display.
        ///    - cell: The `UITableViewCell` object that shows the message.
        open func showMessageMenuSheet(for message: BaseMessage, cell: UITableViewCell) {
            let messageMenuItems = self.createMessageMenuItems(for: message)
            
            guard let parentViewController = self.baseDataSource?.baseChannelModule(
                self,
                parentViewControllerDisplayMenuItems: messageMenuItems
            ) else { return }
            
            let useReaction = SBUEmojiManager.isReactionEnabled(channel: self.baseChannel)
            let menuSheetVC = SBUMenuSheetViewController(message: message, items: messageMenuItems, useReaction: useReaction)
            menuSheetVC.modalPresentationStyle = .custom
            menuSheetVC.transitioningDelegate = parentViewController as? UIViewControllerTransitioningDelegate
            parentViewController.present(menuSheetVC, animated: true)
            menuSheetVC.dismissHandler = { [weak self, cell] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didDismissMenuForCell: cell)
            }
            menuSheetVC.emojiTapHandler = { [weak self, message] emojiKey, setSelect in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(
                    self,
                    didReactToMessage: message,
                    withEmoji: emojiKey,
                    selected: setSelect
                )
            }
            menuSheetVC.moreEmojiTapHandler = { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(
                    self,
                    didTapMoreEmojisOnMessage: message
                )
            }
        }
        
        /// Displays ``SBUMenuView`` in the form of a context menu.
        /// - NOTE: To learn about the event delegates in ``SBUMenuView``, refer to the even delegate method of each menu item in ``SBUBaseChannelModuleListDelegate``.
        /// - Parameters:
        ///    - message: The `BaseMessage` object  that refers to the message of the menu to display.
        ///    - cell: The `UITableViewCell` object that shows the message.
        ///    - indexPath: The `IndexPath` value of the `cell`.
        open func showMessageContextMenu(for message: BaseMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let messageMenuItems = self.createMessageMenuItems(for: message)
            guard !messageMenuItems.isEmpty else { return }
            
            let rowRect = self.tableView.rectForRow(at: indexPath)
            let rowRectInSuperview = self.tableView.convert(
                rowRect,
                to: UIApplication.shared.currentWindow
            )
            SBUMenuView.show(items: messageMenuItems, point: rowRectInSuperview.origin) {
                cell.isSelected = false
            }
        }
        
        /// Creates an array of ``SBUMenuItem`` objects for a `message`.
        /// - Parameter message: The `BaseMessage` object  that refers to the message of the menu to display.
        /// - Returns: The array of ``SBUMenuItem`` objects for a `message`
        open func createMessageMenuItems(for message: BaseMessage) -> [SBUMenuItem] {
            let isSentByMe = message.sender?.userId == SBUGlobals.currentUser?.userId
            var items: [SBUMenuItem] = []
            
            switch message {
            case is UserMessage:
                // UserMessage: copy, (edit), (delete)
                let copy = self.createCopyMenuItem(for: message)
                items.append(copy)
                if isSentByMe {
                    let edit = self.createEditMenuItem(for: message)
                    let delete = self.createDeleteMenuItem(for: message)
                    items.append(edit)
                    items.append(delete)
                }
            case let fileMessage as FileMessage:
                // FileMessage: save, (delete)
                let save = self.createSaveMenuItem(for: message)
                if SBUUtils.getFileType(by: fileMessage) != .voice {
                    items.append(save)
                }
                if isSentByMe {
                    let delete = self.createDeleteMenuItem(for: message)
                    items.append(delete)
                }
            default:
                // UnknownMessage: (delete)
                if !isSentByMe {
                    let delete = self.createDeleteMenuItem(for: message)
                    items.append(delete)
                }
            }
            return items
        }
        
        /// Creates a ``SBUMenuItem`` object that allows users to *copy* the `message`.
        /// - Parameter message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        /// - Returns: The ``SBUMenuItem`` object for a `message`
        open func createCopyMenuItem(for message: BaseMessage) -> SBUMenuItem {
            let menuItem = SBUMenuItem(
                title: SBUStringSet.Copy,
                color: theme?.menuTextColor,
                image: SBUIconSetType.iconCopy.image(
                    with: SBUTheme.componentTheme.alertButtonColor,
                    to: SBUIconSetType.Metric.iconActionSheetItem
                )
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapCopyMessage: message)
            }
            return menuItem
        }
        
        /// Creates a ``SBUMenuItem`` object that allows users to *delete* the `message`.
        /// - Parameter message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        /// - Returns: The ``SBUMenuItem`` object for a `message`
        open func createDeleteMenuItem(for message: BaseMessage) -> SBUMenuItem {
            let isEnabled = message.threadInfo.replyCount == 0
            let menuItem = SBUMenuItem(
                title: SBUStringSet.Delete,
                color: isEnabled ? theme?.menuTextColor : theme?.menuItemDisabledColor,
                image: SBUIconSetType.iconDelete.image(
                    with: isEnabled
                    ? SBUTheme.componentTheme.alertButtonColor
                    : SBUTheme.componentTheme.actionSheetDisabledColor,
                    to: SBUIconSetType.Metric.iconActionSheetItem
                )
            ) { [weak self, message] in
                guard let self = self else { return }
                self.showDeleteMessageAlert(on: message)
            }
            menuItem.isEnabled = message.threadInfo.replyCount == 0
            return menuItem
        }
        
        /// Creates a ``SBUMenuItem`` object that allows users to *edit* the `message`.
        /// - Parameter message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        /// - Returns: The ``SBUMenuItem`` object for a `message`
        open func createEditMenuItem(for message: BaseMessage) -> SBUMenuItem {
            let menuItem = SBUMenuItem(
                title: SBUStringSet.Edit,
                color: theme?.menuTextColor,
                image: SBUIconSetType.iconEdit.image(
                    with: SBUTheme.componentTheme.alertButtonColor,
                    to: SBUIconSetType.Metric.iconActionSheetItem
                )
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapEditMessage: message)
            }
            return menuItem
        }
        
        /// Creates a ``SBUMenuItem`` object that allows users to *save* the `message` when it's a *file message*.
        /// - Parameter message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        /// - Returns: The ``SBUMenuItem`` object for a `message`
        open func createSaveMenuItem(for message: BaseMessage) -> SBUMenuItem {
            let menuItem = SBUMenuItem(
                title: SBUStringSet.Save,
                color: theme?.menuTextColor,
                image: SBUIconSetType.iconDownload.image(
                    with: SBUTheme.componentTheme.alertButtonColor,
                    to: SBUIconSetType.Metric.iconActionSheetItem
                )
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapSaveMessage: message)
            }
            return menuItem
        }
        
        /// Creates a ``SBUMenuItem`` object that allows users to *reply* to a `message`.
        /// - Parameter message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        /// - Returns: The ``SBUMenuItem`` object for a `message`
        open func createReplyMenuItem(for message: BaseMessage) -> SBUMenuItem {
            let replyMenuTitle = SendbirdUI.config.groupChannel.channel.replyType == .thread
            ? SBUStringSet.MessageThread.Menu.replyInThread
            : SBUStringSet.Reply
            let iconSet = SendbirdUI.config.groupChannel.channel.replyType == .thread
            ? SBUIconSetType.iconThread
            : SBUIconSetType.iconReply
            
            let isEnabled = message.parentMessage == nil
            
            let menuItem = SBUMenuItem(
                title: replyMenuTitle,
                color: isEnabled
                ? self.theme?.menuTextColor
                : SBUTheme.componentTheme.actionSheetDisabledColor,
                image: iconSet.image(
                    with: isEnabled
                    ? SBUTheme.componentTheme.alertButtonColor
                    : SBUTheme.componentTheme.actionSheetDisabledColor,
                    to: SBUIconSetType.Metric.iconActionSheetItem
                )
            ) { [weak self, message] in
                guard let self = self else { return }
                self.baseDelegate?.baseChannelModule(self, didTapReplyMessage: message)
            }
            menuItem.isEnabled = isEnabled
            return menuItem
        }
        
        // MARK: - Actions
        
        /// Sets up the cell's tap gesture for handling the message.
        /// - Parameters:
        ///   - cell: Message cell object
        ///   - message: Message object
        ///   - indexPath: indexpath of cell
        open func setTapGesture(_ cell: UITableViewCell, message: BaseMessage, indexPath: IndexPath) {
            if let fileMessage = message as? FileMessage,
               SBUUtils.getFileType(by: fileMessage) == .voice {
                self.baseDelegate?.baseChannelModule(
                    self,
                    didTapVoiceMessage: fileMessage,
                    cell: cell,
                    forRowAt: indexPath
                )
            } else {
                self.baseDelegate?.baseChannelModule(
                    self,
                    didTapMessage: message,
                    forRowAt: indexPath
                )
            }
        }
        
        /// This function sets the cell's long tap gesture handling.
        /// - Parameters:
        ///   - cell: Message cell object
        ///   - message: Message object
        ///   - indexPath: indexpath of cell
        open func setLongTapGesture(_ cell: UITableViewCell, message: BaseMessage, indexPath: IndexPath) {
            self.baseDelegate?.baseChannelModule(self, didLongTapMessage: message, forRowAt: indexPath)
        }
        
        /// This function sets the user profile tap gesture handling.
        ///
        /// If you do not want to use the user profile function, override this function and leave it empty.
        /// - Parameter user: `SBUUser` object used for user profile configuration
        open func setUserProfileTapGesture(_ user: SBUUser) {
            self.baseDelegate?.baseChannelModule(self, didTapUserProfile: user)
        }
        
        /// Moves scroll to bottom.
        open func onTapScrollToBottom() {
            self.baseDelegate?.baseChannelModuleDidTapScrollToButton(self, animated: false)
        }
        
        // MARK: - UITableViewDelegate, UITableViewDataSource
        /// Called when the `scrollView` has been scrolled.
        open func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView == self.tableView else { return }
            self.baseDelegate?.baseChannelModule(self, didScroll: scrollView)
        }
        
        open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            nil
        }

        open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            0
        }

        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.fullMessageList.count
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            preconditionFailure("Needs to implement this method")
        }
        
        open func tableView(
            _ tableView: UITableView,
            willDisplay cell: UITableViewCell,
            forRowAt indexPath: IndexPath
        ) {
            self.baseDelegate?.baseChannelModule(self, willDisplay: cell, forRowAt: indexPath)
        }
        
        open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
        
        open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            
        }
        
        /// Sets images in file message cell. (for not succeeded message)
        /// - Parameters:
        ///   - cell: File message cell
        ///   - fileMessage: File message object
        open func setFileMessageCellImage(_ cell: UITableViewCell, fileMessage: FileMessage) {
            switch fileMessage.sendingStatus {
                case .canceled, .pending, .failed, .none:
                    guard let (pendingMessageManager, isThreadMessage) = self.baseDataSource?.baseChannelModule(self, pendingMessageManagerForCell: cell),
                          let fileInfo = pendingMessageManager?.getFileInfo(
                            requestId: fileMessage.requestId,
                            forMessageThread: isThreadMessage ?? false
                          ),
                          let type = fileInfo.mimeType, let fileData = fileInfo.file,
                          SBUUtils.getFileType(by: type) == .image else { return }
                    
                    let image = UIImage.createImage(from: fileData)
                    let isAnimatedImage = image?.isAnimatedImage() == true
                    
                    if let cell = cell as? SBUFileMessageCell {
                        cell.setImage(
                            isAnimatedImage ? image?.images?.first : image,
                            size: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
                        )
                    } else if let cell = cell as? SBUOpenChannelFileMessageCell {
                        cell.setImage(
                            isAnimatedImage ? image?.images?.first : image,
                            size: SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize
                        )
                    }
                case .succeeded:
                    break
                case .scheduled:
                    break
                @unknown default:
                    SBULog.error("unknown Type")
                    break
            }
        }
        
        /// Gets the position of the message to be grouped.
        ///
        /// Only successful messages can be grouped.
        /// - Parameter currentIndex: Index of current message in the message list
        /// - Returns: Position of a message when grouped
        public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
            
            guard currentIndex < self.fullMessageList.count else { return .none }
            
            var prevMessage = self.fullMessageList.count - 1 != currentIndex
            ? self.fullMessageList[currentIndex+1]
            : nil
            var currentMessage = self.fullMessageList[currentIndex]
            var nextMessage = currentIndex != 0
            ? self.fullMessageList[currentIndex-1]
            : nil
            
            if !self.isTransformedList {
                prevMessage = currentIndex != 0
                ? self.fullMessageList[currentIndex-1]
                : nil
                currentMessage = self.fullMessageList[currentIndex]
                nextMessage = self.fullMessageList.count - 1 != currentIndex
                ? self.fullMessageList[currentIndex+1]
                : nil
            }
            
            let succeededPrevMsg = prevMessage?.sendingStatus != .failed
            ? prevMessage
            : nil
            let succeededCurrentMsg = currentMessage.sendingStatus != .failed
            ? currentMessage
            : nil
            let succeededNextMsg = nextMessage?.sendingStatus != .failed
            ? nextMessage
            : nil
            
            // Unit : milliseconds
            let prevTimestamp = Date
                .sbu_from(succeededPrevMsg?.createdAt ?? -1)
                .sbu_toString(dateFormat: SBUDateFormatSet.yyyyMMddhhmm)
            
            let currentTimestamp = Date
                .sbu_from(succeededCurrentMsg?.createdAt ?? -1)
                .sbu_toString(dateFormat: SBUDateFormatSet.yyyyMMddhhmm)
            
            let nextTimestamp = Date
                .sbu_from(succeededNextMsg?.createdAt ?? -1)
                .sbu_toString(dateFormat: SBUDateFormatSet.yyyyMMddhhmm)
            
            // Check sender
            var prevSender = succeededPrevMsg?.sender?.userId ?? nil
            var currentSender = succeededCurrentMsg?.sender?.userId ?? nil
            var nextSender = succeededNextMsg?.sender?.userId ?? nil
            
            // Check thread info
            if SendbirdUI.config.groupChannel.channel.replyType == .thread {
                let prevThreadReplycount = succeededPrevMsg?.threadInfo.replyCount ?? 0
                let currentThreadReplycount = succeededCurrentMsg?.threadInfo.replyCount ?? 0
                let nextThreadReplycount = succeededNextMsg?.threadInfo.replyCount ?? 0
                
                if prevThreadReplycount > 0 {
                    prevSender = nil
                }
                if currentThreadReplycount > 0 {
                    currentSender = nil
                }
                if nextThreadReplycount > 0 {
                    nextSender = nil
                }
            }
            
            if (prevSender != currentSender && nextSender != currentSender) || currentSender == nil {
                return .none
            } else if prevSender == currentSender && nextSender == currentSender {
                if prevTimestamp == nextTimestamp {
                    return .middle
                } else if prevTimestamp == currentTimestamp {
                    return .bottom
                } else if currentTimestamp == nextTimestamp {
                    return .top
                }
            } else if prevSender == currentSender && nextSender != currentSender {
                return prevTimestamp == currentTimestamp ? .bottom : .none
            } else if prevSender != currentSender && nextSender == currentSender {
                return currentTimestamp == nextTimestamp ? .top : .none
            }
            
            return .none
        }
    }
}

// MARK: - SBUEmptyViewDelegate
extension SBUBaseChannelModule.List: SBUEmptyViewDelegate {
    /// Reload data from the channel. This function invokes `SBUBaseChannelModuleListDelegate baseChannelModuleDidSelectRetry(_:)`
    open func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMessages)
        }
        
        SBULog.info("[Request] Retry load channel list")
        self.baseDelegate?.baseChannelModuleDidSelectRetry(self)
    }
}

// MARK: - SBUUserProfileViewDelegate
extension SBUBaseChannelModule.List: SBUUserProfileViewDelegate {
    open func didSelectClose() {
        // Implementation
        if let userProfileView = self.userProfileView as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
    
    open func didSelectMessage(userId: String?) {
        // Implementation
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SendbirdUI.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
}

// MARK: - UITableViewCell
extension SBUBaseChannelModule.List {
    public var isScrollNearByBottom: Bool {
        tableView.contentOffset.y < 10
    }
    
    /// To keep track of which scrolls tableview.
    func scrollTableView(
        to row: Int,
        at position: UITableView.ScrollPosition = .top,
        animated: Bool = false
    ) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if self.tableView.numberOfRows(inSection: 0) <= row ||
                row < 0 {
                return
            }
            
            let isScrollable = !self.fullMessageList.isEmpty
                && row >= 0
                && row < self.fullMessageList.count
            
            if isScrollable {
                self.tableView.scrollToRow(
                    at: IndexPath(row: row, section: 0),
                    at: position,
                    animated: animated
                )
            } else {
                guard self.tableView.contentOffset != .zero else { return }
                self.tableView.setContentOffset(.zero, animated: false)
            }
        }
    }
    
    /// This function keeps the current scroll position with upserted messages.
    /// - Note: Only newly added messages are used for processing.
    /// - Parameter upsertedMessages: upserted messages
    func keepCurrentScroll(for upsertedMessages: [BaseMessage]) -> IndexPath {
        let firstVisibleIndexPath = tableView
            .indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        var nextInsertedCount = 0
        if let newestMessage = sentMessages.first {
            // only filter out messages inserted at the bottom (newer) of current visible item
            nextInsertedCount = upsertedMessages
                .filter({ $0.createdAt > newestMessage.createdAt })
                .filter({ !SBUUtils.contains(messageId: $0.messageId, in: sentMessages) }).count
        }
        
        SBULog.info("New messages inserted : \(nextInsertedCount)")
        return IndexPath(
            row: firstVisibleIndexPath.row + nextInsertedCount,
            section: 0
        )
    }
    
    /// Scrolls tableview to initial position.
    /// If starting point is set, scroll to the starting point at `.middle`.
    func scrollToInitialPosition() {
        if let startingPoint = self.baseDataSource?.baseChannelModule(self, startingPointIn: self.tableView) {
            if let index = fullMessageList.firstIndex(where: { $0.createdAt <= startingPoint }) {
                self.scrollTableView(to: index, at: .middle)
            } else {
                self.scrollTableView(to: fullMessageList.count - 1, at: .top)
            }
        } else {
            self.scrollTableView(to: 0)
        }
    }
    
    /// This function checks if the current message and the next message date have the same day.
    /// - Parameters:
    ///   - currentIndex: Current message index
    ///   - fullMessageList: The full message list including failed/pending messages as well as sent messages
    /// - Returns: If `true`, the messages date is same day.
    public func checkSameDayAsNextMessage(currentIndex: Int, fullMessageList: [BaseMessage]) -> Bool {
        guard currentIndex < fullMessageList.count-1 else { return false }
        
        let currentMessage = fullMessageList[currentIndex]
        let nextMessage = fullMessageList[currentIndex+1]
        
        let curCreatedAt = currentMessage.createdAt
        let nextCreatedAt = nextMessage.createdAt
        
        return Date.sbu_from(nextCreatedAt).isSameDay(as: Date.sbu_from(curCreatedAt))
    }
    
    public func checkSameDayAsPrevMessage(currentIndex: Int, fullMessageList: [BaseMessage]) -> Bool {
        guard currentIndex < fullMessageList.count,
              currentIndex > 0 else { return false }
        
        let currentMessage = fullMessageList[currentIndex]
        let prevMessage = fullMessageList[currentIndex-1]
        
        let curCreatedAt = currentMessage.createdAt
        let prevCreatedAt = prevMessage.createdAt
        
        return Date.sbu_from(prevCreatedAt).isSameDay(as: Date.sbu_from(curCreatedAt))
    }
}
