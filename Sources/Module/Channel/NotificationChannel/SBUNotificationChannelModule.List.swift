//
//  SBUNotificationChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


public protocol SBUNotificationChannelModuleListDelegate: SBUCommonDelegate {
    /// Called when there’s a tap gesture on a message that includes a web URL. e.g., `"https://www.sendbird.com"`
    /// ```swift
    /// print(action.data) // "https://www.sendbird.com"
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandleWebAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a message that includes a URL scheme defined by Sendbird UIKit. e.g., `"sendbirduikit://delete"`
    /// ```swift
    /// print(action.data) // "sendbirduikit://delete"
    /// ```
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandlePreDefinedAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a message that includes a custom URL scheme. e.g., `"myapp://someaction"`
    /// ```swift
    /// print(action.data) // "myapp://someaction"
    /// ```
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        shouldHandleCustomAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when a user selects the *delete* menu item of a `message` in the list component.
    /// - Parameters:
    ///    - listComponent: A ``SBUNotificationChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        didTapDeleteMessage message: BaseMessage
    )
    
    /// Called when a new cell is being drawn in a row in the list component.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when the `scrollView` method has been used to scroll.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        didScroll scrollView: UIScrollView
    )
    
    /// Called when a user selects the *retry* button in the list component.
    func notificationChannelModuleDidSelectRetry(
        _ listComponent: SBUNotificationChannelModule.List
    )
}

public protocol SBUNotificationChannelModuleListDataSource: AnyObject {
    /// Asks the data source to return a `GroupChannel` object that represents the notification channel.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        channelForTableView tableView: UITableView
    ) -> GroupChannel?
    
    /// Asks the data source to return notification messages that are used in the table view.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        notificationMessageInTableView tableView: UITableView
    ) -> [BaseMessage]
    
    /// Asks the data source to return the timestamp when the channel is last seen at.
    func notificationChannelModule(
        _ listComponent: SBUNotificationChannelModule.List,
        lastSeenForTableView tableView: UITableView
    ) -> Int64
}

extension SBUNotificationChannelModule {
    /// A module component that represent the list of ``SBUNotificationChannelModule``
    @objc(SBUNotificationChannelModuleList)
    @objcMembers
    open class List: UIView, UITableViewDelegate, UITableViewDataSource, SBUEmptyViewDelegate {
        // MARK: - UI Properties (Public)
        
        /// Specifies a table view to show messages in the channel.
        public var tableView = UITableView()
        
        /// Specifies an empty view when there are no messages to show in the channel.
        public var emptyView: UIView? {
            didSet { self.tableView.backgroundView = self.emptyView }
        }
        
        /// Specifies the theme object that’s used as the theme of the list component. The theme must inherit the ``SBUChannelTheme`` class.
        public var theme: SBUChannelTheme? = nil
        
        /// Specifies the message cell for the `BaseMessage` object. Use ``register(notificationMessageCell:nib:)`` to update the message cell.
        public private(set) var notificationMessageCell: SBUBaseMessageCell?
        
        /// The custom message cell for some `BaseMessage`. Use ``register(customMessageCell:nib:)`` to update.
        public private(set) var customMessageCell: SBUBaseMessageCell?
        
        // MARK: - UI properties (Private)
        private lazy var defaultEmptyView: SBUEmptyView? = {
            let emptyView = SBUEmptyView()
            emptyView.type = EmptyViewType.none
            emptyView.delegate = self
            return emptyView
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the ``SBUNotificationChannelModuleListDelegate``.
        public weak var delegate: SBUNotificationChannelModuleListDelegate?
        
        /// The object that acts as the base data source of the list component. The base data source must adopt the ``SBUNotificationChannelModuleListDataSource``.
        public weak var dataSource: SBUNotificationChannelModuleListDataSource?
        
        /// The current *group* channel object from ``SBUNotificationChannelModuleListDataSource/notificationChannelModule(_:channelForTableView:)`` data source method.
        public var channel: GroupChannel? {
            self.dataSource?.notificationChannelModule(
                self,
                channelForTableView: self.tableView
            )
        }
        /// The array of notification messages in the channel. The value is returned by ``SBUNotificationChannelModuleListDataSource/notificationChannelModule(_:notificationMessageInTableView:)`` data source method.
        public var notificationMessages: [BaseMessage] {
            self.dataSource?.notificationChannelModule(
                self,
                notificationMessageInTableView: self.tableView
            ) ?? []
        }
        
        
        // MARK: - Logic properties (Private)
        
        private var lastSeenAt: Int64 {
            self.dataSource?.notificationChannelModule(self, lastSeenForTableView: self.tableView) ?? .max
        }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///    - delegate: ``SBUNotificationChannelModuleListDelegate`` type event delegate.
        ///    - dataSource: The data source that is type of ``SBUNotificationChannelModuleListDataSource``
        ///    - theme: ``SBUChannelTheme`` object.
        open func configure(
            delegate: SBUNotificationChannelModuleListDelegate,
            dataSource: SBUNotificationChannelModuleListDataSource,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - Life cycle
        @available(*, unavailable, renamed: "SBUNotificationChannelModule.List()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUNotificationChannelModule.List()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit { SBULog.info(#function) }
        
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
            
            self.tableView.backgroundView = self.emptyView
            
            self.tableView.rowHeight = UITableView.automaticDimension
            self.tableView.estimatedRowHeight = 44.0
            self.addSubview(self.tableView)
            
            if self.notificationMessageCell == nil {
                self.register(notificationMessageCell: SBUNotificationMessageCell())
            }
        }
        
        /// Sets layouts of the views in the list component.
        open func setupLayouts() {
            self.tableView.sbu_constraint(
                equalTo: self,
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            )
        }
        
        /// Sets styles of the views in the list component with the `theme`. If set theme parameter as `nil`, it uses the stored value.
        /// - Parameter theme: The object that is used as the theme of the list component. The theme must adopt the ``SBUChannelTheme`` class.
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the list component. The theme must adopt the ``SBUChannelTheme`` class.
        open func updateStyles(theme: SBUChannelTheme? = nil) {
            self.setupStyles(theme: theme)
            
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.setupStyles()
            }
        }
        
        // MARK: - Message cell
        
        /// Registers a custom cell as a notification message cell based on ``SBUBaseMessageCell``.
        /// - Parameters:
        ///   - notificationMessageCell: Customized notification message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling ``configure(delegate:dataSource:theme:)``
        /// ```swift
        /// listComponent.register(notificationMessageCell: MyNotificationMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(
            notificationMessageCell: SBUNotificationMessageCell,
            nib: UINib? = nil
        ) {
            self.notificationMessageCell = notificationMessageCell
            self.register(messageCell: notificationMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a additional message cell based on ``SBUBaseMessageCell``.
        /// - Parameters:
        ///   - customMessageCell: Customized message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling ``configure(delegate:dataSource:theme:)``
        /// ```swift
        /// listComponent.register(customMessageCell: MyCustomMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(customMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.customMessageCell = customMessageCell
            self.register(messageCell: customMessageCell, nib: nib)
        }
        
        public func register(messageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: messageCell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: messageCell),
                    forCellReuseIdentifier: messageCell.sbu_className
                )
            }
        }
        
        open func configureCell(_ messageCell: SBUBaseMessageCell, message: BaseMessage, forRowAt indexPath: IndexPath) {
            guard let channel = self.channel else {
                SBULog.error("Channel must exist!")
                return
            }
            
            // NOTE: to disable unwanted animation while configuring cells
            UIView.setAnimationsEnabled(false)
            
            switch (message, messageCell) {
            case let (notificationMessage, notificationMessageCell) as (BaseMessage, SBUNotificationMessageCell):
                let configuration = SBUBaseMessageCellParams(
                    message: notificationMessage,
                    hideDateView: false,
                    messagePosition: .center,
                    groupPosition: .none,
                    receiptState: .notUsed,
                    isThreadMessage: false,
                    joinedAt: channel.joinedAt
                )
                notificationMessageCell.delegate = self
                notificationMessageCell.configure(with: configuration)
                
                // Read status
                if self.lastSeenAt != 0 {
                    let hasRead = message.createdAt <= self.lastSeenAt
                    notificationMessageCell.updateReadStatus(hasRead)
                }
                
                // Action handler
                notificationMessageCell.messageActionHandler = { [indexPath] action in
                    // Action Events
                    switch action.type {
                    case .uikit:
                        self.delegate?.notificationChannelModule(
                            self,
                            shouldHandlePreDefinedAction: action,
                            message: message,
                            forRowAt: indexPath
                        )
                    case .custom:
                        self.delegate?.notificationChannelModule(
                            self,
                            shouldHandleCustomAction: action,
                            message: message,
                            forRowAt: indexPath
                        )
                    case .web:
                        self.delegate?.notificationChannelModule(
                            self,
                            shouldHandleWebAction: action,
                            message: message,
                            forRowAt: indexPath
                        )
                    }
                }
            default:
                let configuration = SBUBaseMessageCellParams(
                    message: message,
                    hideDateView: false,
                    messagePosition: .center,
                    groupPosition: .none,
                    receiptState: .notUsed,
                    isThreadMessage: false,
                    joinedAt: channel.joinedAt
                )
                messageCell.configure(with: configuration)
            }
            
            UIView.setAnimationsEnabled(true)
        }
        
        /// Generates identifier of message cell. As a default, it returns ``SBUNotificationMessageCell``'s `sbu_className`.
        /// To use ``customMessageCell``, please override this method.
        /// - Parameter message: Message object
        /// - Returns: The identifier of message cell.
        open func generateCellIdentifier(by message: BaseMessage) -> String {
            notificationMessageCell?.sbu_className ?? SBUNotificationMessageCell.sbu_className
        }
        
        // MARK: - TableView
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public func reloadTableView() {
            let emptyViewType: EmptyViewType = self.notificationMessages.isEmpty ? .noNotifications : .none
            self.updateEmptyView(type: emptyViewType)
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
                self?.tableView.layoutIfNeeded()
            }
        }
        
        open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return self.notificationMessages.count
        }
        
        open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard indexPath.row < self.notificationMessages.count else {
                SBULog.error("The index is out of range.")
                return .init()
            }
            
            let message = self.notificationMessages[indexPath.row]
            let identifier = self.generateCellIdentifier(by: message)
            
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier) ?? UITableViewCell()
            cell.selectionStyle = .none
            
            guard let messageCell = cell as? SBUBaseMessageCell else {
                SBULog.error("There are no message cells!")
                return cell
            }
            
            self.configureCell(messageCell, message: message, forRowAt: indexPath)
            
            return cell
        }
        
        open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            self.delegate?.notificationChannelModule(
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
        open func scrollViewDidScroll(_ scrollView: UIScrollView) {
            guard scrollView == self.tableView else { return }
            self.delegate?.notificationChannelModule(self, didScroll: scrollView)
        }
        
        // MARK: - EmptyView
        /// Update the ``emptyView`` according its type.
        /// - Parameter type: The value of ``EmptyViewType``.
        public func updateEmptyView(type: EmptyViewType) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(type)
            }
        }
        
        open func didSelectRetry() {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(.noMessages)
            }
            
            SBULog.info("[Request] Retry load channel list")
            self.delegate?.notificationChannelModuleDidSelectRetry(self)
        }
        
        // MARK: - Actions
        open func showDeleteMessageAlert(
            on message: BaseMessage,
            oneTimeTheme: SBUComponentTheme? = nil
        ) {
            let deleteButton = SBUAlertButtonItem(
                title: SBUStringSet.Delete,
                color: self.theme?.alertRemoveColor
            ) { [weak self, message] info in
                guard let self = self else { return }
                SBULog.info("[Request] Delete message: \(message.description)")
                self.delegate?.notificationChannelModule(self, didTapDeleteMessage: message)
            }
            
            let cancelButton = SBUAlertButtonItem(
                title: SBUStringSet.Cancel,
                completionHandler: { _ in }
            )
            
            SBUAlertView.show(
                title: SBUStringSet.Alert_Delete,
                oneTimetheme: oneTimeTheme,
                confirmButtonItem: deleteButton,
                cancelButtonItem: cancelButton
            )
        }
    }
    
}

// MARK: - SBUNotificationMessageCellDelegate
extension SBUNotificationChannelModule.List: SBUNotificationMessageCellDelegate {
    func messageCellShouldReload(_ cell: SBUNotificationMessageCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        guard let visibleIndexPaths = tableView.indexPathsForVisibleRows else { return }
        guard visibleIndexPaths.contains(indexPath) else { return }
        self.tableView.reloadRows(at: [indexPath], with: .none)
    }
}
