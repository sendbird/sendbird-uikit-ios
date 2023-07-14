//
//  SBUMessageThreadViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Methods to get data source for the `SBUMessageThreadViewModel`.
public protocol SBUMessageThreadViewModelDataSource: SBUBaseChannelViewModelDataSource { }

public protocol SBUMessageThreadViewModelDelegate: SBUBaseChannelViewModelDelegate {
    /// Called when the message thread has received mentional member list. Please refer to `loadSuggestedMentions(with:)` in `SBUMessageThreadViewModel`.
    /// - Parameters:
    ///   - viewModel: `SBUMessageThreadViewModel` object.
    ///   - members: Mentional members
    func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didReceiveSuggestedMentions members: [SBUUser]?
    )
    
    /// Called when the message thread has loaded parent message.
    /// - Parameters:
    ///   - viewModel: `SBUMessageThreadViewModel` object.
    ///   - parentMessage: Mentional members
    func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didLoadParentMessage parentMessage: BaseMessage?
    )
    
    /// Called when the message thread has updated parent message.
    /// - Parameters:
    ///   - viewModel: `SBUMessageThreadViewModel` object.
    ///   - parentMessage: Mentional members
    func messageThreadViewModel(
        _ viewModel: SBUMessageThreadViewModel,
        didUpdateParentMessage parentMessage: BaseMessage?
    )
    
    /// Called when the message thread should be dismissed.
    func messageThreadViewModelShouldDismissMessageThread(_ viewModel: SBUMessageThreadViewModel)
}

open class SBUMessageThreadViewModel: SBUBaseChannelViewModel {
    /**
     - Header: Channel delegate
     - ParentMessage: Channel delegate, MessageCollection
     - ThreadedMessage list: Channel delegate
     - Pending message: MessageCollection
     */
    
    // MARK: - Constant
    private let changelogFetchLimit: Int = 100
    
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUMessageThreadViewModelDelegate? {
        get { self.baseDelegate as? SBUMessageThreadViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBUMessageThreadViewModelDataSource? {
        get { self.baseDataSource as? SBUMessageThreadViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    public internal(set) var customizedThreadedMessageListParams: ThreadedMessageListParams?
    public internal(set) var threadedMessageListParams = ThreadedMessageListParams()
    
    // MARK: - Logic properties (Private)
    
    @SBUAtomic private var hasMorePrevious: Bool = true
    @SBUAtomic private var hasMoreNext: Bool = false
    
    @SBUAtomic private var changelogToken: String?
    @SBUAtomic private var lastUpdatedTimestamp: Int64 = 0
    private var currentTimeMillis: Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    private var initSucceeded: Bool = false
    
    var parentMessage: BaseMessage?
    var parentMessageId: Int64?
    
    var debouncer: SBUDebouncer?
    var suggestedMemberList: [SBUUser]?
    var query: MemberListQuery?
    
    var messageCollection: MessageCollection? // for parent message's reply update
    
    // MARK: - LifeCycle
    public init(channel: BaseChannel? = nil,
                channelURL: String? = nil,
                parentMessage: BaseMessage? = nil,
                parentMessageId: Int64? = 0,
                threadedMessageListParams: ThreadedMessageListParams? = nil,
                startingPoint: Int64? = .max,
                delegate: SBUMessageThreadViewModelDelegate? = nil,
                dataSource: SBUMessageThreadViewModelDataSource? = nil) {
        super.init()
        
        self.delegate = delegate
        self.dataSource = dataSource
        self.isTransformedList = false
        self.isThreadMessageMode = true
        
        self.pendingMessageManager = SBUPendingMessageManager.shared
        
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
        
        if let parentMessage = parentMessage {
            self.parentMessage = parentMessage
            self.parentMessageId = parentMessage.messageId
        } else if let parentMessageId = parentMessageId {
            self.parentMessageId = parentMessageId
        }
        
        self.customizedThreadedMessageListParams = threadedMessageListParams
        self.startingPoint = startingPoint
        
        self.debouncer = SBUDebouncer(
            debounceTime: SBUGlobals.userMentionConfig?.debounceTime ?? SBUDebouncer.defaultTime
        )
        
        self.loadChannelAndMessages(channelURL: channelURL)
        
        self.setupSendUserMessageCompletionHandlers()
        self.setupSendFileMessageCompletionHandlers()
    }
    
    deinit {
        self.messageCollection?.dispose()
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
    }
    
    /// Loads channel and messages
    ///
    /// Process order
    /// ```
    /// 1. Connect
    /// 2. loadChannel
    /// 3. loadParentMessage
    /// 4. loadThreadedMessage
    /// ```
    ///
    /// - Parameter channelURL: channel URL string
    public func loadChannelAndMessages(channelURL: String?) {
        guard let channelURL = self.channelURL else { return }
        
        // 1. Connect
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: true)
                return
            }
            
            // 2. loadChannel
            self?.loadChannel(
                channelURL: channelURL,
                completionHandler: { channel, error in
                    guard error == nil,
                          let parentMessageId = self?.parentMessageId,
                          let channel = channel else {
                        self?.delegate?.didReceiveError(error, isBlocker: true)
                        return
                    }
                    
                    self?.channel = channel
                    
                    // 3. loadParentMessage
                    self?.loadParentMessage(
                        parentMessageId: parentMessageId,
                        channelURL: channelURL,
                        isInitilize: true,
                        completionHandler: { parentMessage, error in
                            guard error == nil, let parentMessage = parentMessage else {
                                self?.delegate?.didReceiveError(error, isBlocker: true)
                                return
                            }
                            
                            self?.parentMessage = parentMessage
                            if let self = self {
                                self.delegate?.messageThreadViewModel(
                                    self,
                                    didLoadParentMessage: parentMessage
                                )
                            }
                            
                            // 4. loadThreadedMessage
                            self?.loadInitialMessages(
                                startingPoint: self?.startingPoint,
                                showIndicator: true,
                                initialMessages: nil
                            )
                            
                            guard let self = self,
                                  let channel = self.channel as? GroupChannel else { return }
                            self.messageCollection = SendbirdChat.createMessageCollection(
                                channel: channel,
                                startingPoint: .max,
                                params: self.messageListParams
                            )
                            self.messageCollection?.delegate = self
                        }
                    )
                }
            )
        }
    }
    
    // MARK: - Channel
    public override func loadChannel(channelURL: String,
                                     messageListParams: MessageListParams? = nil,
                                     completionHandler: ((BaseChannel?, SBError?) -> Void)? = nil) {
        SBULog.info("[Request] Load channel: \(String(channelURL))")
        GroupChannel.getChannel(url: channelURL) { [weak self] channel, error in
            guard let self = self else {
                completionHandler?(nil, error)
                return
            }
            
            self.channel = channel
            guard self.canProceed(with: channel, error: error) else {
                completionHandler?(nil, error)
                return
            }
            
            SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
            
            // background refresh to check if user is banned or not.
            self.refreshChannel()
            
            // for updating channel information when the connection state is closed at the time of initial load.
            if SendbirdChat.getConnectState() == .closed {
                let context = MessageContext(
                    source: .eventChannelChanged,
                    sendingStatus: .succeeded
                )
                self.delegate?.baseChannelViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
                completionHandler?(channel, nil)
            }
            
            completionHandler?(channel, nil)
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
                
                let context = MessageContext(
                    source: .eventChannelChanged,
                    sendingStatus: .succeeded
                )
                self.delegate?.baseChannelViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
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
                // Currently thread messages do not support local caching.
//                if SendbirdChat.isLocalCachingEnabled { return true }
                self.delegate?.didReceiveError(error, isBlocker: true)
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
    
    // MARK: - Parent Message
    
    /// Loads parent message.
    /// - Parameters:
    ///   - parentMessageId: Parent message Id
    ///   - channelURL: channel URL string
    ///   - isInitilize: For initialization process, set this value to `true`.
    ///   - completionHandler: completion handler
    public func loadParentMessage(parentMessageId: Int64,
                                  channelURL: String,
                                  isInitilize: Bool? = false,
                                  completionHandler: ((BaseMessage?, SBError?) -> Void)? = nil) {
        if let parentMessage = self.parentMessage, !isInitialLoading {
            // TODO: collection 붙이면 collection 에서 가져오는거 먼저 처리
            completionHandler?(parentMessage, nil)
            return
        }
        
        let params = MessageRetrievalParams()
        params.messageId = parentMessageId
        params.channelType = .group
        params.channelURL = channelURL
        params.includeThreadInfo = true
        params.includeReactions = true
        params.includeMetaArray = true
        
        BaseMessage.getMessage(params: params) { (message, error) in
            guard error == nil else {
                completionHandler?(nil, error)
                return
            }
            
            completionHandler?(message, nil)
        }
    }
    
    /// Updates parent message.
    public func updateParentMessage() {
        guard let parentMessageId = parentMessageId,
              let channelURL = channelURL else { return }
        self.loadParentMessage(
            parentMessageId: parentMessageId,
            channelURL: channelURL
        ) { parentMessage, error in
            guard error == nil, let parentMessage = parentMessage else {
                return
            }
            self.parentMessage = parentMessage
            self.delegate?.messageThreadViewModel(self, didUpdateParentMessage: self.parentMessage)
        }
    }
    
    // MARK: - Load Threaded Messages
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
        self.startingPoint = startingPoint
        self.isInitialLoading = true
        self.reset()
        
        if let initialMessages = initialMessages,
           !initialMessages.isEmpty {
            self.handleInitialResponse(usedParam: nil, messages: initialMessages, error: nil)
        } else {
            self.loadBothMessages(timestamp: startingPoint, showIndicator: showIndicator)
        }
    }
    
    public override func loadPrevMessages() {
        self.loadPrevMessages(timestamp: self.messageList.first?.createdAt)
    }
    
    /// Loads previous messages from given timestamp. Load messages from the latest (`Int64.max`).
    public func loadPrevMessages(timestamp: Int64?) {
        guard self.prevLock.try() else {
            SBULog.info("Prev message already loading")
            return
        }
        
        SBULog.info("[Request] Prev message list from : \(String(describing: timestamp))")
        
        self.isLoadingPrev = true
        
        let params = (self.threadedMessageListParams.copy() as? ThreadedMessageListParams) ?? ThreadedMessageListParams()
        params.nextResultSize = 0
        if params.previousResultSize == 0 {
            params.previousResultSize = self.defaultFetchLimit
            params.includeReactions = SBUEmojiManager.isReactionEnabled(channel: channel)
            params.includeParentMessageInfo = true
        }
        
        self.parentMessage?.getThreadedMessages(
            timestamp: timestamp ?? .max,
            params: params,
            completionHandler: { [weak self] _, messages, error in
                guard let self = self else { return }
                defer {
                    self.prevLock.unlock()
                }
                
                if let error = error {
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    self.isLoadingPrev = false
                    return
                }
                
                guard self.isValidResponse(messages: messages, error: error),
                      let messages = messages else {
                    SBULog.warning("Prev message list request is not valid")
                    self.isLoadingPrev = false
                    return
                }
                
                SBULog.info("[Prev message response] \(messages.count) messages")
                
                self.hasMorePrevious = messages.count >= params.previousResultSize
                
                self.delegate?.baseChannelViewModel(
                    self,
                    shouldUpdateScrollInMessageList: messages,
                    forContext: nil,
                    keepsScroll: false
                )
                
                self.updateLastUpdatedTimestamp(messages: messages)
                
                self.upsertMessagesInList(messages: messages, needReload: true)
                
                self.isLoadingPrev = false
            }
        )
    }
    
    public override func loadNextMessages() {
        guard self.nextLock.try() else {
            SBULog.info("Next message already loading")
            return
        }
        
        SBULog.info("[Request] Next message list from : \(self.lastUpdatedTimestamp)")
        
        self.isLoadingNext = true
        
        let params = (self.threadedMessageListParams.copy() as? ThreadedMessageListParams) ?? ThreadedMessageListParams()
        params.previousResultSize = 0
        if params.nextResultSize == 0 {
            params.nextResultSize = self.defaultFetchLimit
            params.includeReactions = SBUEmojiManager.isReactionEnabled(channel: channel)
            params.includeParentMessageInfo = true
        }
        
        self.parentMessage?.getThreadedMessages(
            timestamp: self.lastUpdatedTimestamp,
            params: params,
            completionHandler: { [weak self] _, messages, error in
                guard let self = self else { return }
                defer {
                    self.nextLock.unlock()
                    self.isLoadingNext = false
                }
                
                guard self.isValidResponse(messages: messages, error: error),
                      let messages = messages else {
                    SBULog.warning("Next message list request is not valid")
                    return
                }
                
                SBULog.info("[Next message Response] \(messages.count) messages")
                
                self.hasMoreNext = messages.count >= params.nextResultSize
                
                self.delegate?.baseChannelViewModel(
                    self,
                    shouldUpdateScrollInMessageList: messages,
                    forContext: nil,
                    keepsScroll: true
                )
                self.updateLastUpdatedTimestamp(messages: messages)
                
                self.upsertMessagesInList(messages: messages, needReload: true)
            }
        )
    }
    
    /// Loads messages to both direction from given timestamp.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`Int64.max`)
    ///   - showIndicator: Whether to show indicator on load or not.
    public func loadBothMessages(timestamp: Int64?, showIndicator: Bool) {
        SBULog.info("[Request] Both message list from : \(String(describing: timestamp))")
        guard self.initialLock.try() else { return }
        self.delegate?.shouldUpdateLoadingState(showIndicator)
        
        let params = (self.threadedMessageListParams.copy() as? ThreadedMessageListParams) ?? ThreadedMessageListParams()
        params.isInclusive = true
        params.includeReactions = SBUEmojiManager.isReactionEnabled(channel: channel)
        params.includeParentMessageInfo = true
        
        let shouldFetchBoth: Bool = timestamp != nil
        if shouldFetchBoth {
            // prev & next
            
            // if one direction is 0, half the other direction to make both direction equal
            if params.previousResultSize == 0 {
                params.previousResultSize = params.nextResultSize / 2
                params.nextResultSize = params.nextResultSize / 2
            } else if params.nextResultSize == 0 {
                params.previousResultSize = params.previousResultSize / 2
                params.nextResultSize = params.previousResultSize / 2
            }
            
            // if one direction is 0, make it half of default limit
            if params.previousResultSize == 0 { params.previousResultSize = self.defaultFetchLimit }
            if params.nextResultSize == 0 { params.nextResultSize = self.defaultFetchLimit }
        } else {
            // prev only
            if params.previousResultSize == 0 {
                params.previousResultSize = self.defaultFetchLimit
            }
            params.nextResultSize = 0
        }
        
        let startingTimestamp: Int64 = timestamp ?? .max
        SBULog.info("""
            Fetch from : \(startingTimestamp),
            limit: prev = \(params.previousResultSize),
            next = \(params.nextResultSize)
            """)
        self.isLoadingNext = true
        
        self.parentMessage?.getThreadedMessages(
            timestamp: startingTimestamp,
            params: params,
            completionHandler: { [weak self] _, messages, error in
                guard let self = self else { return }
                defer { self.initialLock.unlock() }
                
                if let error = error {
                    self.delegate?.shouldUpdateLoadingState(false)
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    return
                }
                
                self.handleInitialResponse(
                    usedParam: params,
                    messages: messages,
                    error: error
                )
            }
        )
    }
    
    /// Handles response from initial loading request of messages (see `loadInitialMessages(startingPoint:showIndicator:initialMessages:)`).
    /// - Parameters:
    ///   - usedParam: `ThreadedMessageListParams` used in `loadInitialMessages`, or `nil` if it was called from custom message list.
    ///   - messages: Messages loaded.
    ///   - error: `SBError` from loading messages.
    private func handleInitialResponse(usedParam: ThreadedMessageListParams?,
                                       messages: [BaseMessage]?,
                                       error: SBError?) {
        self.initSucceeded = error == nil
        
        defer { self.isLoadingNext = false }
        
        guard self.isValidResponse(messages: messages, error: error),
              let messages = messages else {
            SBULog.warning("Initial message list request is not valid")
            self.delegate?.shouldUpdateLoadingState(false)
            return
        }
        
        SBULog.info("[Both message response] \(messages.count) messages")
        let startingTimestamp: Int64 = self.startingPoint ?? .max
        
        if let usedParam = usedParam {
            self.hasMorePrevious = messages
                .filter({ $0.createdAt <= startingTimestamp })
                .count >= usedParam.previousResultSize
            
            if usedParam.nextResultSize > 0 {
                // update hasNext only if message is fetched on next direction.
                self.hasMoreNext = messages
                    .filter({ $0.createdAt >= startingTimestamp })
                    .count >= usedParam.nextResultSize
            }
        }
        
        SBULog.info("""
            [Initial message response] Prev count : \(messages.filter({ $0.createdAt <= startingTimestamp }).count),
            prevLimit : \(String(describing: usedParam?.previousResultSize)),
            hasPrev : \(String(describing: self.hasPrevious))
            """)
        SBULog.info("""
            [Initial message response] Next count : \(messages.filter({ $0.createdAt >= startingTimestamp }).count),
            nextLimit : \(String(describing: usedParam?.nextResultSize)),
            hasNext : \(String(describing: self.hasNext))
            """)
        
        SBULog.info("""
            [Initial message response] First : \(String(describing: messages.first)),
            Last : \(String(describing: messages.last))
            """)

        self.updateLastUpdatedTimestamp(messages: messages)
        
        self.isInitialLoading = false
        self.upsertMessagesInList(messages: messages, needReload: true)
    }
    
    // MARK: - Message
    
    /// Sets up  completion handlers of send user message.
    open func setupSendUserMessageCompletionHandlers() {
        self.sendUserMessageCompletionHandler = { [weak self] userMessage, error in
            guard let self = self else { return }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error)
                SBULog.error("[Failed] Send user message request: \(error.localizedDescription)")
                return
            }

            guard let userMessage = userMessage else { return }
            
            self.pendingMessageManager.removePendingMessage(
                channelURL: userMessage.channelURL,
                requestId: userMessage.requestId,
                forMessageThread: self.isThreadMessageMode
            )
            
            SBULog.info("[Succeed] Send user message: \(userMessage.description)")
            self.upsertMessagesInList(messages: [userMessage], needReload: true)
        }
    }
    
    /// Sets up  completion handlers of send file message.
    open func setupSendFileMessageCompletionHandlers() {
        self.sendFileMessageCompletionHandler = { [weak self] fileMessage, error in
            guard let self = self else { return }
            
            if let error = error {
                self.baseDelegate?.didReceiveError(error)
                SBULog.error(
                    """
                    [Failed] Send file message request:
                    \(error.localizedDescription)
                    """
                )
                return
            }

            guard let fileMessage = fileMessage else { return }
            
            self.pendingMessageManager.removePendingMessage(
                channelURL: fileMessage.channelURL,
                requestId: fileMessage.requestId,
                forMessageThread: self.isThreadMessageMode
            )
            
            SBULog.info("[Succeed] Send file message: \(fileMessage.description)")
            
            self.upsertMessagesInList(messages: [fileMessage], needReload: true)
        }
    }
    
    override func handlePendingResendableMessage<Message: BaseMessage>(_ message: Message?,
                                                                       _ error: SBError?) {
        if let error = error {
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: message?.channelURL,
                message: message,
                forMessageThread: self.isThreadMessageMode
            )
            
            self.sortAllMessageList(needReload: true)
            
            self.baseDelegate?.didReceiveError(error, isBlocker: false)
            
            SBULog.error("[Failed] Resend failed user message request: \(error.localizedDescription)")
            return
            
        } else {
            guard let message = message else { return }
            
            self.pendingMessageManager.removePendingMessage(
                channelURL: message.channelURL,
                requestId: message.requestId,
                forMessageThread: self.isThreadMessageMode
            )
            
            SBULog.info("[Succeed] Resend failed file message: \(message.description)")
            
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    // MARK: - List
    public override func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        let pendingMessages = self.pendingMessageManager.getPendingMessages(
            channelURL: self.channel?.channelURL,
            forMessageThread: self.isThreadMessageMode
        ).filter { $0.parentMessageId == self.parentMessageId }
        
        self.messageList.sort { $0.createdAt < $1.createdAt }
        self.fullMessageList = self.messageList
        + pendingMessages.sorted { $0.createdAt < $1.createdAt }
        
        self.baseDelegate?.shouldUpdateLoadingState(false)
        self.baseDelegate?.baseChannelViewModel(
            self,
            didChangeMessageList: self.fullMessageList,
            needsToReload: needReload,
            initialLoad: self.isInitialLoading
        )
    }
    
    // MARK: - Last Updated timestamp
    private func updateLastUpdatedTimestamp(messages: [BaseMessage]) {
        SBULog.info("""
            hasNext : \(String(describing: self.hasNext)),
            first : \(String(describing: messages.first)),
            last : \(String(describing: messages.last))
            """)
        
        let currentTime = self.currentTimeMillis
        var newTimestamp: Int64 = 0
        
        if self.hasNext() {
            if let latestMessage = messages.last {
                newTimestamp = latestMessage.createdAt
            }
        }
        
        SBULog.info("""
            newTimestamp : \(newTimestamp),
            lastUpdatedTimestamp : \(self.lastUpdatedTimestamp),
            currentTime : \(currentTime)
            """)
        guard newTimestamp > self.lastUpdatedTimestamp else { return }
        self.setLastUpdatedTimestamp(timestamp: newTimestamp)
    }
    
    private func setLastUpdatedTimestamp(timestamp: Int64) {
        SBULog.info("set to \(timestamp)")
        self.lastUpdatedTimestamp = timestamp
    }
    
    private func resetLastUpdatedTimestamp() {
        let currentTime = self.currentTimeMillis
        self.lastUpdatedTimestamp = self.startingPoint ?? currentTime
        SBULog.info("""
            reset timestamp to : \(self.lastUpdatedTimestamp),
            startingPoint : \(String(describing: self.startingPoint)),
            currentTime : \(currentTime)
            """)
    }
    
    // MARK: - Changelog
    
    /// Loads SDK's changelog (updated + deleted) fully + new added messages (fully || once depending on `hasNext`)
    private func loadMessageChangeLogs() {
        guard self.initSucceeded else {
            self.loadInitialMessages(
                startingPoint: self.startingPoint,
                showIndicator: false,
                initialMessages: nil
            )
            return
        }
        
        /// Prevent loadNext being called if changelog is called
        guard self.nextLock.try() else { return }
        
        let changeLogsParams = MessageChangeLogsParams(
            includeThreadInfo: true,
            replyType: .all
        )
        
        var completion: (([BaseMessage]?, [Int64]?, Bool, String?, SBError?) -> Void)!
        completion = { [weak self] updatedMessages, deletedMessageIds, hasMore, nextToken, error in
            guard let self = self else { return }
            
            let updatedMessages = updatedMessages?.filter { $0.parentMessageId == self.parentMessageId }
            
            self.handleChangelogResponse(
                updatedMessages: updatedMessages,
                deletedMessageIds: deletedMessageIds,
                hasMore: hasMore,
                nextToken: nextToken,
                error: error
            )
        }
        
        if let token = self.changelogToken {
            SBULog.info("[Request] Message change logs with token")
            self.channel?.getMessageChangeLogs(
                token: token,
                params: changeLogsParams,
                completionHandler: completion
            )
        } else {
            SBULog.info("[Request] Message change logs with last updated timestamp")
            self.channel?.getMessageChangeLogs(
                timestamp: self.lastUpdatedTimestamp,
                params: changeLogsParams,
                completionHandler: completion
            )
        }
    }
    
    /// Separated loadNext for changelog and normal loading on scroll.
    /// Difference on limit + handling response (setting hasNext, updatedAt, etc)
    private func loadNextMessagesForChangelog(completion: @escaping ([BaseMessage]) -> Void) {
        SBULog.info("[Request] Changelog added message list from : \(self.lastUpdatedTimestamp)")
        
        let params = (self.threadedMessageListParams.copy() as? ThreadedMessageListParams) ?? ThreadedMessageListParams()
        params.previousResultSize = 0
        params.nextResultSize = self.changelogFetchLimit
        params.includeParentMessageInfo = true
        
        self.parentMessage?.getThreadedMessages(
            timestamp: self.lastUpdatedTimestamp,
            params: params,
            completionHandler: { [weak self] _, messages, error in
                
                guard let self = self else { return }
                
                guard self.isValidResponse(messages: messages, error: error),
                      let messages = messages else {
                    SBULog.warning("Changelog added message list request is not valid")
                    self.nextLock.unlock()
                    return
                }
                
                SBULog.info("[Changelog added response] \(messages.count) messages")
                completion(messages)
            }
        )
    }
    
    /// Handling response for Messaging SDK's `getMessageChangeLogs`
    /// Loads SDK's changelog (updated + deleted) fully + new added messages (fully || once depending on `hasNext`)
    private func handleChangelogResponse(updatedMessages: [BaseMessage]?,
                                         deletedMessageIds: [Int64]?,
                                         hasMore: Bool,
                                         nextToken: String?,
                                         error: SBError?) {
        if let error = error {
            SBULog.error("""
                [Failed] Message change logs request:
                \(error.localizedDescription)
                """)
            
            self.nextLock.unlock()
            self.delegate?.didReceiveError(error, isBlocker: true)
            return
        }
        
        SBULog.info("""
            [Response]
            \(String(format: "%d updated messages", updatedMessages?.count ?? 0)),
            \(String(format: "%d deleted messages", deletedMessageIds?.count ?? 0))
            """)
        
        self.changelogToken = nextToken
        
        self.handleChangelogResponse(
            updatedMessages: updatedMessages,
            deletedMessageIds: deletedMessageIds
        )
        
        if hasMore {
            self.loadMessageChangeLogs()
        } else {
            isLoadingNext = true
            
            var loadNextCompletion: (([BaseMessage]) -> Void)!
            loadNextCompletion = { [weak self] messages in
                guard let self = self else { return }
                
                if let firstMessage = messages.first {
                    self.setLastUpdatedTimestamp(timestamp: firstMessage.createdAt)
                }
                
                let canLoadMore = self.handleChangelogResponse(addedMessages: messages)
                guard canLoadMore else {
                    self.nextLock.unlock()
                    self.isLoadingNext = false
                    return
                }
                
                self.loadNextMessagesForChangelog(completion: loadNextCompletion)
            }
            
            self.loadNextMessagesForChangelog(completion: loadNextCompletion)
        }
    }
    
    /// Handling updated & deleted messages
    private func handleChangelogResponse(updatedMessages: [BaseMessage]?, deletedMessageIds: [Int64]?) {
        if let updatedMessages = updatedMessages,
           !updatedMessages.isEmpty {
            self.delegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: updatedMessages,
                forContext: nil,
                keepsScroll: false
            )
            self.upsertMessagesInList(messages: updatedMessages, needReload: true)
            
        }
        if let deletedMessageIds = deletedMessageIds,
           !deletedMessageIds.isEmpty {
            self.deleteMessagesInList(messageIds: deletedMessageIds, needReload: true)
        }
    }
    
    /// Handling added messages
    ///
    /// - Returns: Whether there's more messages to fetch or not.
    private func handleChangelogResponse(addedMessages: [BaseMessage]) -> Bool {
        let hasMore = addedMessages.count >= self.changelogFetchLimit
        
        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: addedMessages,
            forContext: nil,
            keepsScroll: true
        )
        self.upsertMessagesInList(messages: addedMessages, needReload: true)
        
        SBULog.info("Loaded added messages : \(addedMessages.count), hasNext : \(String(describing: self.hasNext))")
        
        return hasMore
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
    
    // MARK: - Mention
    
    /// Loads mentionable member list.
    /// When the suggested list is received, it calls `groupChannelViewModel(_:didReceiveSuggestedMembers:)` delegate method.
    /// - Parameter filterText: The text that is used as filter while searching for the suggested mentions.
    public func loadSuggestedMentions(with filterText: String) {
        self.debouncer?.add { [weak self] in
            guard let self = self else { return }
            
            if let channel = self.channel as? GroupChannel {
                if channel.isSuper {
                    let params = MemberListQueryParams()
                    params.nicknameStartsWithFilter = filterText
                    // +1 is buffer for when the current user is included in the search results
                    params.limit = UInt(SBUGlobals.userMentionConfig?.suggestionLimit ?? 0) + 1
                    self.query = channel.createMemberListQuery(params: params)
                    
                    self.query?.loadNextPage { [weak self] members, _ in
                        guard let self = self else { return }
                        self.suggestedMemberList = SBUUser.convertUsers(members)
                        self.delegate?.messageThreadViewModel(
                            self,
                            didReceiveSuggestedMentions: self.suggestedMemberList
                        )
                    }
                } else {
                    guard channel.members.count > 0 else {
                        self.suggestedMemberList = nil
                        self.delegate?.messageThreadViewModel(self, didReceiveSuggestedMentions: nil)
                        return
                    }
                    
                    let sortedMembers = channel.members.sorted {
                        $0.nickname.lowercased() < $1.nickname.lowercased()
                    }
                    let matchedMembers = sortedMembers.filter {
                        return $0.nickname.lowercased().hasPrefix(filterText.lowercased())
                    }
                    let memberCount = matchedMembers.count
                    // +1 is buffer for when the current user is included in the search results
                    let limit = (SBUGlobals.userMentionConfig?.suggestionLimit ?? 0) + 1
                    let splitCount = min(memberCount, Int(limit))
                    
                    let resultMembers = Array(matchedMembers[0..<splitCount])
                    self.suggestedMemberList = SBUUser.convertUsers(resultMembers)
                    self.delegate?.messageThreadViewModel(
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
    
    /// Checks if the response of loading message is valid.
    /// - Parameters:
    ///   - messages: Messages loaded.
    ///   - error: `SBError` from loading messages.
    /// - Returns: `true` if response is valid.
    private func isValidResponse(messages: [BaseMessage]?, error: SBError?) -> Bool {
        if let error = error {
            SBULog.error("Couldn't retrieve thread list.: \(error)")
            self.isLoadingNext = false
            self.delegate?.didReceiveError(error, isBlocker: true)
            return false
        }
        
        guard messages != nil else {
            SBULog.warning("Response of retrieve thread list is nil")
            self.isLoadingNext = false
            return false
        }
        
        return true
    }
    
    public override func hasNext() -> Bool {
        return self.hasMoreNext
    }
    
    public override func hasPrevious() -> Bool {
        return self.hasMorePrevious
    }
    
    public override func getStartingPoint() -> Int64? {
        return self.startingPoint
    }
    
    override func reset() {
        self.hasMorePrevious = true
        self.hasMoreNext = self.startingPoint != nil
        self.resetLastUpdatedTimestamp()
        
        self.messageCache = nil
        self.resetMessageListParams()
        self.isScrollToInitialPositionFinish = false
    }
    
    private func resetMessageListParams() {
        self.threadedMessageListParams = self.customizedThreadedMessageListParams?.copy() as? ThreadedMessageListParams ?? ThreadedMessageListParams()
        
        if self.threadedMessageListParams.previousResultSize <= 0 {
            self.threadedMessageListParams.previousResultSize = self.defaultFetchLimit
        }
        if self.threadedMessageListParams.nextResultSize <= 0 {
            self.threadedMessageListParams.nextResultSize = self.defaultFetchLimit
        }
        
        self.threadedMessageListParams.includeReactions = SBUEmojiManager.isReactionEnabled(channel: channel)
        self.threadedMessageListParams.includeParentMessageInfo = SBUGlobals.reply.includesParentMessageInfo
        
        self.threadedMessageListParams.includeMetaArray = true
    }
}

// MARK: - ConnectionDelegate
extension SBUMessageThreadViewModel {
    open override func didSucceedReconnection() {
        super.didSucceedReconnection()
        
        self.refreshChannel()
        if let parentMessageId = self.parentMessageId, let channelURL = channelURL {
            self.loadParentMessage(
                parentMessageId: parentMessageId,
                channelURL: channelURL
            ) { [weak self] parentMessage, error in
                guard error == nil, let parentMessage = parentMessage else {
                    return
                }
                
                self?.parentMessage = parentMessage
                if let self = self {
                    self.delegate?.messageThreadViewModel(self, didLoadParentMessage: parentMessage)
                }
                
                self?.loadMessageChangeLogs()
            }
        }
    }
    
    open func didFailReconnection() { }
}

// MARK: - GroupChannelDelegate (parent message, threaded message)
extension SBUMessageThreadViewModel: GroupChannelDelegate {
    // Received message
    open override func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard self.parentMessageId == message.parentMessageId else { return }
        
        super.channel(channel, didReceive: message)
        
        self.updateParentMessage()
        
        let isScrollNearBottom = self.dataSource?.baseChannelViewModel(
            self,
            isScrollNearBottomInChannel: self.channel
        ) ?? true
        
        if self.hasNext() == true || isScrollNearBottom == false {
            guard message is UserMessage || message is FileMessage else { return }
            
            if let channel = self.channel {
                self.delegate?.baseChannelViewModel(
                    self,
                    didReceiveNewMessage: message,
                    forChannel: channel
                )
            }
        }
        
        if self.hasNext() == false {
            self.delegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: [message],
                forContext: nil,
                keepsScroll: !isScrollNearBottom
            )
            
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    // Updated message
    open override func channel(_ channel: BaseChannel, didUpdate message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        if message.messageId == self.parentMessageId {
            SBULog.info("Did update message: \(message)")
            self.delegate?.messageThreadViewModel(self, didUpdateParentMessage: message)
            
        } else if self.parentMessageId == message.parentMessageId {
            SBULog.info("Did update message: \(message)")
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    open override func channel(_ channel: BaseChannel,
                               didUpdateThreadInfo threadInfoUpdateEvent: ThreadInfoUpdateEvent) {
        if self.parentMessage?.messageId == threadInfoUpdateEvent.targetMessageId {
            self.parentMessage?.apply(threadInfoUpdateEvent)
            if let parentMessage = self.parentMessage {
                self.delegate?.messageThreadViewModel(self, didUpdateParentMessage: parentMessage)
            }
        }
    }
    
    open override func channel(_ channel: BaseChannel, updatedReaction reactionEvent: ReactionEvent) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        let message = self.fullMessageList.filter { $0.messageId == reactionEvent.messageId }.first
        
        if reactionEvent.messageId == self.parentMessageId {
            // Parent message
            SBULog.info("Did update message: \(String(describing: self.parentMessage))")
            if let parentMessage = parentMessage {
                if reactionEvent.messageId == parentMessage.messageId {
                    parentMessage.apply(reactionEvent)
                }
                self.baseDelegate?.baseChannelViewModel(
                    self,
                    didUpdateReaction: reactionEvent,
                    forMessage: parentMessage
                )
            }
            
        } else if self.parentMessageId == message?.parentMessageId {
            guard let message = message else { return }
            // threaded message
            SBULog.info("Did update message: \(message.parentMessageId)")
            if reactionEvent.messageId == message.messageId {
                message.apply(reactionEvent)
            }
            
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    // Deleted message
    open override func channel(_ channel: BaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        if messageId == self.parentMessageId {
            self.delegate?.messageThreadViewModelShouldDismissMessageThread(self)
        } else {
            SBULog.info("Message was deleted: \(messageId)")
            
            for message in self.messageList {
                if message.messageId == messageId {
                    self.delegate?.baseChannelViewModel(self, deletedMessages: [message])
                }
            }
            
            self.deleteMessagesInList(messageIds: [messageId], needReload: true)
        }
    }
    
    // MARK: Channel related
    open override func channelWasChanged(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? GroupChannel else { return }
        self.channel = channel
        
        SBULog.info("Channel was changed, ChannelURL:\(channel.channelURL)")
        
        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channelWasFrozen(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? GroupChannel else { return }
        SBULog.info("Channel was frozen, ChannelURL:\(channel.channelURL)")
        
        let context = MessageContext(source: .eventChannelFrozen, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channelWasUnfrozen(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? GroupChannel else { return }
        SBULog.info("Channel was unfrozen, ChannelURL:\(channel.channelURL)")
        
        let context = MessageContext(source: .eventChannelUnfrozen, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channel(_ channel: BaseChannel, userWasMuted user: RestrictedUser) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        if user.userId == SBUGlobals.currentUser?.userId {
            SBULog.info("You are muted.")
            let context = MessageContext(source: .eventUserMuted, sendingStatus: .succeeded)
            self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        }
    }
    
    open override func channel(_ channel: BaseChannel, userWasUnmuted user: User) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        if user.userId == SBUGlobals.currentUser?.userId {
            SBULog.info("You are unmuted.")
            let context = MessageContext(source: .eventUserUnmuted, sendingStatus: .succeeded)
            self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        }
    }
    
    open override func channelDidUpdateOperators(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        let context = MessageContext(source: .eventOperatorUpdated, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        if user.userId == SBUGlobals.currentUser?.userId {
            SBULog.info("You are banned.")
            self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: channel)
        } else {
            let context = MessageContext(source: .eventUserBanned, sendingStatus: .succeeded)
            self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        }
    }
    
    open func channel(_ channel: GroupChannel, userDidJoin user: User) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        let context =  MessageContext(source: .eventUserJoined, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open func channel(_ channel: GroupChannel, userDidLeave user: User) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        if user.userId == SBUGlobals.currentUser?.userId {
            self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: channel)
        } else {
            let context =  MessageContext(source: .eventUserLeft, sendingStatus: .succeeded)
            self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        }
    }
    
    open override func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        guard self.channel?.channelURL == channelURL else { return }
        
        let context = MessageContext(source: .eventChannelDeleted, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: nil, withContext: context)
    }
}

// MARK: - MessageCollectionDelegate
extension SBUMessageThreadViewModel: MessageCollectionDelegate {
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                channel: GroupChannel,
                                addedMessages messages: [BaseMessage]) {
        // -> pending, -> receive new message
        SBULog.info("messageCollection addedMessages : \(messages.count)")
        
        for addedMessage in messages {
            if addedMessage.sendingStatus == .succeeded
                || addedMessage.messageId == self.parentMessageId { continue }
            
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: addedMessage.channelURL,
                message: addedMessage,
                forMessageThread: self.isThreadMessageMode
            )
        }
        
        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: messages,
            forContext: context,
            keepsScroll: true
        )
        
        self.sortAllMessageList(needReload: true)
        
        // Parent message
        self.updateParentMessage()
    }
    
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                channel: GroupChannel,
                                updatedMessages messages: [BaseMessage]) {
        SBULog.info("messageCollection updatedMessages : \(messages.count)")
        
        let parentMessages = messages.filter { $0.messageId == self.parentMessageId }
        if let parentMessage = parentMessages.first {
            self.delegate?.messageThreadViewModel(self, didUpdateParentMessage: parentMessage)
        }
        
        // Edge case - Updates Thread message when resend finished
        let threadMessages = messages.filter { $0.parentMessageId == self.parentMessageId }
        if threadMessages.isEmpty { return }
        self.upsertMessagesInList(messages: threadMessages, needReload: true)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                channel: GroupChannel,
                                deletedMessages messages: [BaseMessage]) {
        SBULog.info("messageCollection deletedMessages : \(messages.count)")
        
        let parentMessages = messages.filter { $0.messageId == self.parentMessageId }
        if let parentMessage = parentMessages.first {
            self.delegate?.messageThreadViewModel(self, didUpdateParentMessage: parentMessage)
        }
        
        self.loadMessageChangeLogs()
    }
    
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                updatedChannel channel: GroupChannel) {
        SBULog.info("messageCollection changedChannel")
    }
    
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                deletedChannel channelURL: String) {
        SBULog.info("messageCollection deletedChannel")
    }
}
