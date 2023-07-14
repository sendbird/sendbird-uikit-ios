//
//  SBUMessageThreadViewController.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
import Photos
import AVKit
import SafariServices

public protocol SBUMessageThreadViewControllerDelegate: AnyObject {
    /// Called when `SBUThreadInfoView` was tapped.
    /// - Parameter threadInfoView: The tapped thread info view.
    
    /// Called when need to move to parent message.
    /// - Parameters:
    ///   - viewController: `SBUMessageThreadViewController` object
    ///   - parentMessage: parent message object
    func messageThreadViewController(
        _ viewController: SBUMessageThreadViewController,
        shouldMoveToParentMessage parentMessage: BaseMessage
    )
    
    /// Called when need to sync voice file informations.
    /// - Parameters:
    ///   - viewController: `SBUMessageThreadViewController` object
    ///   - voiceFileInfos: VoiceFileInfos dictionary
    /// - Since: 3.4.0
    func messageThreadViewController(
        _ viewController: SBUMessageThreadViewController,
        shouldSyncVoiceFileInfos voiceFileInfos: [String: SBUVoiceFileInfo]?
    )
}

@objcMembers
open class SBUMessageThreadViewController: SBUBaseChannelViewController, SBUMessageThreadViewModelDelegate, SBUMessageThreadViewModelDataSource, SBUMessageThreadModuleHeaderDelegate, SBUMessageThreadModuleListDelegate, SBUMessageThreadModuleListDataSource, SBUMessageThreadModuleInputDelegate, SBUMessageThreadModuleInputDataSource, SBUMentionManagerDataSource, SBUVoiceMessageInputViewDelegate {

    // MARK: - UI properties (Public)
    public var headerComponent: SBUMessageThreadModule.Header? {
        get { self.baseHeaderComponent as? SBUMessageThreadModule.Header }
        set { self.baseHeaderComponent = newValue }
    }
    public var listComponent: SBUMessageThreadModule.List? {
        get { self.baseListComponent as? SBUMessageThreadModule.List }
        set { self.baseListComponent = newValue }
    }
    public var inputComponent: SBUMessageThreadModule.Input? {
        get { self.baseInputComponent as? SBUMessageThreadModule.Input }
        set { self.baseInputComponent = newValue }
    }
    /// The input view that is used to record voice message
    public var voiceMessageInputView = SBUVoiceMessageInputView()
    
    // MARK: - Logic properties (Public)
    public var viewModel: SBUMessageThreadViewModel? {
        get { self.baseViewModel as? SBUMessageThreadViewModel }
        set { self.baseViewModel = newValue }
    }
    
    public weak var delegate: SBUMessageThreadViewControllerDelegate?
    
    public override var channel: GroupChannel? { self.viewModel?.channel as? GroupChannel }
    public var parentMessage: BaseMessage? { self.viewModel?.parentMessage }
    
    // MARK: - Logic properties (Private)
    var voiceFileInfos: [String: SBUVoiceFileInfo]?
    
    // MARK: - Lifecycle
    @available(*, unavailable)
    required public init(channelURL: String, startingPoint: Int64? = nil, messageListParams: MessageListParams? = nil) {
        fatalError("init(channelURL:startingPoint:messageListParams:) has not been implemented")
    }
    
    /// If you have channel object, use this initialize function.
    /// - Parameters:
    ///   - channel: Channel object
    ///   - channelURL: ChannelURL object
    ///   - parentMessage: Parent message object
    ///   - parentMessageId: Parent message Id
    ///   - delegate: The object that acts as the delegate of the view controller. The delegate must adopt the `SBUMessageThreadViewControllerDelegate` protocol.
    ///   - threadedMessageListParams: Thread message list params
    ///   - startingPoint: If you want to expose the most recent messages first, use the `.max` value and the last message first, use the `0`.  (default is `.max`).
    ///   - voiceFileInfos: If you have voiceFileInfos, set this value. so the default value of Voice Messages are applied based on the voiceFileInfos.
    ///
    /// - 3Cases of starting point
    ///   - `starting point -> 0`
    ///     - Click thread info in Parent message:
    ///   - `starting point -> timestamp of a specific thread message
    ///     - Click parent info of a specific thread message in channel:
    ///   - `starting point -> .max`
    ///     - Long-tap on the parent message and select the thread addition menu:
    required public init(channel: GroupChannel? = nil,
                         channelURL: String? = nil,
                         parentMessage: BaseMessage? = nil,
                         parentMessageId: Int64? = nil,
                         delegate: SBUMessageThreadViewControllerDelegate? = nil,
                         threadedMessageListParams: ThreadedMessageListParams? = nil,
                         startingPoint: Int64? = .max,
                         voiceFileInfos: [String: SBUVoiceFileInfo]? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info(#function)
        
        self.delegate = delegate
        
        self.voiceFileInfos = voiceFileInfos

        self.createViewModel(
            channel: channel,
            channelURL: channelURL,
            parentMessage: parentMessage,
            parentMessageId: parentMessageId,
            threadedMessageListParams: threadedMessageListParams,
            startingPoint: startingPoint
        )
        
        self.headerComponent = SBUModuleSet.messageThreadModule.headerComponent
        self.listComponent = SBUModuleSet.messageThreadModule.listComponent
        self.inputComponent = SBUModuleSet.messageThreadModule.inputComponent
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        theme.statusBarStyle
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
        
        self.listComponent?.pauseAllVoicePlayer()
        
        self.delegate?.messageThreadViewController(
            self,
            shouldSyncVoiceFileInfos: self.listComponent?.voiceFileInfos
        )
    }
    
    open override func applicationWillResignActivity() {
        self.resetVoiceMessageInput(for: true)
        self.dismissVoiceMessageInput()
        self.listComponent?.pauseAllVoicePlayer()
    }
    
    open override func willPresentSubview() {
        self.listComponent?.pauseAllVoicePlayer()
    }
    
    deinit {
        SBULog.info("")
    }
    
    // MARK: - ViewModel
    /// Creates view model.
    /// - Parameters:
    ///   - channel: Specifies the channel object. (Default: `nil`)
    ///   - channelURL: Specifies the channel URL value. (Default: `nil`)
    ///   - parentMessage: Specifies the parent message object. (Default: `nil`)
    ///   - parentMessageId: Specifies the parent message Id value. (Default: `nil`)
    ///   - threadedMessageListParams: Specifies the threadedMessage list params object. (Default: `nil`)
    ///   - startingPoint: Specifies the startingPoint value. (Default: `nil`)
    open func createViewModel(channel: BaseChannel? = nil,
                              channelURL: String? = nil,
                              parentMessage: BaseMessage? = nil,
                              parentMessageId: Int64? = nil,
                              threadedMessageListParams: ThreadedMessageListParams? = nil,
                              startingPoint: Int64? = nil) {
        guard channel != nil || channelURL != nil else {
            SBULog.error("Either the channel or the channelURL parameter must be set.")
            return
        }
        
        self.isTransformedList = false
        
        self.viewModel = SBUMessageThreadViewModel(
            channel: channel,
            channelURL: channelURL,
            parentMessage: parentMessage,
            parentMessageId: parentMessageId,
            threadedMessageListParams: threadedMessageListParams,
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

        self.headerComponent?.configure(
            delegate: self,
            parentMessage: self.parentMessage,
            theme: self.theme
        )
        
        self.listComponent?.configure(
            delegate: self,
            dataSource: self,
            theme: self.theme,
            voiceFileInfos: self.voiceFileInfos
        )
        
        self.inputComponent?.configure(
            delegate: self,
            dataSource: self,
            parentMessage: self.parentMessage,
            mentionManagerDataSource: self,
            theme: self.theme
        )
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
    
    // MARK: - Action
    public func moveToParentMessage() {
        if let parentMessage = self.parentMessage {
            self.delegate?.messageThreadViewController(self, shouldMoveToParentMessage: parentMessage)
            
            if let navigationController = self.navigationController,
                navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Common
    @discardableResult
    public override func increaseNewMessageCount() -> Bool {
        guard let tableView = self.baseListComponent?.tableView,
              tableView.contentOffset != .zero, // TODO: Check
              self.baseViewModel?.isLoadingNext == false
        else {
            self.lastSeenIndexPath = nil
            return false
        }
        
        self.lastSeenIndexPath = IndexPath(item: (self.viewModel?.fullMessageList ?? []).count - 1, section: 0)
        return true
    }
    
    // MARK: - Channel title
    /// Updates channelTitle with channel and channelName
    public override func updateChannelTitle() {
        if let titleView = self.headerComponent?.titleView as? SBUMessageThreadTitleView {
            titleView.configure(
                channel: self.viewModel?.channel,
                title: self.viewModel?.channel?.name ?? ""
            )
        }
    }
    
    // MARK: - VoiceMessageInput
    open override func showVoiceMessageInput() {
        super.showVoiceMessageInput()
        
        self.voiceMessageInputView.show(delegate: self, canvasView: self.navigationController?.view)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    open override func dismissVoiceMessageInput() {
        super.dismissVoiceMessageInput()
        
        self.voiceMessageInputView.dismiss()
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    open override func resetVoiceMessageInput(for resignActivity: Bool = false) {
        super.resetVoiceMessageInput(for: resignActivity)
        
        self.voiceMessageInputView.reset(for: resignActivity)
    }
    
    // MARK: - SBUMessageThreadViewModelDelegate
    open func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didReceiveSuggestedMentions members: [SBUUser]?
    ) {
        let members = members ?? []
        self.inputComponent?.handlePendingMentionSuggestion(with: members)
    }
    
    open func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didLoadParentMessage parentMessage: BaseMessage?
    ) {
        self.inputComponent?.parentMessage = parentMessage
        self.inputComponent?.updatePlaceholder()
  
        self.listComponent?.updateParentInfoView(parentMessage: parentMessage)
    }
    
    public func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didUpdateParentMessage parentMessage: BaseMessage?
    ) {
        self.inputComponent?.parentMessage = parentMessage
        self.inputComponent?.updatePlaceholder()
        
        self.listComponent?.updateParentInfoView(parentMessage: parentMessage)
    }
    
    open func messageThreadViewModelShouldDismissMessageThread(_ viewModel: SBUMessageThreadViewModel) {
        self.moveToParentMessage()
    }
    
    // MARK: - SBUMessageThreadModuleHeaderDelegate
    open override func baseChannelModule(
        _ headerComponent: SBUBaseChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    ) {
        self.navigationItem.titleView = titleView
    }
    
    open override func baseChannelModule(
        _ headerComponent: SBUBaseChannelModule.Header,
        didTapTitleView titleView: UIView?
    ) {
        self.moveToParentMessage()
    }
    
    open override func baseChannelModule(
        _ headerComponent: SBUBaseChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    ) {
        self.onClickBack()
    }
    
    // MARK: - SBUMessageThreadModuleListDelegate
    open func messageThreadModule(
        _ listComponent: SBUMessageThreadModule.List,
        didTapEmoji emojiKey: String,
        messageCell: SBUBaseMessageCell
    ) {
        guard let currentUser = SBUGlobals.currentUser,
              let message = messageCell.message else { return }
        
        let shouldSelect = message.reactions.first { $0.key == emojiKey }?
            .userIds.contains(currentUser.userId) == false
        self.viewModel?.setReaction(message: message, emojiKey: emojiKey, didSelect: shouldSelect)
    }
    
    open func messageThreadModule(
        _ listComponent: SBUMessageThreadModule.List,
        didLongTapEmoji emojiKey: String,
        messageCell: SBUBaseMessageCell
    ) {
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
    
    open func messageThreadModule(
        _ listComponent: SBUMessageThreadModule.List,
        didTapMoreEmojiForCell messageCell: SBUBaseMessageCell
    ) {
        self.dismissKeyboard()
        
        guard let message = messageCell.message else { return }
        self.showEmojiListModal(message: message)
    }
    
    open func messageThreadModule(
        _ listComponent: SBUMessageThreadModule.List,
        didTapMentionUser user: SBUUser
    ) {
        self.dismissKeyboard()
        
        if let userProfileView = self.baseListComponent?.userProfileView as? SBUUserProfileView,
           let baseView = self.navigationController?.view,
           SendbirdUI.config.common.isUsingDefaultUserProfileEnabled {
            userProfileView.show(
                baseView: baseView,
                user: user
            )
        }
    }
    
    // MARK: - SBUBaseChannelModuleListDelegate
    open override func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        didScroll scrollView: UIScrollView
    ) {
        super.baseChannelModule(listComponent, didScroll: scrollView)
        
        self.lastSeenIndexPath = nil
    }
    
    open override func baseChannelModule(_ listComponent: SBUBaseChannelModule.List, didTapVoiceMessage fileMessage: FileMessage, cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        super.baseChannelModule(listComponent, didTapVoiceMessage: fileMessage, cell: cell, forRowAt: indexPath)
        
        if let cell = cell as? SBUBaseMessageCell {
            self.listComponent?.updateVoiceMessage(cell, message: fileMessage, indexPath: indexPath)
        } else if indexPath.count == 0 { // Called in ParentInfoView 
            self.listComponent?.updateParentInfoVoiceMessage(fileMessage)
        }
    }
    
    open override func baseChannelModule(
        _ listComponent: SBUBaseChannelModule.List,
        willDisplay cell: UITableViewCell,
        forRowAt indexPath: IndexPath
    ) {
        guard let viewModel = self.viewModel else { return }
        guard viewModel.fullMessageList.count > 0 else { return }
        guard viewModel.isScrollToInitialPositionFinish else { return }
        
        let sentMessageList = viewModel.messageList
        let fullMessageList = viewModel.fullMessageList
        
        if indexPath.row < viewModel.defaultFetchLimit/2, viewModel.hasPrevious() {
            viewModel.loadPrevMessages(timestamp: sentMessageList.first?.createdAt)
        } else if indexPath.row >= (fullMessageList.count - viewModel.defaultFetchLimit/2),
                viewModel.hasNext() {
            viewModel.loadNextMessages()
        }
    }
    
    // MARK: - SBUMessageThreadModuleInputDelegate
    open override func baseChannelModule(
        _ inputComponent: SBUBaseChannelModule.Input,
        didUpdateFrozenState isFrozen: Bool
    ) {
        self.listComponent?.channelStateBanner?.isHidden = !isFrozen
    }
    
    open func messageThreadModule(
        _ inputComponent: SBUMessageThreadModule.Input,
        didPickFileData fileData: Data?,
        fileName: String,
        mimeType: String,
        parentMessage: BaseMessage?
    ) {
        self.viewModel?.sendFileMessage(
            fileData: fileData,
            fileName: fileName,
            mimeType: mimeType,
            parentMessage: parentMessage
        )
    }
    
    open func messageThreadModule(
        _ inputComponent: SBUMessageThreadModule.Input,
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
    
    open func messageThreadModule(
        _ inputComponent: SBUMessageThreadModule.Input,
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
    
    open func messageThreadModule(
        _ inputComponent: SBUMessageThreadModule.Input,
        willChangeMode mode: SBUMessageInputMode,
        message: BaseMessage?,
        mentionedMessageTemplate: String,
        mentionedUserIds: [String]
    ) { }
    
    open func messageThreadModule(
        _ inputComponent: SBUMessageThreadModule.Input,
        shouldLoadSuggestedMentions filterText: String
    ) {
        self.viewModel?.loadSuggestedMentions(with: filterText)
    }
    
    open func messageThreadModuleShouldStopSuggestingMention(_ inputComponent: SBUMessageThreadModule.Input) {
        self.viewModel?.cancelLoadingSuggestedMentions()
    }
    
    open func messageThreadModuleDidTapVoiceMessage(_ inputComponent: SBUMessageThreadModule.Input) {
        self.willPresentSubview()
        self.showVoiceMessageInput()
    }
    
    open override func baseChannelModuleDidStartTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.startTypingMessage()
    }
    
    open override func baseChannelModuleDidEndTyping(_ inputComponent: SBUBaseChannelModule.Input) {
        self.viewModel?.endTypingMessage()
        self.inputComponent?.dismissSuggestedMentionList()
    }
    
    // MARK: - SBUMentionManagerDataSource
    open func mentionManager(
        _ manager: SBUMentionManager,
        suggestedMentionUsersWith filterText: String
    ) -> [SBUUser] {
        return self.viewModel?.suggestedMemberList ?? []
    }
    
    // MARK: - SBUBaseChannelViewModelDelegate
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
            case .channelChangelog:
                self.updateChannelTitle()
                self.updateChannelStatus()
                self.inputComponent?.updateMessageInputModeState()
                self.listComponent?.reloadTableView()
                self.updateVoiceMessageInputMode()
                
            case .eventChannelChanged:
                self.updateChannelTitle()
                self.updateChannelStatus()
                self.inputComponent?.updateMessageInputModeState()
                self.updateVoiceMessageInputMode()
            
            case .eventUserLeft, .eventUserJoined:
                self.updateChannelTitle()
                
            case .eventChannelFrozen, .eventChannelUnfrozen,
                    .eventUserMuted, .eventUserUnmuted,
                    .eventOperatorUpdated,
                    .eventUserBanned: // Other User Banned
                self.inputComponent?.updateMessageInputModeState()
            self.updateVoiceMessageInputMode()
            break
                
            default: break
        }
    }
    
    func updateVoiceMessageInputMode() {
        let showAlertCompletionHandler: ((String) -> Void) = { title in
            self.resetVoiceMessageInput()
            
            SBUAlertView.show(
                title: title,
                confirmButtonItem: SBUAlertButtonItem(
                    title: SBUStringSet.OK,
                    completionHandler: { _ in
                        self.dismissVoiceMessageInput()
                    }
                ), cancelButtonItem: nil
            ) {
                self.dismissVoiceMessageInput()
            }
        }
        
        var title = ""
        
        // Frozen
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        let isFrozen = self.channel?.isFrozen ?? false
        if !isBroadcast, !isOperator && isFrozen, self.voiceMessageInputView.isShowing {
            title = SBUStringSet.VoiceMessage.Alert.frozen
        }
        
        let isMuted = self.channel?.myMutedState == .muted
        if (!isFrozen || (isFrozen && isOperator)), isMuted, self.voiceMessageInputView.isShowing {
            title = SBUStringSet.VoiceMessage.Alert.muted
        }

        if title.count > 0 {
            showAlertCompletionHandler(title)
        }
    }
    
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeMessageList messages: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    ) {
        var oldContentHeight: CGFloat = 0
        var oldOffsetY: CGFloat = 0
        let isLoadingPrev = self.viewModel?.isLoadingPrev
        
        if needsToReload && isLoadingPrev == true {
            oldContentHeight = self.listComponent?.tableView.contentSize.height ?? 0
            oldOffsetY = self.listComponent?.tableView.contentOffset.y ?? 0
        }

        let parentMessages = messages.filter { $0.messageId == self.viewModel?.parentMessageId }
        if let parentMessage = parentMessages.first {
            self.inputComponent?.parentMessage = parentMessage
            self.inputComponent?.updatePlaceholder()
            
            self.listComponent?.updateParentInfoView(parentMessage: parentMessage)
        } else {
            self.inputComponent?.updatePlaceholder()
            
            self.listComponent?.updateParentInfoView()
        }
        
        super.baseChannelViewModel(
            viewModel,
            didChangeMessageList: messages,
            needsToReload: needsToReload,
            initialLoad: initialLoad
        )
        
        // The message thread list does not display no messages on emptyView.
        self.listComponent?.updateEmptyView(type: .none)
        
        if needsToReload && isLoadingPrev == true {
            let newContentHeight: CGFloat = self.listComponent?.tableView.contentSize.height ?? 0
            self.listComponent?.tableView.contentOffset.y = oldOffsetY + (newContentHeight - oldContentHeight)
        }
    }
    
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        deletedMessages messages: [BaseMessage]
    ) {
        for message in messages {
            self.listComponent?.pauseVoicePlayer(cacheKey: message.cacheKey)
        }
    }
    
    open override func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didUpdateReaction reaction: ReactionEvent,
        forMessage message: BaseMessage
    ) {
        guard self.parentMessage?.messageId == message.messageId else { return }
        
        self.inputComponent?.parentMessage = message
        self.inputComponent?.updatePlaceholder()
        
        self.listComponent?.updateParentInfoView(parentMessage: message)
    }
    
    // MARK: - SBUVoiceMessageInputViewDelegate
    public func voiceMessageInputViewDidTapCacel(_ inputView: SBUVoiceMessageInputView) {
        self.dismissVoiceMessageInput()
    }
    
    public func voiceMessageInputView(_ inputView: SBUVoiceMessageInputView, didTapSend voiceFileInfo: SBUVoiceFileInfo) {
        self.dismissVoiceMessageInput()

        let parentMessage = self.parentMessage
        self.viewModel?.sendVoiceMessage(voiceFileInfo: voiceFileInfo, parentMessage: parentMessage)
    }
    
    public func voiceMessageInputView(_ inputView: SBUVoiceMessageInputView, willStartToRecord voiceFileInfo: SBUVoiceFileInfo) {
        // ...
    }
}
