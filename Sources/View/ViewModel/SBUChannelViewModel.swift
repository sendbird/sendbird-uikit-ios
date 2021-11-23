//
//  SBUChannelViewModel.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

class SBUChannelViewModel: SBULoadableViewModel {
    
    // MARK: - Properties
    
    let defaultFetchLimit: Int = 30
    
    let prevLock = NSLock()
    let nextLock = NSLock()
    let initialLock = NSLock()
    
    /// Custom param set by user.
    private let customizedMessageListParams: SBDMessageListParams?
    private(set) var messageListParams = SBDMessageListParams()
    
    let channel: SBDBaseChannel
    var groupChannel: SBDGroupChannel? {
        self.channel as? SBDGroupChannel
    }
    
    /// Memory cache of newest messages to be used when message has loaded from specific timestamp.
    private(set) var messageCache: SBUMessageCache?
    
    var messageCollection: SBDMessageCollection?
    let initPolicy: SBDMessageCollectionInitPolicy = .cacheAndReplaceByApi
    
    var initSucceeded: Bool = false
    @SBUAtomic var isLoadingNext = false
    
    // MARK: - Properties (Observable)
    
    let initialLoadObservable = SBUObservable<(fromCache: Bool, messages: [SBDBaseMessage])>()
    let messageUpsertObservable = SBUObservable<([SBDBaseMessage], SBDMessageContext?, Bool)>()
    let messageDeleteObservable = SBUObservable<[Int64]>()
    let channelChangeObservable = SBUObservable<(SBDMessageContext, SBDGroupChannel?)>()
    let hugeGapObservable = SBUObservable<Void>()
    
    // MARK: - Constructor
    
    init(channel: SBDBaseChannel, customizedMessageListParams: SBDMessageListParams?) {
        self.channel = channel
        self.customizedMessageListParams = customizedMessageListParams
        super.init()
    }
    
    
    // MARK: - Initialize
    
    private func initMessageListParams() {
        self.messageListParams = self.customizedMessageListParams?.copy() as? SBDMessageListParams
            ?? SBDMessageListParams()
        
        if self.messageListParams.previousResultSize <= 0 {
            self.messageListParams.previousResultSize = self.defaultFetchLimit
        }
        if self.messageListParams.nextResultSize <= 0 {
            self.messageListParams.nextResultSize = self.defaultFetchLimit
        }
        
        self.messageListParams.reverse = true
        self.messageListParams.includeReactions = SBUEmojiManager.useReaction(channel: channel)
        
        self.messageListParams.includeThreadInfo = true
        self.messageListParams.includeParentMessageInfo = SBUGlobals.ReplyTypeToUse != .none
        self.messageListParams.replyType = SBUGlobals.ReplyTypeToUse.filterValue
    }
    
    private func createMessageCollection(startingPoint: Int64) {
        guard let groupChannel = self.groupChannel else { return }
        
        self.messageCollection = SBDMessageCollection(channel: groupChannel,
                                                      startingPoint: startingPoint,
                                                      params: self.messageListParams)
        self.messageCollection?.delegate = self
    }
    
    // MARK: - Common
    
    func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        guard showIndicator else { return }
        loadingObservable.post(value: loadingState)
    }
    
    func hasNext() -> Bool {
        return self.messageCollection?.hasNext ?? (self.getStartingPoint() != nil)
    }
    
    func hasPrevious() -> Bool {
        return self.messageCollection?.hasPrevious ?? true
    }
    
    func getStartingPoint() -> Int64? {
        return self.messageCollection?.startingPoint
    }
    
    func resetRequestingLoad() {
        self.isLoadingNext = false
    }
    
    func reset() {
        self.messageCache = nil
        self.initMessageListParams()
        self.groupChannel?.markAsRead(completionHandler: nil)
    }
    
    func markAsRead() {
        self.groupChannel?.markAsRead(completionHandler: nil)
    }

    
    // MARK: - Cache
    
    func setupCache() {
        self.messageCache = SBUMessageCache(channel: channel,
                                            messageListParam: self.messageListParams)
        self.messageCache?.loadInitial()
    }
    
    func flushCache(with messages: [SBDBaseMessage]) -> [SBDBaseMessage] {
        SBULog.info("flushing cache with : \(messages.count)")
        guard let messageCache = self.messageCache else { return messages }
        
        let mergedList = messageCache.flush(with: messages)
        self.messageCache = nil
        
        return mergedList
    }
    
    // MARK: - Typing
    
    func startTypingMessage() {
        SBULog.info("[Request] End typing")
        self.groupChannel?.startTyping()
    }
    
    func endTypingMessage() {
        SBULog.info("[Request] End typing")
        self.groupChannel?.endTyping()
    }
    
    
    // MARK: - Load Messages
    
    /// Loads initial messages in channel.
    /// `NOT` using `initialMessages` here since `SBDMessageCollection` handles messages from db.
    /// Only used in `SBUOpenChannelViewModel` where `SBDMessageCollection` is not suppoorted.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`LLONG_MAX`)
    ///   - showIndicator: Whether to show indicator on load or not.
    ///   - initialMessages: Custom messages to start the messages from.
    func loadInitialMessages(startingPoint: Int64?, showIndicator: Bool, initialMessages: [SBDBaseMessage]?) {
        SBULog.info("""
            loadInitialMessages,
            startingPoint : \(String(describing: startingPoint)),
            initialMessages : \(String(describing: initialMessages))
            """
        )
        
        self.reset()
        self.createMessageCollection(startingPoint: startingPoint ?? LLONG_MAX)
        
        if self.hasNext() {
            // Hold on to most recent messages in cache for smooth scrolling.
            setupCache()
        }
        
        self.messageCollection?.start(
            with: initPolicy,
            cacheResultHandler: { [weak self] cacheResult, error in
            guard let self = self else { return }
            if let error = error {
                self.errorObservable.set(value: error)
                return
            }
            
            self.initialLoadObservable.set(value: (true, cacheResult ?? []))
        }, apiResultHandler: { [weak self] apiResult, error in
            guard let self = self else { return }
            
            self.loadInitialPendingMessages()
            
            if let error = error {
                // ignore error if using local caching
                if !SBDMain.isUsingLocalCaching() {
                    self.errorObservable.set(value: error)
                }
                return
            }
            
            self.initialLoadObservable.set(value: (false, apiResult ?? []))
        }
        )
    }
    
    func loadInitialPendingMessages() {
        let pendingMessages = self.messageCollection?.getPendingMessages() ?? []
        let failedMessages = self.messageCollection?.getFailedMessages() ?? []
        let cachedTempMessages = pendingMessages + failedMessages
        for message in cachedTempMessages {
            SBUPendingMessageManager.shared.upsertPendingMessage(channelUrl: self.channel.channelUrl, message: message)
            if let fileMessage = message as? SBDFileMessage,
               let fileMessageParams = fileMessage.getParams() {
                SBUPendingMessageManager.shared.addFileInfo(requestId: fileMessage.requestId, params: fileMessageParams)
            }
        }
    }
    
    /// Loads previous messages from given timestamp.
    /// - Parameter timestamp: Timestamp to load messages from to the `previous` direction, or `nil` to start from the latest (`LLONG_MAX`).
    func loadPrevMessages(timestamp: Int64?) {
        guard let messageCollection = self.messageCollection else { return }
        guard self.prevLock.try() else {
            SBULog.info("Prev message already loading")
            return
        }
        
        SBULog.info("[Request] Prev message list from : \(String(describing: timestamp))")
        self.setLoading(true, false)
        
        messageCollection.loadPrevious { [weak self] messages, error in
            guard let self = self else { return }
            defer {
                self.prevLock.unlock()
                self.setLoading(false, false)
            }
            
            if let error = error {
                self.errorObservable.set(value: error)
                return
            }
            guard let messages = messages else { return }
            
            SBULog.info("[Prev message response] \(messages.count) messages")
            
            self.messageUpsertObservable.set(value: (messages, nil, false))
        }
    }
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    func loadNextMessages() {
        guard let messageCollection = self.messageCollection else { return }
        guard self.nextLock.try() else {
            SBULog.info("Next message already loading")
            return
        }
        
        self.setLoading(true, false)
        
        messageCollection.loadNext { [weak self] messages, error in
            guard let self = self else { return }
            defer {
                self.nextLock.unlock()
                self.resetRequestingLoad()
                self.setLoading(false, false)
            }
            
            if let error = error {
                self.errorObservable.set(value: error)
                return
            }
            guard let messages = messages else { return }
            
            SBULog.info("[Next message Response] \(messages.count) messages")
            
            self.messageUpsertObservable.set(value: (messages, nil, true))
        }
        
        self.isLoadingNext = true
    }
    
    
    // MARK: - SBUViewModelDelegate
    
    override func dispose() {
        super.dispose()
        
        self.messageCollection?.dispose()
        
        self.initialLoadObservable.dispose()
        self.messageUpsertObservable.dispose()
        self.messageDeleteObservable.dispose()
        self.channelChangeObservable.dispose()
        self.hugeGapObservable.dispose()
    }
}


extension SBUChannelViewModel: SBDMessageCollectionDelegate {
    func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           channel: SBDGroupChannel,
                           addedMessages messages: [SBDBaseMessage])
    {
        // -> pending, -> receive new message
        SBULog.info("messageCollection addedMessages : \(messages.count)")
        switch context.source {
        case .eventMessageReceived:
            self.groupChannel?.markAsRead(completionHandler: nil)
        default: break
        }
        self.messageUpsertObservable.set(value: (messages, context, true))
    }
    
    func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           channel: SBDGroupChannel,
                           updatedMessages messages: [SBDBaseMessage])
    {
        // pending -> failed, pending -> succeded, failed -> Pending
        SBULog.info("messageCollection updatedMessages : \(messages.count)")
        self.messageUpsertObservable.set(value: (messages, context, false))
    }
    
    func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           channel: SBDGroupChannel,
                           deletedMessages messages: [SBDBaseMessage])
    {
        SBULog.info("messageCollection deletedMessages : \(messages.count)")
        self.messageDeleteObservable.set(value: messages.compactMap({ $0.messageId }))
    }
    
    func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           updatedChannel channel: SBDGroupChannel)
    {
        SBULog.info("messageCollection changedChannel")
        self.channelChangeObservable.set(value: (context, channel))
    }
    
    func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           deletedChannel channelUrl: String)
    {
        SBULog.info("messageCollection deletedChannel")
        self.channelChangeObservable.set(value: (context, nil))
    }
    
    func didDetectHugeGap(_ collection: SBDMessageCollection) {
        SBULog.info("messageCollection didDetectHugeGap")
        self.messageCollection?.dispose()
        self.hugeGapObservable.set(value: ())
    }
}
