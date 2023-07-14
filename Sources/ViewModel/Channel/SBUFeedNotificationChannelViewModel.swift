//
//  SBUFeedNotificationChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

protocol SBUFeedNotificationChannelViewModelDataSource: AnyObject {
    /// Asks to data source to return the array of index path that represents starting point of channel.
    /// - Parameters:
    ///    - viewModel: ``SBUFeedNotificationChannelViewModel`` object.
    ///    - channel: `FeedChannel` object from `viewModel`
    /// - Returns: The array of `IndexPath` object representing starting point.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: FeedChannel?
    ) -> [IndexPath]
    
    /// Asks to data source whether the channel is scrolled to bottom.
    /// - Parameters:
    ///    - viewModel: `SBUFeedNotificationChannelViewModel` object.
    ///    - channel: `GroupChannel` object.
    /// - Returns:
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        isScrollNearBottomInChannel channel: FeedChannel?
    ) -> Bool
}

protocol SBUFeedNotificationChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the channel has been changed.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didChangeChannel channel: FeedChannel?,
        withContext context: FeedChannelContext
    )
    
    /// Called when the channel has received a new notification.
    func feedNotificationChannelViewModel( // Added docs
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didReceiveNewNotification notification: BaseMessage,
        forChannel channel: FeedChannel
    )
    
    /// Called when the channel should be dismissed.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        shouldDismissForChannel channel: FeedChannel?
    )
    
    /// Called when the notifications has been changed. If there are the first loaded notifications, `initialLoad` is `true`.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didChangeNotificationList notifications: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    )
    
    /// Called when the notifications has been deleted.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        deletedNotifications notifications: [BaseMessage]
    )
    
    /// Called when it should be updated scroll status for notifications.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        shouldUpdateScrollInNotificationList notifications: [BaseMessage],
        forContext context: NotificationContext?,
        keepsScroll: Bool
    )
}

/// A view model for the notification channel.
class SBUFeedNotificationChannelViewModel: NSObject {
    // MARK: - Constant
    let defaultFetchLimit: Int = 30
    let initPolicy: NotificationCollectionInitPolicy = .cacheAndReplaceByApi
    
    // MARK: - Logic properties (Public)
    
    /// The current channel object. It's `FeedChannel` type.
    var channel: FeedChannel?
    /// The URL of the notification channel.
    var channelURL: String?
    /// The starting point of the notification list in the `channel`.
    var startingPoint: Int64?
    
    /// This object has all valid notifications synchronized with the server.
    @SBUAtomic var notifications: [BaseMessage] = []
    
    /// Custom param set by user.
    var customizedNotificationListParams: MessageListParams?
    var notificationListParams = MessageListParams()
    
    weak var dataSource: SBUFeedNotificationChannelViewModelDataSource?
    weak var delegate: SBUFeedNotificationChannelViewModelDelegate?
    
    var lastSeenAt: Int64 = 0
    
    /// The boolean value that allows to update the read status of ``channel``. If it's `false`, ``channel`` doesn't update the read status of a new notification.
    /// - NOTE: If you use ``SBUFeedNotificationChannelViewModel`` in `UITabBarViewController`, because of the life cycle, the ``channel`` *always* marks the read status of the new incoming notifications as read even the view controller that has ``SBUFeedNotificationChannelViewModel`` doesn't appear. In this case, you might need to update  `allowsReadStatusUpdate` value according to the life cycle. Please refer to code snippet.
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
    var allowsReadStatusUpdate = false
    
    // MARK: - Common
    
    /// This function checks that have the following list.
    /// - Returns: This function returns `true` if there is the following list.
    var hasNext: Bool {
        self.notificationCollection?.hasNext ?? (self.getStartingPoint != nil)
    }
    
    /// This function checks that have the previous list.
    /// - Returns: This function returns `true` if there is the previous list.
    var hasPrevious: Bool {
        self.notificationCollection?.hasPrevious ?? true
    }
    
    var getStartingPoint: Int64? {
        self.notificationCollection?.startingPoint
    }
    
    // MARK: - Logic properties (Private)
    var notificationCollection: NotificationCollection?
    
    let prevLock = NSLock()
    let nextLock = NSLock()
    let initialLock = NSLock()
    
    var isInitialLoading = false
    var isScrollToInitialPositionFinish = false
    
    @SBUAtomic var isLoadingNext = false
    @SBUAtomic var isLoadingPrev = false
    
    /// If this option is `true`, when a list is received through the local cache during initialization, it is displayed first.
    var displaysLocalCachedListFirst: Bool = false
    
    // MARK: - LifeCycle
    init(
        channel: FeedChannel? = nil,
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        delegate: SBUFeedNotificationChannelViewModelDelegate? = nil,
        dataSource: SBUFeedNotificationChannelViewModelDataSource? = nil,
        displaysLocalCachedListFirst: Bool = false
    ) {
        super.init()
        
        self.delegate = delegate
        self.dataSource = dataSource
        
        self.displaysLocalCachedListFirst = displaysLocalCachedListFirst
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
        
        SendbirdChat.addChannelDelegate(
            self,
            identifier: "\(SBUConstant.feedChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        self.customizedNotificationListParams = notificationListParams
        self.startingPoint = startingPoint
        
        if let channelURL = self.channelURL {
            self.loadChannel(
                channelURL: channelURL,
                notificationListParams: self.customizedNotificationListParams
            )
        }
    }
    
    func reset() {
        self.markAsRead()
        self.resetNotificationListParams()
        self.isScrollToInitialPositionFinish = false
    }
    
    deinit {
        self.delegate = nil
        self.dataSource = nil
        
        SendbirdChat.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.feedChannelDelegateIdentifier).\(self.description)"
        )
        SendbirdChat.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
        self.notificationCollection?.dispose()
    }
    
    // MARK: - Channel related
    
    /// This function loads channel information and notification list.
    /// - Parameters:
    ///   - channelURL: channel url
    ///   - notificationListParams: (Optional) The parameter to be used when getting channel information.
    ///   - completionHandler: Do something to the completion of the load channel.
    func loadChannel(
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        completionHandler: ((BaseChannel?, SBError?) -> Void)? = nil
    ) {
        guard let channelURL = channelURL else {
            SBULog.error("Invalid ChannelURL")
            let error = ChatError.invalidChannelURL.asSBError(
                message: "Invalid ChannelURL"
            )
            self.delegate?.didReceiveError(error)
            completionHandler?(nil, error)
            return
        }
        
        if let notificationListParams = notificationListParams {
            self.customizedNotificationListParams = notificationListParams
        }
        //        else if self.customizedNotificationListParams == nil {
        //            let notificationListParams = MessageListParams()
        //            SBUGlobalCustomParams.messageListParamsBuilder?(notificationListParams)
        //            self.customizedNotificationListParams = notificationListParams
        //        }
        
        SendbirdUI.connectIfNeeded { [channelURL] _, error in
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            //            SBULog.info("[Request] Load channel: \(String(channelURL))")
            
            let completionHandler: SendbirdChatSDK.FeedChannelHandler? = { [weak self] channel, error in
                guard let self = self else {
                    completionHandler?(nil, error)
                    return
                }
                
                guard self.canProceed(with: channel, error: error) else {
                    self.delegate?.didReceiveError(error, isBlocker: true)
                    completionHandler?(nil, error)
                    return
                }
                
                self.channel = channel
                SBULog.info("[Succeed] Load channel request: \(String(describing: self.channel))")
                
                self.updateLastSeenAt() // will mark as read
                
                // background refresh to update channel header.
                self.refreshChannel()
                
                if SendbirdChat.getConnectState() == .closed {
                    let context = FeedChannelContext(source: .eventChannelChanged)
                    self.delegate?.feedNotificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    completionHandler?(channel, nil)
                }
                
                self.loadInitialNotifications(
                    startingPoint: self.startingPoint,
                    showsIndicator: true
                )
            }
            
            FeedChannel.getChannel(url: channelURL, completionHandler: completionHandler)
        }
    }
    
    /// This function refreshes channel.
    func refreshChannel() {
        if let channel = self.channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                guard self.canProceed(with: channel, error: error) == true else {
                    let context = FeedChannelContext(source: .eventChannelChanged)
                    self.delegate?.feedNotificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    return
                }
                let context = FeedChannelContext(source: .eventChannelChanged)
                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context
                )
            }
        } else if let channelURL = self.channelURL {
            self.loadChannel(channelURL: channelURL)
        }
    }
    
    private func canProceed(with channel: FeedChannel?, error: SBError?) -> Bool {
        if let error = error {
            SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
            
            if error.code == ChatError.nonAuthorized.rawValue {
                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    shouldDismissForChannel: nil
                )
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
        
        return true
    }
    
    func updateLastSeenAt(_ timestamp: Int64? = nil) {
        self.lastSeenAt = timestamp ?? channel?.myLastRead ?? 0
        self.markAsRead()
    }
    
    // MARK: - Notification related
    func markAsRead() {
        if let channel = self.channel, allowsReadStatusUpdate {
            channel.markAsRead(completionHandler: nil)
        }
    }
    
    // MARK: - Load Notifications
    
    /// Loads initial notifications in channel.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load notifications from, or `nil` to load from the latest. (`Int64.max`)
    ///   - showsIndicator: Whether to show indicator on load or not.
    func loadInitialNotifications(
        startingPoint: Int64?,
        showsIndicator: Bool
    ) {
        SBULog.info("""
            loadInitialNotifications,
            startingPoint : \(String(describing: startingPoint))
            """
        )
        
        // Caution in function call order
        self.reset()
        self.createCollectionIfNeeded(startingPoint: startingPoint ?? Int64.max)
        self.clearNotificationList()
        
        self.notificationCollection?.startCollection(
            initPolicy: initPolicy,
            cacheResultHandler: { [weak self] cacheResult, error in
                guard let self = self else { return }
                
                defer { self.displaysLocalCachedListFirst = false }
                
                if let error = error {
                    self.delegate?.didReceiveError(error, isBlocker: false)
                    return
                }
                
                // prevent empty view showing
                if cacheResult == nil, cacheResult?.isEmpty == true { return }
                
                self.isInitialLoading = true
                self.upsertNotificationsInList(
                    notifications: cacheResult,
                    needReload: self.displaysLocalCachedListFirst
                )
                
            }, apiResultHandler: { [weak self] apiResult, error in
                guard let self = self else { return }
                
                if let error = error {
                    // ignore error if using local caching
                    if !SendbirdChat.isLocalCachingEnabled {
                        self.delegate?.didReceiveError(error, isBlocker: false)
                    }
                    
                    self.isInitialLoading = false
                    return
                }
                
                if self.initPolicy == .cacheAndReplaceByApi {
                    self.clearNotificationList()
                }
                
                self.isInitialLoading = false
                self.upsertNotificationsInList(notifications: apiResult, needReload: true)
            }
        )
    }
    
    /// Loads previous notifications.
    func loadPrevNotifications() {
        guard let notificationCollection = self.notificationCollection else { return }
        guard self.prevLock.try() else {
            SBULog.info("Prev notification already loading")
            return
        }
        
        SBULog.info("[Request] Prev notification list")
        
        notificationCollection.loadPrevious { [weak self] notifications, error in
            guard let self = self else { return }
            defer {
                self.prevLock.unlock()
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            
            guard let notifications = notifications, !notifications.isEmpty else { return }
            SBULog.info("[Prev notification response] \(notifications.count) notifications")
            
            self.delegate?.feedNotificationChannelViewModel(
                self,
                shouldUpdateScrollInNotificationList: notifications,
                forContext: nil,
                keepsScroll: false
            )
            self.upsertNotificationsInList(notifications: notifications, needReload: true)
        }
    }
    
    /// Loads next notifications from `lastUpdatedTimestamp`.
    func loadNextNotifications() {
        guard self.nextLock.try() else {
            SBULog.info("Next notification already loading")
            return
        }
        
        guard let notificationCollection = self.notificationCollection else { return }
        self.isLoadingNext = true
        
        notificationCollection.loadNext { [weak self] notifications, error in
            guard let self = self else { return }
            defer {
                self.nextLock.unlock()
                self.isLoadingNext = false
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: false)
                return
            }
            guard let notifications = notifications else { return }
            
            SBULog.info("[Next notification Response] \(notifications.count) notifications")
            
            self.upsertNotificationsInList(notifications: notifications, needReload: true)
        }
    }
    
    /// This function resets list and reloads notification lists.
    func reloadNotificationList() {
        self.loadInitialNotifications(
            startingPoint: nil,
            showsIndicator: false
        )
    }
    
    // MARK: - List
    
    /// This function updates the notifications in the list.
    ///
    /// It is updated only if the notifications already exist in the list, and if not, it is ignored.
    /// And, after updating the notifications, a function to sort the notification list is called.
    /// - Parameters:
    ///   - notifications: Notification array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    func updateNotificationsInList(notifications: [BaseMessage]?, needReload: Bool) {
        notifications?.forEach { notification in
            if let index = SBUUtils.findIndex(of: notification, in: self.notifications) {
                if !self.notificationListParams.belongsTo(notification) {
                    self.notifications.remove(at: index)
                } else {
                    self.notifications[index] = notification
                }
            }
        }
        
        self.sortAllNotificationList(needReload: needReload)
    }
    
    /// This function deletes the notifications in the list using the notification ids.
    /// - Parameters:
    ///   - notificationIds: Notification id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    func deleteNotificationsInList(notificationIds: [Int64]?, needReload: Bool) {
        guard let notificationIds = notificationIds else { return }
        
        var toBeDeleteIndexes: [Int] = []
        
        for (index, notification) in self.notifications.enumerated() {
            for notificationId in notificationIds {
                guard notification.messageId == notificationId,
                      notification.isMessageIdValid else { continue }
                toBeDeleteIndexes.append(index)
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for index in sortedIndexes {
            self.notifications.remove(at: index)
        }
        
        self.sortAllNotificationList(needReload: needReload)
    }
    
    /// This function upserts the notifications in the list.
    /// - Parameters:
    ///   - notifications: Notification array to upsert
    ///   - needUpdateNewNotification: If set to `true`, increases new notification count.
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    func upsertNotificationsInList(
        notifications: [BaseMessage]?,
        needUpdateNewNotification: Bool = false,
        needReload: Bool
    ) {
        SBULog.info("First : \(String(describing: notifications?.first)), Last : \(String(describing: notifications?.last))")
        
        var needsToMarkAsRead = false
        
        notifications?.forEach { notification in
            if let index = SBUUtils.findIndex(of: notification, in: self.notifications) {
                self.notifications.remove(at: index)
            }
            
            guard self.notificationListParams.belongsTo(notification) else {
                self.sortAllNotificationList(needReload: needReload)
                return
            }
            
            if needUpdateNewNotification {
                guard let channel = self.channel else { return }
                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    didReceiveNewNotification: notification,
                    forChannel: channel
                )
            }
            
            if notification.sendingStatus == .succeeded {
                self.notifications.append(notification)
                
                needsToMarkAsRead = true
            }
        }
        
        if needsToMarkAsRead {
            self.markAsRead()
        }
        
        self.sortAllNotificationList(needReload: needReload)
    }
    
    /// This function sorts the all notification list. (Included `presendNotifications`, `notificationList` and `resendableNotifications`.)
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData and, scroll to last seen index.
    func sortAllNotificationList(needReload: Bool) {
        // Generate full list for draw
        self.notifications.sort { $0.createdAt > $1.createdAt }
        
        self.delegate?.feedNotificationChannelViewModel(
            self,
            didChangeNotificationList: self.notifications,
            needsToReload: needReload,
            initialLoad: self.isInitialLoading
        )
    }
    
    /// This functions clears current notification lists
    func clearNotificationList() {
        self.notifications.removeAll(where: { SBUUtils.findIndex(of: $0, in: notifications) != nil })
        self.notifications = []
    }
    
    // MARK: - NotificationListParams
    private func resetNotificationListParams() {
        self.notificationListParams = self.customizedNotificationListParams?.copy() as? MessageListParams
        ?? MessageListParams()
        
        if self.notificationListParams.previousResultSize <= 0 {
            self.notificationListParams.previousResultSize = self.defaultFetchLimit
        }
        if self.notificationListParams.nextResultSize <= 0 {
            self.notificationListParams.nextResultSize = self.defaultFetchLimit
        }
        
        self.notificationListParams.reverse = true
        self.notificationListParams.includeMetaArray = true
    }
    
    // MARK: - Common
    private func createCollectionIfNeeded(startingPoint: Int64) {
        guard let channel = self.channel else { return }
        self.notificationCollection = SendbirdChat.createNotificationCollection(
            channel: channel,
            startingPoint: startingPoint,
            params: self.notificationListParams,
            delegate: self
        )
    }
}

// MARK: - ConnectionDelegate
extension SBUFeedNotificationChannelViewModel: ConnectionDelegate {
    func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        
        SendbirdUI.updateUserInfo { error in
            if let error = error {
                SBULog.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        
        self.markAsRead()
        
        self.refreshChannel()
    }
}

// MARK: - ChannelDelegate
extension SBUFeedNotificationChannelViewModel: FeedChannelDelegate {
    // Received notification
    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        guard self.channel?.channelURL == channel.channelURL else { return }
        guard self.notificationListParams.belongsTo(message) else { return }
        
        switch message {
        case is UserMessage:
            SBULog.info("Did receive user notification: \(message)")
        case is FileMessage:
            SBULog.info("Did receive file notification: \(message)")
        case is AdminMessage:
            SBULog.info("Did receive admin notification: \(message)")
        default:
            break
        }
        
        let isScrollBottom = self.dataSource?.feedNotificationChannelViewModel(
            self,
            isScrollNearBottomInChannel: self.channel
        )
        if self.hasNext == true || isScrollBottom == false {
            if let channel = self.channel {
                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    didReceiveNewNotification: message,
                    forChannel: channel
                )
            }
        }
    }
}

extension SBUFeedNotificationChannelViewModel: NotificationCollectionDelegate {
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        addedMessages messages: [BaseMessage]
    ) {
        // -> pending, -> receive new notification
        SBULog.info("notificationCollection addedMessages : \(messages.count)")
        switch context.source {
        case .eventMessageReceived:
            self.markAsRead()
        default: break
        }
        
        self.delegate?.feedNotificationChannelViewModel(
            self,
            shouldUpdateScrollInNotificationList: messages,
            forContext: context,
            keepsScroll: true
        )
        self.upsertNotificationsInList(notifications: messages, needReload: true)
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        updatedMessages messages: [BaseMessage]
    ) {
        // pending -> failed, pending -> succeded, failed -> Pending
        SBULog.info("notificationCollection updatedNotifications : \(messages.count)")
        
        self.delegate?.feedNotificationChannelViewModel(
            self,
            shouldUpdateScrollInNotificationList: messages,
            forContext: context,
            keepsScroll: false
        )
        
        self.upsertNotificationsInList(
            notifications: notifications,
            needUpdateNewNotification: false,
            needReload: true
        )
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        deletedMessages messages: [BaseMessage]
    ) {
        SBULog.info("notificationCollection deletedNotifications : \(messages.count)")
        self.delegate?.feedNotificationChannelViewModel(self, deletedNotifications: messages)
        self.deleteNotificationsInList(notificationIds: messages.compactMap({ $0.messageId }), needReload: true)
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: FeedChannelContext,
        deletedChannel channelURL: String
    ) {
        SBULog.info("notificationCollection deletedChannel")
        self.delegate?.feedNotificationChannelViewModel(
            self,
            didChangeChannel: nil,
            withContext: context
        )
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: FeedChannelContext,
        updatedChannel: FeedChannel
    ) {
        self.delegate?.feedNotificationChannelViewModel(
            self,
            didChangeChannel: updatedChannel,
            withContext: context
        )
    }
    
    func didDetectHugeGap(_ collection: NotificationCollection) {
        SBULog.info("notificationCollection didDetectHugeGap")
        self.notificationCollection?.dispose()
        
        var startingPoint: Int64?
        let indexPathsForStartingPoint = self.dataSource?.feedNotificationChannelViewModel(
            self,
            startingPointIndexPathsForChannel: self.channel
        )
        let visibleRowCount = indexPathsForStartingPoint?.count ?? 0
        let visibleCenterIdx = indexPathsForStartingPoint?[visibleRowCount / 2].row ?? 0
        if visibleCenterIdx < self.notifications.count {
            startingPoint = self.notifications[visibleCenterIdx].createdAt
        }
        
        self.loadInitialNotifications(
            startingPoint: startingPoint,
            showsIndicator: false
        )
    }
}
