//
//  SBUOpenChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the list component in a open channel.
public protocol SBUOpenChannelModuleListDelegate: SBUBaseChannelModuleListDelegate { }

/// Methods to get data source for list component in a open channel.
public protocol SBUOpenChannelModuleListDataSource: SBUBaseChannelModuleListDataSource {
    /// Ask the data source to return the overlaying state of `listComponent`.
    /// - Parameters:
    ///    - listComponent: `SBUOpenChannelModule.List` object.
    /// - Returns: The boolean value representing the overlaying state of the list component.
    func openChannelModuleIsOverlaid(_ listComponent: SBUOpenChannelModule.List) -> Bool
}

extension SBUOpenChannelModule {
    /// A module component that represent the list of `SBUOpenChannelModule`.
    @objc(SBUOpenChannelModuleList)
    @objcMembers open class List: SBUBaseChannelModule.List {
        
        // MARK: - UI
        
        /// The message cell for `AdminMessage` object. Use `register(adminMessageCell:nib:)` to update.
        public var adminMessageCell: SBUOpenChannelBaseMessageCell?
        
        /// The message cell for `UserMessage` object. Use `register(userMessageCell:nib:)` to update.
        public var userMessageCell: SBUOpenChannelBaseMessageCell?
        
        /// The message cell for `FileMessage` object. Use `register(fileMessageCell:nib:)` to update.
        public var fileMessageCell: SBUOpenChannelBaseMessageCell?
        
        /// The message cell for some unknown message which is not a type of `AdminMessage` | `UserMessage` | ` FileMessage`. Use `register(unknownMessageCell:nib:)` to update.
        public var unknownMessageCell: SBUOpenChannelBaseMessageCell?
        
        /// The custom message cell for some `BaseMessage`. Use `register(customMessageCell:nib:)` to update.
        public var customMessageCell: SBUOpenChannelBaseMessageCell?
        
        // MARK: - Logic
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUOpenChannelModuleListDelegate`.
        public weak var delegate: SBUOpenChannelModuleListDelegate? {
            get { self.baseDelegate as? SBUOpenChannelModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUOpenChannelModuleListDataSource`.
        public weak var dataSource: SBUOpenChannelModuleListDataSource? {
            get { self.baseDataSource as? SBUOpenChannelModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// The current *open* channel object casted from `baseChannel`
        public var channel: OpenChannel? {
            self.baseChannel as? OpenChannel
        }
        
        /// The boolean value that indicates overlaying state of the list component. The value is returned by `openChannelModuleIsOverlaid(_:)`
        public var isOverlaid: Bool {
            self.dataSource?.openChannelModuleIsOverlaid(self) ?? false
        }
        
        // MARK: - LifeCycle
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelModuleListDelegate` type listener.
        ///   - dataSource: The data source that is type of `SBUOpenChannelModuleListDataSource`
        ///   - theme: `SBUChannelTheme` object
        open func configure(
            delegate: SBUOpenChannelModuleListDelegate,
            dataSource: SBUOpenChannelModuleListDataSource,
            theme: SBUChannelTheme
        ) {
            
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        open override func setupViews() {
            super.setupViews()
            
            // register cell (GroupChannel)
            if self.adminMessageCell == nil {
                self.register(adminMessageCell: SBUOpenChannelAdminMessageCell())
            }
            if self.userMessageCell == nil {
                self.register(userMessageCell: SBUOpenChannelUserMessageCell())
            }
            if self.fileMessageCell == nil {
                self.register(fileMessageCell: SBUOpenChannelFileMessageCell())
            }
            if self.unknownMessageCell == nil {
                self.register(unknownMessageCell: SBUOpenChannelUnknownMessageCell())
            }
            
            // new message info view (OpenChannel)
            if let scrollBottomView = self.scrollBottomView {
                scrollBottomView.isHidden = true
                self.addSubview(scrollBottomView)
            }
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.channelStateBanner?
                .sbu_constraint(equalTo: self, leading: 8, trailing: -8, top: 8)
                .sbu_constraint(height: 24)
            
            if let scrollBottomView = self.scrollBottomView {
                scrollBottomView
                    .sbu_constraint(
                        width: SBUConstant.scrollBottomButtonSize.width,
                        height: SBUConstant.scrollBottomButtonSize.height
                    )
                    .sbu_constraint(equalTo: self, trailing: -16)
                    .sbu_constraint(equalTo: self, bottom: 8)
            }
        }
        
        /// Updates layouts of the views in the list component.
        open func updateLayouts() {
            
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class. The default value is `nil` to use the stored value.
        ///   - componentTheme: The object that is used as the theme of some UI component in the list component such as `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`
        open override func updateStyles(theme: SBUChannelTheme? = nil, componentTheme: SBUComponentTheme = SBUTheme.componentTheme) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.isOverlay = self.isOverlaid
            }
            super.updateStyles(theme: theme, componentTheme: componentTheme)
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - Scroll Bottom View
        open override func setScrollBottomView(hidden: Bool) {
            let hasNext = self.dataSource?.baseChannelModule(self, hasNextInTableView: self.tableView) ?? false
            let isHidden = hidden && !hasNext
            
            guard self.scrollBottomView?.isHidden != isHidden else { return }
            self.scrollBottomView?.isHidden = isHidden
        }
        
        open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            super.scrollViewDidScroll(scrollView)
            
            self.setScrollBottomView(hidden: isScrollNearByBottom)
        }
        
        // MARK: - TableView: Cell
        
        /// Registers a custom cell as a admin message cell based on `SBUOpenChannelBaseMessageCell`.
        /// - Parameters:
        ///   - adminMessageCell: Customized admin message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        open func register(adminMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            self.adminMessageCell = adminMessageCell
            self.register(messageCell: adminMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a user message cell based on `SBUOpenChannelBaseMessageCell`.
        /// - Parameters:
        ///   - userMessageCell: Customized user message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        open func register(userMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            self.userMessageCell = userMessageCell
            self.register(messageCell: userMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a file message cell based on `SBUOpenChannelBaseMessageCell`.
        /// - Parameters:
        ///   - fileMessageCell: Customized file message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        open func register(fileMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            self.fileMessageCell = fileMessageCell
            self.register(messageCell: fileMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a unknown message cell based on `SBUOpenChannelBaseMessageCell`.
        /// - Parameters:
        ///   - unknownMessageCell: Customized unknown message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        open func register(unknownMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            self.unknownMessageCell = unknownMessageCell
            self.register(messageCell: unknownMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a additional message cell based on `SBUOpenChannelBaseMessageCell`.
        /// - Parameters:
        ///   - customMessageCell: Customized message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        open func register(customMessageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            self.customMessageCell = customMessageCell
            self.register(messageCell: customMessageCell, nib: nib)
        }
        
        // MARK: - EmptyView
        
        // MARK: - Menu
        @available(*, deprecated, renamed: "calculateMessageMenuCGPoint(indexPath:)")
        public func calculatorMenuPoint(
            indexPath: IndexPath
        ) -> CGPoint {
            self.calculateMessageMenuCGPoint(indexPath: indexPath)
        }
        
        /// Calculates the `CGPoint` value that indicates where to draw the message menu in the open channel screen.
        /// - Parameters:
        ///   - indexPath: The index path of the selected message cell
        /// - Returns: `CGPoint` value
        open func calculateMessageMenuCGPoint(indexPath: IndexPath) -> CGPoint {
            let rowRect = self.tableView.rectForRow(at: indexPath)
            let rowRectInSuperview = self.tableView.convert(
                rowRect,
                to: UIApplication.shared.currentWindow
            )
            
            return rowRectInSuperview.origin
        }
        
        open override func createMessageMenuItems(for message: BaseMessage) -> [SBUMenuItem] {
            return super.createMessageMenuItems(for: message)
        }
        
        open override func showMessageContextMenu(for message: BaseMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let messageMenuItems = self.createMessageMenuItems(for: message)
            guard !messageMenuItems.isEmpty else { return }
            
            guard let cell = cell as? SBUOpenChannelBaseMessageCell else { return }
            let menuPoint = self.calculateMessageMenuCGPoint(indexPath: indexPath)
            SBUMenuView.show(
                items: messageMenuItems,
                point: menuPoint,
                oneTimetheme: self.isOverlaid ? SBUComponentTheme.dark : nil
            ) {
                cell.isSelected = false
            }
        }
        
        // MARK: - Actions
        /// Sets gestures in message cell.
        /// - Parameters:
        ///   - cell: The message cell
        ///   - message: message object
        ///   - indexPath: Cell's indexPath
        open func setMessageCellGestures(_ cell: SBUOpenChannelBaseMessageCell, message: BaseMessage, indexPath: IndexPath) {
            cell.tapHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setTapGesture(cell, message: message, indexPath: indexPath)
            }
            
            cell.longPressHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setLongTapGesture(cell, message: message, indexPath: indexPath)
            }
        }
        
        // MARK: - UITableView relations
        
        open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard self.channel != nil else {
                SBULog.error("Channel must exist!")
                return .init()
            }
            let message = self.fullMessageList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.generateCellIdentifier(by: message)) ?? UITableViewCell()
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
            cell.selectionStyle = .none
            
            guard let messageCell = cell as? SBUOpenChannelBaseMessageCell else {
                SBULog.error("There are no message cells!")
                return cell
            }
            
            self.configureCell(messageCell, message: message, forRowAt: indexPath)
            
            return cell
        }
        
        /// Configures cell with message for a particular row.
        /// - Parameters:
        ///    - messageCell: `SBUOpenChannelBaseMessageCell` object.
        ///    - message: The message for `messageCell`.
        ///    - indexPath: An index path representing the `messageCell`
        open func configureCell(_ messageCell: SBUOpenChannelBaseMessageCell, message: BaseMessage, forRowAt indexPath: IndexPath) {
            // NOTE: to disable unwanted animation while configuring cells
            UIView.setAnimationsEnabled(false)
            
            let isSameDay = self.checkSameDayAsNextMessage(
                currentIndex: indexPath.row,
                fullMessageList: self.fullMessageList
            )
            let isOverlay = self.isOverlaid
            
            switch (message, messageCell) {
                    // Admin message
                case let (adminMessage, adminMessageCell) as (AdminMessage, SBUOpenChannelAdminMessageCell):
                    adminMessageCell.configure(
                        adminMessage,
                        hideDateView: isSameDay,
                        isOverlay: isOverlay
                    )
                    self.setMessageCellGestures(
                        adminMessageCell,
                        message: adminMessage,
                        indexPath: indexPath
                    )
                    
                    // Unknown Message
                case let (unknownMessage, unknownMessageCell) as (BaseMessage, SBUOpenChannelUnknownMessageCell):
                    unknownMessageCell.configure(
                        unknownMessage,
                        hideDateView: isSameDay,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        withTextView: true,
                        isOverlay: isOverlay
                    )
                    self.setMessageCellGestures(
                        unknownMessageCell,
                        message: unknownMessage,
                        indexPath: indexPath
                    )
                    
                    // User Message
                case let (userMessage, userMessageCell) as (UserMessage, SBUOpenChannelUserMessageCell):
                    userMessageCell.configure(
                        userMessage,
                        hideDateView: isSameDay,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        withTextView: true,
                        isOverlay: isOverlay
                    )
                    self.setMessageCellGestures(
                        userMessageCell,
                        message: userMessage,
                        indexPath: indexPath
                    )
                    
                    // File Message
                case let (fileMessage, fileMessageCell) as (FileMessage, SBUOpenChannelFileMessageCell):
                    fileMessageCell.configure(
                        fileMessage,
                        hideDateView: isSameDay,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        fileType: SBUUtils.getFileType(by: fileMessage),
                        isOverlay: isOverlay
                    )
                    
                    self.setMessageCellGestures(
                        fileMessageCell,
                        message: fileMessage,
                        indexPath: indexPath
                    )
                    
                    self.setFileMessageCellImage(fileMessageCell, fileMessage: fileMessage)
                    
                default:
                    messageCell.configure(
                        message: message,
                        hideDateView: isSameDay,
                        isOverlay: isOverlay
                    )
            }
            UIView.setAnimationsEnabled(true)
            
            // Tap profile action
            messageCell.userProfileTapHandler = { [weak messageCell, weak self] in
                guard let self = self else { return }
                guard let cell = messageCell else { return }
                guard let sender = cell.message?.sender else { return }
                self.setUserProfileTapGesture(SBUUser(sender: sender))
            }
        }
        
        /// Register the message cell to the table view.
        public func register(messageCell: SBUOpenChannelBaseMessageCell, nib: UINib? = nil) {
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: messageCell.sbu_className
                )
            } else {
                self.tableView.register(
                    type(of: messageCell), forCellReuseIdentifier: messageCell.sbu_className)
            }
        }
        
        /// Generates identifier of message cell.
        /// - Parameter message: Message object
        /// - Returns: The identifier of message cell.
        open func generateCellIdentifier(by message: BaseMessage) -> String {
            switch message {
                case is FileMessage:
                    return fileMessageCell?.sbu_className ?? SBUOpenChannelFileMessageCell.sbu_className
                case is UserMessage:
                    return userMessageCell?.sbu_className ?? SBUOpenChannelUserMessageCell.sbu_className
                case is AdminMessage:
                    return adminMessageCell?.sbu_className ?? SBUOpenChannelAdminMessageCell.sbu_className
                default:
                    return unknownMessageCell?.sbu_className ?? SBUOpenChannelUnknownMessageCell.sbu_className
            }
        }
    }
}
