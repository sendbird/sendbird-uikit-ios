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
    
    /// Called when URL link in a message cell is tapped.
    /// - Parameters:
    ///    - URL: The`URL` object from the tapped URL link.
    /// - Since: 3.32.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapURL url: URL)
    
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
    @available(*, deprecated, message: "This method is deprecated in 3.27.0.")
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmit form: SendbirdChatSDK.Form, messageCell: SBUBaseMessageCell)
    
    /// Called when submit the messageForm.
    /// - Parameters:
    ///   - listComponent: `SBUGroupChannelModule.List` object.
    ///   - messageForm: Message Form object
    ///   - messageCell: Message cell object
    /// - Since: 3.27.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didSubmitMessageForm messageForm: MessageForm, messageCell: SBUBaseMessageCell)
    
    /// Called when updated the feedback answer.
    /// - Parameters:
    ///    - answer: The answer of the feedback that is updated by user.
    ///    - messageCell: Message cell object
    /// - Since: 3.15.0
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didUpdate feedbackAnswer: SBUFeedbackAnswer, messageCell: SBUBaseMessageCell)
    
    /// Called when there’s a tap gesture on a message template that includes a web URL. e.g., `"https://www.sendbird.com"`
    /// ```swift
    /// print(action.data) // "https://www.sendbird.com"
    /// ```
    /// - Since: 3.21.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplateAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a message template that includes a URL scheme defined by Sendbird UIKit. e.g., `"sendbirduikit://delete"`
    /// ```swift
    /// print(action.data) // "sendbirduikit://delete"
    /// ```
    /// - Since: 3.21.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplatePreDefinedAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when there’s a tap gesture on a message template that includes a custom URL scheme. e.g., `"myapp://someaction"`
    /// ```swift
    /// print(action.data) // "myapp://someaction"
    /// ```
    /// - Since: 3.21.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleTemplateCustomAction action: SBUMessageTemplate.Action,
        message: BaseMessage,
        forRowAt indexPath: IndexPath
    )
    
    /// Called when a message template is not cached and needs to be downloaded.
    /// - Since: 3.21.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleUncachedTemplateKeys templateKeys: [String],
        messageCell: SBUBaseMessageCell
    )
    
    /// - Since: 3.21.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        shouldHandleUncachedTemplateImages cacheData: [String: String],
        messageCell: SBUBaseMessageCell
    )
    
    /// Called when the unreadMessageNewLine comes on-screen.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelModule.List` object.
    ///    - messageCell: The message cell that the unreadMessageNewLine belongs to.
    /// - Since: 3.32.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        didScrollToUnreadMessageNewLine messageCell: SBUBaseMessageCell
    )
    
    /// Called when the button of  unreadMessageInfoView is tapped.
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelModule.List` object.
    ///    - didTapUnreadMessageInfoView: The `SBUUnreadMessageInfoView` object.
    /// - Since: 3.32.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        didTapUnreadMessageInfoView: Bool
    )
    
    /// Called when a user selects the *mark as unread* menu item of a `message` in the `listComponent`.
    /// - Parameters:
    ///    - listComponent: A ``SBUBaseChannelModule/List`` object.
    ///    - message: The message that the selected menu item belongs to.
    /// - Since: 3.32.0
    func groupChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapMarkAsUnread message: BaseMessage)
}

/// Methods to get data source for list component in a group channel.
public protocol SBUGroupChannelModuleListDataSource: SBUBaseChannelModuleListDataSource {
    /// Ask to data source to return the highlight info
    /// - Parameters:
    ///    - listComponent: `SBUGroupChannelModule.List` object.
    ///    - tableView: `UITableView` object from list component.
    /// - Returns: `SBUHightlightMessageInfo` object.
    func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, highlightInfoInTableView tableView: UITableView) -> SBUHighlightMessageInfo?
    
    /// Ask to data source to return template load state cache.
    /// - Returns: If the result is `nil`, it means that no attempt was made to load the template.
    /// - Since: 3.29.0
    func groupChannelModule(
        _ listComponent: SBUGroupChannelModule.List,
        didHandleUncachedTemplateKeys templateKeys: [String]
    ) -> Bool?
    
    /// Ask data source to return the first unread message.
    /// - Returns: A `BaseMessage` instance if there is a first unread message, `nil` if there is none.
    /// - Since: 3.32.0
    func groupChannelModuleFirstUnreadMessage(_ listComponent: SBUGroupChannelModule.List) -> BaseMessage?
    
    /// Ask data source whether messages should be marked as read when scrolling.
    /// - Returns: `true` if messages should be marked as read on scroll, `false` otherwise.
    /// - Since: 3.32.0
    func groupChannelModuleAllowsAutoMarkAsReadOnScroll(_ listComponent: SBUGroupChannelModule.List) -> Bool
}

extension SBUGroupChannelModule {
    /// A module component that represent the list of ``SBUGroupChannelModule``.
    @objc(SBUGroupChannelModuleList)
    @objcMembers
    open class List: SBUBaseChannelModule.List, SBUVoicePlayerDelegate {

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
        
        /// The message cell for `MessageTemplate` data in `extendedMessagePayload`.
        /// Use `register(messageTemplateCell:nib:)` to update.
        /// - Since: 3.27.2
        public private(set) var messageTemplateCell: SBUMessageTemplateCell?
        
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
        
        public var voicePlayer: SBUVoicePlayer?
        
        /// The first of all unread messages in the channel.
        /// - Since: 3.32.0
        public var firstUnreadMessage: BaseMessage? {
            return self.dataSource?.groupChannelModuleFirstUnreadMessage(self)
        }
        
        /// Whether messages should be marked as read when scrolling.
        /// - Since: 3.32.0
        public var allowsAutoMarkAsReadOnScroll: Bool {
            self.dataSource?.groupChannelModuleAllowsAutoMarkAsReadOnScroll(self) ?? false
        }
        
        /// A boolean flag that shows whether a unreadMessageNewLine has been on-screen or not.
        /// - Since: 3.32.0
        public var hasSeenNewLine: Bool = false
        
        /// A boolean flag that shows whether an unread message existed in the channel before receiving new messages.
        /// - Since: 3.32.0
        public var didUnreadMessageExist: Bool = false
        
        /// A set of strings that keep track of previously on-screen newlines.
        /// It is used to detect the moment the newline goes off-screen.
        /// - Since: 3.32.0
        public var previouslyVisibleNewLines: Set<String> = []
        
        // MARK: default views
        
        override func createDefaultEmptyView() -> SBUEmptyView {
            SBUEmptyView.createDefault(Self.EmptyView, delegate: self)
        }
        
        override func createDefaultChannelStateBanner() -> SBUChannelStateBanner {
            SBUChannelStateBanner.createDefault(Self.ChannelStateBanner, isThreadMessage: false, isHidden: true)
        }
        
        override func createDefaultUserProfileView() -> SBUUserProfileView {
            SBUUserProfileView.createDefault(Self.UserProfileView, delegate: self)
        }
        
        override func createDefaultScrollBottomView() -> SBUScrollBottomView? {
            SBUScrollBottomView.createDefault(
                Self.ScrollBottomView,
                channelType: .group,
                target: self,
                action: #selector(self.onTapScrollToBottom)
            )
        }
        
        override func createDefaultNewMessageInfoView() -> SBUNewMessageInfo? {
            SBUNewMessageInfo.createDefault(Self.NewMessageInfo)
        }
        
        override func createDefaultUnreadMessageInfoView() -> SBUUnreadMessageInfoView? {
            let view = SBUUnreadMessageInfoView.createDefault(Self.UnreadMessageInfoView)
            view.actionHandler = { [weak self] in
                guard let self else { return }
                
                // vc -> vm.markAsRead()
                self.delegate?.groupChannelModule(
                    self,
                    didTapUnreadMessageInfoView: true
                )
                
                // Hide unreadMessageInfoView, newMessageInfoView.
                self.unreadMessageInfoView?.isHidden = true
                self.newMessageInfoView?.isHidden = true
                
                self.hasSeenNewLine = true
            }
            return view
        }
        
        // MARK: Private properties
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
            #if SWIFTUI
            if self.applyViewConverter(.entireContent) {
                self.voicePlayer = SBUVoicePlayer(delegate: self)
                return
            }
            #endif
            
            super.setupViews()
            
            // Register message cell types
            if self.adminMessageCell == nil {
                self.register(messageCellType: Self.AdminMessageCell)
            }
            
            if self.userMessageCell == nil {
                self.register(messageCellType: Self.UserMessageCell)
            }
            
            if self.fileMessageCell == nil {
                self.register(messageCellType: Self.FileMessageCell)
            }
            
            if self.multipleFilesMessageCell == nil {
                self.register(messageCellType: Self.MultipleFilesMessageCell)
            }
            
            if self.typingIndicatorMessageCell == nil {
                self.register(messageCellType: Self.TypingIndicatorMessageCell)
            }
            
            if self.unknownMessageCell == nil {
                self.register(messageCellType: Self.UnknownMessageCell)
            }
            
            if self.messageTemplateCell == nil {
                self.register(messageCellType: SBUMessageTemplateCell.self)
            }
            
            if let customMessageCellType = Self.CustomMessageCell {
                self.register(messageCellType: customMessageCellType)
            }
            
            // setup topStackView, channelStateBanner, unreadMessageInfoView
            let isMarkAsUnreadEnabled = SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled
            if isMarkAsUnreadEnabled {
                if self.unreadMessageInfoView == nil {
                    self.unreadMessageInfoView = self.createDefaultUnreadMessageInfoView()
                }
            }
            
            if let channelStateBanner = self.channelStateBanner {
                topStackView.addArrangedSubview(channelStateBanner)
            }
            
            if let unreadMessageInfoView = self.unreadMessageInfoView {
                topStackView.addArrangedSubview(unreadMessageInfoView)
            }
            
            self.addSubview(topStackView)
          
            if let newMessageInfoView = self.newMessageInfoView {
                newMessageInfoView.isHidden = true
                self.addSubview(newMessageInfoView)
            }
            
            if let unreadMessageInfoView = self.unreadMessageInfoView {
                unreadMessageInfoView.isHidden = true
            }

            if let scrollBottomView = self.scrollBottomView {
                scrollBottomView.isHidden = true
                self.addSubview(scrollBottomView)
            }
            
            self.voicePlayer = SBUVoicePlayer(delegate: self)
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.topStackView
                .sbu_constraint(equalTo: self, leading: 8, trailing: -8, top: 8)
            
            channelStateBanner?.sbu_constraint(height: 24)
            channelStateBanner?.sbu_constraint(equalTo: topStackView, leading: 0, trailing: 0)
            
            self.unreadMessageInfoView?.sbu_constraint(height: 38)
            
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
            
            // If markAsUnread feature is enabled,
            // handle markAsRead, markAsUnread, and unreadMessageInfoView
            // depending on whether `unreadMessageNewLine` comes on-screen or goes off-screen.
            let isMarkAsUnreadEnabled = SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled
            guard isMarkAsUnreadEnabled else { return }
            
            // Get all visible cells
            guard let tableView = scrollView as? UITableView else { return }
            let visibleCells = tableView.visibleCells
            var currentlyVisibleNewLines: Set<String> = []
            for case let messageCell as SBUBaseMessageCell in visibleCells {
                guard let newline = messageCell.unreadMessageNewLine else { return }
                
                // Detect whether the messagecell with a newline completely came on-screen.
                checkIfNewLineCameOnScreen(messageCell: messageCell, newline: newline)
                
                // Keep track of visible newlines
                currentlyVisibleNewLines = recordVisibleNewLines(messageCell: messageCell, newline: newline, currentlyVisibleNewLines: currentlyVisibleNewLines)
            }
            
            // Detect whether a newline went completely off-screen.
            checkIfNewLineWentOffScreen(currentlyVisibleNewLines: currentlyVisibleNewLines)
            
            // Update state for next scroll event
            previouslyVisibleNewLines = currentlyVisibleNewLines
        }
        
        /// If the message cell with the newline starts coming on-screen, update UI states.
        /// - Since: 3.32.0
        public func checkIfNewLineCameOnScreen(messageCell: SBUBaseMessageCell, newline: UIView) {
            let newlineInTable = newline.convert(newline.bounds, to: tableView)
            let visibleRect = tableView.bounds
            
            // Check if the message cell with the newline starts coming on-screen (intersects with visible area).
            if newline.isHidden == false, visibleRect.intersects(newlineInTable) {
                // unreadMessageNewLine is starting to come on-screen or is partially/entirely on-screen
                
                if self.allowsAutoMarkAsReadOnScroll {
                    // User has never explicitly called markAsUnread.
                    if self.hasSeenNewLine == false {
                        self.delegate?.groupChannelModule(self, didScrollToUnreadMessageNewLine: messageCell)
                        self.hasSeenNewLine = true
                    }
                } else {
                    // User has explicitly called markAsUnread.
                    // Only hide unreadMessageInfoView.
                    // Do not call markAsRead()
                    self.unreadMessageInfoView?.isHidden = true
                }
            } else {
                // unreadMessageNewLine is completely off-screen
            }
        }
        
        /// Track visible newlines for off-screen detection.
        /// - Since: 3.32.0
        public func recordVisibleNewLines(messageCell: SBUBaseMessageCell, newline: UIView, currentlyVisibleNewLines: Set<String>) -> Set<String> {
            var tempCurrentlyVisibleNewLines = currentlyVisibleNewLines
            
            // Convert the newline's bounds into the tableView’s coordinate space
            let newlineInTable = newline.convert(newline.bounds, to: tableView)
            
            // tableView.bounds is the visible area in its own coordinates
            let visibleRect = tableView.bounds
            
            let newlineKey: String
            if let message = messageCell.message {
                newlineKey = "newline_\(message.messageId)"
            } else {
                newlineKey = "newline_cell_\(messageCell.hashValue)"
            }
            
            // Check if the newline is actually visible on screen
            if !newline.isHidden && visibleRect.intersects(newlineInTable) {
                // newline is visible on screen
                tempCurrentlyVisibleNewLines.insert(newlineKey)
            }
            
            return tempCurrentlyVisibleNewLines
        }
        
        /// Detects the moment when newline goes off-screen.
        /// - Since: 3.32.0
        public func checkIfNewLineWentOffScreen(currentlyVisibleNewLines: Set<String> ) {
            // Find newlines that went off-screen
            let newlinesGoneOffScreen = previouslyVisibleNewLines.subtracting(currentlyVisibleNewLines)
            
            for newlineKey in newlinesGoneOffScreen {
                SBULog.info("Newline '\(newlineKey)' just went off-screen.")
                
                // This is the moment the newline goes off-screen.
                // If unreMessagesCount > 0, update unreadMessageInfoView to be visible.
                if let unreadMessageCount = channel?.unreadMessageCount, unreadMessageCount > 0 {
                    self.unreadMessageInfoView?.isHidden = false
                    
                    (self.unreadMessageInfoView as? SBUUnreadMessageInfoView)?.updateCount(replaceCount: unreadMessageCount)
                    
                    // Break after first detection, since we only want to handle one at a time
                    break
                }
            }
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
        
        /// Creates a markAsUnread menu item.
        /// - Parameters:
        ///   - message: The `BaseMessage` object  that corresponds to the message of the menu item to show.
        ///   - isThreadMessage: Whether it is for thread message screen or not.
        /// - Since: 3.32.0
        open override func createMarkAsUnreadMenuItem(for message: BaseMessage, isThreadMessage: Bool) -> SBUMenuItem? {
            let isMarkAsUnreadEnabled = SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled
            guard isMarkAsUnreadEnabled else { return nil }
            
            guard isThreadMessage == false else { return nil }
                
            let iconImage = SBUIconSetType.iconMarkAsUnread.image(
                with: SBUTheme.componentTheme.alertButtonColor,
                to: SBUIconSetType.Metric.iconActionSheetItem
            )
            
            let menuItem = SBUMenuItem(
                title: SBUStringSet.MarkAsUnread,
                color: self.theme?.menuTextColor,
                image: iconImage
            ) { [weak self, message] in
                guard let self = self else { return }
                // call channel.markAsUnread()
                self.delegate?.groupChannelModule(self, didTapMarkAsUnread: message)
            }
            
            return menuItem
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
                multipleFilesMessageCell.fileSelectHandler = { [weak self, weak multipleFilesMessageCell] _, index in
                    guard let self = self, let multipleFilesMessageCell else { return }
                    self.delegate?.groupChannelModule(
                        self,
                        didSelectFileAt: index,
                        multipleFilesMessageCell: multipleFilesMessageCell,
                        forRowAt: indexPath
                    )
                }
            } else {
                cell.tapHandlerToContent = { [weak self, weak cell] in
                    guard let self = self, let cell else { return }
                    self.setTapGesture(cell, message: message, indexPath: indexPath)
                }
            }
            
            cell.longPressHandlerToContent = { [weak self, weak cell] in
                guard let self = self, let cell else { return }
                self.setLongTapGesture(cell, message: message, indexPath: indexPath)
            }
        }
        
        // MARK: - TableView
        public override func reloadTableView(needsToLayout: Bool = true) {
            var didApplyTableViewConverter = false
            
            #if SWIFTUI
            didApplyTableViewConverter = self.applyViewConverter(.entireContent)
            #endif
            if !didApplyTableViewConverter {
                super.reloadTableView(needsToLayout: needsToLayout)
            }
        }
        
        // MARK: - TableView: Cell
        
        /// Registers message cell type to the message tableview.
        /// - Since: 3.31.0
        public func register(messageCellType: SBUBaseMessageCell.Type) {
            self.tableView.register(messageCellType, forCellReuseIdentifier: messageCellType.sbu_className)
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
        @available(*, deprecated, message: "This method is deprecated in 3.31.0. Use `SBUGroupChannelModule.List.AdminMessageCell` instead")
        open func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.adminMessageCell = adminMessageCell
            
            Self.AdminMessageCell = type(of: adminMessageCell)
            self.register(nib: nib, messageCell: adminMessageCell)
            self.register(messageCellType: type(of: adminMessageCell))
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
        @available(*, deprecated, message: "This method is deprecated in 3.31.0. Use `SBUGroupChannelModule.List.UserMessageCell` instead")
        open func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.userMessageCell = userMessageCell

            Self.UserMessageCell = type(of: userMessageCell)
            self.register(nib: nib, messageCell: userMessageCell)
            self.register(messageCellType: type(of: userMessageCell))
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
        @available(*, deprecated, message: "This method is deprecated in 3.31.0. Use `SBUGroupChannelModule.List.FileMessageCell` instead")
        open func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.fileMessageCell = fileMessageCell
            
            Self.FileMessageCell = type(of: fileMessageCell)
            self.register(nib: nib, messageCell: fileMessageCell)
            self.register(messageCellType: type(of: fileMessageCell))
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
        @available(*, deprecated, message: "This method is deprecated in 3.31.0. Use `SBUGroupChannelModule.List.MultipleFilesMessageCell` instead")
        open func register(multipleFilesMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.multipleFilesMessageCell = multipleFilesMessageCell
            
            Self.MultipleFilesMessageCell = type(of: multipleFilesMessageCell)
            self.register(nib: nib, messageCell: multipleFilesMessageCell)
            self.register(messageCellType: type(of: multipleFilesMessageCell))
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
        @available(*, deprecated, message: "This method is deprecated in 3.31.0. Use `SBUGroupChannelModule.List.TypingIndicatorMessageCell` instead")
        open func register(typingIndicatorMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.typingIndicatorMessageCell = typingIndicatorMessageCell
            
            Self.TypingIndicatorMessageCell = type(of: typingIndicatorMessageCell)
            self.register(nib: nib, messageCell: typingIndicatorMessageCell)
            self.register(messageCellType: type(of: typingIndicatorMessageCell))
        }
        
        /// Registers a custom cell as a message template cell based on `SBUMessageTemplateCell`.
        /// - Parameters:
        ///     - messageTemplateCell: Customized message template cell
        ///     - nib: nib information. If the value is nil, the nib file is not used.
        /// - Important: To register custom message cell, please use this function before calling `configure(delegate:dataSource:theme:)`
        /// ```swift
        /// listComponent.register(messageTemplateCell: MyMessageTemplateCell)
        /// listComponent.configure(delegate: self, dataSource: self, theme: theme)
        /// ```
        /// - Since: 3.27.2
        open func register(messageTemplateCell: SBUMessageTemplateCell, nib: UINib? = nil) {
            self.messageTemplateCell = messageTemplateCell
            
            self.register(nib: nib, messageCell: messageTemplateCell)
            self.register(messageCellType: type(of: messageTemplateCell))
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
        @available(*, deprecated, message: "Use `SBUGroupChannelModule.List.UnknownMessageCell` instead")
        open func register(unknownMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.unknownMessageCell = unknownMessageCell
            
            Self.UnknownMessageCell = type(of: unknownMessageCell)
            self.register(nib: nib, messageCell: unknownMessageCell)
            self.register(messageCellType: type(of: unknownMessageCell))
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
        @available(*, deprecated, message: "Use `SBUGroupChannelModule.List.CustomMessageCell` instead")
        open func register(customMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
            self.customMessageCell = customMessageCell
            
            Self.CustomMessageCell = type(of: customMessageCell)
            self.register(nib: nib, messageCell: customMessageCell)
            self.register(messageCellType: type(of: customMessageCell))
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
            let enableEmojiLongPress = SBUEmojiManager.isEmojiLongPressEnabled(channel: channel)
            
            messageCell.reloadCellHandler = { [weak self] cell in
                guard let self = self else { return }
                self.reloadCell(cell)
            }
            
            self.configureMessageTemplateHandlers(
                with: messageCell,
                indexPath: indexPath
            )
            
            // Update isFirstUnreadMessage only if markAsUnread feature is enabled.
            var isFirstUnreadMessage = false
            if SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled {
                if let firstUnreadMessage = self.firstUnreadMessage,
                   firstUnreadMessage.messageId == message.messageId {
                    isFirstUnreadMessage = true
                }
            }
            
            switch (message, messageCell) {
                // Admin message
            case let (adminMessage, adminMessageCell) as (AdminMessage, SBUAdminMessageCell):
                let configuration = SBUAdminMessageCellParams(
                    message: adminMessage,
                    hideDateView: isSameDay,
                    isThreadMessage: false,
                    isFirstUnreadMessage: isFirstUnreadMessage
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
                let shouldHideSuggestedReplies = SendbirdUI.config.groupChannel.channel.showSuggestedRepliesFor.shouldHideSuggestedReplies(
                    message: userMessage,
                    fullMessageList: fullMessageList
                )
                
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
                    shouldHideSuggestedReplies: shouldHideSuggestedReplies,
                    shouldHideFormTypeMessage: false,
                    enableEmojiLongPress: enableEmojiLongPress,
                    isFirstUnreadMessage: isFirstUnreadMessage
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
                    voiceFileInfo: voiceFileInfo,
                    enableEmojiLongPress: enableEmojiLongPress,
                    isFirstUnreadMessage: isFirstUnreadMessage
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
                    useReaction: true,
                    enableEmojiLongPress: enableEmojiLongPress,
                    isFirstUnreadMessage: isFirstUnreadMessage
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
                
            // message template cell
            case let (message, templateCell) as (BaseMessage, SBUMessageTemplateCell):
                let shouldHideSuggestedReplies =  
                SendbirdUI.config.groupChannel.channel.showSuggestedRepliesFor
                    .shouldHideSuggestedReplies(
                        message: message,
                        fullMessageList: fullMessageList
                    )
                
                let configuration = SBUMessageTemplateCellParams(
                    message: message,
                    hideDateView: isSameDay, // FIXED: https://sendbird.atlassian.net/browse/CLNP-6060
                    shouldHideSuggestedReplies: shouldHideSuggestedReplies
                )
                templateCell.configure(with: configuration)
                
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
            
            messageCell.urlTapHandler = { [weak self] url in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didTapURL: url)
            }
            
            messageCell.suggestedReplySelectHandler = { [weak self] optionView in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didSelect: optionView)
            }
            
            messageCell.submitMessageFormHandler = { [weak self] form, cell in
                guard let self = self else { return }
                guard let form = message.messageForm else { return }
                self.delegate?.groupChannelModule(self, didSubmitMessageForm: form, messageCell: cell)
            }
            
            messageCell.updateFeedbackHandler = { [weak self] answer, cell in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(self, didUpdate: answer, messageCell: cell)
            }
            
            messageCell.uncachedMessageTemplateImageHandler = { [weak self] cacheData, messageCell in
                guard let self = self else { return }
                self.delegate?.groupChannelModule(
                    self,
                    shouldHandleUncachedTemplateImages: cacheData,
                    messageCell: messageCell
                )
            }
            
            messageCell.errorHandler = { [weak self] error in
                guard let self = self else { return }
                self.delegate?.didReceiveError(error, isBlocker: false)
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
                  fileMessageCell.baseFileContentView is SBUVoiceContentView else { return }
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
        
        public func register(nib: UINib? = nil, messageCell: SBUBaseMessageCell) {
            if let nib = nib {
                self.tableView.register(
                    nib,
                    forCellReuseIdentifier: messageCell.sbu_className
                )
            }
        }
        
        /// Generates identifier of message cell.
        /// - Parameter message: Message object
        /// - Returns: The identifier of message cell.
        open func generateCellIdentifier(by message: BaseMessage) -> String {
            if let template = message.asMessageTemplate {
                if SBUMessageTemplate.Container.ContainerType.isValidType(with: template) == true {
                    return messageTemplateCell?.sbu_className ?? SBUMessageTemplateCell.sbu_className
                } else {
                    SBULog.warning("Invalid `extended_message_paylod.template.type` of message template")
                    return unknownMessageCell?.sbu_className ?? SBUUnknownMessageCell.sbu_className
                }
            }
            
            switch message {
            case is SBUTypingIndicatorMessage:
                return Self.TypingIndicatorMessageCell.sbu_className
            case is MultipleFilesMessage:
                return Self.MultipleFilesMessageCell.sbu_className
            case is FileMessage:
                return Self.FileMessageCell.sbu_className
            case is UserMessage:
                return Self.UserMessageCell.sbu_className
            case is AdminMessage:
                return Self.AdminMessageCell.sbu_className
            default:
                return Self.UnknownMessageCell.sbu_className
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
            for cell in tableView.visibleCells where cell is SBUTypingIndicatorMessageCell {
                return false
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
    /// This method is called when the voice player encounters an error.
    /// - Parameters:
    ///   - player: The `SBUVoicePlayer` that encountered the error.
    ///   - errorStatus: The error status of the `SBUVoicePlayer`.
    public func voicePlayerDidReceiveError(_ player: SBUVoicePlayer, errorStatus: SBUVoicePlayerErrorStatus) {}
    
    /// This method is called when the voice player starts.
    /// - Parameter player: The `SBUVoicePlayer` that started.
    public func voicePlayerDidStart(_ player: SBUVoicePlayer) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = true
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.playing, time: currentPlayTime)
        }
    }
    
    /// This method is called when the voice player is paused.
    /// - Parameters:
    ///   - player: The `SBUVoicePlayer` that is paused.
    ///   - voiceFileInfo: The `SBUVoiceFileInfo` of the voice file that is paused.
    public func voicePlayerDidPause(_ player: SBUVoicePlayer, voiceFileInfo: SBUVoiceFileInfo?) {
        let currentPlayTime = self.currentVoiceFileInfo?.currentPlayTime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.pause, time: currentPlayTime)
        }
    }
    
    /// This method is called when the voice player stops.
    /// - Parameter player: The `SBUVoicePlayer` that stopped.
    public func voicePlayerDidStop(_ player: SBUVoicePlayer) {
        let time = self.currentVoiceFileInfo?.playtime ?? 0
        self.currentVoiceFileInfo?.isPlaying = false
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.finishPlaying, time: time)
        }
    }
    
    /// This method is called when the voice player is reset.
    /// - Parameter player: The `SBUVoicePlayer` that was reset.
    public func voicePlayerDidReset(_ player: SBUVoicePlayer) {}
    
    /// This method is called when the voice player updates play time.
    /// - Parameters:
    ///   - player: The `SBUVoicePlayer` that updated the play time.
    ///   - time: The updated play time.
    public func voicePlayerDidUpdatePlayTime(_ player: SBUVoicePlayer, time: TimeInterval) {
        self.currentVoiceFileInfo?.currentPlayTime = time
        self.currentVoiceFileInfo?.isPlaying = true
        
        if let indexPath = self.currentVoiceContentIndexPath,
           let cell = self.tableView.cellForRow(at: indexPath) as? SBUFileMessageCell,
           let voiceContentView = cell.baseFileContentView as? SBUVoiceContentView {
            voiceContentView.updateVoiceContentStatus(.playing, time: time)
        }
    }
    
    /// Methods for quickly applying a text value to a stream message
    /// - Parameters:
    ///   - messageId: message id
    ///   - value: message text value
    /// - Since: 3.20.0
    public func updateStreamMessage(_ message: BaseMessage) {
        let cell = self.tableView.visibleCells
            .compactMap({ $0 as? SBUUserMessageCell })
            .first(where: { $0.message?.messageId == message.messageId })
        
        Thread.executeOnMain { [weak self, weak cell] in
            guard let cell = cell else { return }
            guard let indexPath = self?.tableView.indexPath(for: cell) else { return }
            
            self?.configureCell(cell, message: message, forRowAt: indexPath)
            
            cell.layoutIfNeeded()
            cell.invalidateIntrinsicContentSize()
        }
    }
}

extension SBUGroupChannelModule.List {
    public func configureMessageTemplateHandlers(
        with messageCell: SBUBaseMessageCell,
        indexPath: IndexPath
    ) {
        messageCell.messageTemplateActionHandler = { [weak self, indexPath] action in
            guard let self = self, let message = messageCell.message else { return }
            
            // Action Events
            switch action.type {
            case .uikit:
                self.delegate?.groupChannelModule(
                    self,
                    shouldHandleTemplatePreDefinedAction: action,
                    message: message,
                    forRowAt: indexPath
                )
            case .custom:
                self.delegate?.groupChannelModule(
                    self,
                    shouldHandleTemplateCustomAction: action,
                    message: message,
                    forRowAt: indexPath
                )
            case .web:
                self.delegate?.groupChannelModule(
                    self,
                    shouldHandleTemplateAction: action,
                    message: message,
                    forRowAt: indexPath
                )
            }
        }
        
        messageCell.uncachedMessageTemplateDownloadHandler = { [weak self] templateKeys, messageCell in
            guard let self = self else { return }
            self.delegate?.groupChannelModule(
                self,
                shouldHandleUncachedTemplateKeys: templateKeys,
                messageCell: messageCell
            )
        }
        
        messageCell.uncachedMessageTemplateStateHandler = { [weak self] keys in
            guard let self = self else { return nil }
            return self.dataSource?.groupChannelModule(self, didHandleUncachedTemplateKeys: keys) ?? nil
        }
    }
}

// - MARK: MarkAsRead
extension SBUGroupChannelModule.List {
    /// Checks to call markAsRead(), if `unreadMessageNewLine` is displayed upon entering the channel.
    /// - Since: 3.32.0
    public func checkForMarkAsRead() {
        let isMarkAsUnreadEnabled = SendbirdUI.config.groupChannel.channel.isMarkAsUnreadEnabled
        guard isMarkAsUnreadEnabled else { return }
        
        // Set initial shouldShowUnreadMessageInfoView value.
        var shouldShowUnreadMessageInfoView: Bool = false
        if let unreadCount = self.channel?.unreadMessageCount, unreadCount > 0 {
            shouldShowUnreadMessageInfoView = true
        }
        
        // Check all visible message cells.
        let visibleCells = tableView.visibleCells
        for case let messageCell as SBUBaseMessageCell in visibleCells {
            guard let newline = messageCell.unreadMessageNewLine else { return }
            
            // Convert the newline bounds into the tableView’s coordinate space
            let newlineInTable = newline.convert(newline.bounds, to: tableView)
            
            // tableView.bounds is the visible area in its own coordinates
            let visibleRect = tableView.bounds
            
            // Check for full containment
            if self.allowsAutoMarkAsReadOnScroll,
               newline.isHidden == false,
               visibleRect.contains(newlineInTable) {
                // unreadMessageNewLine is entirely on-screen.
                self.delegate?.groupChannelModule(self, didScrollToUnreadMessageNewLine: messageCell)
                
                shouldShowUnreadMessageInfoView = false
                hasSeenNewLine = true 
            } else {
                // unreadMessageNewLine is partially or completely off-screen
            }
        }

        if shouldShowUnreadMessageInfoView {
            if let unreadCount = self.channel?.unreadMessageCount, unreadCount > 0 {
                SBULog.info("Show unreadMessageInfoView")
                self.unreadMessageInfoView?.isHidden = false
                (self.unreadMessageInfoView as? SBUUnreadMessageInfoView)?.updateCount(replaceCount: unreadCount)
            }
        }
        
        // check for didUnreadMessageExist
        guard let channel = self.channel else {
            self.didUnreadMessageExist = false
            return
        }
        self.didUnreadMessageExist = channel.myLastRead < (channel.lastMessage?.createdAt ?? -1)
    }
}
