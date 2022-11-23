//
//  SBUGroupChannelViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
import AVKit
import SafariServices


@objcMembers
open class SBUGroupChannelViewController: SBUBaseChannelViewController, SBUGroupChannelViewModelDelegate, SBUGroupChannelModuleHeaderDelegate, SBUGroupChannelModuleListDelegate, SBUGroupChannelModuleListDataSource, SBUGroupChannelModuleInputDelegate, SBUGroupChannelModuleInputDataSource, SBUGroupChannelViewModelDataSource, SBUMentionManagerDataSource, SBUMessageThreadViewControllerDelegate {

    // MARK: - UI properties (Public)
    public var headerComponent: SBUGroupChannelModule.Header? {
        get { self.baseHeaderComponent as? SBUGroupChannelModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUGroupChannelModule.List? {
        get { self.baseListComponent as? SBUGroupChannelModule.List }
        set { self.baseListComponent = newValue }
    }
    public var inputComponent: SBUGroupChannelModule.Input? {
        get { self.baseInputComponent as? SBUGroupChannelModule.Input }
        set { self.baseInputComponent = newValue }
    }
    
    public var highlightInfo: SBUHighlightMessageInfo?
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUGroupChannelViewModel? {
        get { self.baseViewModel as? SBUGroupChannelViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public override var channel: GroupChannel? { self.viewModel?.channel as? GroupChannel }
    
    public private(set) var newMessagesCount: Int = 0
    
    
    // MARK: - Logic properties (Private)
    
    
    // MARK: - Lifecycle
    
    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = MessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeThreadInfo = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `MessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    /// - Since: 1.0.11
    required public init(channel: GroupChannel, messageListParams: MessageListParams? = nil) {
        super.init(baseChannel: channel, messageListParams: messageListParams)
        
        self.headerComponent = SBUModuleSet.groupChannelModule.headerComponent
        self.listComponent = SBUModuleSet.groupChannelModule.listComponent
        self.inputComponent = SBUModuleSet.groupChannelModule.inputComponent
    }
    
    required public init(
        channelURL: String,
        startingPoint: Int64? = nil,
        messageListParams: MessageListParams? = nil
    ) {
        super.init(
            channelURL: channelURL,
            startingPoint: startingPoint,
            messageListParams: messageListParams
        )
        
        self.headerComponent = SBUModuleSet.groupChannelModule.headerComponent
        self.listComponent = SBUModuleSet.groupChannelModule.listComponent
        self.inputComponent = SBUModuleSet.groupChannelModule.inputComponent
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        SBULog.info("")
    }
    
    
    // MARK: - ViewModel
    open override func createViewModel(
        channel: BaseChannel? = nil,
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        showIndicator: Bool = true
    ) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.baseViewModel = SBUGroupChannelViewModel(
            channel: channel,
            channelURL: channelURL,
            messageListParams: messageListParams,
            startingPoint: startingPoint,
            delegate: self,
            dataSource: self
        )
        
        if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
            messageInputView.setMode(.none)
        }
    }
    
    
    // MARK: - Sendbird UIKit Life cycle
    open override func setupViews() {
        super.setupViews()
        
        self.headerComponent?
            .configure(delegate: self, theme: self.theme)
        self.listComponent?
            .configure(delegate: self, dataSource: self, theme: self.theme)
        self.inputComponent?
            .configure(delegate: self, dataSource: self, mentionManagerDataSource: self, theme: self.theme)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()

        self.listComponent?.translatesAutoresizingMaskIntoConstraints = false
        if let listComponent = listComponent {
            self.tableViewTopConstraint = listComponent.topAnchor.constraint(
                equalTo: self.view.topAnchor,
                constant: 0
            )
            
            NSLayoutConstraint.activate([
                self.tableViewTopConstraint,
                listComponent.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
                listComponent.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
                listComponent.bottomAnchor.constraint(
                    equalTo: self.inputComponent?.topAnchor ?? self.view.bottomAnchor,
                    constant: 0
                )
            ])
        }
        
        self.inputComponent?.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputViewBottomConstraint = self.inputComponent?.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: 0
        )
        if let inputComponent = self.inputComponent {
            NSLayoutConstraint.activate([
                inputComponent.topAnchor.constraint(
                    equalTo: self.listComponent?.bottomAnchor ?? self.view.bottomAnchor,
                    constant: 0
                ),
                inputComponent.leftAnchor.constraint(
                    equalTo: self.view.leftAnchor,
                    constant: 0
                ),
                inputComponent.rightAnchor.constraint(
                    equalTo: self.view.rightAnchor,
                    constant: 0
                ),
                messageInputViewBottomConstraint
            ])
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
    }
    
    open override func updateStyles() {
        self.setupStyles()
        super.updateStyles()
        
        self.headerComponent?.updateStyles(theme: self.theme)
        self.listComponent?.updateStyles(theme: self.theme)
        
        self.listComponent?.reloadTableView()
    }


    // MARK: - New message count

    /// This function increases the new message count.
    @discardableResult
    public override func increaseNewMessageCount() -> Bool {
        guard let viewModel = viewModel else { return false }
        guard !baseChannelViewModel(viewModel, isScrollNearBottomInChannel: viewModel.channel) else { return false }
        
        guard super.increaseNewMessageCount() else { return false }
        
        self.updateNewMessageInfo(hidden: false)
        self.newMessagesCount += 1
        
        if let newMessageInfoView = self.listComponent?.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.updateCount(count: self.newMessagesCount) { [weak self] in
                guard let self = self else { return }
                guard let listComponent = self.listComponent else { return }
                self.baseChannelModuleDidTapScrollToButton(listComponent, animated: true)
            }
        }
        return true
    }
    
    // MARK: - Message: Menu
    
    @available(*, deprecated, message: "Please use `calculateMessageMenuCGPoint(indexPath:position:)` in `SBUGroupChannelModule.List`") // 3.1.2
    /// Calculates the `CGPoint` value that indicates where to draw the message menu in the group channel screen.
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - position: Message position
    /// - Returns: `CGPoint` value
    /// - Since: 1.2.5
    public func calculatorMenuPoint(
        indexPath: IndexPath,
        position: MessagePosition
    ) -> CGPoint {
        guard let listComponent = listComponent else {
            SBULog.error("listComponent is not set up.")
            return .zero
        }
        
        return listComponent.calculateMessageMenuCGPoint(indexPath: indexPath, position: position)
    }
    
    @available(*, deprecated, message: "Please use `showMessageContextMenu(message:cell:forRowAt:)` in `SBUGroupChannelModule.List`") // 3.1.2
    open override func showMenuModal(_ cell: UITableViewCell, indexPath: IndexPath, message: BaseMessage) {
        self.listComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    @available(*, deprecated, message: "Please use `showMessageContextMenu(message:cell:forRowAt:)` in `SBUGroupChannelModule.List`") // 3.1.2
    public override func showMenuModal(_ cell: UITableViewCell,
                                       indexPath: IndexPath,
                                       message: BaseMessage,
                                       types: [MessageMenuItem]?) {
        self.listComponent?.showMessageContextMenu(for: message, cell: cell, forRowAt: indexPath)
    }
    
    open override func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        let channelSettingsVC = SBUViewControllerSet.GroupChannelSettingsViewController.init(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    open override func showMessageThread(channelURL: String, parentMessageId: Int64, parentMessageCreatedAt: Int64? = 0, startingPoint: Int64? = 0) {
        if (parentMessageCreatedAt ?? 0) < (self.channel?.joinedAt ?? 0) * 1000 {
            SBULog.warning(SBUStringSet.Message_Reply_Cannot_Found_Original)
            return
        }
        
        var parentMessage: BaseMessage? = nil
        if let fullMessageList = self.viewModel?.fullMessageList {
            parentMessage = fullMessageList.filter { $0.messageId == parentMessageId }.first
        }
           
        
        let messageThreadVC = SBUViewControllerSet.MessageThreadViewController.init(
            channelURL: channelURL,
            parentMessage: parentMessage,
            parentMessageId: parentMessageId,
            delegate: self,
            startingPoint: startingPoint
        )
        self.navigationController?.pushViewController(messageThreadVC, animated: true)
    }
    
    
    // MARK: - SBUGroupChannelViewModelDelegate
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: BaseChannel?,
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
                if context.source == .eventReadStatusUpdated {
                    self.updateChannelStatus()
                }
                self.listComponent?.reloadTableView()
                
            case .eventTypingStatusUpdated:
                self.updateChannelStatus()
                
            case .channelChangelog:
                self.updateChannelTitle()
                self.inputComponent?.updateMessageInputModeState()
                self.listComponent?.reloadTableView()
                
            case .eventChannelChanged:
                self.updateChannelTitle()
                self.inputComponent?.updateMessageInputModeState()
                
            case .eventChannelFrozen, .eventChannelUnfrozen,
                    .eventUserMuted, .eventUserUnmuted,
                    .eventOperatorUpdated,
                    .eventUserBanned: // Other User Banned
                self.inputComponent?.updateMessageInputModeState()
                
            default: break
        }
    }
    
    open func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didReceiveSuggestedMentions members: [SBUUser]?)
    {
        let members = members ?? []
        self.inputComponent?.handlePendingMentionSuggestion(with: members)
    }
    
    // MARK: - SBUGroupChannelModuleHeaderDelegate
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem) {
        self.onClickBack()
    }
    
    open override func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {
        self.showChannelSettings()
    }
    
    // MARK: - SBUGroupChannelModuleListDelegate
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell) {
        guard let currentUser = SBUGlobals.currentUser,
              let message = messageCell.message else { return }
        
        let shouldSelect = message.reactions.first { $0.key == emojiKey }?
            .userIds.contains(currentUser.userId) == false
        self.viewModel?.setReaction(message: message, emojiKey: emojiKey, didSelect: shouldSelect)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didLongTapEmoji emojiKey: String, messageCell: SBUBaseMessageCell) {
        guard let channel = self.channel,
              let message = messageCell.message else { return }
        
        let reaction = message.reactions.first { $0.key == emojiKey }
        let reactionsVC = SBUReactionsViewController(
            channel: channel,
            message: message,
            selectedReaction: reaction
        )
        reactionsVC.modalPresentationStyle = UIModalPresentationStyle.custom
        reactionsVC.transitioningDelegate = self
        self.present(reactionsVC, animated: true)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMoreEmojiForCell messageCell: SBUBaseMessageCell) {
        self.dismissKeyboard()
        
        guard let message = messageCell.message else { return }
        self.showEmojiListModal(message: message)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapQuotedMessageView quotedMessageView: SBUQuotedBaseMessageView) {
        if SBUGlobals.reply.threadReplySelectType == .thread {
            if let channelURL = self.baseViewModel?.channelURL {
                self.showMessageThread(
                    channelURL: channelURL,
                    parentMessageId: quotedMessageView.messageId,
                    parentMessageCreatedAt: quotedMessageView.params?.quotedMessageCreatedAt,
                    startingPoint: quotedMessageView.params?.messageCreatedAt
                )
            }
            return
        }
        
        if (quotedMessageView.params?.quotedMessageCreatedAt ?? 0) < (self.channel?.joinedAt ?? 0) * 1000 {
            SBULog.warning(SBUStringSet.Message_Reply_Cannot_Found_Original)
            return
        }
        
        guard let row = self.baseViewModel?.fullMessageList.firstIndex(
            where: { $0.messageId == quotedMessageView.messageId }
        ) else {
            SBULog.info("There is no cached linked message. Reloads messages based on linked messages.")
            self.viewModel?.loadInitialMessages(
                startingPoint: quotedMessageView.params?.quotedMessageCreatedAt,
                showIndicator: true,
                initialMessages: nil
            )
            return
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        
        self.listComponent?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
        guard let cell = self.listComponent?.tableView.cellForRow(at: indexPath) as? SBUBaseMessageCell else {
            SBULog.error("The cell for row at \(indexPath) is not `SBUBaseMessageCell`")
            return
        }
        cell.messageContentView.animate(.shakeUpDown)
    }
    
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, didTapMentionUser user: SBUUser) {
        self.dismissKeyboard()
        
        if let userProfileView = self.baseListComponent?.userProfileView as? SBUUserProfileView,
           let baseView = self.navigationController?.view,
           SBUGlobals.isUserProfileEnabled
        {
            userProfileView.show(
                baseView: baseView,
                user: user
            )
        }
    }
    
    open func groupChannelModuleDidTapThreadInfoView(_ threadInfoView: SBUThreadInfoView) {
        guard let message = threadInfoView.message,
              let channelURL = self.channel?.channelURL else { return }
        
        // If it is the parent message itself, use `messageId` rather than `parentMessageId`.
        self.showMessageThread(
            channelURL: channelURL,
            parentMessageId: message.messageId,
            parentMessageCreatedAt: message.createdAt
        )
    }
    
    open override func baseChannelModuleDidTapScrollToButton(_ listComponent: SBUBaseChannelModule.List, animated: Bool) {
        guard self.baseViewModel?.fullMessageList.isEmpty == false else { return }
        self.newMessagesCount = 0
        
        super.baseChannelModuleDidTapScrollToButton(listComponent, animated: animated)
    }
    
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didScroll scrollView: UIScrollView) {
        super.baseChannelModule(listComponent, didScroll: scrollView)
        
        self.lastSeenIndexPath = nil
        
        if listComponent.isScrollNearByBottom {
            self.newMessagesCount = 0
            self.updateNewMessageInfo(hidden: true)
        }
    }
    
    // MARK: - SBUGroupChannelModuleListDataSource
    open func groupChannelModule(_ listComponent: SBUGroupChannelModule.List, highlightInfoInTableView tableView: UITableView) -> SBUHighlightMessageInfo? {

        guard self.viewModel?.isInitialLoading == false else { return nil }
        
        return self.highlightInfo
    }
    
    
    // MARK: - SBUGroupChannelModuleInputDelegate
    open override func baseChannelModule(_ inputComponent: SBUBaseChannelModule.Input, didUpdateFrozenState isFrozen: Bool) {
        self.listComponent?.channelStateBanner?.isHidden = !isFrozen
    }
    
    open func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, didPickFileData fileData: Data?, fileName: String, mimeType: String, parentMessage: BaseMessage?) {
        self.viewModel?.sendFileMessage(
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parentMessage: parentMessage
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapSend text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String],
        parentMessage: BaseMessage?
    ) {
        self.viewModel?.sendUserMessage(
            text: text,
            mentionedMessageTemplate: mentionedMessageTemplate,
            mentionedUserIds: mentionedUserIds,
            parentMessage: parentMessage
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        didTapEdit text: String,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    ) {
        guard let message = self.baseViewModel?.inEditingMessage else { return }
        self.viewModel?.updateUserMessage(
            message: message,
            text: text,
            mentionedMessageTemplate: mentionedMessageTemplate,
            mentionedUserIds: mentionedUserIds
        )
    }
    
    open func groupChannelModule(
        _ inputComponent: SBUGroupChannelModule.Input,
        willChangeMode mode: SBUMessageInputMode,
        message: BaseMessage?,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    ) { }
    
    open func groupChannelModule(_ inputComponent: SBUGroupChannelModule.Input, shouldLoadSuggestedMentions filterText: String) {
        self.viewModel?.loadSuggestedMentions(with: filterText)
    }
    
    open func groupChannelModuleShouldStopSuggestingMention(_ inputComponent: SBUGroupChannelModule.Input) {
        self.viewModel?.cancelLoadingSuggestedMentions()
    }
    
    open override func baseChannelModuleDidStartTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.startTypingMessage()
    }
    
    open override func baseChannelModuleDidEndTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.endTypingMessage()
    }
    
    
    // MARK: - SBUGroupChannelViewModelDataSource
    open func groupChannelViewModel(_ viewModel: SBUGroupChannelViewModel,
                                    startingPointIndexPathsForChannel channel: GroupChannel?) -> [IndexPath]? {
        return self.listComponent?.tableView.indexPathsForVisibleRows
    }
    
    
    // MARK: - SBUMentionManagerDataSource
    open func mentionManager(_ manager: SBUMentionManager, suggestedMentionUsersWith filterText: String) -> [SBUUser] {
        return self.viewModel?.suggestedMemberList ?? []
    }
    
    
    // MARK: - SBUMessageThreadViewControllerDelegate
    open func messageThreadViewController(
        _ viewController: SBUMessageThreadViewController,
        shouldMoveToParentMessage parentMessage: BaseMessage
    ) {
        
        guard let row = self.baseViewModel?.fullMessageList.firstIndex(
            where: { $0.messageId == parentMessage.messageId }
        ) else {
            SBULog.info("There is no cached linked message. Reloads messages based on linked messages.")
            self.viewModel?.loadInitialMessages(
                startingPoint: parentMessage.createdAt,
                showIndicator: true,
                initialMessages: self.viewModel?.fullMessageList
            )
            return
        }
        
        let indexPath = IndexPath(row: row, section: 0)
        self.listComponent?.tableView.scrollToRow(at: indexPath, at: .middle, animated: false)
    }
}
