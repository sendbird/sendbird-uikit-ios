//
//  SBUGroupChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/15.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK
import simd

@available(*, deprecated, renamed: "SBUGroupChannelViewModelDataSource") // 3.0.0
public typealias SBUChannelViewModelDataSource = SBUGroupChannelViewModelDataSource

@available(*, deprecated, renamed: "SBUGroupChannelViewModelDelegate") // 3.0.0
public typealias SBUChannelViewModelDelegate = SBUGroupChannelViewModelDelegate

@available(*, deprecated, renamed: "SBUGroupChannelViewModel") // 3.0.0
public typealias SBUChannelViewModel = SBUGroupChannelViewModel

public protocol SBUGroupChannelViewModelDataSource: SBUBaseChannelViewModelDataSource {
    /// Asks to data source to return the array of index path that represents starting point of channel.
    /// - Parameters:
    ///    - viewModel: `SBUGroupChannelViewModel` object.
    ///    - channel: `SBDGroupChannel` object from `viewModel`
    /// - Returns: The array of `IndexPath` object representing starting point.
    func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        startingPointIndexPathsForChannel channel: SBDGroupChannel?
    ) -> [IndexPath]?
}

public protocol SBUGroupChannelViewModelDelegate: SBUBaseChannelViewModelDelegate {
    /// Called when the channel has received mentional member list. Please refer to `loadSuggestedMentions(with:)` in `SBUGroupChannelViewModel`.
    /// - Parameters:
    ///   - viewModel: `SBUGroupChannelViewModel` object.
    ///   - users: Mentional members
    func groupChannelViewModel(
        _ viewModel: SBUGroupChannelViewModel,
        didReceiveSuggestedMentions users: [SBUUser]?
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

    
    // MARK: - Logic properties (private)
    var messageCollection: SBDMessageCollection?
    var debouncer: SBUDebouncer?
    var suggestedMemberList: [SBUUser]?

    
    // MARK: - LifeCycle
    public init(channel: SBDBaseChannel? = nil,
                channelUrl: String? = nil,
                messageListParams: SBDMessageListParams? = nil,
                startingPoint: Int64? = LLONG_MAX,
                delegate: SBUGroupChannelViewModelDelegate? = nil,
                dataSource: SBUGroupChannelViewModelDataSource? = nil)
    {
        super.init()
    
        self.delegate = delegate
        self.dataSource = dataSource
        
        if let channel = channel {
            self.channel = channel
            self.channelUrl = channel.channelUrl
        } else if let channelUrl = channelUrl {
            self.channelUrl = channelUrl
        }
        
        self.customizedMessageListParams = messageListParams
        self.startingPoint = startingPoint
        
        self.debouncer = SBUDebouncer(
            debounceTime: SBUGlobals.userMentionConfig?.debounceTime ?? SBUDebouncer.defaultTime
        )
        
        guard let channelUrl = self.channelUrl else { return }
        self.loadChannel(
            channelUrl: channelUrl,
            messageListParams: self.customizedMessageListParams
        )
    }
    
    deinit {
        self.messageCollection?.dispose()
    }

    
    // MARK: - Channel related
    public override func loadChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else if self.customizedMessageListParams == nil {
            let messageListParams = SBDMessageListParams()
            SBUGlobalCustomParams.messageListParamsBuilder?(messageListParams)
            self.customizedMessageListParams = messageListParams
        }
        
        // TODO: loading
//        self.delegate?.shouldUpdateLoadingState(true)
        
        SendbirdUI.connectIfNeeded { [weak self] user, error in
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: true)
                return
            }
            
            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }

                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                self.channel = channel
                
                guard self.canProceed(with: channel, error: error) else { return }
                
                // background refresh to check if user is banned or not.
                self.refreshChannel()

                // for updating channel information when the connection state is closed at the time of initial load.
                if SBDMain.getConnectState() == .closed {
                    let context = SBDMessageContext()
                    context.source = .eventChannelChanged
                    self.delegate?.baseChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
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
        if let channel = self.channel as? SBDGroupChannel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                guard self.canProceed(with: channel, error: error) == true else { return }
                
                let context = SBDMessageContext()
                context.source = .eventChannelChanged
                self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
            }
        } else if let channelUrl = self.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }
    }
    
    private func canProceed(with channel: SBDGroupChannel?, error: SBDError?) -> Bool {
        if let error = error {
            SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
            
            if error.code == SBDErrorCode.nonAuthorized.rawValue {
                self.delegate?.baseChannelViewModel(self, shouldDismissForChannel: nil)
            } else {
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
    
    private func belongsToChannel(error: SBDError) -> Bool {
        return error.code != SBDErrorCode.nonAuthorized.rawValue
    }
    
    
    // MARK: - Load Messages
    public override func loadInitialMessages(startingPoint: Int64?,
                                      showIndicator: Bool,
                                      initialMessages: [SBDBaseMessage]?) {
        SBULog.info("""
            loadInitialMessages,
            startingPoint : \(String(describing: startingPoint)),
            initialMessages : \(String(describing: initialMessages))
            """
        )
        
        // Caution in function call order
        self.reset()
        self.createCollectionIfNeeded(startingPoint: startingPoint ?? LLONG_MAX)
        if self.initPolicy == .cacheAndReplaceByApi {
            self.clearMessageList()
        }
        
        if self.hasNext() {
            // Hold on to most recent messages in cache for smooth scrolling.
            setupCache()
        }
        
        self.delegate?.shouldUpdateLoadingState(showIndicator)
        
        self.messageCollection?.start(
            with: initPolicy,
            cacheResultHandler: { [weak self] cacheResult, error in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    return
                }
                
                // prevent empty view showing
                if cacheResult == nil, cacheResult?.isEmpty == true { return }
                
                self.isInitialLoading = true
                self.upsertMessagesInList(messages: cacheResult, needReload: true)
                
            }, apiResultHandler: { [weak self] apiResult, error in
                guard let self = self else { return }
                
                self.loadInitialPendingMessages()
                
                if let error = error {
                    self.delegate?.shouldUpdateLoadingState(false)
                    
                    // ignore error if using local caching
                    if !SBDMain.isUsingLocalCaching() {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    }
                    return
                }
                
                self.upsertMessagesInList(messages: apiResult, needReload: true)
                self.isInitialLoading = false
            })
    }
    
    func loadInitialPendingMessages() {
        let pendingMessages = self.messageCollection?.getPendingMessages() ?? []
        let failedMessages = self.messageCollection?.getFailedMessages() ?? []
        let cachedTempMessages = pendingMessages + failedMessages
        for message in cachedTempMessages {
            SBUPendingMessageManager.shared.upsertPendingMessage(channelUrl: self.channel?.channelUrl, message: message)
            if let fileMessage = message as? SBDFileMessage,
               let fileMessageParams = fileMessage.messageParams as? SBDFileMessageParams {
                SBUPendingMessageManager.shared.addFileInfo(requestId: fileMessage.requestId, params: fileMessageParams)
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
    
    override public func deleteResendableMessage(_ message: SBDBaseMessage, needReload: Bool) {
        if self.channel is SBDGroupChannel {
            self.messageCollection?.removeFailedMessages([message], completionHandler: nil)
        }
        super.deleteResendableMessage(message, needReload: needReload)
    }
    
    // MARK: - Message related
    public func markAsRead() {
        if let channel = self.channel as? SBDGroupChannel {
            channel.markAsRead(completionHandler: nil)
        }
    }
    
    
    // MARK: - Typing
    public func startTypingMessage() {
        guard let channel = self.channel as? SBDGroupChannel else { return }

        SBULog.info("[Request] End typing")
        channel.startTyping()
    }
    
    public func endTypingMessage() {
        guard let channel = self.channel as? SBDGroupChannel else { return }

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
            
            if let channel = self.channel as? SBDGroupChannel {
                if channel.isSuper {
                    let query = channel.createMemberListQuery()
                    query?.limit = UInt(SBUGlobals.userMentionConfig?.suggestionLimit ?? 0)
                    query?.nicknameStartsWithFilter = filterText
                    
                    query?.loadNextPage { [weak self] members, error in
                        guard let self = self else { return }
                        self.suggestedMemberList = SBUUser.convertUsers(members)
                        self.delegate?.groupChannelViewModel(
                            self,
                            didReceiveSuggestedMentions: self.suggestedMemberList
                        )
                    }
                } else {
                    guard let members = channel.members as? [SBDMember] else {
                        self.suggestedMemberList = nil
                        self.delegate?.groupChannelViewModel(self, didReceiveSuggestedMentions: nil)
                        return
                    }
                    
                    let sortedMembers = members.sorted { $0.nickname?.lowercased() ?? "" < $1.nickname?.lowercased() ?? "" }
                    let matchedMembers = sortedMembers.filter {
                        return $0.nickname?.lowercased().hasPrefix(filterText.lowercased()) ?? false
                    }
                    let memberCount = matchedMembers.count
                    let limit = SBUGlobals.userMentionConfig?.suggestionLimit ?? 0
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
        guard let channel = self.channel as? SBDGroupChannel else { return }
        
        self.messageCollection = SBDMessageCollection(
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
    
    override func getStartingPoint() -> Int64? {
        return self.messageCollection?.startingPoint
    }
    
    override func reset() {
        self.markAsRead()
        
        super.reset()
    }
}


extension SBUGroupChannelViewModel: SBDMessageCollectionDelegate {
    open func messageCollection(_ collection: SBDMessageCollection,
                                context: SBDMessageContext,
                                channel: SBDGroupChannel,
                                addedMessages messages: [SBDBaseMessage])
    {
        // -> pending, -> receive new message
        SBULog.info("messageCollection addedMessages : \(messages.count)")
        switch context.source {
        case .eventMessageReceived:
            self.markAsRead()
        default: break
        }
        
        self.delegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: messageList,
            forContext: context,
            keepsScroll: true
        )
        self.upsertMessagesInList(messages: messages, needReload: true)
    }
    
    open func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           channel: SBDGroupChannel,
                           updatedMessages messages: [SBDBaseMessage])
    {
        // pending -> failed, pending -> succeded, failed -> Pending
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
    
    open func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           channel: SBDGroupChannel,
                           deletedMessages messages: [SBDBaseMessage])
    {
        SBULog.info("messageCollection deletedMessages : \(messages.count)")
        self.deleteMessagesInList(messageIds: messages.compactMap({ $0.messageId }), needReload: true)
    }
    
    open func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           updatedChannel channel: SBDGroupChannel)
    {
        SBULog.info("messageCollection changedChannel")
        self.delegate?.baseChannelViewModel(self, didChangeChannel: channel, withContext: context)
    }
    
    open func messageCollection(_ collection: SBDMessageCollection,
                           context: SBDMessageContext,
                           deletedChannel channelUrl: String)
    {
        SBULog.info("messageCollection deletedChannel")
        self.delegate?.baseChannelViewModel(self, didChangeChannel: nil, withContext: context)
    }
    
    open func didDetectHugeGap(_ collection: SBDMessageCollection) {
        SBULog.info("messageCollection didDetectHugeGap")
        self.messageCollection?.dispose()
        
        var startingPoint: Int64?
        let indexPathsForStartingPoint = self.dataSource?.groupChannelViewModel(self, startingPointIndexPathsForChannel: self.channel as? SBDGroupChannel)
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
}


// MARK: - SBDConnectionDelegate
extension SBUGroupChannelViewModel {
    open override func didSucceedReconnection() {
        super.didSucceedReconnection()
        
        if self.hasNext() {
            self.messageCache?.loadNext()
        }
        
        self.refreshChannel()
        
        self.markAsRead()
    }
}


// MARK: - SBDChannelDelegate
extension SBUGroupChannelViewModel {
    // Received message
    open override func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard self.messageListParams.belongs(to: message) else { return }

        super.channel(sender, didReceive: message)
        
        let isScrollBottom = self.dataSource?.baseChannelViewModel(self, isScrollNearBottomInChannel: self.channel)
        if (self.hasNext() == true || isScrollBottom == false) &&
            (message is SBDUserMessage || message is SBDFileMessage)
        {
            let context = SBDMessageContext()
            context.source = .eventMessageReceived

            if let channel = self.channel {
                self.delegate?.baseChannelViewModel(self, didReceiveNewMessage: message, forChannel: channel)
            }
        }
    }
}
