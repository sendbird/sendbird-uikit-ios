//
//  SBUGroupChannelModule.List.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import AVFAudio

/// Event methods for the views updates and performing actions from the list component in a group channel.
public protocol SBUGroupChannelModuleListDelegate: SBUBaseChannelModuleListDelegate {
    
    /// Called when tapped quoted message view in the cell.
    /// - Parameters:
    ///   - didTapQuotedMessageView: `SBUQuotedBaseMessageView` object of the message cell.
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapQuotedMessageView quotedMessageView: SBUQuotedBaseMessageView)
    
    /// Called when tapped emoji in the cell.
    /// - Parameters:
    ///   - emojiKey: emoji key
    ///   - messageCell: Message cell object
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell)
    
    /// Called when long tapped emoji in the cell.
    /// - Parameters:
    ///   - emojiKey: emoji key
    ///   - messageCell: Message cell object
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didLongTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell)
    
    /// Called when tapped the cell to get more emoji
    /// - Parameters:
    ///   - messageCell: Message cell object
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMoreEmojiForCell messageCell: SBUBaseMessageCell)
    
    /// Called when tapped the mentioned nickname in the cell.
    /// - Parameters:
    ///    - user: The`SBUUser` object from the tapped mention.
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMentionUser user: SBUUser)
    
    /// Called when tapped the thread info in the cell
    /// - Parameter threadInfoView: The `SBUThreadInfoView` object from the tapped thread info.
    /// - Since: 3.3.0
    func groupChannelModuleDidTapThreadInfoView(_ threadInfoView: SBUThreadInfoView)
    
    /// Called when one of the suggested reply options is tapped.
    /// - Parameters:
    ///    - text: The reply text that is selected by user
    /// - Since: 3.11.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSelect suggestedReplyOptionView: SBUSuggestedReplyOptionView)
    
    /// Called when selected one of the files in the multiple file message cell.
    /// - Parameters:
    ///    - index: The index number of the selected file in `MultipleFilesMessage.files`
    ///    - multipleFilesMessageCell: ``SBUMultipleFilesMessageCell`` that contains the tapped file.
    ///    - cellIndexPath: `IndexPath` value of the ``SBUMultipleFilesMessageCell``.
    /// - Since: 3.10.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        didSelectFileAt index: Int,
        multipleFilesMessageCell: SBUMultipleFilesMessageCell,
        forRowAt cellIndexPath: IndexPath
    )
    
    /// Called when submit the form.
    /// - Parameters:
    ///   - listComponent: `SBUGroupChannelModule.List` object.
    ///   - form: `SendbirdChatSDK.Form` object.
    ///   - messageCell: Message cell object
    /// - Since: 3.16.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmit form: SendbirdChatSDK.Form, messageCell: SBUBaseMessageCell)
    
    /// Called when updated the feedback answer.
    /// - Parameters:
    ///    - answer: The answer of the feedback that is updated by user.
    ///    - messageCell: Message cell object
    /// - Since: 3.15.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didUpdate feedbackAnswer: SBUFeedbackAnswer, messageCell: SBUBaseMessageCell)
}

/// Methods to get data source for list component in a group channel.
public protocol SBUGroupChannelModuleListDataSource: SBUBaseChannelModuleListDataSource {
    /// Ask to data source to return the highlight info
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBUHightlightMessageInfo` object.
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, highlightInfoInTableView tableView: UITableView) -> SBUHighlightMessageInfo?
}

extension SBUGroupChannelModule {
    /// A module component that represent the list of ``SBUGroupChannelModule``.
    @objc(SBUGroupChannelModuleList)
    @objcMembers open class List: SBUBaseChannelModule.List, SBUVoicePlayerDelegate {

        // MARK: - UI properties (Public)
        
        /// The message cell for `AdminMessage` object. Use `register(adminMessageCell:nib:)` to update.
        public private(set) var adminMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `UserMessage` object. Use `register(userMessageCell:nib:)` to update.
        public private(set) var userMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `FileMessage` object. Use `register(fileMessageCell:nib:)` to update.
        public private(set) var fileMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `MultipleFilesMessage` object.
        /// Use `register(multipleFilesMessageCell:nib:)` to update.
        /// - Since: 3.10.0
        public private(set) var multipleFilesMessageCell: SBUBaseMessageCell?
        
        /// The message cell for `SBUTypingIndicatorMessage` object.
        /// Use `register(typingIndicatorMessageCell:nib:)` to update.
        /// - Since: 3.12.0
        public private(set) var typingIndicatorMessageCell: SBUBaseMessageCell?
        
        /// The message cell for some unknown message which is not a type of `AdminMessage` | `UserMessage` | ` FileMessage`. Use `register(unknownMessageCell:nib:)` to update.
        public private(set) var unknownMessageCell: SBUBaseMessageCell?
        
        /// The custom message cell for some `BaseMessage`. Use `register(customMessageCell:nib:)` to update.
        public private(set) var customMessageCell: SBUBaseMessageCell?
        
        /// A high light information of the message with ID and updated time.
        public var highlightInfo: SBUHighlightMessageInfo? {
            self.dataSource?.groupChannelModule(self, highlightInfoInTableView: self.tableView)
        }
        
        /// When message have highlightInfo, it is used to make sure it has been animated.
        /// - Since: 3.4.0
        public var isHighlightInfoAnimated: Bool = false
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the list component. The delegate must adopt the `SBUGroupChannelModuleListDelegate`.
        public weak var delegate: SBUGroupChannelModuleListDelegate? {
            get { self.baseDelegate as? SBUGroupChannelModuleListDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the data source of the list component. The data source must adopt the `SBUGroupChannelModuleListDataSource`.
        public weak var dataSource: SBUGroupChannelModuleListDataSource? {
            get { self.baseDataSource as? SBUGroupChannelModuleListDataSource }
            set { self.baseDataSource = newValue }
        }
        
        /// The current *group* channel object casted from `baseChannel`
        public var channel: GroupChannel? {
            self.baseChannel as? GroupChannel
        }
        
        // MARK: Private properties
        var voicePlayer: SBUVoicePlayer?
        var voiceFileInfos: [String: SBUVoiceFileInfo] = [:]
        var currentVoiceFileInfo: SBUVoiceFileInfo?
        var currentVoiceContentView: SBUVoiceContentView?
        var currentVoiceContentIndexPath: IndexPath?
        
        var shouldRedrawTypingBubble: Bool = false

        /// Configures component with parameters.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelModuleListDelegate` type listener
        ///   - dataSource: The data source that is type of `SBUGroupChannelModuleListDataSource`
        ///   - theme: `SBUChannelTheme` object
        open func configure(
            delegate: SBUGroupChannelModuleListDelegate,
            dataSource: SBUGroupChannelModuleListDataSource,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        
        open override func setupViews() {
            super.setupViews()
            
            // register cell (GroupChannel)
            if self.adminMessageCell == nil {
                self.register(adminMessageCell: SBUAdminMessageCell())
            }
            if self.userMessageCell == nil {
                self.register(userMessageCell: SBUUserMessageCell())
            }
            if self.fileMessageCell == nil {
                self.register(fileMessageCell: SBUFileMessageCell())
            }
            if self.multipleFilesMessageCell == nil {
                self.register(messageCell: SBUMultipleFilesMessageCell())
            }
            if self.typingIndicatorMessageCell == nil {
                self.register(messageCell: SBUTypingIndicatorMessageCell())
            }
            
            if self.unknownMessageCell == nil {
                self.register(unknownMessageCell: SBUUnknownMessageCell())
            }
            
            if let newMessageInfoView = self.newMessageInfoView {
                newMessageInfoView.isHidden = true
                self.addSubview(newMessageInfoView)
            }

            if let scrollBottomView = self.scrollBottomView {
                scrollBottomView.isHidden = true
                self.addSubview(scrollBottomView)
            }
            
            self.voicePlayer = SBUVoicePlayer(delegate: self)
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.channelStateBanner?
                .sbu_constraint(equalTo: self, leading: 8, trailing: -8, top: 8)
                .sbu_constraint(height: 24)
            
            (self.newMessageInfoView as? SBUNewMessageInfo)?
                .sbu_constraint(equalTo: self, bottom: 8, centerX: 0)
            
            self.scrollBottomView?
                .sbu_constraint(
                    width: SBUConstant.scrollBottomButtonSize.width,
                    height: SBUConstant.scrollBottomButtonSize.height
                )
                .sbu_constraint(equalTo: self, trailing: -16, bottom: 8)
        }
        
        /// Updates styles of the views in the list component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the list component. The theme must adopt the `SBUChannelTheme` class. The default value is `nil` to use the stored value.
        ///   - componentTheme: The object that is used as the theme of some UI component in the list component such as `scrollBottomView`. The theme must adopt the `SBUComponentTheme` class. The default value is `SBUTheme.componentTheme`
        open override func updateStyles(theme: SBUChannelTheme? = nil, componentTheme: SBUComponentTheme = SBUTheme.componentTheme) {
            super.updateStyles(theme: theme, componentTheme: componentTheme)
            
            if let scrollBottomView = self.scrollBottomView {
                setupScrollBottomViewStyle(scrollBottomView: scrollBottomView, theme: componentTheme)
            }
            
            (self.newMessageInfoView as? SBUNewMessageInfo)?.setupStyles()
            (self.emptyView as? SBUEmptyView)?.setupStyles()
        }
        
        // MARK: - Scroll View
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
        
        // MARK: - EmptyView
        
        // MARK: - Menu
        @available(*, deprecated, renamed: "calculateMessageMenuCGPoint(indexPath:position:)")
        public func calculatorMenuPoint(
            indexPath: IndexPath,
            position: MessagePosition
        ) -> CGPoint {
            self.calculateMessageMenuCGPoint(indexPath: indexPath, position: position)
        }
        
        /// Calculates the `CGPoint` value that indicates where to draw the message menu in the group channel screen.
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
            var items = super.createMessageMenuItems(for: message)
            
            switch message {
            case is UserMessage, is FileMessage, is MultipleFilesMessage:
                if SendbirdUI.config.groupChannel.channel.replyType != .none {
                    let reply = self.createReplyMenuItem(for: message)
                    items.append(reply)
                }
            default: break
            }
            
            return items
        }
        
        open override func showMessageContextMenu(for message: BaseMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            let messageMenuItems = self.createMessageMenuItems(for: message)
            guard !messageMenuItems.isEmpty else { return }
            
            guard let cell = cell as? SBUBaseMessageCell else { return }
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
            if let multipleFilesMessageCell = cell as? SBUMultipleFilesMessageCell {
                multipleFilesMessageCell.fileSelectHandler = { [weak self] _, index in
                    guard let self = self else { return }
                    self.delegate?.groupChannelModule(
                        self,
                        didSelectFileAt: index,
                        multipleFilesMessageCell: multipleFilesMessageCell,
                        forRowAt: indexPath
                    )
                }
            } else {
                cell.tapHandlerToContent = { [weak self] in
                    guard let self = self else { return }
                    self.setTapGesture(cell, message: message, indexPath: indexPath)
                }
            }
            
            cell.longPressHandlerToContent = { [weak self] in
                guard let self = self else { return }
                self.setLongTapGesture(cell, message: message, indexPath: indexPath)
            }
        }
        
        // MARK: - TableView: Cell
        
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
        
        /// Registers a custom cell as a multiple files message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///     - multipleFilesMessageCell: Customized multiple files message cell
        ///     - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(multipleFilesMessageCell: MyMultipleFilesMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        /// - Since: 3.10.0
        open func register(multipleFilesMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.multipleFilesMessageCell = multipleFilesMessageCell
            self.register(messageCell: multipleFilesMessageCell, nib: nib)
        }
        
        /// Registers a custom cell as a typing message cell based on `SBUBaseMessageCell`.
        /// - Parameters:
        ///     - typingIndicatorMessageCell: Customized typing indicator message cell
        ///     - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(typingIndicatorMessageCell: MyTypingIndicatorMessageCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        /// - Since: 3.12.0
        open func register(typingIndicatorMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.typingIndicatorMessageCell = typingIndicatorMessageCell
            self.register(messageCell: typingIndicatorMessageCell, nib: nib)
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
        open func configureCell(_ messageCell: SBUBaseMessageCell, message: BaseMessage, forRowAt indexPath: IndexPath) {
            guard let channel = self.channel else {
                SBULog.error("Channel must exist!")
                return
            }
            
            // NOTE: to disable unwanted animation while configuring cells
            UIView.setAnimationsEnabled(false)
            
            let isSameDay = self.checkSameDayAsNextMessage(
                currentIndex: indexPath.row,
                fullMessageList: fullMessageList
            )
            let receiptState = SBUUtils.getReceiptState(of: message, in: channel)
            let useReaction = SBUEmojiManager.isReactionEnabled(channel: self.channel)
            
            switch (message, messageCell) {
                    // Admin message
                case let (adminMessage, adminMessageCell) as (AdminMessage, SBUAdminMessageCell):
                    let configuration = SBUAdminMessageCellParams(
                        message: adminMessage,
                        hideDateView: isSameDay
                    )
                    adminMessageCell.configure(with: configuration)
                    self.setMessageCellAnimation(adminMessageCell, message: adminMessage, indexPath: indexPath)
                    self.setMessageCellGestures(adminMessageCell, message: adminMessage, indexPath: indexPath)
                    
                    // Unknown message
                case let (unknownMessage, unknownMessageCell) as (BaseMessage, SBUUnknownMessageCell):
                    let configuration = SBUUnknownMessageCellParams(
                        message: unknownMessage,
                        hideDateView: isSameDay,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: receiptState,
                        useReaction: useReaction,
                        joinedAt: self.channel?.joinedAt ?? 0,
                        messageOffsetTimestamp: self.channel?.messageOffsetTimestamp ?? 0
                    )
                    unknownMessageCell.configure(with: configuration)
                    self.setMessageCellAnimation(unknownMessageCell, message: unknownMessage, indexPath: indexPath)
                    self.setMessageCellGestures(unknownMessageCell, message: unknownMessage, indexPath: indexPath)
                    
                    // User message
                case let (userMessage, userMessageCell) as (UserMessage, SBUUserMessageCell):
                    let isLatestUserMessage = userMessage.messageId == fullMessageList.first(where: { $0.sender != nil })?.messageId
                    let configuration = SBUUserMessageCellParams(
                        message: userMessage,
                        hideDateView: isSameDay,
                        useMessagePosition: true,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: receiptState,
                        useReaction: useReaction,
                        withTextView: true,
                        joinedAt: self.channel?.joinedAt ?? 0,
                        messageOffsetTimestamp: self.channel?.messageOffsetTimestamp ?? 0,
                        shouldHideSuggestedReplies: !isLatestUserMessage,
                        shouldHideFormTypeMessage: false
                    )
                    configuration.shouldHideFeedback = message.myFeedbackStatus == .notApplicable
                    userMessageCell.configure(with: configuration)
                    userMessageCell.configure(highlightInfo: self.highlightInfo)
                    (userMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
                    (userMessageCell.threadInfoView as? SBUThreadInfoView)?.delegate = self

                    self.setMessageCellAnimation(userMessageCell, message: userMessage, indexPath: indexPath)
                    self.setMessageCellGestures(userMessageCell, message: userMessage, indexPath: indexPath)
                    
                    // File message
                case let (fileMessage, fileMessageCell) as (FileMessage, SBUFileMessageCell):
                    let voiceFileInfo = self.voiceFileInfos[fileMessage.cacheKey] ?? nil
                    let configuration = SBUFileMessageCellParams(
                        message: fileMessage,
                        hideDateView: isSameDay,
                        useMessagePosition: true,
                        groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                        receiptState: receiptState,
                        useReaction: useReaction,
                        joinedAt: self.channel?.joinedAt ?? 0,
                        messageOffsetTimestamp: self.channel?.messageOffsetTimestamp ?? 0,
                        voiceFileInfo: voiceFileInfo
                    )
                    configuration.shouldHideFeedback = message.myFeedbackStatus == .notApplicable
                    
                    if voiceFileInfo != nil {
                        self.currentVoiceFileInfo = nil
                        self.currentVoiceContentView = nil
                    }
                    
                    fileMessageCell.configure(with: configuration)
                    fileMessageCell.configure(highlightInfo: self.highlightInfo)
                    (fileMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
                    (fileMessageCell.threadInfoView as? SBUThreadInfoView)?.delegate = self
                    self.setMessageCellAnimation(fileMessageCell, message: fileMessage, indexPath: indexPath)
                    self.setMessageCellGestures(fileMessageCell, message: fileMessage, indexPath: indexPath)
                    self.setFileMessageCellImage(fileMessageCell, fileMessage: fileMessage)
                    
                    if let voiceFileInfo = voiceFileInfo,
                       voiceFileInfo.isPlaying == true,
                       let voiceContentView = fileMessageCell.baseFileContentView as? SBUVoiceContentView {
                        
                        self.currentVoiceContentIndexPath = indexPath
                        self.currentVoiceFileInfo = voiceFileInfo
                        self.currentVoiceContentView = voiceContentView
                    }
                    
                case let (multipleFilesMessage, multipleFilesMessageCell) as (MultipleFilesMessage, SBUMultipleFilesMessageCell):
                    let configuration = SBUMultipleFilesMessageCellParams(
                        message: multipleFilesMessage,
                        hideDateView: isSameDay,
                        useMessagePosition: true,
                        receiptState: receiptState,
                        useReaction: true
                    )
                    configuration.shouldHideFeedback = message.myFeedbackStatus == .notApplicable
                    multipleFilesMessageCell.configure(with: configuration)
                    (multipleFilesMessageCell.quotedMessageView as? SBUQuotedBaseMessageView)?.delegate = self
                    self.setMessageCellAnimation(multipleFilesMessageCell, message: multipleFilesMessage, indexPath: indexPath)
                    self.setMessageCellGestures(multipleFilesMessageCell, message: multipleFilesMessage, indexPath: indexPath)
                    (multipleFilesMessageCell.threadInfoView as? SBUThreadInfoView)?.delegate = self
                
                case let (typingMessage, typingMessageCell) as (SBUTypingIndicatorMessage, SBUTypingIndicatorMessageCell):
                    
                    let configuration = SBUTypingIndicatorMessageCellParams(
                        message: typingMessage,
                        shouldRedrawTypingBubble: self.shouldRedrawTypingBubble
                    )
                    typingMessageCell.configure(with: configuration)
                    
                default:
                    let configuration = SBUBaseMessageCellParams(
                        message: message,
                        hideDateView: isSameDay,
                        messagePosition: .center,
                        groupPosition: .none,
                        receiptState: receiptState,
                        joinedAt: self.channel?.joinedAt ?? 0,
                        messageOffsetTimestamp: self.channel?.messageOffsetTimestamp ?? 0
                    )
                    messageCell.configure(with: configuration)
            }
            
            UIView.setAnimationsEnabled(true)
            
            // TODO: Move to `setMessageCellGestures`?
            messageCell.userProfileTapHandler = { [weak messageCell, weak self] in
                guard let self = self else { return }
                guard let cell = messageCell else { return }
                guard let sender = cell.message?.sender else { return }
                self.setUserProfileTapGesture(SBUUser(sender: sender))
            }
            
            // Reaction action
            messageCell.emojiTapHandler = { [weak messageCell, weak self] emojiKey in
                guard let self = self else { return }
                guard let cell = messageCell else { return }
                self.delegate?.groupChannelModule(self, didTapEmoji: emojiKey, messageCell: cell)
            }
            
            messageCell.emojiLongPressHandler = { [weak messageCell, weak self] emojiKey in
                guard let self = self else { return }
                guard let cell = messageCell else { return }
                self.delegate?.groupChannelModule(self, didLongTapEmoji: emojiKey, messageCell: cell)
            }
            
            messageCell.moreEmojiTapHandler = { [weak messageCell, weak self] in
                guard let self = self else { return }
                guard let cell = messageCell else { return }
                self.delegate?.groupChannelModule(self, didTapMoreEmojiForCell: cell)
            }
            
            messageCell.mentionTapHandler = { [weak self] user in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didTapMentionUser: user)
            }
            
            messageCell.suggestedReplySelectHandler = { [weak self] optionView in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didSelect: optionView)
            }
            
            messageCell.submitFormHandler = { [weak self] form, cell in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didSubmit: form, messageCell: cell)
            }
            
            messageCell.updateFeedbackHandler = { [weak self] answer, cell in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didUpdate: answer, messageCell: cell)
            }
        }
        
        open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard indexPath.row < self.fullMessageList.count else {
                SBULog.error("The index is out of range.")
                return .init()
            }
            
            let message = fullMessageList[indexPath.row]
            
            let cell = tableView.dequeueReusableCell(withIdentifier: self.generateCellIdentifier(by: message)) ?? UITableViewCell()
            cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
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
        
        /// Generates identifier of message cell.
        /// - Parameter message: Message object
        /// - Returns: The identifier of message cell.
        open func generateCellIdentifier(by message: BaseMessage) -> String {
            switch message {
                case is SBUTypingIndicatorMessage:
                    return typingIndicatorMessageCell?.sbu_className ?? SBUTypingIndicatorMessageCell.sbu_className
                case is MultipleFilesMessage:
                    return multipleFilesMessageCell?.sbu_className ?? SBUMultipleFilesMessageCell.sbu_className
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
        
        /// Sets animation in message cell.
        /// - Parameters:
        ///   - cell: The message cell
        ///   - message: message object
        ///   - indexPath: Cell's indexPath
        open func setMessageCellAnimation(_ messageCell: SBUBaseMessageCell, message: BaseMessage, indexPath: IndexPath) {
            if message.messageId == highlightInfo?.messageId,
               message.updatedAt == highlightInfo?.updatedAt,
               self.highlightInfo?.animated == true,
               self.isHighlightInfoAnimated == false {
                self.cellAnimationDebouncer.add {
                    messageCell.messageContentView.animate(.shakeUpDown)
                    self.isHighlightInfoAnimated = true
                }
            }
        }
        
        /// Checks if a typing bubble is already displayed on screen.
        /// - returns: `true` if a SBUTypingIndicatorMessageCell was not previoulsy being displayed on screen, `false` if a SBUTypingIndicatorMessageCell was already being displayed.
        /// - Since: 3.12.0
        func decideToRedrawTypingBubble() -> Bool {
            for cell in tableView.visibleCells {
                if cell is SBUTypingIndicatorMessageCell {
                    return false
                }
            }
            return true
        }
        
        // MARK: - Menu
        
    }
}

extension SBUGroupChannelModule.List: SBUQuotedMessageViewDelegate {
    open func didTapQuotedMessageView(_ quotedMessageView: SBUQuotedBaseMessageView) {
        self.delegate?.groupChannelModule(self, didTapQuotedMessageView: quotedMessageView)
    }
}

extension SBUGroupChannelModule.List: SBUThreadInfoViewDelegate {
    open func threadInfoViewDidTap(_ threadInfoView: SBUThreadInfoView) {
        self.delegate?.groupChannelModuleDidTapThreadInfoView(threadInfoView)
    }
}

// MARK: - Voice message
extension SBUGroupChannelModule.List {
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
    ///
    /// - Note: As a default, it's called from `baseChannelModule(_:didTapVoiceMessage:cell:forRowAt:)` delegate method.
    ///
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

            var playtime: Double = 0
            let metaArrays = message.metaArrays(keys: [SBUConstant.voiceMessageDurationKey])
            if metaArrays.count > 0 {
                let value = metaArrays[0].value[0]
                playtime = Double(value) ?? 0
            }
            
            guard let filePath = filePath else {
                self?.pauseAllVoicePlayer()
                voiceContentView.updateVoiceContentStatus(.none, time: playtime)
                return
            }
            if voiceContentView.status == .loading || voiceContentView.status == .none {
                voiceContentView.updateVoiceContentStatus(.prepared)
            }
            
            var voicefileInfo: SBUVoiceFileInfo?
            if self?.voiceFileInfos[fileMessage.cacheKey] == nil {
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
    
    // MARK: - SBUVoicePlayerDelegate
    public func voicePlayerDidReceiveError(_ player: SBUVoicePlayer, errorStatus: SBUVoicePlayerErrorStatus) {}
    
    public func voicePlayerDidStart(_ player: SBUVoicePlayer) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = true
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.playing, time: currentPlayTime)
        }
    }
    
    public func voicePlayerDidPause(_ player: SBUVoicePlayer, voiceFileInfo: SBUVoiceFileInfo?) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.pause, time: currentPlayTime)
        }
    }
    
    public func voicePlayerDidStop(_ player: SBUVoicePlayer) {
        let time = self.currentVoiceFileInfo?.playtime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.finishPlaying, time: time)
        }
    }
    
    public func voicePlayerDidReset(_ player: SBUVoicePlayer) {}
    
    public func voicePlayerDidUpdatePlayTime(_ player: SBUVoicePlayer, time: TimeInterval) {
        self.currentVoiceFileInfo?.currentPlayTime = time
        self.currentVoiceFileInfo?.isPlaying = true
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.playing, time: time)
        }
    }
}
