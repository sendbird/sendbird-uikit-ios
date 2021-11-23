//
//  SBUOpenChannelViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/06/03.
//  Copyright © 2021 SendBird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUOpenChannelViewModel: SBUChannelViewModel {
    
    // MARK: - Properties
    
    private let changelogFetchLimit: Int = 100
    
    private var startingPoint: Int64? {
        didSet { self.hasMoreNext = self.startingPoint != nil }
    }
    
    @SBUAtomic private var hasMorePrevious: Bool = true
    @SBUAtomic private var hasMoreNext: Bool = false
    
    @SBUAtomic private var changelogToken: String? = nil
    @SBUAtomic private var lastUpdatedTimestamp: Int64 = 0
    private var currentTimeMillis: Int64 {
        return Int64(Date().timeIntervalSince1970 * 1000)
    }
    
    // MARK: - Common
    
    override func hasNext() -> Bool {
        return self.hasMoreNext
    }
    
    override func hasPrevious() -> Bool {
        return self.hasMorePrevious
    }
    
    override func getStartingPoint() -> Int64? {
        return self.startingPoint
    }
    
    override func reset() {
        self.hasMorePrevious = true
        self.hasMoreNext = self.startingPoint != nil
        self.resetLastUpdatedTimestamp()
        
        super.reset()
    }
    
    // MARK: - Load Messages
    
    /// Loads initial messages in channel.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`LLONG_MAX`)
    ///   - showIndicator: Whether to show indicator on load or not.
    ///   - initialMessages: Custom messages to start the messages from.
    override func loadInitialMessages(startingPoint: Int64?, showIndicator: Bool, initialMessages: [SBDBaseMessage]?) {
        SBULog.info("""
            loadInitialMessages,
            startingPoint : \(String(describing: startingPoint)),
            initialMessages : \(String(describing: initialMessages))
            """
        )
        
        self.startingPoint = startingPoint
        self.reset()
        
        if self.hasNext() {
            // Hold on to most recent messages in cache for smooth scrolling.
            setupCache()
        }
        
        if let initialMessages = initialMessages,
           !initialMessages.isEmpty {
            self.handleInitialResponse(usedParam: nil,
                                       messages: initialMessages,
                                       error: nil)
        } else {
            self.loadBothMessages(timestamp: startingPoint, showIndicator: showIndicator)
        }
    }
    
    /// Loads messages to both direction from given timestamp.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`LLONG_MAX`)
    ///   - showIndicator: Whether to show indicator on load or not.
    private func loadBothMessages(timestamp: Int64?, showIndicator: Bool) {
        SBULog.info("[Request] Both message list from : \(String(describing: timestamp))")
        guard self.initialLock.try() else { return }
        
        self.setLoading(true, showIndicator)
        
        let params: SBDMessageListParams = self.messageListParams.copy() as? SBDMessageListParams ?? SBDMessageListParams()
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
        
        let startingTimestamp: Int64 = timestamp ?? LLONG_MAX
        SBULog.info("Fetch from : \(startingTimestamp) limit: prev = \(params.previousResultSize), next = \(params.nextResultSize)")
        self.isLoadingNext = true
        
        channel.getMessagesByTimestamp(startingTimestamp, params: params) { [weak self] (messages, error) in
            guard let self = self else { return }
            defer {
                self.setLoading(false, showIndicator)
                self.initialLock.unlock()
            }
            
            self.handleInitialResponse(usedParam: params,
                                       messages: messages,
                                       error: error)
        }
    }
    
    /// Handles response from initial loading request of messages (see `loadInitialMessages(startingPoint:showIndicator:initialMessages:)`).
    /// - Parameters:
    ///   - usedParam: `SBDMessageListParams` used in `loadInitialMessages`, or `nil` if it was called from custom message list.
    ///   - messages: Messages loaded.
    ///   - error: `SBDError` from loading messages.
    private func handleInitialResponse(usedParam: SBDMessageListParams?, messages: [SBDBaseMessage]?, error: SBDError?) {
        self.initSucceeded = error == nil
        
        guard self.isValidResponse(messages: messages, error: error),
              let messages = messages else {
            SBULog.warning("Initial message list request is not valid")
            self.resetRequestingLoad()
            return
        }
        
        SBULog.info("[Both message response] \(messages.count) messages")
        let startingTimestamp: Int64 = self.startingPoint ?? LLONG_MAX
        
        if let usedParam = usedParam {
            self.hasMorePrevious = messages.filter({ $0.createdAt <= startingTimestamp }).count >= usedParam.previousResultSize
            if usedParam.nextResultSize > 0 {
                // update hasNext only if message is fetched on next direction.
                self.hasMoreNext = messages.filter({ $0.createdAt >= startingTimestamp }).count >= usedParam.nextResultSize
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
        
        self.initialLoadObservable.set(value: (false, messages))
    }
    
    /// Loads previous messages from given timestamp.
    /// - Parameter timestamp: Timestamp to load messages from to the `previous` direction, or `nil` to start from the latest (`LLONG_MAX`).
    override func loadPrevMessages(timestamp: Int64?) {
        guard self.prevLock.try() else {
            SBULog.info("Prev message already loading")
            return
        }
        
        SBULog.info("[Request] Prev message list from : \(String(describing: timestamp))")
        self.setLoading(true, false)
        
        let params: SBDMessageListParams = self.messageListParams.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        params.nextResultSize = 0
        if params.previousResultSize == 0 {
            params.previousResultSize = self.defaultFetchLimit
        }
        
        channel.getMessagesByTimestamp(timestamp ?? LLONG_MAX, params: params) { [weak self] (messages, error) in
            guard let self = self else { return }
            defer {
                self.setLoading(false, false)
            }
            
            guard self.isValidResponse(messages: messages, error: error),
                  let messages = messages else {
                SBULog.warning("Prev message list request is not valid")
                self.prevLock.unlock()
                return
            }
            
            SBULog.info("[Prev message response] \(messages.count) messages")
            
            self.hasMorePrevious = messages.count >= params.previousResultSize
            self.updateLastUpdatedTimestamp(messages: messages)
            self.prevLock.unlock()
            
            self.messageUpsertObservable.set(value: (messages, nil, false))
        }
    }
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    override func loadNextMessages() {
        guard self.nextLock.try() else {
            SBULog.info("Next message already loading")
            return
        }
        
        SBULog.info("[Request] Next message list from : \(self.lastUpdatedTimestamp)")
        self.setLoading(true, false)
        
        let params: SBDMessageListParams = self.messageListParams.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        params.previousResultSize = 0
        if params.nextResultSize == 0 {
            params.nextResultSize = self.defaultFetchLimit
        }
        
        self.isLoadingNext = true
        
        self.channel.getMessagesByTimestamp(self.lastUpdatedTimestamp, params: params) { [weak self] messages, error in
            guard let self = self else { return }
            defer {
                self.setLoading(false, false)
            }
            
            guard self.isValidResponse(messages: messages, error: error),
                  let messages = messages else {
                SBULog.warning("Next message list request is not valid")
                self.resetRequestingLoad()
                self.nextLock.unlock()
                return
            }
            
            SBULog.info("[Next message Response] \(messages.count) messages")
            
            let prevHasNext = self.hasNext()
            self.hasMoreNext = messages.count >= params.nextResultSize
            
            var mergedList: [SBDBaseMessage]? = nil
            if !self.hasNext() && (self.hasNext() != prevHasNext) {
                mergedList = self.flushCache(with: messages)
            }
            
            self.updateLastUpdatedTimestamp(messages: mergedList ?? messages)
            self.nextLock.unlock()
            
            self.messageUpsertObservable.set(value: (mergedList ?? messages, nil, true))
        }
    }
    
    // MARK: - Handling response
    
    /// Checks if the response of loading message is valid.
    /// - Parameters:
    ///   - messages: Messages loaded.
    ///   - error: `SBDError` from loading messages.
    /// - Returns: `true` if response is valid.
    private func isValidResponse(messages: [SBDBaseMessage]?, error: SBDError?) -> Bool {
        if let error = error {
            SBULog.error("[Failed] Message list request: \(error)")
            self.resetRequestingLoad()
            self.errorObservable.set(value: error)
            return false
        }
        
        guard messages != nil else {
            SBULog.warning("Message list request is nil")
            self.resetRequestingLoad()
            return false
        }
        
        return true
    }
    
    
    // MARK: - Last Updated At
    
    private func updateLastUpdatedTimestamp(messages: [SBDBaseMessage]) {
        SBULog.info("hasNext : \(String(describing: self.hasNext)). first : \(String(describing: messages.first)), last : \(String(describing: messages.last))")
        
        let currentTime = self.currentTimeMillis
        var newTimestamp: Int64 = 0
        
        if self.hasNext() {
            if let latestMessage = messages.first {
                newTimestamp = latestMessage.createdAt
            }
        } else {
            if let groupChannel = self.channel as? SBDGroupChannel {
                newTimestamp = groupChannel.lastMessage?.createdAt ?? currentTime
            } else if self.channel is SBDOpenChannel {
                if let latestMessage = messages.first {
                    newTimestamp = latestMessage.createdAt
                }
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
    func loadMessageChangeLogs() {
        guard self.initSucceeded else {
            self.loadInitialMessages(startingPoint: self.startingPoint, showIndicator: false, initialMessages: nil)
            return
        }
        
        /// Prevent loadNext being called if changelog is called
        guard self.nextLock.try() else { return }
        
        let changeLogsParams = SBDMessageChangeLogsParams.create(with: self.messageListParams)
        
        if self.hasNext() {
            self.messageCache?.loadNext()
        }

        var completion: (([SBDBaseMessage]?, [NSNumber]?, Bool, String?, SBDError?) -> ())!
        completion = { [weak self] updatedMessages, deletedMessageIds, hasMore, nextToken, error in
            self?.handleChangelogResponse(updatedMessages: updatedMessages,
                                          deletedMessageIds: deletedMessageIds,
                                          hasMore: hasMore,
                                          nextToken: nextToken,
                                          error: error)
        }
        
        if let token = self.changelogToken {
            SBULog.info("[Request] Message change logs with token")
            self.channel.getMessageChangeLogs(sinceToken: token, params: changeLogsParams, completionHandler: completion)
        } else {
            SBULog.info("[Request] Message change logs with last updated timestamp")
            self.channel.getMessageChangeLogs(sinceTimestamp: self.lastUpdatedTimestamp, params: changeLogsParams, completionHandler: completion)
        }
    }
    
    /// Separated loadNext for changelog and normal loading on scroll.
    /// Difference on limit + handling response (setting hasNext, updatedAt, etc)
    private func loadNextMessagesForChangelog(completion: @escaping ([SBDBaseMessage]) -> Void) {
        SBULog.info("[Request] Changelog added message list from : \(self.lastUpdatedTimestamp)")
        
        let params: SBDMessageListParams = messageListParams.copy() as? SBDMessageListParams ?? SBDMessageListParams()
        params.previousResultSize = 0
        params.nextResultSize = self.changelogFetchLimit
        
        self.channel.getMessagesByTimestamp(self.lastUpdatedTimestamp, params: params) { [weak self] messages, error in
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
    private func handleChangelogResponse(updatedMessages: [SBDBaseMessage]?,
                                         deletedMessageIds: [NSNumber]?,
                                         hasMore: Bool,
                                         nextToken: String?,
                                         error: SBDError?) {
        if let error = error {
            SBULog.error("""
                [Failed] Message change logs request:
                \(error.localizedDescription)
                """)
            
            self.nextLock.unlock()
            self.errorObservable.set(value: error)
            return
        }
        
        SBULog.info("""
            [Response]
            \(String(format: "%d updated messages", updatedMessages?.count ?? 0)),
            \(String(format: "%d deleted messages", deletedMessageIds?.count ?? 0))
            """)
        
        self.changelogToken = nextToken
        
        self.handleChangelogResponse(updatedMessages: updatedMessages, deletedMessageIds: deletedMessageIds as? [Int64])
        
        if hasMore {
            self.loadMessageChangeLogs()
        } else {
            isLoadingNext = true
            
            var loadNextCompletion: (([SBDBaseMessage]) -> Void)!
            loadNextCompletion = { [weak self] messages in
                guard let self = self else { return }
                
                if let firstMessage = messages.first {
                    self.setLastUpdatedTimestamp(timestamp: firstMessage.createdAt)
                }
                
                let canLoadMore = self.handleChangelogResponse(addedMessages: messages)
                guard canLoadMore else {
                    self.nextLock.unlock()
                    self.resetRequestingLoad()
                    return
                }
                
                self.loadNextMessagesForChangelog(completion: loadNextCompletion)
            }
            
            self.loadNextMessagesForChangelog(completion: loadNextCompletion)
        }
    }
    
    /// Handling updated & deleted messages
    private func handleChangelogResponse(updatedMessages: [SBDBaseMessage]?, deletedMessageIds: [Int64]?) {
        if let updatedMessages = updatedMessages,
           !updatedMessages.isEmpty {
            self.messageUpsertObservable.set(value: (updatedMessages, nil, false))
        }
        if let deletedMessageIds = deletedMessageIds,
           !deletedMessageIds.isEmpty {
            self.messageDeleteObservable.set(value: deletedMessageIds)
        }
        
        self.messageCache?.applyChangeLog(updated: updatedMessages,
                                         deleted: deletedMessageIds)
    }
    
    /// Handling added messages
    ///
    /// - Returns: Whether there's more messages to fetch or not.
    private func handleChangelogResponse(addedMessages: [SBDBaseMessage]) -> Bool {
        var mergedList: [SBDBaseMessage]? = nil
        let hasMore = addedMessages.count >= self.changelogFetchLimit
        
        if !hasMore, self.hasNext() {
            self.hasMoreNext = false
            mergedList = self.flushCache(with: addedMessages)
        }
        
        self.messageUpsertObservable.set(value: (mergedList ?? addedMessages, nil, true))
        
        SBULog.info("Loaded added messages : \(addedMessages.count), hasNext : \(String(describing: self.hasNext))")
        
        return hasMore
    }
}
