//
//  SBUMessageThreadModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import AVFAudio

/// Event methods for the views updates and performing actions from the list component in a message thread.
public protocol SBUMessageThreadModuleListDelegate: SBUBaseChannelModuleListDelegate {
    
    /// Called when tapped emoji in the cell.
    /// - Parameters:
    ///   - emojiKey: emoji key
    ///   - messageCell: Message cell object
    func messageThreadModule(_ listComponent: SBUMessageThreadModule.List, didTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell)
    
    /// Called when long tapped emoji in the cell.
    /// - Parameters:
    ///   - emojiKey: emoji key
    ///   - messageCell: Message cell object
    func messageThreadModule(_ listComponent: SBUMessageThreadModule.List, didLongTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell)
    
    /// Called when tapped the cell to get more emoji
    /// - Parameters:
    ///   - messageCell: Message cell object
    func messageThreadModule(_ listComponent: SBUMessageThreadModule.List, didTapMoreEmojiForCell messageCell: SBUBaseMessageCell)
    
    /// Called when tapped the mentioned nickname in the cell.
    /// - Parameters:
    ///    - user: The`SBUUser` object from the tapped mention.
    func messageThreadModule(_ listComponent: SBUMessageThreadModule.List, didTapMentionUser user: SBUUser)
}

/// Methods to get data source for list component in a message thread.
public protocol SBUMessageThreadModuleListDataSource: SBUBaseChannelModuleListDataSource { }

extension SBUMessageThreadModule {
    /// A module component that represent the list of `SBUMessageThreadModule`.
    /// - Since: 3.3.0
    @objc(SBUMessageThreadModuleList)
    @objcMembers open class List: SBUBaseChannelModule.List, SBUParentMessageInfoViewDelegate, SBUVoicePlayerDelegate {

        // MARK: - UI properties (Public)
        
        /// A view that shows parent message info on the message thread.
        public var parentMessageInfoView = SBUParentMessageInfoView()
        
        public var tempMarginView = UIView()
        
        /// The message cell for `AdminMessage` object. Use `register(adminMessageCell:nib:)` to update.
        public private(set) var adminMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `UserMessage` object. Use `register(userMessageCell:nib:)` to update.
        public private(set) var userMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `FileMessage` object. Use `register(fileMessageCell:nib:)` to update.
        public private(set) var fileMessageCell: SBUBaseMessageCell?
        
        /// The message cell for some unknown message which is not a type of `AdminMessage` | `UserMessage` | ` FileMessage`. Use `register(unknownMessageCell:nib:)` to update.
        public private(set) var unknownMessageCell: SBUBaseMessageCell?
        
        /// The custom message cell for some `BaseMessage`. Use `register(customMessageCell:nib:)` to update.
        public private(set) var customMessageCell: SBUBaseMessageCell?
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUMessageThreadModuleListDelegate`.
        public weak var delegate: SBUMessageThreadModuleListDelegate? {
            get { self.baseDelegate as? SBUMessageThreadModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUMessageThreadModuleDataSource`.
        public weak var dataSource: SBUMessageThreadModuleListDataSource? {
            get { self.baseDataSource as? SBUMessageThreadModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// The current *group* channel object casted from `baseChannel`
        public var channel: GroupChannel? {
            self.baseChannel as? GroupChannel
        }
        
        public var parentMessage: BaseMessage?
        
        var voicePlayer: SBUVoicePlayer?
        var voiceFileInfos: [String: SBUVoiceFileInfo] = [:]
        var currentVoiceFileInfo: SBUVoiceFileInfo?
        var currentVoiceContentView: SBUVoiceContentView?
        var currentVoiceContentIndexPath: IndexPath?
        
        // MARK: - LifeCycle
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUMessageThreadModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUMessageThreadModuleListDataSource`
        ///   - theme: `SBUChannelTheme` object
        ///   - voiceFileInfos: If you have voiceFileInfos, set this value. so the default value of Voice Messages are applied based on the voiceFileInfos.
        /// - Since: 3.4.0
        open func configure(
            delegate: SBUMessageThreadModuleListDelegate,
            dataSource: SBUMessageThreadModuleListDataSource,
            theme: SBUChannelTheme,
            voiceFileInfos: [String: SBUVoiceFileInfo]? = nil) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.isTransformedList = false
            if let voiceFileInfos = voiceFileInfos {
                self.voiceFileInfos = voiceFileInfos
            }
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        
        open override func setupViews() {
            self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
            
            super.setupViews()
            
            self.tableView.tableFooterView =
            UIView(frame: CGRect(origin: .zero,
                                 size: CGSize(width: CGFloat.leastNormalMagnitude,
                                              height: CGFloat.leastNormalMagnitude)))
            
            self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: 1)
            self.tableView.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            // register cell (MessageThread)
            if self.adminMessageCell == nil {
                self.register(adminMessageCell: SBUAdminMessageCell())
            }
            if self.userMessageCell == nil {
                self.register(userMessageCell: SBUUserMessageCell())
            }
            if self.fileMessageCell == nil {
                self.register(fileMessageCell: SBUFileMessageCell())
            }
            if self.unknownMessageCell == nil {
                self.register(unknownMessageCell: SBUUnknownMessageCell())
            }
            
            self.newMessageInfoView = nil
            self.scrollBottomView = nil
            
            self.voicePlayer = SBUVoicePlayer(delegate: self)
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.channelStateBanner?
                .sbu_constraint(equalTo: self, leading: 8, trailing: -8, top: 8)
                .sbu_constraint(height: 24)
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUChannelTheme` object
        open override func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            if let channelStateBanner = channelStateBanner as? UILabel {
                channelStateBanner.textColor = theme?.channelStateBannerTextColor
                channelStateBanner.font = theme?.channelStateBannerFont
                channelStateBanner.backgroundColor = theme?.channelStateBannerBackgroundColor
            }
            self.tableView.backgroundColor = self.theme?.backgroundColor
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
            
            self.parentMessageInfoView.setupStyles()
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class. The default value is `nil` to use the stored value.
        ///   - componentTheme: The object that is used as the theme of some UI component in the list component such as `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`
        open override func updateStyles(
            theme: SBUChannelTheme? = nil,
            componentTheme: SBUComponentTheme = SBUTheme.componentTheme
        ) {
            super.updateStyles(theme: theme, componentTheme: componentTheme)
            
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - Parent info view
        public func updateParentInfoView() {
            self.updateParentInfoView(parentMessage: self.parentMessage)
        }
        
        public func updateParentInfoView(parentMessage: BaseMessage?) {
            if let parentMessage = parentMessage {
                self.parentMessage = parentMessage
            }
            
            let useReaction = SBUEmojiManager.isReactionEnabled(channel: self.channel)
            
            var voiceFileInfo: SBUVoiceFileInfo?
            if let cacheKey = parentMessage?.cacheKey {
                voiceFileInfo = self.voiceFileInfos[cacheKey]
            }
            self.parentMessageInfoView.configure(
                message: self.parentMessage,
                delegate: self,
                useReaction: useReaction,
                voiceFileInfo: voiceFileInfo
            )
            
            self.reloadTableView()
            
            if let parentMessage = self.parentMessage {
                self.setParentMessageInfoViewGestures(message: parentMessage)
            }
        }
        
        open func setParentMessageInfoViewGestures(message: BaseMessage) {
            self.parentMessageInfoView.tapHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setTapGesture(UITableViewCell(), message: message, indexPath: IndexPath())
            }
            
            self.parentMessageInfoView.moreButtonTapHandlerToContent = { [weak self] in
                guard let self = self else { return }
                let cell = SBUBaseMessageCell()
                self.showMessageMenuSheet(for: message, cell: cell)
            }
            
            self.parentMessageInfoView.userProfileTapHandler = { [ weak self] in
                guard let self = self else { return }
                guard let sender = message.sender else { return }
                self.setUserProfileTapGesture(SBUUser(sender: sender))
            }
            
            self.parentMessageInfoView.emojiTapHandler = { [weak self] emojiKey in
                guard let self = self else { return }
                let cell = SBUBaseMessageCell()
                cell.message = message
                self.delegate?.messageThreadModule(self, didTapEmoji: emojiKey, messageCell: cell)
            }
            
            self.parentMessageInfoView.emojiLongPressHandler = { [weak self] emojiKey in
                guard let self = self else { return }
                let cell = SBUBaseMessageCell()
                cell.message = message
                self.delegate?.messageThreadModule(self, didLongTapEmoji: emojiKey, messageCell: cell)
            }
            
            self.parentMessageInfoView.moreEmojiTapHandler = { [weak self] in
                guard let self = self else { return }
                let cell = SBUBaseMessageCell()
                cell.message = message
                self.delegate?.messageThreadModule(self, didTapMoreEmojiForCell: cell)
            }
            
            self.parentMessageInfoView.mentionTapHandler = { [weak self] user in
                guard let self = self else { return }
                self.delegate?.messageThreadModule(self, didTapMentionUser: user)
            }
        }
        
        // MARK: - EmptyView
        
        // MARK: - Menu
        
        /// Calculates the `CGPoint` value that indicates where to draw the message menu in the message thread screen.
        /// - Parameters:
        ///   - indexPath: The index path of the selected message cell
        ///   - position: Message position
        /// - Returns: `CGPoint` value
        open func calculateMessageMenuCGPoint(
            indexPath: IndexPath,
            position: MessagePosition
        ) -> CGPoint {
            let rowRect = self.tableView.rectForRow(at: indexPath)
            let rowRectInSuperview = self.tableView.convert(
                rowRect,
                to: UIApplication.shared.currentWindow
            )
            
            let originX = (position == .right) ? rowRectInSuperview.width : rowRectInSuperview.origin.x
            let menuPoint = CGPoint(x: originX, y: rowRectInSuperview.origin.y)
            
            return menuPoint
        }
        
        open override func createMessageMenuItems(for message: BaseMessage) -> [SBUMenuItem] {
            let items = super.createMessageMenuItems(for: message)
            return items
        }
        
        open override func showMessageContextMenu(for message: BaseMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let messageMenuItems = self.createMessageMenuItems(for: message)
            guard !messageMenuItems.isEmpty,
                  let cell = cell as? SBUBaseMessageCell else {
                cell.isSelected = false
                return
            }
            
            let menuPoint = self.calculateMessageMenuCGPoint(indexPath: indexPath, position: cell.position)
            SBUMenuView.show(items: messageMenuItems, point: menuPoint) {
                cell.isSelected = false
            }
        }
        
        // MARK: - Actions
        
        /// Sets gestures in message cell.
        /// - Parameters:
        ///   - cell: The message cell
        ///   - message: message object
        ///   - indexPath: Cell's indexPath
        open func setMessageCellGestures(_ cell: SBUBaseMessageCell, message: BaseMessage, indexPath: IndexPath) {
            cell.tapHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setTapGesture(cell, message: message, indexPath: indexPath)
            }
            
            cell.longPressHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setLongTapGesture(cell, message: message, indexPath: indexPath)
            }
            
            cell.userProfileTapHandler = { [weak self] in
                guard let self = self else { return }
                guard let sender = cell.message?.sender else { return }
                self.setUserProfileTapGesture(SBUUser(sender: sender))
            }
            
            cell.emojiTapHandler = { [weak self] emojiKey in
                guard let self = self else { return }
                self.delegate?.messageThreadModule(self, didTapEmoji: emojiKey, messageCell: cell)
            }
            
            cell.emojiLongPressHandler = { [weak self] emojiKey in
                guard let self = self else { return }
                self.delegate?.messageThreadModule(self, didLongTapEmoji: emojiKey, messageCell: cell)
            }
            
            cell.moreEmojiTapHandler = { [weak self] in
                guard let self = self else { return }
                self.delegate?.messageThreadModule(self, didTapMoreEmojiForCell: cell)
            }
            
            cell.mentionTapHandler = { [weak self] user in
                guard let self = self else { return }
                self.delegate?.messageThreadModule(self, didTapMentionUser: user)
            }
        }
        
        // MARK: - TableView
                
        /// Reloads table view. This method corresponds to `UITableView reloadData()`.
        public override func reloadTableView() {
            if Thread.isMainThread {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()

            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                    self?.tableView.layoutIfNeeded()
                }
            }
        }
        
        // MARK: - TableView: Cell
        
        /// Register the message cell to the table view.
        public func register(messageCell: SBUBaseMessageCell, nib: UINib? = nil) {
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
        
        /// Registers a custom cell as a admin message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///   - adminMessageCell: Customized admin message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(adminMessageCell: MyAdminMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.adminMessageCell = adminMessageCell
            self.register(messageCell: adminMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a user message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///   - userMessageCell: Customized user message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(userMessageCell: MyUserMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.userMessageCell = userMessageCell
            self.register(messageCell: userMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a file message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///   - fileMessageCell: Customized file message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(fileMessageCell: MyFileMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.fileMessageCell = fileMessageCell
            self.register(messageCell: fileMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a unknown message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///   - unknownMessageCell: Customized unknown message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(unknownMessageCell: MyUnknownMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(unknownMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.unknownMessageCell = unknownMessageCell
            self.register(messageCell: unknownMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a additional message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///   - customMessageCell: Customized message cell
        ///   - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(customMessageCell: MyCustomMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        open func register(customMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.customMessageCell = customMessageCell
            self.register(messageCell: customMessageCell, nib: nib)
        }
        
        /// Configures cell with message for a particular row.
        /// - Parameters:
        ///    - messageCell: `SBUBaseMessageCell` object.
        ///    - message: The message for `messageCell`.
        ///    - indexPath: An index path representing the `messageCell`
        open func configureCell(
            _ messageCell: SBUBaseMessageCell,
            message: BaseMessage,
            forRowAt indexPath: IndexPath
        ) {
            guard self.channel != nil else {
                SBULog.error("Channel must exist!")
                return
            }
            
            // NOTE: to disable unwanted animation while configuring cells
            UIView.setAnimationsEnabled(false)
            
            let isSameDay = self.checkSameDayAsPrevMessage(
                currentIndex: indexPath.row,
                fullMessageList: fullMessageList
            )
            let useReaction = SBUEmojiManager.isReactionEnabled(channel: self.channel)
            
            switch (message, messageCell) {
                    // Admin message
                case let (adminMessage, adminMessageCell) as (AdminMessage, SBUAdminMessageCell):
                    let configuration = SBUAdminMessageCellParams(
                        message: adminMessage,
                        hideDateView: isSameDay
                    )
                    adminMessageCell.configure(with: configuration)
                    self.setMessageCellGestures(adminMessageCell, message: adminMessage, indexPath: indexPath)
                    
                    // Unknown message
                case let (unknownMessage, unknownMessageCell) as (BaseMessage, SBUUnknownMessageCell):
                    let configuration = SBUUnknownMessageCellParams(
                        message: unknownMessage,
                        hideDateView: isSameDay,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: .notUsed,
                        useReaction: useReaction,
                        isThreadMessage: true
                    )
                    unknownMessageCell.configure(with: configuration)
                    self.setMessageCellGestures(unknownMessageCell, message: unknownMessage, indexPath: indexPath)
                    
                    // User message
                case let (userMessage, userMessageCell) as (UserMessage, SBUUserMessageCell):
                    let configuration = SBUUserMessageCellParams(
                        message: userMessage,
                        hideDateView: isSameDay,
                        useMessagePosition: true,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: .notUsed,
                        useReaction: useReaction,
                        withTextView: true,
                        isThreadMessage: true
                    )
                    userMessageCell.configure(with: configuration)
                    self.setMessageCellGestures(userMessageCell, message: userMessage, indexPath: indexPath)
                    
                    // File message
                case let (fileMessage, fileMessageCell) as (FileMessage, SBUFileMessageCell):
                    let voiceFileInfo = self.voiceFileInfos[fileMessage.cacheKey] ?? nil
                    let configuration = SBUFileMessageCellParams(
                        message: fileMessage,
                        hideDateView: isSameDay,
                        useMessagePosition: true,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: .notUsed,
                        useReaction: useReaction,
                        isThreadMessage: true,
                        voiceFileInfo: voiceFileInfo
                    )
                    
                if voiceFileInfo != nil,
                   self.parentMessageInfoView.baseFileContentView != self.currentVoiceContentView {
                    self.currentVoiceFileInfo = nil
                    self.currentVoiceContentView = nil
                }
                
                fileMessageCell.configure(with: configuration)
                self.setMessageCellGestures(fileMessageCell, message: fileMessage, indexPath: indexPath)
                self.setFileMessageCellImage(fileMessageCell, fileMessage: fileMessage)
                
                if let voiceFileInfo = voiceFileInfo,
                   voiceFileInfo.isPlaying == true,
                   let voiceContentView = fileMessageCell.baseFileContentView as? SBUVoiceContentView {
                    
                    self.currentVoiceContentIndexPath = indexPath
                    self.currentVoiceFileInfo = voiceFileInfo
                    self.currentVoiceContentView = voiceContentView
                }
                
            default:
                    let configuration = SBUBaseMessageCellParams(
                        message: message,
                        hideDateView: isSameDay,
                        messagePosition: .center,
                        groupPosition: .none,
                        receiptState: .notUsed,
                        isThreadMessage: true
                    )
                    messageCell.configure(with: configuration)
            }
            
            UIView.setAnimationsEnabled(true)
        }
        
        // MARK: - UITableViewDelegate, UITableViewDataSource
        open override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            return self.parentMessageInfoView
        }
        
        open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            let headerView = self.parentMessageInfoView
            
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame
            
            // Comparison necessary to avoid infinite loop
            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                self.parentMessageInfoView = headerView
            }
            return headerFrame.height
        }
        
        open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let headerView = UIView()
            headerView.backgroundColor = UIColor.clear
            return headerView
        }
        
        open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            return CGFloat.leastNormalMagnitude
        }
        
        open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard indexPath.row < self.fullMessageList.count else {
                SBULog.error("The index is out of range.")
                return .init()
            }
            
            let message = fullMessageList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(
                withIdentifier: self.generateCellIdentifier(by: message)
            ) ?? UITableViewCell()
            cell.selectionStyle = .none
            
            guard let messageCell = cell as? SBUBaseMessageCell else {
                SBULog.error("There are no message cells!")
                return cell
            }
            
            self.configureCell(messageCell, message: message, forRowAt: indexPath)
            
            return cell
        }
        
        open override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard let fileMessageCell = cell as? SBUFileMessageCell,
                  let _ = fileMessageCell.baseFileContentView as? SBUVoiceContentView else { return }
        }
        
        /// Generates identifier of message cell.
        /// - Parameter message: Message object
        /// - Returns: The identifier of message cell.
        open func generateCellIdentifier(by message: BaseMessage) -> String {
            switch message {
                case is FileMessage:
                    return fileMessageCell?.sbu_className ?? SBUFileMessageCell.sbu_className
                case is UserMessage:
                    return userMessageCell?.sbu_className ?? SBUUserMessageCell.sbu_className
                case is AdminMessage:
                    return adminMessageCell?.sbu_className ?? SBUAdminMessageCell.sbu_className
                default:
                    return unknownMessageCell?.sbu_className ?? SBUUnknownMessageCell.sbu_className
            }
        }
        
        // MARK: - Scroll View
        open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
            super.scrollViewDidScroll(scrollView)
        }
        
        // MARK: - SBUParentMessageInfoViewDelegate
        open func parentMessageInfoViewBoundsDidChanged(_ view: SBUParentMessageInfoView) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.updateTopAnchorConstraint(constant: view.frame.height)
            }
        }
        
        open func parentMessageInfoViewBoundsWillChanged(_ view: SBUParentMessageInfoView) {
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.updateTopAnchorConstraint(constant: view.frame.height)
            }
        }
    }
}

// MARK: - Scroll related
extension SBUMessageThreadModule.List {
    public override var isScrollNearByBottom: Bool {
        (tableView.contentOffset.y + (tableView.visibleCells.last?.frame.height ?? 0)) >= (tableView.contentSize.height - tableView.frame.size.height) - 20
    }
    
    /// To keep track of which scrolls tableview.
    override func scrollTableView(
        to row: Int,
        at position: UITableView.ScrollPosition = .top,
        animated: Bool = false) {
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
                if row+1 == self.fullMessageList.count {
                    let indexPath = IndexPath(item: self.fullMessageList.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
                } else {
                    self.tableView.scrollToRow(
                        at: IndexPath(row: row, section: 0),
                        at: position,
                        animated: animated
                    )
                }
            } else {
                let indexPath = IndexPath(item: self.fullMessageList.count - 1, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    /// This function keeps the current scroll position with upserted messages.
    /// - Note: Only newly added messages are used for processing.
    /// - Parameter upsertedMessages: upserted messages
    override func keepCurrentScroll(for upsertedMessages: [BaseMessage]) -> IndexPath {
        let firstVisibleIndexPath = tableView
            .indexPathsForVisibleRows?.last ?? IndexPath(row: 0, section: 0)
        var nextInsertedCount = 0
        if let newestMessage = sentMessages.last {
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
    override func scrollToInitialPosition() {
        if let startingPoint = self.baseDataSource?.baseChannelModule(self, startingPointIn: self.tableView) {
            if startingPoint != 0 {
                if let index = fullMessageList.firstIndex(where: { $0.createdAt >= startingPoint }) {
                    // from quotedMessage
                    self.scrollTableView(to: index, at: .middle)
                } else {
                    // from select reply thread on parent message menu
                    self.scrollTableView(to: fullMessageList.count - 1, at: .bottom)
                }
            } else {
                // from threadInfo
                self.scrollTableView(to: 0)
            }
        } else {
            // from send message
            self.scrollTableView(to: self.fullMessageList.count - 1)
        }
    }
}

// MARK: - Voice message
extension SBUMessageThreadModule.List {
    func pauseVoicePlayer() {
        self.currentVoiceFileInfo?.isPlaying = false
        self.voicePlayer?.pause()
    }
    
    func pauseVoicePlayer(cacheKey: String) {
        if let voiceFileInfo = self.voiceFileInfos[cacheKey],
           voiceFileInfo.isPlaying == true {
            voiceFileInfo.isPlaying = false
            self.voicePlayer?.pause()
        }
    }
    
    func pauseAllVoicePlayer() {
        self.currentVoiceFileInfo?.isPlaying = false
        self.voicePlayer?.pause()
        
        for (_, value) in self.voiceFileInfos {
            value.isPlaying = false
        }
    }
    
    /// Updates voice message
    /// - Note: As a default, it's called from `baseChannelModule(_:didTapVoiceMessage:cell:forRowAt:)` delegate method.
    /// - Parameters:
    ///   - cell: The message cell
    ///   - message: message object
    ///   - indexPath: Cell's indexPath
    ///
    /// - Since: 3.4.0
    func updateVoiceMessage(_ cell: SBUBaseMessageCell, message: BaseMessage, indexPath: IndexPath) {
        guard let fileMessageCell = cell as? SBUFileMessageCell,
              let fileMessage = message as? FileMessage,
              let voiceContentView = fileMessageCell.baseFileContentView as? SBUVoiceContentView,
              SBUUtils.getFileType(by: fileMessage) == .voice else { return }

        if self.voiceFileInfos[fileMessage.cacheKey] == nil {
            voiceContentView.updateVoiceContentStatus(.loading)
        }
        
        SBUCacheManager.File.loadFile(
            urlString: fileMessage.url,
            cacheKey: fileMessage.cacheKey,
            fileName: fileMessage.name
        ) { [weak self] filePath, _ in
            if voiceContentView.status == .loading || voiceContentView.status == .none {
                voiceContentView.updateVoiceContentStatus(.prepared)
            }
            
            var voicefileInfo: SBUVoiceFileInfo?
            if self?.voiceFileInfos[fileMessage.cacheKey] == nil {
                var playtime: Double = 0
                let metaArrays = message.metaArrays(keys: [SBUConstant.voiceMessageDurationKey])
                if metaArrays.count > 0 {
                    let value = metaArrays[0].value[0]
                    playtime = Double(value) ?? 0
                }
                
                voicefileInfo = SBUVoiceFileInfo(
                    fileName: fileMessage.name,
                    filePath: filePath,
                    playtime: playtime,
                    currentPlayTime: 0
                )
                
                self?.voiceFileInfos[fileMessage.cacheKey] = voicefileInfo
            } else {
                voicefileInfo = self?.voiceFileInfos[fileMessage.cacheKey]
            }
            
            var actionInSameView = false
            if let voicefileInfo = voicefileInfo {
                if self?.currentVoiceFileInfo?.isPlaying == true {
                    // updated status of previously contentView
                    let currentPlayTime = self?.currentVoiceFileInfo?.currentPlayTime ?? 0
                    self?.currentVoiceFileInfo?.isPlaying = false
                    self?.currentVoiceContentView?.updateVoiceContentStatus(.pause, time: currentPlayTime)
                    
                    if self?.currentVoiceContentView == voiceContentView {
                        actionInSameView = true
                    }
                }
                
                self?.voicePlayer?.configure(voiceFileInfo: voicefileInfo)
            }
            
            if let voicefileInfo = voicefileInfo {
                self?.voicePlayer?.configure(voiceFileInfo: voicefileInfo)
                self?.currentVoiceContentIndexPath = indexPath
            }
            
            if self?.currentVoiceFileInfo != voicefileInfo {
                self?.pauseAllVoicePlayer()
            }
            
            self?.currentVoiceFileInfo = voicefileInfo
            self?.currentVoiceContentView = voiceContentView
            
            switch voiceContentView.status {
            case .none:
                break
            case .loading:
                break
            case .prepared:
                self?.voicePlayer?.play()
            case .playing:
                self?.voicePlayer?.pause()
            case .pause:
                if actionInSameView == true { break }

                let currentPlayTime = self?.currentVoiceFileInfo?.currentPlayTime ?? 0
                self?.voicePlayer?.play(fromTime: currentPlayTime)
            case .finishPlaying:
                self?.voicePlayer?.play()
            }
        }
    }
    
    func updateParentInfoVoiceMessage(_ fileMessage: FileMessage) {
        guard let voiceContentView = self.parentMessageInfoView.baseFileContentView as? SBUVoiceContentView,
              SBUUtils.getFileType(by: fileMessage) == .voice else { return }
        
        SBUCacheManager.File.loadFile(
            urlString: fileMessage.url,
            cacheKey: fileMessage.cacheKey,
            fileName: fileMessage.name
        ) { [weak self] filePath, _ in
            if voiceContentView.status == .loading || voiceContentView.status == .none {
                voiceContentView.updateVoiceContentStatus(.prepared)
            }
            
            var voicefileInfo: SBUVoiceFileInfo?
            if self?.voiceFileInfos[fileMessage.cacheKey] == nil {
                var playtime: Double = 0
                let metaArrays = fileMessage.metaArrays(keys: [SBUConstant.voiceMessageDurationKey])
                if metaArrays.count > 0 {
                    let value = metaArrays[0].value[0]
                    playtime = Double(value) ?? 0
                }
                
                voicefileInfo = SBUVoiceFileInfo(
                    fileName: fileMessage.name,
                    filePath: filePath,
                    playtime: playtime,
                    currentPlayTime: 0
                )
                
                self?.voiceFileInfos[fileMessage.cacheKey] = voicefileInfo
            } else {
                voicefileInfo = self?.voiceFileInfos[fileMessage.cacheKey]
            }
            
            var actionInSameView = false
            if let voicefileInfo = voicefileInfo {
                if self?.currentVoiceFileInfo?.isPlaying == true {
                    // updated status of previously contentView
                    let currentPlayTime = self?.currentVoiceFileInfo?.currentPlayTime ?? 0
                    self?.currentVoiceFileInfo?.isPlaying = false
                    self?.currentVoiceContentView?.updateVoiceContentStatus(.pause, time: currentPlayTime)
                    
                    if self?.currentVoiceContentView == voiceContentView {
                        actionInSameView = true
                    }
                }
                
                self?.voicePlayer?.configure(voiceFileInfo: voicefileInfo)
            }
            
            if let voicefileInfo = voicefileInfo {
                self?.voicePlayer?.configure(voiceFileInfo: voicefileInfo)
                self?.currentVoiceContentIndexPath = nil
            }
            
            if self?.currentVoiceFileInfo != voicefileInfo {
                self?.pauseAllVoicePlayer()
            }
            
            self?.currentVoiceFileInfo = voicefileInfo
            self?.currentVoiceContentView = voiceContentView
            
            switch voiceContentView.status {
            case .none:
                break
            case .loading:
                break
            case .prepared:
                self?.voicePlayer?.play()
            case .playing:
                self?.voicePlayer?.pause()
            case .pause:
                if actionInSameView == true { break }

                let currentPlayTime = self?.currentVoiceFileInfo?.currentPlayTime ?? 0
                self?.voicePlayer?.play(fromTime: currentPlayTime)
            case .finishPlaying:
                self?.voicePlayer?.play()
            }
        }
    }
    
    // MARK: - SBUVoicePlayerDelegate
    public func voicePlayerDidReceiveError(_ player: SBUVoicePlayer, errorStatus: SBUVoicePlayerErrorStatus) {}
    
    public func voicePlayerDidStart(_ player: SBUVoicePlayer) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = true
        
        var voiceContentView: SBUVoiceContentView?
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell {
            voiceContentView = cell.baseFileContentView as? SBUVoiceContentView
        } else if parentMessageInfoView.baseFileContentView == self.currentVoiceContentView {
            voiceContentView = parentMessageInfoView.baseFileContentView as? SBUVoiceContentView
        }
        
        voiceContentView?.updateVoiceContentStatus(.playing, time: currentPlayTime)
    }
    
    public func voicePlayerDidPause(_ player: SBUVoicePlayer, voiceFileInfo: SBUVoiceFileInfo?) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        var voiceContentView: SBUVoiceContentView?
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell {
            voiceContentView = cell.baseFileContentView as? SBUVoiceContentView
        } else if parentMessageInfoView.baseFileContentView == self.currentVoiceContentView {
            voiceContentView = parentMessageInfoView.baseFileContentView as? SBUVoiceContentView
        }
        
        voiceContentView?.updateVoiceContentStatus(.pause, time: currentPlayTime)
    }
    
    public func voicePlayerDidStop(_ player: SBUVoicePlayer) {
        let time = self.currentVoiceFileInfo?.playtime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        var voiceContentView: SBUVoiceContentView?
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell {
            voiceContentView = cell.baseFileContentView as? SBUVoiceContentView
        } else if parentMessageInfoView.baseFileContentView == self.currentVoiceContentView {
            voiceContentView = parentMessageInfoView.baseFileContentView as? SBUVoiceContentView
        }
        
        voiceContentView?.updateVoiceContentStatus(.finishPlaying, time: time)
    }
    
    public func voicePlayerDidReset(_ player: SBUVoicePlayer) {}
    
    public func voicePlayerDidUpdatePlayTime(_ player: SBUVoicePlayer, time: TimeInterval) {
        self.currentVoiceFileInfo?.currentPlayTime = time
        self.currentVoiceFileInfo?.isPlaying = true
        
        var voiceContentView: SBUVoiceContentView?
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell {
            voiceContentView = cell.baseFileContentView as? SBUVoiceContentView
        } else if parentMessageInfoView.baseFileContentView == self.currentVoiceContentView {
            voiceContentView = parentMessageInfoView.baseFileContentView as? SBUVoiceContentView
        }
        
        voiceContentView?.updateVoiceContentStatus(.playing, time: time)
    }
}
