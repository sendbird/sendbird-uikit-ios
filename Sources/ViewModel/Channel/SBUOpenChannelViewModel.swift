//
//  SBUOpenChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/06/03.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

public protocol SBUOpenChannelViewModelDataSource: SBUBaseChannelViewModelDataSource {
}

public protocol SBUOpenChannelViewModelDelegate: SBUBaseChannelViewModelDelegate {
    /// Called when the user entered channel
    /// - Parameters:
    ///  - viewModel: `SBUOpenChannelViewModel` object.
    ///  - user: The entered user.
    ///  - channel: The channel object.
    func openChannelViewModel(
        _ viewModel: SBUOpenChannelViewModel,
        userDidEnter user: User,
        forChannel channel: OpenChannel
    )
    
    /// Called when the user exited at the channel
    /// - Parameters:
    ///  - viewModel: `SBUOpenChannelViewModel` object.
    ///  - user: The exited user.
    ///  - channel: The channel object.
    func openChannelViewModel(
        _ viewModel: SBUOpenChannelViewModel,
        userDidExit user: User,
        forChannel channel: OpenChannel
    )
}

extension SBUOpenChannelViewModelDelegate {
    public func openChannelViewModel(
        _ viewModel: SBUOpenChannelViewModel,
        userDidEnter user: User,
        forChannel channel: OpenChannel
    ) {}
    
    public func openChannelViewModel(
        _ viewModel: SBUOpenChannelViewModel,
        userDidExit user: User,
        forChannel channel: OpenChannel
    ) {}
}

open class SBUOpenChannelViewModel: SBUBaseChannelViewModel {
    // MARK: - Constant
    private let changelogFetchLimit: Int = 100
    
    // MARK: - Logic properties (Public)
    public weak var delegate: SBUOpenChannelViewModelDelegate? {
        get { self.baseDelegate as? SBUOpenChannelViewModelDelegate }
        set { self.baseDelegate = newValue }
    }
    
    public weak var dataSource: SBUOpenChannelViewModelDataSource? {
        get { self.baseDataSource as? SBUOpenChannelViewModelDataSource }
        set { self.baseDataSource = newValue }
    }
    
    // MARK: - Logic properties (Private)
    
    @SBUAtomic private var hasMorePrevious: Bool = true
    @SBUAtomic private var hasMoreNext: Bool = false
    
    @SBUAtomic private var changelogToken: String?
    @SBUAtomic private var lastUpdatedTimestamp: Int64 = 0
    private var currentTimeMillis: Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    private var initSucceeded: Bool = false
    
    // MARK: - LifeCycle
    public init(channel: BaseChannel? = nil,
                channelURL: String? = nil,
                messageListParams: MessageListParams? = nil,
                startingPoint: Int64? = nil,
                delegate: SBUOpenChannelViewModelDelegate? = nil,
                dataSource: SBUOpenChannelViewModelDataSource? = nil) {
        super.init()
    
        self.delegate = delegate
        self.dataSource = dataSource
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        self.customizedMessageListParams = messageListParams
        self.startingPoint = startingPoint
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(
            channelURL: channelURL,
            messageListParams: self.customizedMessageListParams
        )
        
        self.setupSendUserMessageCompletionHandlers()
        self.setupSendFileMessageCompletionHandlers()
    }
    
    deinit {
        SBULog.info("")
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.openChannelDelegateIdentifier).\(self.description)"
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
        
        SendbirdUI.connectIfNeeded { _, error in
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            SBULog.info("[Request] Load channel: \(String(channelURL))")
            OpenChannel.getChannel(url: channelURL) { [weak self] channel, error in
                guard let self = self else {
                    completionHandler?(nil, error)
                    return
                }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self.delegate?.didReceiveError(error, isBlocker: true)
                    completionHandler?(nil, error)
                    return
                }
                
                channel?.enter { [weak self] (error) in
                    guard let self = self else {
                        completionHandler?(nil, error)
                        return
                    }
                    if let error = error {
                        SBULog.error("[Failed] Enter channel request: \(error.localizedDescription)")
                        self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: nil)
                        completionHandler?(nil, error)
                        return
                    }
                    
                    SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                    self.channel = channel
                    
                    self.refreshChannel()
                    
                    completionHandler?(channel, nil)
                    
                    let cachedMessages = self.flushCache(with: [])
                    self.loadInitialMessages(
                        startingPoint: self.startingPoint,
                        showIndicator: true,
                        initialMessages: cachedMessages
                    )
                }
            }
        }
    }
    
    public override func refreshChannel() {
        if let channel = self.channel as? OpenChannel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    
                    if error.code != CoreError.networkError.rawValue {
                        self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: nil)
                    } else {
                        self.delegate?.didReceiveError(error, isBlocker: true)
                    }
                }
                
                SBULog.info("[Succeed] Refresh channel request")
                let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
                self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)

                self.loadMessageChangeLogs()
            }
        } else if let channelURL = self.channelURL {
            self.loadChannel(channelURL: channelURL)
        }
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
        self.startingPoint = startingPoint
        self.reset()
        
        if self.hasNext() {
            // Hold on to most recent messages in cache for smooth scrolling.
            setupCache()
        }
        
        if let initialMessages = initialMessages,
           !initialMessages.isEmpty {
            self.handleInitialResponse(usedParam: nil, messages: initialMessages, error: nil)
        } else {
            self.loadBothMessages(timestamp: startingPoint, showIndicator: showIndicator)
        }
    }
    
    public override func loadPrevMessages() {
        self.loadPrevMessages(timestamp: .max)
    }
    
    /// Loads previous messages from given timestamp.
    /// - Parameter timestamp: Timestamp to load messages from to the `previous` direction, or `nil` to start from the latest (`Int64.max`).
    public func loadPrevMessages(timestamp: Int64?) {
        guard self.prevLock.try() else {
            SBULog.info("Prev message already loading")
            return
        }
        
        SBULog.info("[Request] Prev message list from : \(String(describing: timestamp))")
        
        let params = self.messageListParams.copy() as? MessageListParams ?? MessageListParams()
        params.nextResultSize = 0
        
        if params.previousResultSize == 0 {
            params.previousResultSize = self.defaultFetchLimit
        }
        
        channel?.getMessagesByTimestamp(
            timestamp ?? .max,
            params: params
        ) { [weak self] (messages, error) in
            guard let self = self else { return }
            defer {
                self.prevLock.unlock()
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            guard self.isValidResponse(messages: messages, error: error),
                  let messages = messages else {
                SBULog.warning("Prev message list request is not valid")
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
        }
    }
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    public override func loadNextMessages() {
        guard self.nextLock.try() else {
            SBULog.info("Next message already loading")
            return
        }
        
        SBULog.info("[Request] Next message list from : \(self.lastUpdatedTimestamp)")

        let params: MessageListParams = self.messageListParams.copy() as? MessageListParams ?? MessageListParams()
        params.previousResultSize = 0
        if params.nextResultSize == 0 {
            params.nextResultSize = self.defaultFetchLimit
        }

        self.isLoadingNext = true

        self.channel?.getMessagesByTimestamp(
            self.lastUpdatedTimestamp,
            params: params
        ) { [weak self] messages, error in
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
            
            let prevHasNext = self.hasNext()
            self.hasMoreNext = messages.count >= params.nextResultSize
            
            var mergedList: [BaseMessage]?
            if !self.hasNext() && (self.hasNext() != prevHasNext) {
                mergedList = self.flushCache(with: messages)
            }
            
            self.updateLastUpdatedTimestamp(messages: mergedList ?? messages)
            
            SBULog.info("[Next message Response] \(messages.count) messages")
            
            self.delegate?.baseChannelViewModel(
                self,
                shouldUpdateScrollInMessageList: mergedList ?? messages,
                forContext: nil,
                keepsScroll: true
            )
            self.upsertMessagesInList(messages: mergedList ?? messages, needReload: true)
        }
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
        
        let params = self.messageListParams.copy() as? MessageListParams ?? MessageListParams()
        params.isInclusive = true
        
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
            if params.previousResultSize == 0 { params.previousResultSize = self.defaultFetchLimit / 2 }
            if params.nextResultSize == 0 { params.nextResultSize = self.defaultFetchLimit / 2 }
        } else {
            // prev only
            if params.previousResultSize == 0 {
                params.previousResultSize = self.defaultFetchLimit
            }
            params.nextResultSize = 0
        }
        
        let startingTimestamp: Int64 = timestamp ?? .max
        SBULog.info("Fetch from : \(startingTimestamp) limit: prev = \(params.previousResultSize), next = \(params.nextResultSize)")
        self.isLoadingNext = true
        
        channel?.getMessagesByTimestamp(
            startingTimestamp,
            params: params
        ) { [weak self] (messages, error) in
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
    }
    
    /// Handles response from initial loading request of messages (see `loadInitialMessages(startingPoint:showIndicator:initialMessages:)`).
    /// - Parameters:
    ///   - usedParam: `MessageListParams` used in `loadInitialMessages`, or `nil` if it was called from custom message list.
    ///   - messages: Messages loaded.
    ///   - error: `SBError` from loading messages.
    private func handleInitialResponse(usedParam: MessageListParams?,
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
        
        SBULog.info("[Initial message response] First : \(String(describing: messages.first)), Last : \(String(describing: messages.last))")
        
        self.updateLastUpdatedTimestamp(messages: messages)
        
        self.upsertMessagesInList(messages: messages, needReload: true)
    }
    
    override func handlePendingResendableMessage<Message: BaseMessage>(_ message: Message?, _ error: SBError?) {
        if let error = error {
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: message?.channelURL,
                message: message
            )
            
            self.sortAllMessageList(needReload: true)
            
            self.baseDelegate?.didReceiveError(error, isBlocker: false)
            
            SBULog.error("[Failed] Resend failed user message request: \(error.localizedDescription)")
            return
            
        } else {
            guard let message = message else { return }
            
            self.pendingMessageManager.removePendingMessage(
                channelURL: message.channelURL,
                requestId: message.requestId
            )
            
            SBULog.info("[Succeed] Resend failed file message: \(message.description)")
            
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    // MARK: - Last Updated timestamp
    private func updateLastUpdatedTimestamp(messages: [BaseMessage]) {
        SBULog.info("hasNext : \(String(describing: self.hasNext)). first : \(String(describing: messages.first)), last : \(String(describing: messages.last))")
        
        let currentTime = self.currentTimeMillis
        var newTimestamp: Int64 = 0
        
        if self.hasNext() {
            if let latestMessage = messages.last {
                newTimestamp = latestMessage.createdAt
            }
        } else {
            // TODO: Remove after confirmation
            if let latestMessage = messages.last {
                newTimestamp = latestMessage.createdAt
            }
        }
        
        SBULog.info("newTimestamp : \(newTimestamp), lastUpdatedTimestamp : \(self.lastUpdatedTimestamp), currentTime : \(currentTime)")
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
        SBULog.info("reset timestamp to : \(self.lastUpdatedTimestamp), startingPoint : \(String(describing: self.startingPoint)) currentTime : \(currentTime)")
    }
    
    // MARK: - Changelog
    
    /// Loads SDK's changelog (updated + deleted) fully + new added messages (fully || once depending on `hasNext`)
    private func loadMessageChangeLogs() {
        guard self.initSucceeded else {
            self.loadInitialMessages(startingPoint: self.startingPoint, showIndicator: false, initialMessages: nil)
            return
        }
        
        /// Prevent loadNext being called if changelog is called
        guard self.nextLock.try() else { return }
        
        let changeLogsParams = MessageChangeLogsParams.create(with: self.messageListParams)
        
        if self.hasNext() {
            self.messageCache?.loadNext()
        }

        var completion: (([BaseMessage]?, [Int64]?, Bool, String?, SBError?) -> Void)!
        completion = { [weak self] updatedMessages, deletedMessageIds, hasMore, nextToken, error in
            self?.handleChangelogResponse(
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
        
        let params: MessageListParams = messageListParams.copy() as? MessageListParams ?? MessageListParams()
        params.previousResultSize = 0
        params.nextResultSize = self.changelogFetchLimit
        
        self.channel?.getMessagesByTimestamp(self.lastUpdatedTimestamp, params: params) { [weak self] messages, error in
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
        
        self.messageCache?.applyChangeLog(updated: updatedMessages,
                                         deleted: deletedMessageIds)
    }
    
    /// Handling added messages
    ///
    /// - Returns: Whether there's more messages to fetch or not.
    private func handleChangelogResponse(addedMessages: [BaseMessage]) -> Bool {
        var mergedList: [BaseMessage]?
        let hasMore = addedMessages.count >= self.changelogFetchLimit
        
        if !hasMore, self.hasNext() {
            self.hasMoreNext = false
            mergedList = self.flushCache(with: addedMessages)
        }

        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: mergedList ?? addedMessages,
            forContext: nil,
            keepsScroll: true
        )
        self.upsertMessagesInList(messages: mergedList ?? addedMessages, needReload: true)
        
        SBULog.info("Loaded added messages : \(addedMessages.count), hasNext : \(String(describing: self.hasNext))")
        
        return hasMore
    }
    
    // MARK: - Message
    open func setupSendUserMessageCompletionHandlers() {
        self.sendUserMessageCompletionHandler = { [weak self] userMessage, error in
            guard let self = self else { return }
            guard self.channel is OpenChannel else { return }
            
            if let error = error {
                self.pendingMessageManager.upsertPendingMessage(
                    channelURL: userMessage?.channelURL,
                    message: userMessage
                )
                
                self.sortAllMessageList(needReload: true)
                
                self.baseDelegate?.didReceiveError(error)
                SBULog.error("[Failed] Send user message request: \(error.localizedDescription)")
                return
            }

            guard let userMessage = userMessage else { return }
            
            self.pendingMessageManager.removePendingMessage(
                channelURL: userMessage.channelURL,
                requestId: userMessage.requestId
            )
            
            SBULog.info("[Succeed] Send user message: \(userMessage.description)")
            self.upsertMessagesInList(messages: [userMessage], needReload: true)
        }
    }

    open func setupSendFileMessageCompletionHandlers() {
        self.sendFileMessageCompletionHandler = { [weak self] fileMessage, error in
            guard let self = self else { return }
            guard self.channel is OpenChannel else { return }
            
            if let error = error {
                if let fileMessage = fileMessage, self.messageListParams.belongsTo(fileMessage) {
                    self.pendingMessageManager.upsertPendingMessage(
                        channelURL: fileMessage.channelURL,
                        message: fileMessage
                    )
                }
                
                self.sortAllMessageList(needReload: true)

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
                requestId: fileMessage.requestId
            )
            
            SBULog.info("[Succeed] Send file message: \(fileMessage.description)")
            
            self.upsertMessagesInList(messages: [fileMessage], needReload: true)
        }
    }
    
    // MARK: - Common
    
    /// Checks if the response of loading message is valid.
    /// - Parameters:
    ///   - messages: Messages loaded.
    ///   - error: `SBError` from loading messages.
    /// - Returns: `true` if response is valid.
    private func isValidResponse(messages: [BaseMessage]?, error: SBError?) -> Bool {
        if let error = error {
            SBULog.error("[Failed] Message list request: \(error)")
            self.isLoadingNext = false
            self.delegate?.didReceiveError(error, isBlocker: true)
            return false
        }
        
        guard messages != nil else {
            SBULog.warning("Message list request is nil")
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
        
        super.reset()
    }
}

// MARK: - ConnectionDelegate
extension SBUOpenChannelViewModel {
    // MARK: ConnectionDelegate
    open override func didSucceedReconnection() {
        super.didSucceedReconnection()
    }
}

// MARK: - OpenChannelDelegate
extension SBUOpenChannelViewModel: OpenChannelDelegate {
    // Received message
    open override func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard self.messageListParams.belongsTo(message) else { return }

        super.channel(channel, didReceive: message)
        
        let isScrollNearBottom = self.dataSource?.baseChannelViewModel(self, isScrollNearBottomInChannel: self.channel) ?? true
        if self.hasNext() == true || isScrollNearBottom == false {
            self.messageCache?.add(messages: [message])

            guard message is UserMessage || message is FileMessage else { return }
            
            if let channel = self.channel {
                self.delegate?.baseChannelViewModel(self, didReceiveNewMessage: message, forChannel: channel)
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
        SBULog.info("Did update message: \(message)")
        self.updateMessagesInList(messages: [message], needReload: true)
    }
    
    // Deleted message
    open override func channel(_ channel: BaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        SBULog.info("Message was deleted: \(messageId)")
        self.deleteMessagesInList(messageIds: [messageId], needReload: true)
    }
      
    open override func channelWasChanged(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? OpenChannel else { return }
        self.channel = channel
        
        SBULog.info("Channel was changed, ChannelURL:\(channel.channelURL)")

        let context = MessageContext(source: .eventChannelChanged, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channelWasFrozen(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? OpenChannel else { return }
        SBULog.info("Channel was frozen, ChannelURL:\(channel.channelURL)")
        
        let context = MessageContext(source: .eventChannelFrozen, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open override func channelWasUnfrozen(_ channel: BaseChannel) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard let channel = channel as? OpenChannel else { return }
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
    
    open func channel(_ channel: OpenChannel, userDidEnter user: User) {
        guard self.channel?.channelURL == channel.channelURL else { return }

        let context = MessageContext(source: .eventChannelMemberCountChanged, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        self.delegate?.openChannelViewModel(self, userDidEnter: user, forChannel: channel)
    }
    
    open func channel(_ channel: OpenChannel, userDidExit user: User) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        let context = MessageContext(source: .eventChannelMemberCountChanged, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
        self.delegate?.openChannelViewModel(self, userDidExit: user, forChannel: channel)
    }
    
    open override func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {
        guard self.channel?.channelURL == channelURL else { return }
        
        let context = MessageContext(source: .eventChannelDeleted, sendingStatus: .succeeded)
        self.delegate?.baseChannelViewModel(self, didChangeChannel: nil, withContext: context)
    }
}
