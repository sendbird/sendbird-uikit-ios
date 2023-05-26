//
//  SBUChatNotificationChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component in a chat notification channel.
protocol SBUChatNotificationChannelModuleListDelegate: SBUCommonDelegate {
    /// Called when there’s a tap gesture on a notification that includes a web URL. e.g., `"https://www.sendbird.com"`
    /// ```swift
    /// print(action.data) // "https://www.sendbird.com"
    /// ```
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandleWebAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a notification that includes a URL scheme defined by Sendbird UIKit. e.g., `"sendbirduikit://delete"`
    /// ```swift
    /// print(action.data) // "sendbirduikit://delete"
    /// ```
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandlePreDefinedAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a notification that includes a custom URL scheme. e.g., `"myapp://someaction"`
    /// ```swift
    /// print(action.data) // "myapp://someaction"
    /// ```
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandleCustomAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when a new cell is being drawn in a row in the list component.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the `scrollView` method has been used to scroll.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        didScroll scrollView: UIScrollView
    )
    
    /// Called when the `scrollBottomView`was tapped in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUChatNotificationChannelModule.List` object.
    ///    - animated: if it's `true`, the list component will be scrolled while animating
    func chatNotificationChannelModuleDidTapScrollToButton(
        _ listComponent: SBUChatNotificationChannelModule.List,
        animated: Bool
    )
    
    /// Called when a user selects the *retry* button in the list component.
    func chatNotificationChannelModuleDidSelectRetry(
        _ listComponent: SBUChatNotificationChannelModule.List
    )
}

extension SBUChatNotificationChannelModuleListDelegate {
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        shouldHandlePreDefinedAction action: SBUMessageTemplate.Action,
        notification: BaseMessage,
        forRowAt indexPath: IndexPath
    ) {
        // INFO: In the current version, the notification feature does not support deletion.
//        if action.data.lowercased().contains("delete") {
//            return
//        }
    }
}

/// Methods to get data source for list component in a group channel.
protocol SBUChatNotificationChannelModuleListDataSource: AnyObject {
    /// Asks the data source to return a `GroupChannel` object that represents the notification channel.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> GroupChannel?
    
    /// Asks the data source to return notification notifications that are used in the table view.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        notificationInTableView tableView: UITableView
    ) -> [BaseMessage]
    
    /// Asks the data source to return the timestamp when the channel is last seen at.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        lastSeenForTableView tableView: UITableView
    ) -> Int64
 
    /// Ask the data source to return the starting point
    /// - Parameters:
    ///    - listComponent: `SBUChatNotificationChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: The starting point.
    func chatNotificationChannelModule(
        _ listComponent: SBUChatNotificationChannelModule.List,
        startingPointIn tableView: UITableView
    ) -> Int64?
}

extension SBUChatNotificationChannelModule {
    /// A module component that represent the list of `SBUChatNotificationChannelModule`.
    ///  - Since: 3.5.0
    @objc(SBUChatNotificationChannelModuleList)
    @objcMembers
    public class List: UIView, UITableViewDelegate, UITableViewDataSource, SBUEmptyViewDelegate {
        // MARK: - UI properties (Public)
        
        /// The table view to show notifications in the channel
        var tableView = UITableView()
        
        /// A view that shows when there is no notification in the channel.
        var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// A view that indicates a new received notification.
        /// If you use a view that inherits `SBUNewNotificationInfo`, you can change the button and their action.
        /// - NOTE: You can use the customized view and a view that inherits `SBUNewNotificationInfo`.
        var newNotificationInfoView: UIView?
        
        /// Specifies the theme object that’s used as the theme of the list component. The theme must inherit the ``SBUNotificationTheme.List`` class.
        var theme: SBUNotificationTheme.List {
            switch SBUTheme.colorScheme {
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        /// Specifies the notification cell for the `BaseMessage` object. Use ``register(notificationCell:nib:)`` to update the notification cell.
        var notificationCell: SBUBaseMessageCell?
        
        /// The custom notification cell for some `BaseMessage`. Use ``register(customNotificationCell:nib:)`` to update.
        var customNotificationCell: SBUBaseMessageCell?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUNotificationEmptyView? = {
            let emptyView = SBUNotificationEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the ``SBUChatNotificationChannelModuleListDelegate``.
        weak var delegate: SBUChatNotificationChannelModuleListDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the ``SBUChatNotificationChannelModuleListDataSource``.
        weak var dataSource: SBUChatNotificationChannelModuleListDataSource?
        
        /// The current *group* channel object from ``SBUChatNotificationChannelModuleListDataSource/ChatNotificationChannelModule(_:channelForTableView:)`` data source method.
        var channel: GroupChannel? {
            self.dataSource?.chatNotificationChannelModule(
                self,
                channelForTableView: self.tableView
            )
        }
        
        /// The array of notification notifications in the channel. The value is returned by ``SBUChatNotificationChannelModuleListDataSource/ChatNotificationChannelModule(_:notificationInTableView:)`` data source method.
        var notifications: [BaseMessage] {
            self.dataSource?.chatNotificationChannelModule(
                self,
                notificationInTableView: self.tableView
            ) ?? []
        }
        
        // MARK: - Logic properties (Private)
        private var lastSeenAt: Int64 {
            self.dataSource?.chatNotificationChannelModule(self, lastSeenForTableView: self.tableView) ?? 0
        }
        
        var isTableViewReloading = false
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUChatNotificationChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUChatNotificationChannelModuleListDataSource`
        func configure(
            delegate: SBUChatNotificationChannelModuleListDelegate,
            dataSource: SBUChatNotificationChannelModuleListDataSource
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUChatNotificationChannelModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUChatNotificationChannelModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit { SBULog.info(#function) }
        
        /// Set values of the views in the list component when it needs.
        func setupViews() {
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
            
            if self.notificationCell == nil {
                self.register(notificationCell: SBUChatNotificationCell())
            }
            
            // common
            if self.newNotificationInfoView == nil {
                self.newNotificationInfoView = SBUNewNotificationInfo()
            }
            if let newNotificationInfoView = self.newNotificationInfoView {
                newNotificationInfoView.isHidden = true
                self.addSubview(newNotificationInfoView)
            }
        }
        
        func setupLayouts() {
            self.tableView.sbu_constraint(
                equalTo: self,
                left: 0,
                right: 0,
                top: 0
            )
            self.tableView.sbu_constraint_equalTo(
                bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor, bottom: 0
            )
            
            (self.newNotificationInfoView as? SBUNewNotificationInfo)?
                .sbu_constraint(equalTo: self, centerX: 0)
                .sbu_constraint_equalTo(
                    bottomAnchor: self.safeAreaLayoutGuide.bottomAnchor, bottom: 8
                )
        }
        
        /// Sets styles of the views in the list component. If set theme parameter as `nil`, it uses the stored value.
        func setupStyles() {
            self.tableView.backgroundColor = self.theme.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        /// Updates styles of the views in the list component.
        func updateStyles() {
            self.setupStyles()
            
            (self.newNotificationInfoView as? SBUNewNotificationInfo)?.setupStyles()
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - Actions
        
        /// Sets gestures in notification cell.
        /// - Parameters:
        ///   - cell: The notification cell
        ///   - notification: notification object
        ///   - indexPath: Cell's indexPath
        func setNotificationCellGestures(
            _ cell: SBUBaseMessageCell,
            notification: BaseMessage,
            indexPath: IndexPath
        ) {
            cell.longPressHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setLongTapGesture(cell, notification: notification, indexPath: indexPath)
            }
        }
        
        /// This function sets the cell's long tap gesture handling.
        /// - Parameters:
        ///   - cell: Notification cell object
        ///   - notification: Notification object
        ///   - indexPath: indexpath of cell
        func setLongTapGesture(
            _ cell: UITableViewCell,
            notification: BaseMessage,
            indexPath: IndexPath
        ) {
            // .. Implement long tap gesture here
        }
        
        // MARK: - Notification cell
        
        /// Registers a custom cell as a notification notification cell based on ``SBUBaseMessageCell``.
        /// - Parameters:
        ///   - notificationCell: Customized notification notification cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom notification cell, please use this function before calling ``configure(delegate:dataSource:)``
        func register(
            notificationCell: SBUNotificationCell,
            nib: UINib? = nil
        ) {
            self.notificationCell = notificationCell
            self.register(cell: notificationCell, nib: nib)
        }
        
        /// Registers a custom cell as a additional notification cell based on ``SBUBaseMessageCell``.
        /// - Parameters:
        ///   - customNotificationCell: Customized notification cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom notification cell, please use this function before calling ``configure(delegate:dataSource:)``
        /// ```swift
        /// listComponent.register(customNotificationCell: MyCustomNotificationCell)
        /// listComponent.configure(delegate: self, dataSource: self)
        /// ```
        func register(customNotificationCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.customNotificationCell = customNotificationCell
            self.register(cell: customNotificationCell, nib: nib)
        }
        
        func register(cell: SBUBaseMessageCell, nib: UINib? = nil) {
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: cell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: cell),
                    forCellReuseIdentifier: cell.sbu_className
                )
            }
        }
        
        func configureCell(
            _ notificationCell: SBUBaseMessageCell,
            notification: BaseMessage,
            forRowAt indexPath: IndexPath
        ) {
            guard let channel = self.channel else {
                SBULog.error("Channel must exist!")
                return
            }
            
            // NOTE: to disable unwanted animation while configuring cells
            UIView.setAnimationsEnabled(false)
            
            let isSameDay = self.checkSameDayAsNextNotification(
                currentIndex: indexPath.row,
                notificationList: notifications
            )
            
            switch (notification, notificationCell) {
            case let (notification, notificationCell) as (BaseMessage, SBUNotificationCell):
                let configuration = SBUBaseMessageCellParams(
                    message: notification,
                    hideDateView: isSameDay,
                    messagePosition: .left,
                    receiptState: .notUsed
                )
                configuration.profileImageURL = self.channel?.coverURL
                notificationCell.delegate = self
                
                // Read status
                let hasRead = notification.createdAt <= self.lastSeenAt
                notificationCell.updateReadStatus(hasRead)
                
                // Action handler
                notificationCell.notificationActionHandler = { [weak self, indexPath] action in
                    guard let self = self else { return }
                    
                    // Action Events
                    switch action.type {
                    case .uikit:
                        self.delegate?.chatNotificationChannelModule(
                            self,
                            shouldHandlePreDefinedAction: action,
                            notification: notification,
                            forRowAt: indexPath
                        )
                    case .custom:
                        self.delegate?.chatNotificationChannelModule(
                            self,
                            shouldHandleCustomAction: action,
                            notification: notification,
                            forRowAt: indexPath
                        )
                    case .web:
                        self.delegate?.chatNotificationChannelModule(
                            self,
                            shouldHandleWebAction: action,
                            notification: notification,
                            forRowAt: indexPath
                        )
                    }
                }
                notificationCell.configure(with: configuration)
                self.setNotificationCellGestures(notificationCell, notification: notification, indexPath: indexPath)
                
            default:
                let configuration = SBUBaseMessageCellParams(
                    message: notification,
                    hideDateView: false,
                    messagePosition: .center,
                    groupPosition: .none,
                    receiptState: .notUsed,
                    isThreadMessage: false,
                    joinedAt: channel.joinedAt
                )
                notificationCell.configure(with: configuration)
            }
            
            UIView.setAnimationsEnabled(true)
        }
        
        /// Generates identifier of notification cell. As a default, it returns ``SBUNotificationCell``'s `sbu_className`.
        /// To use ``customNotificationCell``, please override this method.
        /// - Parameter notification: Notification object
        /// - Returns: The identifier of notification cell.
        func generateCellIdentifier(by notification: BaseMessage) -> String {
            notificationCell?.sbu_className ?? SBUNotificationCell.sbu_className
        }
        
        // MARK: - TableView
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            if Thread.isMainThread {
                self.isTableViewReloading = true
                self.tableView.reloadData()
                self.isTableViewReloading = false

            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.isTableViewReloading = true
                    self?.tableView.reloadData()
                    self?.isTableViewReloading = false
                }
            }
        }
        
        public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.notifications.count
        }
        
        public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard indexPath.row < self.notifications.count else {
                SBULog.error("The index is out of range.")
                return .init()
            }
            
            let notification = self.notifications[indexPath.row]
            let identifier = self.generateCellIdentifier(by: notification)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell()
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            
            guard let notificationCell = cell as? SBUBaseMessageCell else {
                SBULog.error("There are no notification cells!")
                return cell
            }
            
            self.configureCell(notificationCell, notification: notification, forRowAt: indexPath)
            
            return cell
        }
        
        public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            self.delegate?.chatNotificationChannelModule(
                self,
                willDisplay: cell,
                forRowAt: indexPath
            )
        }
        
        public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            UITableView.automaticDimension
        }
        
        // MARK: - ScrollView
        /// Called when the ``tableView`` has been scrolled.
        public func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView == self.tableView else { return }
            self.delegate?.chatNotificationChannelModule(self, didScroll: scrollView)
        }

        // MARK: - EmptyView
        /// Update the ``emptyView`` according its type.
        /// - Parameter type: The value of ``EmptyViewType``.
        func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
        
        public func didSelectRetry() {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(.noNotifications)
            }
            
            SBULog.info("[Request] Retry load channel list")
            self.delegate?.chatNotificationChannelModuleDidSelectRetry(self)
        }
        
        // MARK: - Common
        /// This function checks if the current notification and the next notification date have the same day.
        /// - Parameters:
        ///   - currentIndex: Current notification index
        ///   - notificationList: The full notification list including failed/pending notifications as well as sent notifications
        /// - Returns: If `true`, the notifications date is same day.
        func checkSameDayAsNextNotification(
            currentIndex: Int,
            notificationList: [BaseMessage]
        ) -> Bool {
            guard currentIndex < notificationList.count-1 else { return false }
            
            let currentNotification = notificationList[currentIndex]
            let nextNotification = notificationList[currentIndex+1]
            
            let curCreatedAt = currentNotification.createdAt
            let nextCreatedAt = nextNotification.createdAt
            
            return Date.sbu_from(nextCreatedAt).isSameDay(as: Date.sbu_from(curCreatedAt))
        }
    }
}

// MARK: - SBUNotificationCellDelegate
extension SBUChatNotificationChannelModule.List: SBUNotificationCellDelegate {
    func notificationCellShouldReload(_ cell: SBUNotificationCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        guard visibleIndexPaths.contains(indexPath) else { return }
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}

// MARK: - UITableViewCell
extension SBUChatNotificationChannelModule.List {
    var isScrollNearByBottom: Bool {
        tableView.contentOffset.y < 10
    }
    
    /// To keep track of which scrolls tableview.
    func scrollTableView(
        to row: Int,
        at position: UITableView.ScrollPosition = .top,
        animated: Bool = false
    ) {
        func setContentOffset() {
            if self.tableView.numberOfRows(inSection: 0) <= row ||
                row < 0 {
                return
            }
            
            let isScrollable = !self.notifications.isEmpty
                && row >= 0
                && row < self.notifications.count
            
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
        
        if Thread.isMainThread {
            setContentOffset()
        } else {
            DispatchQueue.main.async {
                setContentOffset()
            }
        }
    }
    
    /// This function keeps the current scroll position with upserted notifications.
    /// - Note: Only newly added notifications are used for processing.
    /// - Parameter upsertedNotifications: upserted notifications
    func keepCurrentScroll(for upsertedNotifications: [BaseMessage]) -> IndexPath {
        let firstVisibleIndexPath = tableView
            .indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        let nextInsertedCount = 1
        
        return IndexPath(
            row: firstVisibleIndexPath.row + nextInsertedCount,
            section: 0
        )
    }
    
    /// Scrolls tableview to initial position.
    /// If starting point is set, scroll to the starting point at `.middle`.
    func scrollToInitialPosition() {
        if let startingPoint = self.dataSource?.chatNotificationChannelModule(
            self, startingPointIn:
                self.tableView
        ) {
            if let index = notifications.firstIndex(where: { $0.createdAt <= startingPoint }) {
                self.scrollTableView(to: index, at: .middle)
            } else {
                self.scrollTableView(to: notifications.count - 1, at: .top)
            }
        } else {
            self.scrollTableView(to: 0)
        }
    }
}
