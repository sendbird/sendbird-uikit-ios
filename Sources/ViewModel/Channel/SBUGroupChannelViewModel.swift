//
//  SBUGroupChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK
import simd

public protocol SBUGroupChannelViewModelDataSource: SBUBaseChannelViewModelDataSource {
    /// Asks to data source to return the array of index path that represents starting point of channel.
    /// - Parameters:
    ///    - viewModel: `SBUGroupChannelViewModel` object.
    ///    - channel: `GroupChannel` object from `viewModel`
    /// - Returns: The array of `IndexPath` object representing starting point.
    func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        startingPointIndexPathsForChannel channel: GroupChannel?
    ) -> [IndexPath]?
}

public protocol SBUGroupChannelViewModelDelegate: SBUBaseChannelViewModelDelegate {
    /// Called when the channel has received mentional member list. Please refer to `loadSuggestedMentions(with:)` in `SBUGroupChannelViewModel`.
    /// - Parameters:
    ///   - viewModel: `SBUGroupChannelViewModel` object.
    ///   - members: Mentional members
    func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didReceiveSuggestedMentions members: [SBUUser]?
    )
    
    func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didFinishUploadingFileAt index: Int,
        multipleFilesMessageRequestId requestId: String
    )
}

open class SBUGroupChannelViewModel: SBUBaseChannelViewModel {
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUGroupChannelViewModelDelegate? {
        get { self.baseDelegate as? SBUGroupChannelViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBUGroupChannelViewModelDataSource? {
        get { self.baseDataSource as? SBUGroupChannelViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    /// A completion handler that is called after sending a multiple files message is completed.
    /// - Since: 3.10.0
    public var sendMultipleFilesMessageCompletionHandler: SendbirdChatSDK.MultipleFilesMessageHandler?
    
    // MARK: - Logic properties (private)
    var messageCollection: MessageCollection?
    var debouncer: SBUDebouncer?
    var suggestedMemberList: [SBUUser]?
    var query: MemberListQuery?

    /// (GroupChannel only) If this option is `true`, when a list is received through the local cache during initialization, it is displayed first.
    /// - Since: 3.3.5
    var displaysLocalCachedListFirst: Bool = false
    
    // MARK: - LifeCycle
    public init(channel: BaseChannel? = nil,
                channelURL: String? = nil,
                messageListParams: MessageListParams? = nil,
                startingPoint: Int64? = .max,
                delegate: SBUGroupChannelViewModelDelegate? = nil,
                dataSource: SBUGroupChannelViewModelDataSource? = nil,
                displaysLocalCachedListFirst: Bool = false) {
        super.init()
    
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.displaysLocalCachedListFirst = displaysLocalCachedListFirst
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        self.customizedMessageListParams = messageListParams
        self.startingPoint = startingPoint
        
        self.debouncer = SBUDebouncer(
            debounceTime: SBUGlobals.userMentionConfig?.debounceTime ?? SBUDebouncer.defaultTime
        )
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(
            channelURL: channelURL,
            messageListParams: self.customizedMessageListParams
        )
    }
    
    deinit {
        self.messageCollection?.dispose()
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
    }
    
    // MARK: - Channel related
    public override func loadChannel(channelURL: String,
                                     messageListParams: MessageListParams? = nil,
                                     completionHandler: ((BaseChannel?, SBError?) -> Void)? = nil) {
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else if self.customizedMessageListParams == nil {
            let messageListParams = MessageListParams()
            SBUGlobalCustomParams.messageListParamsBuilder?(messageListParams)
            self.customizedMessageListParams = messageListParams
        }
        
        // TODO: loading
//        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            SBULog.info("[Request] Load channel: \(String(channelURL))")
            GroupChannel.getChannel(url: channelURL) { [weak self] channel, error in
                guard let self = self else {
                    completionHandler?(nil, error)
                    return
                }

                guard self.canProceed(with: channel, error: error) else {
                    completionHandler?(nil, error)
                    return
                }
                
                self.channel = channel
                self.channelURL = channel?.channelURL
                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                // background refresh to check if user is banned or not.
                self.refreshChannel()

                // for updating channel information when the connection state is closed at the time of initial load.
                if SendbirdChat.getConnectState() == .closed {
                    let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                    self.delegate?.baseChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    completionHandler?(channel, nil)
                }
                
                let cachedMessages = self.flushCache(with: [])
                self.loadInitialMessages(
                    startingPoint: self.startingPoint,
                    showIndicator: true,
                    initialMessages: cachedMessages
                )
            }
        }
    }
    
    public override func refreshChannel() {
        if let channel = self.channel as? GroupChannel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                guard self.canProceed(with: channel, error: error) == true else {
                    let context = MessageContext(source: .eventChannelChanged, sendingStatus: .failed)
                    self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
                    return
                }
                
                let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
            }
        } else if let channelURL = self.channelURL {
            self.loadChannel(channelURL: channelURL)
        }
    }
    
    private func canProceed(with channel: GroupChannel?, error: SBError?) -> Bool {
        if let error = error {
            SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
            
            if error.code == ChatError.nonAuthorized.rawValue {
                self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: nil)
            } else {
                if SendbirdChat.isLocalCachingEnabled &&
                    error.code == ChatError.networkError.rawValue &&
                    channel != nil {
                    return true
                } else {
                    self.delegate?.didReceiveError(error, isBlocker: true)
                }
            }
            return false
        }
        
        guard let channel = channel,
              channel.myMemberState != .none
        else {
            self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: channel)
            return false
        }

        return true
    }
    
    private func belongsToChannel(error: SBError) -> Bool {
        return error.code != ChatError.nonAuthorized.rawValue
    }
    
    // MARK: - Message
    /// Sends a multiple files message.
    /// - Parameters:
    ///    - fileInfoList: A list of `UploadableFileInfo` that contains information about the files to be included in the multiple files message.
    /// - Since: 3.10.0
    open func sendMultipleFilesMessage(fileInfoList: [UploadableFileInfo]) {
        if let channel = self.channel as? GroupChannel {
            let param = MultipleFilesMessageCreateParams(uploadableFileInfoList: fileInfoList)
            SBUGlobalCustomParams.multipleFilesMessageParamsSendBuilder?(param)
            
            let preSendMessage: MultipleFilesMessage?
            preSendMessage = channel.sendMultipleFilesMessage(
                params: param,
                fileUploadHandler: { requestId, index, _, error in
                    if let error = error {
                        SBULog.error("Multiple files message - failed to upload file at index [\(index)]. \(error.localizedDescription)")
                    } else {
                        SBULog.info("Multiple files message - file at index [\(index)] upload completed.")
                    }
                    
                    // Update the multipleFilesMessage collection view cell
                    // when the upload is complete.
                    self.updateMultipleFilesMessageCell(requestId: requestId, index: index)
                },
                completionHandler: { [weak self] multipleFilesMessage, error in
                    if let error = error {
                        SBULog.error(error.localizedDescription)
                    }
                    self?.sendMultipleFilesMessageCompletionHandler?(multipleFilesMessage, error)
                })
            
            // Save each file data to cache.
            if let preSendMessage = preSendMessage {
                for (index, fileInfo) in param.uploadableFileInfoList.enumerated() {
                    SBUCacheManager.Image.preSave(
                        multipleFilesMessage: preSendMessage,
                        uploadableFileInfo: fileInfo,
                        index: index
                    )
                }
            }
            
            // Upsert pending message to fullMessageList.
            if let preSendMessage = preSendMessage, self.messageListParams.belongsTo(preSendMessage) {
              // Upsert pendingMessage.
              self.pendingMessageManager.upsertPendingMessage(
                  channelURL: channel.channelURL,
                  message: preSendMessage
              )
            } else {
                SBULog.info("A filtered file message has been sent.")
            }
          
            self.sortAllMessageList(needReload: true)
            let context = MessageContext(source: .eventMessageSent, sendingStatus: .succeeded)
            self.baseDelegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: self.fullMessageList,
                forContext: context,
                keepsScroll: false
            )
        }
    }
    
    /// Updates a multiple files message cell of the given index of a multiple files message.
    /// - Parameters:
    ///    - requestId: the requestId of the multiple files message.
    ///    - index: the index of the cell of a multiple files message to update.
    /// - Since: 3.10.0
    open func updateMultipleFilesMessageCell(requestId: String, index: Int) {
        self.delegate?.groupChannelViewModel(
            self,
            didFinishUploadingFileAt: index,
            multipleFilesMessageRequestId: requestId
        )
    }
    
    // MARK: - Load Messages
    public override func loadInitialMessages(startingPoint: Int64?,
                                      showIndicator: Bool,
                                      initialMessages: [BaseMessage]?) {
        SBULog.info("""
            loadInitialMessages,
            startingPoint : \(String(describing: startingPoint)),
            initialMessages : \(String(describing: initialMessages))
            """
        )
        
        // Caution in function call order
        self.reset()
        self.createCollectionIfNeeded(startingPoint: startingPoint ?? .max)
        self.clearMessageList()
        
        if self.hasNext() {
            // Hold on to most recent messages in cache for smooth scrolling.
            setupCache()
        }
        
        self.delegate?.shouldUpdateLoadingState(showIndicator)
        
        self.messageCollection?.startCollection(
            initPolicy: initPolicy,
            cacheResultHandler: { [weak self] cacheResult, error in
                guard let self = self else { return }
                
                defer { self.displaysLocalCachedListFirst = false }
                
                if let error = error {
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    return
                }
                
                // prevent empty view showing
                if cacheResult == nil || cacheResult?.isEmpty == true { return }
                
                self.isInitialLoading = true
                
                self.upsertMessagesInList(
                    messages: cacheResult,
                    needReload: self.displaysLocalCachedListFirst
                )
                
            }, apiResultHandler: { [weak self] apiResult, error in
                guard let self = self else { return }
                
                self.loadInitialPendingMessages()
                
                if let error = error {
                    self.delegate?.shouldUpdateLoadingState(false)
                    
                    // ignore error if using local caching
                    if !SendbirdChat.isLocalCachingEnabled {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    } else {
                        self.isInitialLoading = false
                        self.upsertMessagesInList(messages: nil, needReload: true)
                    }
                    
                    return
                }
        
                if self.initPolicy == .cacheAndReplaceByApi {
                    self.clearMessageList()
                }
                
                self.isInitialLoading = false
                self.upsertMessagesInList(messages: apiResult, needReload: true)
            })
    }
    
    func loadInitialPendingMessages() {
        let pendingMessages = self.messageCollection?.pendingMessages ?? []
        let failedMessages = self.messageCollection?.failedMessages ?? []
        let cachedTempMessages = pendingMessages + failedMessages
        for message in cachedTempMessages {
            if message.channelURL != self.channelURL { continue }
            if message.parentMessageId > 0 { continue }
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: self.channel?.channelURL,
                message: message,
                forMessageThread: self.isThreadMessageMode
            )
            if let fileMessage = message as? FileMessage,
               let fileMessageParams = fileMessage.messageParams as? FileMessageCreateParams {
                self.pendingMessageManager.addFileInfo(requestId: fileMessage.requestId, params: fileMessageParams)
            }
        }
    }
    
    public override func loadPrevMessages() {
        guard let messageCollection = self.messageCollection else { return }
        guard self.prevLock.try() else {
            SBULog.info("Prev message already loading")
            return
        }
        
        SBULog.info("[Request] Prev message list")
        
        messageCollection.loadPrevious { [weak self] messages, error in
            guard let self = self else { return }
            defer {
                self.prevLock.unlock()
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            guard let messages = messages, !messages.isEmpty else { return }
            SBULog.info("[Prev message response] \(messages.count) messages")
            
            self.delegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: messages,
                forContext: nil,
                keepsScroll: false
            )
            self.upsertMessagesInList(messages: messages, needReload: true)
        }
    }
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    public override func loadNextMessages() {
        guard self.nextLock.try() else {
            SBULog.info("Next message already loading")
            return
        }

        guard let messageCollection = self.messageCollection else { return }
        self.isLoadingNext = true
        
        messageCollection.loadNext { [weak self] messages, error in
            guard let self = self else { return }
            defer {
                self.nextLock.unlock()
                self.isLoadingNext = false
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            guard let messages = messages else { return }
            
            SBULog.info("[Next message Response] \(messages.count) messages")
            
            self.delegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: messages,
                forContext: nil,
                keepsScroll: true
            )
            self.upsertMessagesInList(messages: messages, needReload: true)
        }
    }

    // MARK: - Resend
    
    override public func deleteResendableMessage(_ message: BaseMessage, needReload: Bool) {
        if self.channel is GroupChannel {
            self.messageCollection?.removeFailed(messages: [message], completionHandler: nil)
        }
        super.deleteResendableMessage(message, needReload: needReload)
    }
    
    // MARK: - Message related
    public func markAsRead() {
        self.markAsRead(completionHandler: nil)
    }
    
    func markAsRead(completionHandler: SendbirdChatSDK.SBErrorHandler?) {
        if let channel = self.channel as? GroupChannel {
            channel.markAsRead(completionHandler: completionHandler)
        }
    }
    
    // MARK: - Typing
    public func startTypingMessage() {
        guard let channel = self.channel as? GroupChannel else { return }

        SBULog.info("[Request] Start typing")
        channel.startTyping()
    }
    
    public func endTypingMessage() {
        guard let channel = self.channel as? GroupChannel else { return }

        SBULog.info("[Request] End typing")
        channel.endTyping()
    }
    
    // MARK: - Typing Indicator Message
    private func updateTypingIndicatorMessage() {
        guard let channel = self.channel as? GroupChannel, let collection = self.messageCollection else { return }
        
        // One or more user is typing.
        if var typers = channel.getTypingUsers(),
            typers.isEmpty == false,
            let typingMessage = SBUTypingIndicatorMessage.make(["": ""]) {
            // if hasNext is true, don't show typing bubble.
            if collection.hasNext { return }
            
            let truncatedTypers = Array(typers.prefix(3))
            typingMessage.typingIndicatorInfo = SBUTypingIndicatorInfo(
                typers: truncatedTypers,
                numberOfTypers: typers.count
            )
            
            self.typingMessageManager.typingMessages[channel.channelURL] = typingMessage
        }
        // No user is typing.
        else {
            self.clearTypingMessage()
        }
        
        self.sortAllMessageList(needReload: false)  // tableview reload is handled in GroupChannelVC
    }
    
    func clearTypingMessage() {
        guard let channel = self.channel as? GroupChannel else { return }
        self.typingMessageManager.typingMessages.removeValue(forKey: channel.channelURL)
    }
    
    // MARK: - Mention
    
    /// Loads mentionable member list.
    /// When the suggested list is received, it calls `groupChannelViewModel(_:didReceiveSuggestedMembers:)` delegate method.
    /// - Parameter filterText: The text that is used as filter while searching for the suggested mentions.
    public func loadSuggestedMentions(with filterText: String) {
        self.debouncer?.add { [weak self] in
            guard let self = self else { return }
            
            if let channel = self.channel as? GroupChannel {
                if channel.isSuper {
                    guard let config = SBUGlobals.userMentionConfig else {
                        SBULog.error("`SBUGlobals.userMentionConfig` is `nil`")
                        return
                    }
                    
                    guard SendbirdUI.config.groupChannel.channel.isMentionEnabled else {
                        SBULog.error("User mention features are disabled. See `SBUGlobals.isMentionEnabled` for more information")
                        return
                    }
                    
                    let params = MemberListQueryParams()
                    params.nicknameStartsWithFilter = filterText
                    
                    // +1 is buffer for when the current user is included in the search results
                    params.limit = UInt(config.suggestionLimit) + 1
                    self.query = channel.createMemberListQuery(params: params)
                    
                    self.query?.loadNextPage { [weak self] members, _ in
                        guard let self = self else { return }
                        self.suggestedMemberList = SBUUser.convertUsers(members)
                        self.delegate?.groupChannelViewModel(
                            self,
                            didReceiveSuggestedMentions: self.suggestedMemberList
                        )
                    }
                } else {
                    guard channel.members.count > 0 else {
                        self.suggestedMemberList = nil
                        self.delegate?.groupChannelViewModel(self, didReceiveSuggestedMentions: nil)
                        return
                    }
                    
                    let sortedMembers = channel.members.sorted { $0.nickname.lowercased() < $1.nickname.lowercased() }
                    let matchedMembers = sortedMembers.filter {
                        return $0.nickname.lowercased().hasPrefix(filterText.lowercased())
                    }
                    let memberCount = matchedMembers.count
                    // +1 is buffer for when the current user is included in the search results
                    let limit = (SBUGlobals.userMentionConfig?.suggestionLimit ?? 0) + 1
                    let splitCount = min(memberCount, Int(limit))
                    
                    let resultMembers = Array(matchedMembers[0..<splitCount])
                    self.suggestedMemberList = SBUUser.convertUsers(resultMembers)
                    self.delegate?.groupChannelViewModel(
                        self,
                        didReceiveSuggestedMentions: self.suggestedMemberList
                    )
                }
            }
        }
    }
    
    /// Cancels loading the suggested mentions.
    public func cancelLoadingSuggestedMentions() {
        self.debouncer?.cancel()
    }
    
    // MARK: - Common
    private func createCollectionIfNeeded(startingPoint: Int64) {
        // GroupChannel only
        guard let channel = self.channel as? GroupChannel else { return }
        self.messageCollection = SendbirdChat.createMessageCollection(
            channel: channel,
            startingPoint: startingPoint,
            params: self.messageListParams
        )
        self.messageCollection?.delegate = self
    }

    public override func hasNext() -> Bool {
        return self.messageCollection?.hasNext ?? (self.getStartingPoint() != nil)
    }
    
    public override func hasPrevious() -> Bool {
        return self.messageCollection?.hasPrevious ?? true
    }
    
    public override func getStartingPoint() -> Int64? {
        return self.messageCollection?.startingPoint
    }
    
    override func reset() {
        self.markAsRead()
        
        super.reset()
    }
}

extension SBUGroupChannelViewModel: MessageCollectionDelegate {
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                channel: GroupChannel,
                                addedMessages messages: [BaseMessage]) {
        // -> pending, -> receive new message
        
        // message thread case exception
        var existInPendingMessage = false
        for addedMessage in messages {
            if addedMessage.sendingStatus == .succeeded { continue }
            let filteredMessages = self.pendingMessageManager
                .getPendingMessages(
                    channelURL: self.channelURL,
                    forMessageThread: true
                )
                .filter { $0.requestId == addedMessage.requestId }
                .filter { $0.isRequestIdValid }
            if !filteredMessages.isEmpty {
                existInPendingMessage = true
            }
        }
        if existInPendingMessage { return }

        SBULog.info("messageCollection addedMessages : \(messages.count)")
        switch context.source {
        case .eventMessageReceived:
            self.markAsRead()
        default: break
        }
        
        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: messages,
            forContext: context,
            keepsScroll: true
        )
        self.upsertMessagesInList(messages: messages, needReload: true)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           channel: GroupChannel,
                           updatedMessages messages: [BaseMessage]) {
        // pending -> failed, pending -> succeded, failed -> Pending
        
        // message thread case exception
        var existInPendingMessage = false
        for addedMessage in messages {
            if addedMessage.sendingStatus == .succeeded { continue }
            let filteredMessages = self.pendingMessageManager
                .getPendingMessages(
                    channelURL: self.channelURL,
                    forMessageThread: true
                )
                .filter { $0.requestId == addedMessage.requestId }
                .filter { $0.isRequestIdValid }
            if !filteredMessages.isEmpty {
                existInPendingMessage = true
            }
        }
        if existInPendingMessage { return }
        
        SBULog.info("messageCollection updatedMessages : \(messages.count)")
        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: messages,
            forContext: context,
            keepsScroll: false
        )
        self.upsertMessagesInList(
            messages: messages,
            needUpdateNewMessage: false,
            needReload: true
        )
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           channel: GroupChannel,
                           deletedMessages messages: [BaseMessage]) {
        SBULog.info("messageCollection deletedMessages : \(messages.count)")
        self.delegate?.baseChannelViewModel(self, deletedMessages: messages)
        self.deleteMessagesInList(messageIds: messages.compactMap({ $0.messageId }), needReload: true)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           updatedChannel channel: GroupChannel) {
        SBULog.info("messageCollection changedChannel")
        
        // Update typingMessageBubble.
        if context.source == .eventTypingStatusUpdated,
           SendbirdUI.config.groupChannel.channel.isTypingIndicatorEnabled,
           SendbirdUI.config.groupChannel.channel.typingIndicatorTypes.contains(.bubble) {
            updateTypingIndicatorMessage()
        }
        
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           deletedChannel channelURL: String) {
        SBULog.info("messageCollection deletedChannel")
        self.delegate?.baseChannelViewModel(self, didChangeChannel: nil, withContext: context)
    }
    
    open func didDetectHugeGap(_ collection: MessageCollection) {
        SBULog.info("messageCollection didDetectHugeGap")
        self.messageCollection?.dispose()
        
        var startingPoint: Int64?
        let indexPathsForStartingPoint = self.dataSource?.groupChannelViewModel(self, startingPointIndexPathsForChannel: self.channel as? GroupChannel)
        let visibleRowCount = indexPathsForStartingPoint?.count ?? 0
        let visibleCenterIdx = indexPathsForStartingPoint?[visibleRowCount / 2].row ?? 0
        if visibleCenterIdx < self.fullMessageList.count {
            startingPoint = self.fullMessageList[visibleCenterIdx].createdAt
        }
        
        self.loadInitialMessages(
            startingPoint: startingPoint,
            showIndicator: false,
            initialMessages: nil
        )
    }
    
    // MARK: - Submit Form.
    /// This function is used to submit form data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to submit form.
    ///   - answer: `SendbirdChatSDK.Form` object.
    /// - Since: 3.16.0
    public func submitForm(message: BaseMessage, form: SendbirdChatSDK.Form) {
        SBULog.info("[Request] Submit Form")
        message.submitForm(form: form) { error in
            if let error = error {
                SBULog.error("[Request] Submit Form - error: \(error.localizedDescription)")
                self.delegate?.didReceiveError(error)
                return
            }
        }
    }
    
    // MARK: - Request feedback.
    
    /// This function is used to submit feedback data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to submit feedback.
    ///   - answer: set feedback asnwer.
    ///   - completionHandler: Completion handler.
    /// - Since: 3.15.0
    public func submitFeedback(
        message: BaseMessage,
        answer: SBUFeedbackAnswer,
        completionHandler: ((Feedback?) -> Void)? = nil
    ) {
        guard let rating = answer.rating else { return }
        SBULog.info("[Request] Submit feedback")
        message.submitFeedback(rating: rating, comment: answer.comment) { feedback, error in
            if let error = error {
                SBULog.error("[Request] Submit feedback - error: \(error.localizedDescription)")
                self.delegate?.didReceiveError(error)
                return
            }
            
            completionHandler?(feedback)
        }
    }
    
    /// This function is used to update feedback data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to update feedback.
    ///   - answer: set feedback asnwer.
    ///   - completionHandler: Completion handler.
    /// - Since: 3.15.0
    public func updateFeedback(
        message: BaseMessage,
        answer: SBUFeedbackAnswer,
        completionHandler: ((Feedback?) -> Void)? = nil
    ) {
        guard let rating = answer.rating else { return }
        SBULog.info("[Request] Update feedback")
        message.updateFeedback(rating: rating, comment: answer.comment) { feedback, error in
            if let error = error {
                SBULog.error("[Request] update feedback - error: \(error.localizedDescription)")
                self.delegate?.didReceiveError(error)
                return
            }
            completionHandler?(feedback)
        }
    }
    
    /// This function is used to delete feedback data.
    /// - Parameters:
    ///   - message: `BaseMessage` object to delete feedback.
    ///   - completionHandler: Completion handler.
    /// - Since: 3.15.0
    public func deleteFeedback(
        message: BaseMessage,
        completionHandler: (() -> Void)? = nil
    ) {
        SBULog.info("[Request] Delete feedback")
        message.deleteFeedback { error in
            if let error = error {
                SBULog.error("[Request] delete feedback - error: \(error.localizedDescription)")
                self.delegate?.didReceiveError(error)
                return
            }
            completionHandler?()
        }
    }
}

// MARK: - ConnectionDelegate
extension SBUGroupChannelViewModel {
    open override func didSucceedReconnection() {
        super.didSucceedReconnection()
        
        if self.hasNext() {
            self.messageCache?.loadNext()
        }
        
        self.markAsRead { [weak self] _ in
            self?.refreshChannel()
        }
    }
}

// MARK: - GroupChannelDelegate
extension SBUGroupChannelViewModel: GroupChannelDelegate {
    // Received message
    open override func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard self.messageListParams.belongsTo(message) else { return }

        super.channel(channel, didReceive: message)
        
        let isScrollBottom = self.dataSource?.baseChannelViewModel(self, isScrollNearBottomInChannel: self.channel)
        if (self.hasNext() == true || isScrollBottom == false) &&
            (message is UserMessage || message is FileMessage) {
//            let context = MessageContext(source: .eventMessageReceived, sendingStatus: .succeeded)
            if let channel = self.channel {
                self.delegate?.baseChannelViewModel(self, didReceiveNewMessage: message, forChannel: channel)
            }
        }
    }
}
