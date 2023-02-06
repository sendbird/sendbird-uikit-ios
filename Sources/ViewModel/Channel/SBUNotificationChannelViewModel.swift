//
//  SBUNotificationChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

public protocol SBUNotificationChannelViewModelDataSource: AnyObject {
    /// Asks to data source to return the array of index path that represents starting point of channel.
    /// - Parameters:
    ///    - viewModel: ``SBUNotificationChannelViewModel`` object.
    ///    - channel: `GroupChannel` object from `viewModel`
    /// - Returns: The array of `IndexPath` object representing starting point.
    func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: GroupChannel
    ) -> [IndexPath]
}

public protocol SBUNotificationChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the channel has been changed.
    func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        didChangeChannel channel: GroupChannel?,
        withContext context: MessageContext
    )
    
    /// Called when the channel has received a new message.
    func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        didReceiveNewMessage message: BaseMessage,
        forChannel channel: GroupChannel
    )
    
    /// Called when the channel should be dismissed.
    func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        shouldDismissForChannel channel: GroupChannel?
    )
    
    /// Called when the messages has been changed. If there are the first loaded messages, `initialLoad` is `true`.
    func notificationChannelViewModel(
        _ viewModel: SBUNotificationChannelViewModel,
        didChangeMessageList messages: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    )
}

/// A view model for the notification channel.
/// - Since: [NEXT_VERISON]
open class SBUNotificationChannelViewModel: NSObject {
    // MARK: - Constant
    let defaultFetchLimit: Int = 30
    let initPolicy: MessageCollectionInitPolicy = .cacheAndReplaceByApi
    
    
    // MARK: - Logic properties (Public)
    
    /// The current channel object. It's `GroupChannel` type.
    public internal(set) var channel: GroupChannel?
    /// The URL of the notification channel for the current user.
    public var channelURL: String? {
        guard let userId = SBUGlobals.currentUser?.userId else { return nil }
        return SBUStringSet.Notification_Channel_URL(userId)
    }
    /// The starting point of the message list in the `channel`.
    public internal(set) var startingPoint: Int64?
    
    /// This object has all valid messages synchronized with the server.
    @SBUAtomic public internal(set) var messages: [BaseMessage] = []

    /// Custom param set by user.
    public var customizedMessageListParams: MessageListParams?
    public internal(set) var messageListParams = MessageListParams()
    
    public weak var dataSource: SBUNotificationChannelViewModelDataSource?
    public weak var delegate: SBUNotificationChannelViewModelDelegate?
    
    public internal(set) var lastSeenAt: Int64 = 0
    
    /// The boolean value that allows to update the read status of ``channel``. If it's `false`, ``channel`` doesn't update the read status of a new message.
    /// - NOTE: If you use ``SBUNotificationChannelViewModel`` in `UITabBarViewController`, because of the life cycle, the ``channel`` *always* marks the read status of the new incoming messages as read even the view controller that has ``SBUNotificationChannelViewModel`` doesn't appear. In this case, you might need to update  `allowsReadStatusUpdate` value according to the life cycle. Please refer to code snippet.
    /// ```swift
    /// override func viewWillAppear(_ animated: Bool) {
    ///     // ...
    ///     viewModel.allowsReadStatusUpdate = true
    /// }
    ///
    /// override func viewWillDisappear(_ animated: Bool) {
    ///     // ...
    ///     viewModel.allowsReadStatusUpdate = false
    /// }
    /// ```
    public var allowsReadStatusUpdate = false
    
    
    // MARK: - Common
    
    /// This function checks that have the following list.
    /// - Returns: This function returns `true` if there is the following list.
    public var hasNext: Bool {
        self.messageCollection?.hasNext ?? (self.getStartingPoint != nil)
    }
    
    /// This function checks that have the previous list.
    /// - Returns: This function returns `true` if there is the previous list.
    public var hasPrevious: Bool {
        self.messageCollection?.hasPrevious ?? true
    }
    
    public var getStartingPoint: Int64? {
        self.messageCollection?.startingPoint
    }
    
    
    // MARK: - Logic properties (Private)
    var messageCollection: MessageCollection?
    
    let prevLock = NSLock()
    let nextLock = NSLock()
    let initialLock = NSLock()
    
    var isInitialLoading = false
    var isScrollToInitialPositionFinish = false
    
    @SBUAtomic var isLoadingNext = false
    @SBUAtomic var isLoadingPrev = false

    
    // MARK: - LifeCycle
    public override init() {
        super.init()
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
    }
    
    public init(
        channel: GroupChannel? = nil,
        messageListParams: MessageListParams? = nil,
        startingPoint: Int64 = .max,
        delegate: SBUNotificationChannelViewModelDelegate?,
        dataSource: SBUNotificationChannelViewModelDataSource?
    ) {
        super.init()
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
        }
        
        self.customizedMessageListParams = messageListParams
        self.startingPoint = startingPoint
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(
            channelURL: channelURL,
            messageListParams: self.customizedMessageListParams
        )
    }
    
    func reset() {
        self.markAsRead()
        self.resetMessageListParams()
        self.isScrollToInitialPositionFinish = false
    }
    
    deinit {
        self.delegate = nil
        self.dataSource = nil
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
        SendbirdChat.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
        self.messageCollection?.dispose()
    }
    
    
    // MARK: - Channel related
    
    /// This function loads channel information and message list.
    /// - Parameters:
    ///   - channelURL: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information.
    public func loadChannel(
        channelURL: String? = nil,
        messageListParams: MessageListParams? = nil,
        completionHandler: ((BaseChannel?, SBError?) -> Void)? = nil
    ) {
        guard let channelURL = channelURL ?? self.channelURL else {
            SBULog.error("SBUGlobals.currentUser has no value.")
            let error = ChatError.invalidChannelURL.asSBError(
                message: "SBUGlobals.currentUser has no value."
            )
            self.delegate?.didReceiveError(error)
            completionHandler?(nil, error)
            return
        }
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else if self.customizedMessageListParams == nil {
            let messageListParams = MessageListParams()
            SBUGlobalCustomParams.messageListParamsBuilder?(messageListParams)
            self.customizedMessageListParams = messageListParams
        }
        
        SendbirdUI.connectIfNeeded { [channelURL] user, error in
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            SBULog.info("[Request] Load channel: \(String(channelURL))")
            
            GroupChannel.getChannel(url: channelURL) { channel, error in
                guard self.canProceed(with: channel, error: error) else {
                    completionHandler?(nil, error)
                    return
                }
                
                self.channel = channel
                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                self.updateLastSeenAt() // will refresh channel
                
                if SendbirdChat.getConnectState() == .closed {
                    let context = MessageContext(
                        source: .eventChannelChanged,
                        sendingStatus: .succeeded
                    )
                    self.delegate?.notificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    completionHandler?(channel, nil)
                }
                
                self.loadInitialMessages(
                    startingPoint: self.startingPoint,
                    showsIndicator: true
                )
            }
        }
    }
    
    
    /// This function refreshes channel.
    public func refreshChannel() {
        self.markAsRead()
        if let channel = self.channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                guard self.canProceed(with: channel, error: error) == true else {
                    let context = MessageContext(
                        source: .eventChannelChanged,
                        sendingStatus: .failed
                    )
                    self.delegate?.notificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    return
                }
                let context = MessageContext(
                    source: .eventChannelChanged,
                    sendingStatus: .succeeded
                )
                self.delegate?.notificationChannelViewModel(
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
                self.delegate?.notificationChannelViewModel(
                    self,
                    shouldDismissForChannel: nil
                )
            } else {
                self.delegate?.didReceiveError(error, isBlocker: true)
            }
            return false
        }
        
        guard let channel = channel,
              channel.myMemberState != .none
        else {
            self.delegate?.notificationChannelViewModel(
                self,
                shouldDismissForChannel: channel
            )
            return false
        }

        return true
    }
    
    private func belongsToChannel(error: SBError) -> Bool {
        return error.code != ChatError.nonAuthorized.rawValue
    }
    
    public func updateLastSeenAt(_ timestamp: Int64? = nil) {
        self.lastSeenAt = timestamp ?? channel?.myLastRead ?? .max
        self.markAsRead()
    }
    
    // MARK: - Message related
    public func markAsRead() {
        if let channel = self.channel, allowsReadStatusUpdate {
            channel.markAsRead(completionHandler: nil)
        }
    }

    
    // MARK: - Load Messages
    
    /// Loads initial messages in channel.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`LLONG_MAX`)
    ///   - showsIndicator: Whether to show indicator on load or not.
    public func loadInitialMessages(
        startingPoint: Int64?,
        showsIndicator: Bool
    ) {
        SBULog.info("""
            loadInitialMessages,
            startingPoint : \(String(describing: startingPoint))
            """
        )
        
        // Caution in function call order
        self.reset()
        self.createCollectionIfNeeded(startingPoint: startingPoint ?? Int64.max)
        self.clearMessageList()
        
        self.delegate?.shouldUpdateLoadingState(showsIndicator)
        
        self.messageCollection?.startCollection(
            initPolicy: initPolicy,
            cacheResultHandler: { [weak self] cacheResult, error in
                guard let self = self else { return }
                if let error = error {
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    return
                }
                
                // prevent empty view showing
                if cacheResult == nil, cacheResult?.isEmpty == true { return }
                
                self.isInitialLoading = true
                self.upsertMessagesInList(messages: cacheResult, needReload: false)
                
            }, apiResultHandler: { [weak self] apiResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.delegate?.shouldUpdateLoadingState(false)
                    
                    // ignore error if using local caching
                    if !SendbirdChat.isLocalCachingEnabled {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    }
                    
                    self.isInitialLoading = false
                    return
                }
        
                if self.initPolicy == .cacheAndReplaceByApi {
                    self.clearMessageList()
                }
                
                self.upsertMessagesInList(messages: apiResult, needReload: true)
                self.isInitialLoading = false
            }
        )
    }
    
    /// Loads previous messages.
    public func loadPrevMessages() {
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
            
            self.upsertMessagesInList(messages: messages, needReload: true)
        }
    }
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    public func loadNextMessages() {
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
            
            self.upsertMessagesInList(messages: messages, needReload: true)
        }
    }
    
    /// This function resets list and reloads message lists.
    public func reloadMessageList() {
        self.loadInitialMessages(
            startingPoint: nil,
            showsIndicator: false
        )
    }
    
    
    // MARK: - List
    
    /// This function updates the messages in the list.
    ///
    /// It is updated only if the messages already exist in the list, and if not, it is ignored.
    /// And, after updating the messages, a function to sort the message list is called.
    /// - Parameters:
    ///   - messages: Message array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func updateMessagesInList(messages: [BaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messages) {
                if !self.messageListParams.belongsTo(message) {
                    self.messages.remove(at: index)
                } else {
                    self.messages[index] = message
                }
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// This function deletes the messages in the list using the message ids.
    /// - Parameters:
    ///   - messageIds: Message id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func deleteMessagesInList(messageIds: [Int64]?, needReload: Bool) {
        guard let messageIds = messageIds else { return }
        
        var toBeDeleteIndexes: [Int] = []
        var toBeDeleteRequestIds: [String] = []
        
        for (index, message) in self.messages.enumerated() {
            for messageId in messageIds {
                guard message.messageId == messageId else { continue }
                toBeDeleteIndexes.append(index)
                
                guard message.requestId.count > 0 else { continue }
                
                switch message {
                case let userMessage as UserMessage:
                    let requestId = userMessage.requestId
                    toBeDeleteRequestIds.append(requestId)

                case let fileMessage as FileMessage:
                    let requestId = fileMessage.requestId
                    toBeDeleteRequestIds.append(requestId)
                    
                default: break
                }
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for index in sortedIndexes {
            self.messages.remove(at: index)
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// Deletes a message with message object from ``channel``.
    /// - Parameter message: `BaseMessage` based class object
    public func deleteMessage(_ message: BaseMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        self.channel?.deleteMessage(message, completionHandler: nil)
    }
    
    
    /// This function upserts the messages in the list.
    /// - Parameters:
    ///   - messages: Message array to upsert
    ///   - needUpdateNewMessage: If set to `true`, increases new message count.
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    public func upsertMessagesInList(
        messages: [BaseMessage]?,
        needUpdateNewMessage: Bool = false,
        needReload: Bool
    ) {
        SBULog.info("First : \(String(describing: messages?.first)), Last : \(String(describing: messages?.last))")
        
        var needsToMarkAsRead = false
        
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messages) {
                self.messages.remove(at: index)
            }

            guard self.messageListParams.belongsTo(message) else {
                self.sortAllMessageList(needReload: needReload)
                return
            }
            
            if needUpdateNewMessage {
                guard let channel = self.channel else { return }
                self.delegate?.notificationChannelViewModel(
                    self,
                    didReceiveNewMessage: message,
                    forChannel: channel
                )
            }
            
            if message.sendingStatus == .succeeded {
                self.messages.append(message)

                needsToMarkAsRead = true
            }
        }
        
        if needsToMarkAsRead {
            self.markAsRead()
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// This function sorts the all message list. (Included `presendMessages`, `messages` and `resendableMessages`.)
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData and, scroll to last seen index.
    public func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        self.messages.sort { $0.createdAt > $1.createdAt }
        
        self.delegate?.shouldUpdateLoadingState(false)
        self.delegate?.notificationChannelViewModel(
            self,
            didChangeMessageList: self.messages,
            needsToReload: needReload,
            initialLoad: self.isInitialLoading
        )
    }
    
    /// This functions clears current message lists
    public func clearMessageList() {
        self.messages.removeAll(where: { SBUUtils.findIndex(of: $0, in: messages) != nil })
        self.messages = []
    }
    
    
    // MARK: - MessageListParams
    private func resetMessageListParams() {
        self.messageListParams = self.customizedMessageListParams?.copy() as? MessageListParams
            ?? MessageListParams()
        
        if self.messageListParams.previousResultSize <= 0 {
            self.messageListParams.previousResultSize = self.defaultFetchLimit
        }
        if self.messageListParams.nextResultSize <= 0 {
            self.messageListParams.nextResultSize = self.defaultFetchLimit
        }
        
        self.messageListParams.reverse = true
        self.messageListParams.includeReactions = SBUEmojiManager.useReaction(channel: channel)
        
        self.messageListParams.includeThreadInfo = SBUGlobals.reply.includesThreadInfo
        self.messageListParams.includeParentMessageInfo = SBUGlobals.reply.includesParentMessageInfo
        self.messageListParams.replyType = SBUGlobals.reply.replyType.filterValue
    }
    
    

    
    // MARK: - Common
    private func createCollectionIfNeeded(startingPoint: Int64) {
        guard let channel = self.channel else { return }
        self.messageCollection = SendbirdChat.createMessageCollection(
            channel: channel,
            startingPoint: startingPoint,
            params: self.messageListParams
        )
        self.messageCollection?.delegate = self
    }
}


// MARK: - ConnectionDelegate
extension SBUNotificationChannelViewModel: ConnectionDelegate {
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        
        SendbirdUI.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        
        self.refreshChannel()
    }
}


// MARK: - ChannelDelegate
extension SBUNotificationChannelViewModel: GroupChannelDelegate {
    // Received message
    open func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        
        switch message {
        case is UserMessage:
            SBULog.info("Did receive user message: \(message)")
        case is FileMessage:
            SBULog.info("Did receive file message: \(message)")
        case is AdminMessage:
            SBULog.info("Did receive admin message: \(message)")
        default:
            break
        }
    }
}


extension SBUNotificationChannelViewModel: MessageCollectionDelegate {
    open func messageCollection(_ collection: MessageCollection,
                                context: MessageContext,
                                channel: GroupChannel,
                                addedMessages messages: [BaseMessage])
    {
        // -> pending, -> receive new message
        SBULog.info("messageCollection addedMessages : \(messages.count)")
        switch context.source {
        case .eventMessageReceived:
            self.markAsRead()
        default: break
        }
        
        self.upsertMessagesInList(messages: messages, needReload: true)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           channel: GroupChannel,
                           updatedMessages messages: [BaseMessage])
    {
        // pending -> failed, pending -> succeded, failed -> Pending
        SBULog.info("messageCollection updatedMessages : \(messages.count)")
        
        self.upsertMessagesInList(
            messages: messages,
            needUpdateNewMessage: false,
            needReload: true
        )
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           channel: GroupChannel,
                           deletedMessages messages: [BaseMessage])
    {
        SBULog.info("messageCollection deletedMessages : \(messages.count)")
        self.deleteMessagesInList(messageIds: messages.compactMap({ $0.messageId }), needReload: true)
    }
    
    open func messageCollection(_ collection: MessageCollection,
                           context: MessageContext,
                           deletedChannel channelURL: String)
    {
        SBULog.info("messageCollection deletedChannel")
        self.delegate?.notificationChannelViewModel(
            self,
            didChangeChannel: nil,
            withContext: context
        )
    }
    
    public func messageCollection(_ collection: MessageCollection, context: MessageContext, updatedChannel: GroupChannel) {
        self.delegate?.notificationChannelViewModel(
            self,
            didChangeChannel: updatedChannel,
            withContext: context
        )
    }
}
