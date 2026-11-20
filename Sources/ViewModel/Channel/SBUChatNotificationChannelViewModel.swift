//
//  SBUChatNotificationChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/03/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

// swiftlint:disable type_name
protocol SBUChatNotificationChannelViewModelDataSource: AnyObject {
    /// Asks to data source to return the array of index path that represents starting point of channel.
    /// - Parameters:
    ///    - viewModel: `SBUChatNotificationChannelViewModel` object.
    ///    - channel: `GroupChannel` object from `viewModel`
    /// - Returns: The array of `IndexPath` object representing starting point.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        startingPointIndexPathsForChannel channel: GroupChannel?
    ) -> [IndexPath]?
    
    /// Asks to data source whether the channel is scrolled to bottom.
    /// - Parameters:
    ///    - viewModel: `SBUChatNotificationChannelViewModel` object.
    ///    - channel: `GroupChannel` object.
    /// - Returns:
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        isScrollNearBottomInChannel channel: GroupChannel?
    ) -> Bool
}

protocol SBUChatNotificationChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the channel has been changed.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didChangeChannel channel: GroupChannel?,
        withContext context: MessageContext
    )
    
    /// Called when the channel has received a new notification.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didReceiveNewNotification notification: BaseMessage,
        forChannel channel: GroupChannel
    )
    
    /// Called when the channel should be dismissed.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        shouldDismissForChannel channel: GroupChannel?
    )
    
    /// Called when the notifications has been changed. If there are the first loaded notifications, `initialLoad` is `true`.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        didChangeNotificationList notifications: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    )
    
    /// Called when the notifications has been deleted.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        deletedNotifications notifications: [BaseMessage]
    )
    
    /// Called when it should be updated scroll status for notifications.
    func chatNotificationChannelViewModel(
        _ viewModel: SBUChatNotificationChannelViewModel,
        shouldUpdateScrollInNotificationList notifications: [BaseMessage],
        forContext context: MessageContext?,
        keepsScroll: Bool
    )
}
// swiftlint:enable type_name

/// A view model for the notification channel.
class SBUChatNotificationChannelViewModel: NSObject {
    // MARK: - Constant
    let defaultFetchLimit: Int = 30
    let initPolicy: MessageCollectionInitPolicy = .cacheAndReplaceByApi
    
    // MARK: - Logic properties (Public)
    
    /// The current channel object. It's `GroupChannel` type.
    var channel: GroupChannel?
    /// The URL of the current channel.
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
    
    weak var dataSource: SBUChatNotificationChannelViewModelDataSource?
    weak var delegate: SBUChatNotificationChannelViewModelDelegate?
    
    var lastSeenAt: Int64 = 0
    
    /// The boolean value that allows to update the read status of ``channel``. If it's `false`, ``channel`` doesn't update the read status of a new notification.
    /// - NOTE: If you use ``SBUChatNotificationChannelViewModel`` in `UITabBarViewController`, because of the life cycle, the ``channel`` *always* marks the read status of the new incoming notifications as read even the view controller that has ``SBUChatNotificationChannelViewModel`` doesn't appear. In this case, you might need to update  `allowsReadStatusUpdate` value according to the life cycle. Please refer to code snippet.
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
    var notificationCollection: MessageCollection?
    
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
    override init() {
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
    
    init(
        channel: GroupChannel? = nil,
        channelURL: String? = nil,
        notificationListParams: MessageListParams? = nil,
        startingPoint: Int64? = .max,
        delegate: SBUChatNotificationChannelViewModelDelegate? = nil,
        dataSource: SBUChatNotificationChannelViewModelDataSource? = nil,
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
            identifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
        )
        
        if let channel = channel {
            self.channel = channel
            self.channelURL = channel.channelURL
        } else if let channelURL = channelURL {
            self.channelURL = channelURL
        }
        
        self.customizedNotificationListParams = notificationListParams
        self.startingPoint = startingPoint
        
        guard let channelURL = self.channelURL else { return }
        self.loadChannel(
            channelURL: channelURL,
            notificationListParams: self.customizedNotificationListParams
        )
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
            forIdentifier: "\(SBUConstant.groupChannelDelegateIdentifier).\(self.description)"
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
        guard let channelURL = channelURL ?? self.channelURL else {
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
        
        SendbirdUI.connectIfNeeded { [weak self] _, error in
            if let error = error {
                self?.delegate?.didReceiveError(error, isBlocker: true)
                completionHandler?(nil, error)
                return
            }
            
            Log.info("[Request] Load channel: \(String(channelURL))")
            GroupChannel.getChannel(url: channelURL) { [weak self] channel, error in
                guard let self = self else {
                    completionHandler?(nil, error)
                    return
                }
                
                // 오류 알림(화면 닫기, 차단 오류)은 부른 큐에서 보낸다. 화면 부분은 받는 VC가 main으로 넘기고 errorHandler는 그대로 부른다.
                guard self.canProceed(with: channel, error: error) else {
                    completionHandler?(nil, error)
                    return
                }

                // Chat 콜백 큐를 바꾼 앱에서는 이 응답이 백그라운드에서 온다. 채널 대입, 읽음 위치, 새로 고침 시작,
                // 첫 목록 시작(목록 비우기와 collection 생성)은 main에서 한다.
                // 연결이 닫혀 있을 때의 채널 변경 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로
                // develop처럼 Chat 콜백 큐에서 보내고, 그 뒤에 첫 목록을 시작해 develop의 순서를 지킨다.
                let startInitialLoad = { [weak self] in
                    Thread.executeOnMain { [weak self] in
                        guard let self = self else { return }
                        self.loadInitialNotifications(
                            startingPoint: self.startingPoint,
                            showsIndicator: true
                        )
                    }
                }
                self.executeOnMainThenNotifyOnCallbackQueue({ [weak self] in
                    guard let self = self else { return false }
                    self.channel = channel
                    // 채널 전체(description)를 문자열로 만들지 않고 URL만 남긴다.
                    Log.info("[Succeed] Load channel request: \(self.channel?.channelURL ?? "")")

                    self.updateLastSeenAt() // will mark as read

                    // background refresh to check if user is banned or not.
                    self.refreshChannel()

                    // for updating channel information when the connection state is closed at the time of initial load.
                    guard SendbirdChat.getConnectState() == .closed else {
                        startInitialLoad()
                        return false
                    }
                    return true
                }, notify: { [weak self] in
                    guard let self = self else { return }
                    let context = MessageContext(
                        source: .eventChannelChanged,
                        sendingStatus: .succeeded
                    )
                    self.delegate?.chatNotificationChannelViewModel(
                        self,
                        didChangeChannel: channel,
                        withContext: context
                    )
                    completionHandler?(channel, nil)
                    startInitialLoad()
                })
            }
        }
    }
    
    func refreshChannel() {
        if let channel = self.channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                guard self.canProceed(with: channel, error: error) == true else {
                    let context = MessageContext(
                        source: .eventChannelChanged,
                        sendingStatus: .failed
                    )
                    self.delegate?.chatNotificationChannelViewModel(
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
                self.delegate?.chatNotificationChannelViewModel(
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
            Log.error("[Failed] Load channel request: \(error.localizedDescription)")
            
            if error.code == ChatError.nonAuthorized.rawValue {
                self.delegate?.chatNotificationChannelViewModel(self, shouldDismissForChannel: nil)
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
        if let channel = self.channel,
            allowsReadStatusUpdate,
           SendbirdChat.getConnectState() == .open {
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
    /// `NOT` using `initialNotifications` here since `MessageCollection` handles notifications from db.
    /// Only used in `SBUOpenChannelViewModel` where `MessageCollection` is not suppoorted.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load notifications from, or `nil` to load from the latest. (`Int64.max`)
    ///   - showsIndicator: Whether to show indicator on load or not.
    ///   - initialNotifications: Custom notifications to start the notifications from.
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
        self.createCollectionIfNeeded(startingPoint: startingPoint ?? .max)
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
                    defer {
                        self.displaysLocalCachedListFirst = false
                    }

                    guard error == nil else { return }

                    // prevent empty view showing
                    if cacheResult == nil || cacheResult?.isEmpty == true { return }

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
            })
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

                self.delegate?.chatNotificationChannelViewModel(
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
            // Chat 콜백 큐를 바꾼 앱에서는 페이지 응답이 백그라운드에서 온다. 스크롤 갱신과 목록 반영은 main에서 처리한다.
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

                self.delegate?.chatNotificationChannelViewModel(
                    self,
                    shouldUpdateScrollInNotificationList: notifications,
                    forContext: nil,
                    keepsScroll: true
                )
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
        var toBeDeleteRequestIds: [String] = []
        
        for (index, notification) in self.notifications.enumerated() {
            for notificationId in notificationIds {
                guard notification.messageId == notificationId,
                      notification.isMessageIdValid else { continue }
                // 같은 id 가 두 번 들어오면 같은 index 를 두 번 지우게 되므로 한 번만 담는다.
                guard toBeDeleteIndexes.contains(index) == false else { continue }
                toBeDeleteIndexes.append(index)
                
                guard notification.isRequestIdValid else { continue }
                
                switch notification {
                case let adminMessage as AdminMessage:
                    let requestId = adminMessage.requestId
                    toBeDeleteRequestIds.append(requestId)
                default: break
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
    
    /// Deletes a notification with notification object.
    /// - Parameter notification: `BaseMessage` based class object
    //    func deleteNotification(notification: BaseMessage) {
    //        Log.info("[Request] Delete notification: \(notification.description)")
    //        self.channel?.deleteMessage(notification, completionHandler: nil)
    //    }
    
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
                self.delegate?.chatNotificationChannelViewModel(
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
        
        self.delegate?.chatNotificationChannelViewModel(
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
        // GroupChannel only
        guard let channel = self.channel else { return }
        self.notificationCollection = SendbirdChat.createMessageCollection(
            channel: channel,
            startingPoint: startingPoint,
            params: self.notificationListParams
        )
        self.notificationCollection?.delegate = self
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
}

// MARK: - ConnectionDelegate
extension SBUChatNotificationChannelViewModel: ConnectionDelegate {
    func didSucceedReconnection() {
        Log.info("Did succeed reconnection")
        
        SendbirdUI.updateUserInfo { error in
            if let error = error {
                Log.error("[Failed] Update user info: \(error.localizedDescription)")
            }
        }
        
        // 재연결 알림과 읽음 처리 결과는 Chat delegate 큐에서 온다. 채널을 읽는 읽음 처리와 새로 고침 시작은 main에서 한다.
        // main에서 불리면 지금처럼 바로 실행된다.
        Thread.executeOnMain { [weak self] in
            self?.markAsRead { [weak self] _ in
                Thread.executeOnMain { [weak self] in
                    self?.refreshChannel()
                }
            }
        }
    }
}

// MARK: - GroupChannelDelegate
extension SBUChatNotificationChannelViewModel: GroupChannelDelegate {
    // Received message
    func channel(_ channel: BaseChannel, didReceive message: BaseMessage) {
        // Chat 콜백 큐를 바꾼 앱에서는 채널 이벤트가 백그라운드에서 온다. 채널 확인과 화면의 스크롤 위치 읽기는 main에서 하고,
        // 새 알림 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로 develop처럼 Chat 콜백 큐에서 보낸다.
        // main에서 불리면 지금처럼 바로 실행된다.
        var receivingChannel: GroupChannel?
        self.executeOnMainThenNotifyOnCallbackQueue({ [weak self] in
            guard let self = self else { return false }
            guard self.channel?.channelURL == channel.channelURL else { return false }
            guard self.notificationListParams.belongsTo(message) else { return false }

            switch message {
            case is UserMessage:
                Log.info("Did receive user message: \(message)")
            case is FileMessage:
                Log.info("Did receive file message: \(message)")
            case is AdminMessage:
                Log.info("Did receive admin message: \(message)")
            default:
                break
            }

            let isScrollBottom = self.dataSource?.chatNotificationChannelViewModel(
                self,
                isScrollNearBottomInChannel: self.channel
            )
            guard self.hasNext == true || isScrollBottom == false, let currentChannel = self.channel else { return false }
            receivingChannel = currentChannel
            return true
        }, notify: { [weak self] in
            guard let self = self, let receivingChannel = receivingChannel else { return }
            self.delegate?.chatNotificationChannelViewModel(
                self,
                didReceiveNewNotification: message,
                forChannel: receivingChannel
            )
        })
    }
}

extension SBUChatNotificationChannelViewModel: MessageCollectionDelegate {
    func messageCollection(
        _ collection: MessageCollection,
        context: MessageContext,
        channel: GroupChannel,
        addedMessages messages: [BaseMessage]
    ) {
        // Chat 콜백 큐를 바꾼 앱에서는 collection 콜백이 백그라운드에서 온다. collection 콜백은 모두 main에서 도착 순서대로 처리한다
        // (수정 뒤 삭제처럼 이어 온 콜백의 목록 변경 순서가 뒤집히지 않게). main에서 불리면 지금처럼 바로 실행된다.
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            // -> pending, -> receive new notification
            Log.info("messageCollection addedNotifications : \(messages.count)")
            switch context.source {
            case .eventMessageReceived:
                self.markAsRead()
            default: break
            }

            self.delegate?.chatNotificationChannelViewModel(
                self,
                shouldUpdateScrollInNotificationList: messages,
                forContext: context,
                keepsScroll: true
            )
            self.upsertNotificationsInList(notifications: messages, needReload: true)
        }
    }

    func messageCollection(
        _ collection: MessageCollection,
        context: MessageContext,
        channel: GroupChannel,
        updatedMessages messages: [BaseMessage]
    ) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            // pending -> failed, pending -> succeded, failed -> Pending
            Log.info("messageCollection updatedNotifications : \(messages.count)")

            self.delegate?.chatNotificationChannelViewModel(
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

    func messageCollection(
        _ collection: MessageCollection,
        context: MessageContext,
        channel: GroupChannel,
        deletedMessages messages: [BaseMessage]
    ) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            Log.info("messageCollection deletedNotifications : \(messages.count)")
            self.delegate?.chatNotificationChannelViewModel(self, deletedNotifications: messages)
            self.deleteNotificationsInList(notificationIds: messages.compactMap({ $0.messageId }), needReload: true)
        }
    }

    func messageCollection(
        _ collection: MessageCollection,
        context: MessageContext,
        updatedChannel channel: GroupChannel
    ) {
        // 채널 변경 알림은 develop처럼 Chat 콜백 큐에서 보낸다(deletedChannel 주석 참고). 화면 갱신은 받는 VC가 main으로 넘긴다.
        Log.info("messageCollection changedChannel")
        self.delegate?.chatNotificationChannelViewModel(
            self,
            didChangeChannel: channel,
            withContext: context
        )
    }

    func messageCollection(
        _ collection: MessageCollection,
        context: MessageContext,
        deletedChannel channelURL: String
    ) {
        // 채널 변경 알림은 화면이 고객 override(didUpdateUnreadMessageCount)를 부르므로 develop처럼 Chat 콜백 큐에서 보낸다.
        // 화면 닫기는 받는 VC가 main으로 넘기며, 다른 collection 콜백과 같이 main 큐에 도착 순서대로 들어간다.
        Log.info("messageCollection deletedChannel")
        self.delegate?.chatNotificationChannelViewModel(
            self,
            didChangeChannel: nil,
            withContext: context
        )
    }

    func didDetectHugeGap(_ collection: MessageCollection) {
        // collection 콜백은 모두 main에서 도착 순서대로 처리한다(addedMessages 주석 참고).
        // 시작 위치를 정하려고 화면의 보이는 행을 읽으므로 main에서 해야 한다.
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }
            Log.info("messageCollection didDetectHugeGap")
            self.notificationCollection?.dispose()

            var startingPoint: Int64?
            let indexPathsForStartingPoint = self.dataSource?.chatNotificationChannelViewModel(
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
