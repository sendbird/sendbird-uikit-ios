//
//  SBUFeedNotificationChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

// swiftlint:disable type_name
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
    /// - Parameter refreshesCategoryFilter: 채널 새로 고침 응답일 때만 true다. 받는 쪽은 이 값으로 카테고리 필터를 다시 그린다.
    ///   view model 상태로 두면 Chat 콜백 큐의 쓰기와 main의 읽기가 겹치므로 알림마다 값으로 넘긴다.
    func feedNotificationChannelViewModel(
        _ viewModel: SBUFeedNotificationChannelViewModel,
        didChangeChannel channel: FeedChannel?,
        withContext context: FeedChannelContext,
        refreshesCategoryFilter: Bool
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
// swiftlint:enable type_name

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
    
    /// Data fields for templates to cache load states
    /// - Since: 3.29.0
    var templateLoadCache: [String: SBUMessageTemplate.TemplateCacheState] { // template-key : load-state
        // 캐시 초기화로 메모리에서 사라진 템플릿은 성공으로 보지 않는다. 셀이 다시 받게 된다.
        get { self.storedTemplateLoadCache.removingSuccessMissingFromMemory(type: .notification) }
        set { self.storedTemplateLoadCache = newValue }
    }
    private var storedTemplateLoadCache: [String: SBUMessageTemplate.TemplateCacheState] = [:]
    
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
    
    // MARK: - Mark as viewed
    
    /// The time interval to wait to send the viewed action after scrolling has stopped
    static let markAsViewsInterval: TimeInterval = 0.5
    
    /// A timer for markAsViewed
    private var markAsViewedTimer: Timer?
    
    private var markAsViewedEnabled: Bool = false
    
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
    
    var isCategoryFilterEnabled: Bool { // 3.9.0
        self.channel?.isCategoryFilterEnabled ?? false
    }
    
    var categories: [NotificationCategory] { // 3.9.0
        self.channel?.categories ?? []
    }
    
    var isTemplateLabelEnabled: Bool { // 3.9.0
        self.channel?.isTemplateLabelEnabled ?? false
    }
    
    var selectedCategory: NotificationCategory? // 3.9.0
    
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
            Log.error("Invalid ChannelURL")
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
        
        SendbirdUI.authenticateFeedIfNeeded { [weak self, channelURL] _, error in
            guard let self = self else {
                completionHandler?(nil, error)
                return
            }
            
            if let error = error {
                self.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            let completionHandler: SendbirdChatSDK.FeedChannelHandler? = { channel, error in
                // 오류 알림(화면 닫기, 차단 오류)은 부른 큐에서 보낸다. 화면 부분은 받는 VC가 main으로 넘기고 errorHandler는 그대로 부른다.
                guard self.canProceed(with: channel, error: error) else {
                    self.delegate?.didReceiveError(error, isBlocker: true)
                    completionHandler?(nil, error)
                    return
                }

                // Chat 콜백 큐를 바꾼 앱에서는 이 응답이 백그라운드에서 온다. 채널 대입, 읽음 위치, 새로 고침 시작,
                // 첫 목록 시작(목록 비우기와 collection 생성)은 main에서 한다.
                // 연결이 닫혀 있을 때의 채널 변경 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로
                // develop처럼 Chat 콜백 큐에서 보내고, 그 뒤에 첫 목록을 시작해 develop의 순서를 지킨다.
                let startInitialLoad = {
                    Thread.executeOnMain {
                        self.loadInitialNotifications(
                            startingPoint: self.startingPoint,
                            showsIndicator: true
                        )
                    }
                }
                self.executeOnMainThenNotifyOnCallbackQueue({
                    self.channel = channel
                    // 채널 전체(description)를 문자열로 만들지 않고 URL만 남긴다.
                    Log.info("[Succeed] Load channel request: \(self.channel?.channelURL ?? "")")

                    self.updateLastSeenAt() // will mark as read

                    // background refresh to update channel header.
                    self.refreshChannel()

                    guard SendbirdChat.getConnectState() == .closed else {
                        startInitialLoad()
                        return false
                    }
                    return true
                }, notify: {
                    let context = FeedChannelContext(source: .eventChannelChanged)
                    self.delegate?.feedNotificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context,
                        refreshesCategoryFilter: false
                    )
                    completionHandler?(channel, nil)
                    startInitialLoad()
                })
            }
            
            FeedChannel.getChannel(url: channelURL, completionHandler: completionHandler)
        }
    }
    
    /// This function refreshes channel.
    func refreshChannel() {
        if let channel = self.channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                // 오류 알림과 채널 변경 알림은 develop처럼 부른 큐(Chat 콜백 큐)에서 보낸다. 화면은 받는 VC가 main으로 넘긴다.
                // 카테고리 필터 갱신 여부는 view model 상태에 쓰지 않고 이 알림의 값으로 넘긴다.
                _ = self.canProceed(with: channel, error: error)
                let context = FeedChannelContext(source: .eventChannelChanged)
                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    didChangeChannel: channel,
                    withContext: context,
                    refreshesCategoryFilter: true
                )
            }
        } else if let channelURL = self.channelURL {
            self.loadChannel(channelURL: channelURL)
        }
    }
    
    private func canProceed(with channel: FeedChannel?, error: SBError?) -> Bool {
        if let error = error {
            Log.error("[Failed] Load channel request: \(error.localizedDescription)")
            
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
    func markAsRead(completionHandler: SendbirdChatSDK.SBErrorHandler? = nil) {
        if let channel = self.channel, allowsReadStatusUpdate {
            channel.markAsRead(completionHandler: completionHandler)
        }
    }
    
    /// 목록과 화면 상태 작업(`work`)은 main에서 하고, `work`가 true를 돌려주면 이어서 고객 override에 닿는 알림(`notify`)을
    /// develop처럼 Chat 콜백 큐에서 보낸다. 응답이 main에서 왔으면(기본 설정) 둘 다 지금처럼 바로 실행된다.
    private func executeOnMainThenNotifyOnCallbackQueue(
        _ work: @escaping () -> Bool,
        notify: @escaping () -> Void
    ) {
        guard !Thread.isMainThread else {
            if work() { notify() }
            return
        }
        DispatchQueue.main.async {
            guard work() else { return }
            SendbirdChat.performCompletionHandlerDelegateQueue(notify)
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
        Log.info("""
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
                // 오류 알림은 고객이 받는 지점(didReceiveError override, errorHandler)이라 develop처럼 Chat 콜백 큐에서 먼저 보낸다.
                if let error = error {
                    self?.delegate?.didReceiveError(error, isBlocker: false)
                }
                // Chat 콜백 큐를 바꾼 앱에서는 이 응답이 백그라운드에서 온다. 첫 목록 반영은 main에서 처리한다.
                // main에서 불리면 지금처럼 바로 실행된다.
                Thread.executeOnMain { [weak self] in
                    guard let self = self else { return }

                    defer { self.displaysLocalCachedListFirst = false }

                    guard error == nil else { return }

                    // prevent empty view showing
                    if cacheResult == nil, cacheResult?.isEmpty == true { return }

                    self.isInitialLoading = true
                    self.upsertNotificationsInList(
                        notifications: cacheResult,
                        needReload: self.displaysLocalCachedListFirst
                    )
                }
            }, apiResultHandler: { [weak self] apiResult, error in
                // 오류 알림은 고객이 받는 지점이라 develop처럼 Chat 콜백 큐에서 먼저 보낸다.
                // ignore error if using local caching
                if let error = error, !SendbirdChat.isLocalCachingEnabled {
                    self?.delegate?.didReceiveError(error, isBlocker: false)
                }
                // Chat 콜백 큐를 바꾼 앱에서는 이 응답이 백그라운드에서 온다. 첫 목록 반영은 main에서 처리한다.
                // main에서 불리면 지금처럼 바로 실행된다.
                Thread.executeOnMain { [weak self] in
                    guard let self = self else { return }

                    guard error == nil else {
                        self.isInitialLoading = false
                        return
                    }

                    if self.initPolicy == .cacheAndReplaceByApi {
                        self.clearNotificationList()
                    }

                    self.isInitialLoading = false
                    self.upsertNotificationsInList(notifications: apiResult, needReload: true)
                }
            }
        )
    }
    
    /// Loads previous notifications.
    func loadPrevNotifications() {
        guard let notificationCollection = self.notificationCollection else { return }
        guard self.prevLock.try() else {
            Log.info("Prev notification already loading")
            return
        }
        
        Log.info("[Request] Prev notification list")
        
        notificationCollection.loadPrevious { [weak self] notifications, error in
            // 오류 알림은 고객이 받는 지점이라 develop처럼 Chat 콜백 큐에서 먼저 보낸다. lock은 그 뒤 main에서 푼다.
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: false)
            }
            // Chat 콜백 큐를 바꾼 앱에서는 페이지 응답이 백그라운드에서 온다. 스크롤 갱신과 목록 반영은 main에서 처리한다.
            // main에서 불리면 지금처럼 바로 실행된다.
            Thread.executeOnMain { [weak self] in
                guard let self = self else { return }
                defer {
                    self.prevLock.unlock()
                }

                guard error == nil else { return }

                guard let notifications = notifications, !notifications.isEmpty else { return }
                Log.info("[Prev notification response] \(notifications.count) notifications")

                self.delegate?.feedNotificationChannelViewModel(
                    self,
                    shouldUpdateScrollInNotificationList: notifications,
                    forContext: nil,
                    keepsScroll: false
                )
                self.upsertNotificationsInList(notifications: notifications, needReload: true)
            }
        }
    }
    
    /// Loads next notifications from `lastUpdatedTimestamp`.
    func loadNextNotifications() {
        // 잠금을 쥔 뒤에 collection이 없어 돌아가면 잠금이 풀리지 않아 다음 페이지를 다시 불러오지 못한다.
        // loadPrevNotifications처럼 collection을 먼저 확인한다.
        guard let notificationCollection = self.notificationCollection else { return }
        guard self.nextLock.try() else {
            Log.info("Next notification already loading")
            return
        }
        
        self.isLoadingNext = true
        
        notificationCollection.loadNext { [weak self] notifications, error in
            // 오류 알림은 고객이 받는 지점이라 develop처럼 Chat 콜백 큐에서 먼저 보낸다. lock과 로딩 표시는 그 뒤 main에서 푼다.
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: false)
            }
            // Chat 콜백 큐를 바꾼 앱에서는 페이지 응답이 백그라운드에서 온다. 목록 반영은 main에서 처리한다.
            // main에서 불리면 지금처럼 바로 실행된다.
            Thread.executeOnMain { [weak self] in
                guard let self = self else { return }
                defer {
                    self.nextLock.unlock()
                    self.isLoadingNext = false
                }

                guard error == nil else { return }
                guard let notifications = notifications else { return }

                Log.info("[Next notification Response] \(notifications.count) notifications")

                self.upsertNotificationsInList(notifications: notifications, needReload: true)
            }
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
                if toBeDeleteIndexes.contains(index) == false {
                    toBeDeleteIndexes.append(index)
                }
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
        Log.info("First : \(String(describing: notifications?.first)), Last : \(String(describing: notifications?.last))")
        
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
            self.markAsRead { [weak self] _ in
                // 읽음 처리 결과는 Chat 콜백 큐에서 온다. 정렬과 목록 알림은 main에서 한다.
                Thread.executeOnMain { [weak self] in
                    self?.sortAllNotificationList(needReload: needReload)
                }
            }
        } else {
            self.sortAllNotificationList(needReload: needReload)
        }
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
        self.notificationListParams.customType = self.selectedCategory?.customType
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
    
    // MARK: - Mark as viewed
    /// Appends viewed action.
    func markAsViewed(messages: [BaseMessage]) {
        if self.markAsViewedEnabled == false {
            return
        }
        
        self.invalidateLogImpressionTimer()
        
        self.markAsViewedTimer = Timer.scheduledTimer(
            withTimeInterval: Self.markAsViewsInterval,
            repeats: false
        ) { [weak self] _ in
            guard let self = self else { return }
            _ = self.channel?.logViewed(messages: messages)
        }
    }
    
    func enableLogImpression(_ enable: Bool) {
        self.markAsViewedEnabled = enable
    }

    func invalidateLogImpressionTimer() {
        self.markAsViewedTimer?.invalidate()
    }
    
    func loadUncachedTemplate(
        keys: [String],
        completionHandler: @escaping (Bool) -> Void
    ) {
        guard let uncachedKeys = self.templateLoadCache.uncachedKeys(from: keys) else {
            Log.info("[Request] All requested keys are already marked as failed or are loading: \(keys)")
            completionHandler(false)
            return
        }
        
        self.templateLoadCache.loadingKeys(from: uncachedKeys)
        
        SBUMessageTemplateManager.loadTemplateList(type: .notification, keys: uncachedKeys) { [weak self] success in
            guard let self = self else { return }
            Log.info("[Request] Load request completed - success: \(success)")
            
            self.templateLoadCache.didLoadKeys(form: uncachedKeys, success: success)

            completionHandler(success)
        }
    }
    
    /// This function refreshes channel and checkes updated message.
    /// - Parameter completionHandler: completion handler
    ///
    /// - Since: Not public access level yet
//    func refresh(completionHandler: SBErrorHandler?) {
//        self.notificationCollection?.refresh(completionHandler: completionHandler)
//    }
}

// MARK: - ConnectionDelegate
extension SBUFeedNotificationChannelViewModel: ConnectionDelegate {
    func didSucceedReconnection() {
        Log.info("Did succeed reconnection")
        
        SendbirdUI.updateUserInfo { error in
            if let error = error {
                Log.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        
        // 재연결 알림과 읽음 처리 결과는 Chat delegate 큐에서 온다. 채널을 읽는 읽음 처리와 새로 고침 시작
        // (카테고리 필터 갱신 표시 끄기 포함)은 main에서 한다. main에서 불리면 지금처럼 바로 실행된다.
        Thread.executeOnMain { [weak self] in
            self?.markAsRead { [weak self] _ in
                Thread.executeOnMain { [weak self] in
                    self?.refreshChannel()
                }
            }
        }
    }
}

// MARK: - ChannelDelegate
extension SBUFeedNotificationChannelViewModel: FeedChannelDelegate {
    // Received notification
    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        // Chat 콜백 큐를 바꾼 앱에서는 채널 이벤트가 백그라운드에서 온다. 채널 확인과 화면의 스크롤 위치 읽기는 main에서 하고,
        // 새 알림 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로 develop처럼 Chat 콜백 큐에서 보낸다.
        // main에서 불리면 지금처럼 바로 실행된다.
        var receivingChannel: FeedChannel?
        self.executeOnMainThenNotifyOnCallbackQueue({ [weak self] in
            guard let self = self else { return false }
            guard self.channel?.channelURL == channel.channelURL else { return false }
            guard self.notificationListParams.belongsTo(message) else { return false }
        
            switch message {
            case is UserMessage:
                Log.info("Did receive user notification: \(message)")
            case is FileMessage:
                Log.info("Did receive file notification: \(message)")
            case is AdminMessage:
                Log.info("Did receive admin notification: \(message)")
            default:
                break
            }
        
            let isScrollBottom = self.dataSource?.feedNotificationChannelViewModel(
                self,
                isScrollNearBottomInChannel: self.channel
            )
            guard self.hasNext == true || isScrollBottom == false, let currentChannel = self.channel else { return false }
            receivingChannel = currentChannel
            return true
        }, notify: { [weak self] in
            guard let self = self, let receivingChannel = receivingChannel else { return }
            self.delegate?.feedNotificationChannelViewModel(
                self,
                didReceiveNewNotification: message,
                forChannel: receivingChannel
            )
        })
    }
}

extension SBUFeedNotificationChannelViewModel: NotificationCollectionDelegate {
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        addedMessages messages: [BaseMessage]
    ) {
        // Chat 콜백 큐를 바꾼 앱에서는 collection 콜백이 백그라운드에서 온다. collection 콜백은 모두 main에서 도착 순서대로 처리한다
        // (수정 뒤 삭제처럼 이어 온 콜백의 목록 변경 순서가 뒤집히지 않게). main에서 불리면 지금처럼 바로 실행된다.
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            // -> pending, -> receive new notification
            Log.info("notificationCollection addedMessages : \(messages.count)")
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
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        updatedMessages messages: [BaseMessage]
    ) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            // pending -> failed, pending -> succeded, failed -> Pending
            Log.info("notificationCollection updatedNotifications : \(messages.count)")
        
            self.delegate?.feedNotificationChannelViewModel(
                self,
                shouldUpdateScrollInNotificationList: messages,
                forContext: context,
                keepsScroll: false
            )
        
            self.upsertNotificationsInList(
                notifications: messages,
                needUpdateNewNotification: false,
                needReload: true
            )
        }
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: NotificationContext,
        channel: FeedChannel,
        deletedMessages messages: [BaseMessage]
    ) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            Log.info("notificationCollection deletedNotifications : \(messages.count)")
            self.delegate?.feedNotificationChannelViewModel(self, deletedNotifications: messages)
            self.deleteNotificationsInList(notificationIds: messages.compactMap({ $0.messageId }), needReload: true)
        }
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: FeedChannelContext,
        deletedChannel channelURL: String
    ) {
        // 채널 변경 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로 develop처럼 Chat 콜백 큐에서 보낸다.
        // 화면 닫기는 받는 VC가 main으로 넘기며, 다른 collection 콜백과 같이 main 큐에 도착 순서대로 들어간다.
        Log.info("notificationCollection deletedChannel")
        self.delegate?.feedNotificationChannelViewModel(
            self,
            didChangeChannel: nil,
            withContext: context,
            refreshesCategoryFilter: false
        )
    }
    
    func notificationCollection(
        _ collection: NotificationCollection,
        context: FeedChannelContext,
        updatedChannel: FeedChannel
    ) {
        // 채널 변경 알림은 develop처럼 Chat 콜백 큐에서 보낸다(deletedChannel 주석 참고). 화면 갱신은 받는 VC가 main으로 넘긴다.
        self.delegate?.feedNotificationChannelViewModel(
            self,
            didChangeChannel: updatedChannel,
            withContext: context,
            refreshesCategoryFilter: false
        )
    }
    
    func didDetectHugeGap(_ collection: NotificationCollection) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        // 시작 위치를 정하려고 화면의 보이는 행을 읽으므로 main에서 해야 한다.
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            Log.info("notificationCollection didDetectHugeGap")
            self.notificationCollection?.dispose()
        
            var startingPoint: Int64?
            let indexPathsForStartingPoint = self.dataSource?.feedNotificationChannelViewModel(
                self,
                startingPointIndexPathsForChannel: self.channel
            )
            let visibleRowCount = indexPathsForStartingPoint?.count ?? 0
            // 보이는 행이 없으면(빈 배열) [0] 접근이 크래시하므로 nil 일 때처럼 0번을 쓴다.
            let visibleCenterIdx = indexPathsForStartingPoint?[safe: visibleRowCount / 2]?.row ?? 0
            if visibleCenterIdx < self.notifications.count {
                startingPoint = self.notifications[visibleCenterIdx].createdAt
            }
        
            self.loadInitialNotifications(
                startingPoint: startingPoint,
                showsIndicator: false
            )
        }
    }
}
