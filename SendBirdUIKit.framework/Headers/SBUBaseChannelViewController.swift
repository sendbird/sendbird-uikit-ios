//
//  SBUBaseChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK
import MobileCoreServices

@objcMembers
open class SBUBaseChannelViewController: SBUBaseViewController {
    
    public var theme: SBUChannelTheme = SBUTheme.channelTheme
    
    // MARK: - Properties (View)
    
    public private(set) lazy var tableView = UITableView()
    
    public lazy var messageInputView: SBUMessageInputView = SBUMessageInputView()
    
    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
    /// And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = {
        let userProfileView = SBUUserProfileView(delegate: self)
         return userProfileView
     }()
    
    public lazy var emptyView: UIView? = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    // MARK: - Properties
    
    public let startingPoint: Int64?
    public internal(set) var channelUrl: String?
    
    /// This object is used in the user message in being edited.
    public internal(set) var inEditingMessage: SBDUserMessage? = nil
    
    /// This is a params used to get a list of messages. Only getter is provided, please use initialization function to set params directly.
    /// - note: For params properties, see `SBDMessageListParams` class.
    /// - Since: 1.0.11
    public var messageListParams: SBDMessageListParams {
        return self.channelViewModel?.messageListParams ?? self.customizedMessageListParams ?? SBDMessageListParams()
    }
    
    /// This object has a list of all success messages synchronized with the server.
    @SBUAtomic public internal(set) var messageList: [SBDBaseMessage] = []
    /// This object has a list of all messages.
    @SBUAtomic public internal(set) var fullMessageList: [SBDBaseMessage] = []
    
    
    var baseChannel: SBDBaseChannel? {
        didSet { createViewModel(startingPoint: self.startingPoint) }
    }
    var channelViewModel: SBUChannelViewModel? {
        willSet { self.disposeViewModel() }
        didSet { self.bindViewModel() }
    }
    var customizedMessageListParams: SBDMessageListParams? = nil
    var lastSeenIndexPath: IndexPath?
    
    private var isKeyboardShowing: Bool = false
    
    // MARK: - Constraints
    // for constraint
    var messageInputViewBottomConstraint: NSLayoutConstraint!
    var tableViewTopConstraint: NSLayoutConstraint!
    
    // MARK: - Lifecycle
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.startingPoint = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeReplies = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    /// - Since: 1.0.11
    init(baseChannel: SBDBaseChannel, messageListParams: SBDMessageListParams? = nil) {
        self.startingPoint = nil
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.baseChannel = baseChannel
        self.channelUrl = baseChannel.channelUrl

        self.customizedMessageListParams = messageListParams
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ```
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeReplies = true
    ///     ...
    /// ```
    /// - note: The `reverse` and the `previousResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channelUrl: Channel url string
    /// - Since: 1.0.11
    init(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        self.startingPoint = nil
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl

        self.customizedMessageListParams = messageListParams
    }
    
    /// Use this initializer to enter a channel to start from a specific timestamp..
    ///
    /// - Parameters:
    ///     - channelUrl: Channel's url
    ///     - startingPoint: A starting point timestamp to start the message list from
    ///     - messageListParams: `SBDMessageListParams` object to be used when loading messages.
    ///
    /// - Since: 2.1.0
    init(channelUrl: String, startingPoint: Int64, messageListParams: SBDMessageListParams? = nil) {
        self.startingPoint = startingPoint
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.customizedMessageListParams = messageListParams
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let userProfileView = userProfileView as? SBUUserProfileView {
            userProfileView.dismiss()
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        // tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.keyboardDismissMode = .interactive
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
    }
    
    deinit {
        self.disposeViewModel()
    }
    
    
    // MARK: - Styles
    
    open override func updateStyles() {
        if let userProfileView = self.userProfileView as? SBUUserProfileView {
            userProfileView.setupStyles()
        }
    }
    
    func setupScrollBottomViewStyle(scrollBottomView: UIView, theme: SBUComponentTheme = SBUTheme.componentTheme) {
        view.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
        
        guard let scrollBottomButton = scrollBottomView.subviews.first as? UIButton else { return }
        
        scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
        scrollBottomButton.clipsToBounds = true
        
        scrollBottomButton.setImage(SBUIconSetType.iconChevronDown.image(with: theme.scrollBottomButtonIconColor,
                                                                         to: SBUIconSetType.Metric.iconChevronDown),
                                    for: .normal)
        scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
        scrollBottomButton.setBackgroundImage(UIImage.from(color: theme.scrollBottomButtonHighlighted), for: .highlighted)
    }
    
    /// This function sets the user profile tap gesture handling.
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    ///
    /// - Since: 1.2.2
    open func setUserProfileTapGestureHandler(_ user: SBUUser) {
        self.dismissKeyboard()
        if let userProfileView = self.userProfileView as? SBUUserProfileView,
            let baseView = self.navigationController?.view,
            SBUGlobals.UsingUserProfile
        {
            userProfileView.show(
                baseView: baseView,
                user: user
            )
        }
    }
    
    // MARK: - View Binding
    
    /// Recreates the view model, loading initial messages from given starting point.
    /// - Parameters:
    ///     - startingPoint: The starting point timestamp of the messages. `nil` to start from the latest.
    ///     - showIndicator: Whether to show loading indicator on loading the initial messages.
    func createViewModel(startingPoint: Int64?, showIndicator: Bool = true) {
        guard let baseChannel = self.baseChannel else {
            SBULog.warning("Something wrong. Channel object is nil.")
            return
        }
        
        let cachedMessages = self.channelViewModel?.messageCache.flush(with: [])

        self.channelViewModel = SBUChannelViewModel(
            channel: baseChannel,
            customizedMessageListParams: self.customizedMessageListParams
        )
        
        self.channelViewModel?.loadInitialMessages(startingPoint: startingPoint,
                                                   showIndicator: showIndicator,
                                                   initialMessages: cachedMessages)
    }

    private func bindViewModel() {
        SBULog.info("bindViewModel")
        guard let channelViewModel = self.channelViewModel else { return }
        
        channelViewModel.loadingObservable.observe { [weak self] loadingState in
            guard let self = self else { return }
            
            if loadingState {
                self.shouldShowLoadingIndicator()
            } else {
                self.shouldDismissLoadingIndicator()
            }
        }
        
        channelViewModel.errorObservable.observe { [weak self] error in
            guard let self = self else { return }
            
            if self.messageList.isEmpty {
                if let emptyView = self.emptyView as? SBUEmptyView {
                    emptyView.reloadData(self.fullMessageList.isEmpty ? .error : .none)
                }
            }
            
            self.didReceiveError(error.localizedDescription)
        }
        
        channelViewModel.initialLoadObservable.observe { [weak self] messages in
            guard let self = self else { return }
            SBULog.info("Initial messages count : \(messages.count)")
            
            self.shouldDismissLoadingIndicator()
            
            if messages.isEmpty {
                SBULog.info("Fetched empty messages.")
                if let emptyView = self.emptyView as? SBUEmptyView {
                    emptyView.reloadData(.noMessages)
                }
            }
            
            self.clearMessageList()
            self.upsertMessagesInList(messages: messages, needReload: true)
            
            self.tableView.layoutIfNeeded()

            if let startingPoint = self.channelViewModel?.startingPoint,
               let index = self.fullMessageList.firstIndex(where: { $0.createdAt <= startingPoint }) {
                SBULog.info("Scrolling to : \(index)")
                self.scrollTableViewTo(row: index, at: .middle)
            } else {
                self.scrollTableViewTo(row: 0)
            }
        }
        
        channelViewModel.messageFetchedObservable.observe { [weak self] upsertedMessages, keepScroll in
            guard let self = self else { return }
            SBULog.info("Fetched : \(upsertedMessages.count), keepScroll : \(keepScroll)")
            
            guard !upsertedMessages.isEmpty else {
                SBULog.info("Fetched empty messages.")
                return
            }
            
            if keepScroll {
                let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
                var nextInsertedCount = 0
                if let newestMessage = self.messageList.first {
                    // only filter out messages inserted at the bottom (newer) of current visible item
                    nextInsertedCount = upsertedMessages
                        .filter({ $0.createdAt > newestMessage.createdAt })
                        .filter({ !SBUUtils.contains(messageId: $0.messageId, in: self.messageList) }).count
                }
                
                SBULog.info("New messages inserted : \(nextInsertedCount)")
                self.lastSeenIndexPath = IndexPath(row: firstVisibleIndexPath.row + nextInsertedCount, section: 0)
            }
            
            self.upsertMessagesInList(messages: upsertedMessages, needReload: true)
        }
        
        channelViewModel.messageUpdatedObservable.observe { [weak self] updatedMessages in
            guard let self = self else { return }
            
            let messagesToUpdate = updatedMessages.filter { SBUUtils.findIndex(of: $0, in: self.messageList) != nil }
            SBULog.info("UpdatedMessages : \(updatedMessages.count), messagesToUpdate : \(messagesToUpdate)")
            
            guard !messagesToUpdate.isEmpty else { return }
            self.upsertMessagesInList(messages: messagesToUpdate, needReload: true)
        }
        
        channelViewModel.deletedMessageFetchedObservable.observe { [weak self] deletedMessageIds in
            guard !deletedMessageIds.isEmpty else { return }
            self?.deleteMessagesInList(messageIds: deletedMessageIds, needReload: false)
        }
    }
    
    private func disposeViewModel() {
        self.channelViewModel?.dispose()
    }
    
    // MARK: - Keyboard
    /// This function changes the messageInputView bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Since: 1.2.5
    public func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue else { return }
        
        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue
        
        // iOS 14 bug, keyboardWillShow is called instead of keyboardWillHide.
        if endFrame.origin.y >= UIScreen.main.bounds.height {
            self.keyboardWillHide(notification)
            return
        }
        
        if (beginFrame.origin.equalTo(endFrame.origin)
                && beginFrame.height != endFrame.height) {
            return
        }
        
        self.isKeyboardShowing = true
        
        //NOTE: needs this on show as well to prevent bug on switching orientation as show&hide will be called simultaneously.
        setKeyboardWindowFrame(origin: .zero)
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.messageInputViewBottomConstraint.constant = -keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    /// This function changes the messageInputView bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Since: 1.2.5
    public func keyboardWillHide(_ notification: Notification) {
        self.isKeyboardShowing = false
        
        setKeyboardWindowFrame(origin: CGPoint(x: 0, y: 50))
        
        self.messageInputViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    /// This function dismisses the keyboard.
    /// - Since: 1.2.5
    public func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // To hide autocorrection view on keyboard hidden.
    // https://stackoverflow.com/questions/59278526/keyboard-dismiss-very-buggy-on-tableview-interactive
    private func setKeyboardWindowFrame(origin: CGPoint, size: CGSize = UIScreen.main.bounds.size) {
        var keyboardWindow: UIWindow? = nil
        for window in UIApplication.shared.windows {
            if (NSStringFromClass(type(of: window).self) == "UIRemoteKeyboardWindow") {
                keyboardWindow = window
            }
        }
        
        keyboardWindow?.frame = CGRect(origin: origin, size: size)
    }
    
    private var initialMessageInputBottomConstraint: CGFloat = 0
    private var initialMessageInputOrigin: CGPoint = .zero
    
    @objc private func dismissKeyboardIfTouchInput(sender: UIPanGestureRecognizer) {
        // no needs to listen to pan gesture if keyboard is not showing.
        guard self.isKeyboardShowing else {
            cancel(gestureRecognizer: sender)
            return
        }
        
        switch sender.state {
        case .began:
            initialMessageInputOrigin = self.view.convert(self.messageInputView.frame.origin, to: self.view)
            initialMessageInputBottomConstraint = self.messageInputViewBottomConstraint.constant
        case .changed:
            switch self.tableView.keyboardDismissMode {
            case .interactive:
                let initialMessageInputBottomY = initialMessageInputOrigin.y + self.messageInputView.frame.size.height
                let point = sender.location(in: view)
                
                // calculate how much the point is diverged with the initial message input's bottom.
                let diffBetweenPointYMessageInputBottomY = point.y - initialMessageInputBottomY
                
                // add the diff value to initial message bottom constraint, but keep minimum value as it's initial constraint as
                // keyboard can't go any higher.
                self.messageInputViewBottomConstraint.constant =
                    max(initialMessageInputBottomConstraint + diffBetweenPointYMessageInputBottomY, initialMessageInputBottomConstraint)
                break
            default:
                self.cancel(gestureRecognizer: sender)
            }
        case .ended:
            // defense code to prevent bottom constant to be set as some other value
            self.messageInputViewBottomConstraint.constant = self.isKeyboardShowing ? initialMessageInputBottomConstraint : 0
            break
        default:
            break
        }
    }
    
    private func cancel(gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizer.isEnabled = false
        gestureRecognizer.isEnabled = true
    }
    
    /// This functions adds the hide keyboard gesture in tableView.
    /// - Since: 1.2.5
    public func addGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboardIfTouchInput))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        tableView.addGestureRecognizer(pan)
    }
    
    // MARK: - Channel
    
    public func loadChannel(channelUrl: String?, messageListParams: SBDMessageListParams? = nil) {}
    
    /// This functions clears current message lists
    ///
    /// - Since: 2.1.0
    public func clearMessageList() {
        self.fullMessageList.removeAll(where: { SBUUtils.findIndex(of: $0, in: self.messageList) != nil })
        self.messageList = []
    }
    
    // MARK: - List
    
    /// To keep track of which reloads tableview.
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    /// To keep track of which scrolls tableview.
    func scrollTableViewTo(row: Int, at position: UITableView.ScrollPosition = .top, animated: Bool = false) {
        if self.fullMessageList.isEmpty {
            guard self.tableView.contentOffset != .zero else { return }
            
            self.tableView.setContentOffset(.zero, animated: false)
        } else {
            self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: position, animated: animated)
        }
    }
    
    /// This function upserts the messages in the list.
    /// - Parameters:
    ///   - messages: Message array to upsert
    ///   - needUpdateNewMessage: If set to `true`, increases new message count.
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func upsertMessagesInList(messages: [SBDBaseMessage]?,
                                      needUpdateNewMessage: Bool = false,
                                      needReload: Bool) {
        SBULog.info("First : \(String(describing: messages?.first)), Last : \(String(describing: messages?.last))")
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList.remove(at: index)
            }
            self.messageList.append(message)
            
            guard message is SBDUserMessage ||
                    message is SBDFileMessage else { return }

            if needUpdateNewMessage {
                self.increaseNewMessageCount()
            }
        }
        
        self.channelViewModel?.resetRequestingLoad()
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// This function deletes the messages in the list using the message ids. (Resendable messages are also delete together.)
    /// - Parameters:
    ///   - messageIds: Message id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteMessagesInList(messageIds: [Int64]?, needReload: Bool) {
        self.deleteMessagesInList(
            messageIds: messageIds,
            excludeResendableMessages: false,
            needReload: needReload
        )
    }
    
    /// This function deletes the messages in the list using the message ids.
    /// - Parameters:
    ///   - messageIds: Message id array to delete
    ///   - excludeResendableMessages: If set to `true`, the resendable messages are not deleted.
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 2.1.8
    public func deleteMessagesInList(messageIds: [Int64]?,
                                     excludeResendableMessages: Bool,
                                     needReload: Bool) {
        guard let messageIds = messageIds else { return }
        
        // if deleted message contains the currently editing message,
        // end edit mode.
        if let editMessage = inEditingMessage,
           messageIds.contains(editMessage.messageId) {
            self.setEditMode(for: nil)
        }
        
        var toBeDeleteIndexes: [Int] = []
        var toBeDeleteRequestIds: [String] = []
        
        for (index, message) in self.messageList.enumerated() {
            for messageId in messageIds {
                guard message.messageId == messageId else { continue }
                toBeDeleteIndexes.append(index)
                
                guard message.requestId.count > 0 else { continue }
                
                switch message {
                case let userMessage as SBDUserMessage:
                    let requestId = userMessage.requestId
                    toBeDeleteRequestIds.append(requestId)

                case let fileMessage as SBDFileMessage:
                    let requestId = fileMessage.requestId
                    toBeDeleteRequestIds.append(requestId)
                    
                default: break
                }
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for index in sortedIndexes {
            self.messageList.remove(at: index)
        }
        
        if excludeResendableMessages {
            self.sortAllMessageList(needReload: needReload)
        } else {
            self.deleteResendableMessages(requestIds: toBeDeleteRequestIds, needReload: needReload)
        }
    }
    
    /// This functions deletes the resendable messages using the request ids.
    /// - Parameters:
    ///   - requestIds: Request id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteResendableMessages(requestIds: [String], needReload: Bool) {
        for requestId in requestIds {
            SBUPendingMessageManager.shared.removePendingMessage(
                channelUrl: self.baseChannel?.channelUrl,
                requestId: requestId
            )
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// Deletes a message with message object.
    /// - Parameter message: `SBDBaseMessage` based class object
    /// - Since: 1.0.9
    public func deleteMessage(message: SBDBaseMessage) {
        self.deleteMessage(message: message, oneTimetheme: nil)
    }
                       
    func deleteMessage(message: SBDBaseMessage,
                       oneTimetheme: SBUComponentTheme?) {
        let deleteButton = SBUAlertButtonItem(
            title: SBUStringSet.Delete,
            color: self.theme.alertRemoveColor
        ) { [weak self] info in
            guard let self = self else { return }
            SBULog.info("[Request] Delete message: \(message.description)")
            
            self.baseChannel?.delete(message, completionHandler: { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.didReceiveError(error.localizedDescription)
                    SBULog.error("[Failed] Delete message request: \(error.localizedDescription)")
                    return
                }
                
                SBULog.info("[Succeed] Delete message: \(message.description)")
                
                self.deleteMessagesInList(messageIds: [message.messageId],
                                          needReload: true)
            })
        }
        
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }
        
        SBUAlertView.show(
            title: SBUStringSet.Alert_Delete,
            oneTimetheme: oneTimetheme,
            confirmButtonItem: deleteButton,
            cancelButtonItem: cancelButton
        )
    }
    
    /// This function sorts the all message list. (Included `presendMessages`, `messageList` and `resendableMessages`.)
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData and, scroll to last seen index.
    /// - Since: 1.2.5
    public func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        let pendingMessages = SBUPendingMessageManager.shared.getPendingMessages(
            channelUrl: self.baseChannel?.channelUrl
        )
        let sendMessages = self.messageList
        
        self.fullMessageList = pendingMessages
            .sorted { $0.createdAt > $1.createdAt }
            + sendMessages.sorted { $0.createdAt > $1.createdAt }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(self.fullMessageList.isEmpty ? .noMessages : .none)
        }
        
        guard needReload else { return }
        
        self.reloadTableView()
        
        guard let lastSeenIndexPath = self.lastSeenIndexPath else {
            self.setScrollBottomView(hidden: nil)
            return
        }
        
        self.scrollTableViewTo(row: lastSeenIndexPath.row)
        self.setScrollBottomView(hidden: nil)
    }
    
    /// This function increases the new message count.
    public func increaseNewMessageCount() {
        guard self.tableView.contentOffset != .zero else {
            self.lastSeenIndexPath = nil
            return
        }
        
        guard self.channelViewModel?.isRequestingLoad == false else {
            self.lastSeenIndexPath = nil
            return
        }
        
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        self.lastSeenIndexPath = IndexPath(row: firstVisibleIndexPath.row + 1, section: 0)
    }
    
    // MARK: - Error handling
    
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: - Message input mode
    
    /// Set/Unset edit mode for given userMessage.
    /// - Parameter userMessage : User message to edit, or nil to end edit mode.
    public func setEditMode(for userMessage: SBDUserMessage?) {
        inEditingMessage = userMessage
        
        if let userMessage = userMessage {
            self.messageInputView.startEditMode(text: userMessage.message)
        } else {
            self.messageInputView.endEditMode()
        }
    }
    
    // MARK: - Cell binding
    
    /// This function sets images in file message cell.
    /// - Parameters:
    ///   - cell: File message cell
    ///   - fileMessage: File message object
    func setCellImage(_ cell: UITableViewCell,
                      fileMessage: SBDFileMessage) {
        switch fileMessage.sendingStatus {
        case .canceled, .pending, .failed, .none:
            if let fileInfo = SBUPendingMessageManager.shared.getFileInfo(requestId: fileMessage.requestId),
                let type = fileInfo.mimeType, let fileData = fileInfo.file {
                if SBUUtils.getFileType(by: type) == .image {
                    let image = UIImage.createImage(from: fileData)
                    let isAnimatedImage = image?.isAnimatedImage() == true
                    
                    if let cell = cell as? SBUFileMessageCell {
                        cell.setImage(isAnimatedImage ? image?.images?.first : image,
                                      size: SBUConstant.thumbnailSize)
                    } else if let cell = cell as? SBUOpenChannelFileMessageCell {
                        cell.setImage(isAnimatedImage ? image?.images?.first : image,
                                      size: SBUConstant.openChannelThumbnailSize)
                    }
                }
            }
        case .succeeded:
            break
        @unknown default:
            self.didReceiveError("unknown Type")
        }
    }
    
    // MARK: - Cell's menu
    
    func createMenuItems(message: SBDBaseMessage,
                         titleColor: UIColor,
                         iconColor: UIColor,
                         types: [MessageMenuItem]) -> [SBUMenuItem] {
        let items: [SBUMenuItem] = types.map {
            switch $0 {
            case .copy:
                return SBUMenuItem(
                    title: SBUStringSet.Copy,
                    color: titleColor,
                    image: SBUIconSetType.iconCopy.image(
                        with: iconColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) {
                    guard let userMessage = message as? SBDUserMessage else { return }
                    
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = userMessage.message
                }
            case .edit:
                return SBUMenuItem(
                    title: SBUStringSet.Edit,
                    color: titleColor,
                    image: SBUIconSetType.iconEdit.image(
                        with: iconColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    guard let userMessage = message as? SBDUserMessage else { return }
                    
                    if self.baseChannel?.isFrozen == false {
                        self.setEditMode(for: userMessage)
                    } else {
                        SBULog.info("This channel is frozen")
                    }
                }
            case .delete:
                return SBUMenuItem(
                    title: SBUStringSet.Delete,
                    color: titleColor,
                    image: SBUIconSetType.iconDelete.image(
                        with: iconColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    self.deleteMessage(message: message)
                }
            case .save:
                return SBUMenuItem(
                    title: SBUStringSet.Save,
                    color: titleColor,
                    image: SBUIconSetType.iconDownload.image(
                        with: iconColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    guard let fileMessage = message as? SBDFileMessage else { return }
                    
                    SBUDownloadManager.saveFile(with: fileMessage, parent: self)
                }
            }
        }
        
        return items
    }
    
    
    // MARK: - Sending messages
    
    /// Sends a user message with only text.
    /// - Parameter text: String value
    /// - Since: 1.0.9
    public func sendUserMessage(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParams = SBDUserMessageParams(message: text) else { return }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
        
        self.sendUserMessage(messageParams: messageParams)
    }
    
    /// Sends a user messag with messageParams.
    ///
    /// You can send a message by setting various properties of MessageParams.
    /// - Parameter messageParams: `SBDUserMessageParams` class object
    /// - Since: 1.0.9
    public func sendUserMessage(messageParams: SBDUserMessageParams) {
        SBULog.info("[Request] Send user message")
        
        let preSendMessage = self.baseChannel?.sendUserMessage(with: messageParams)
        { [weak self] userMessage, error in
            if (error != nil) {
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: userMessage?.channelUrl,
                    message: userMessage
                )
            } else {
                SBUPendingMessageManager.shared.removePendingMessage(
                    channelUrl: userMessage?.channelUrl,
                    requestId: userMessage?.requestId
                )
            }
            
            guard let self = self else { return }
            
            if let error = error {
                self.sortAllMessageList(needReload: true)
                self.didReceiveError(error.localizedDescription)
                SBULog.error("[Failed] Send user message request: \(error.localizedDescription)")
                return
            }
            
            guard let message = userMessage else { return }
            SBULog.info("[Succeed] Send user message: \(message.description)")
              
            self.upsertMessagesInList(messages: [message], needReload: true)
            if let channel = self.baseChannel as? SBDGroupChannel {
                channel.markAsRead()
            }
        }
               
        SBUPendingMessageManager.shared.upsertPendingMessage(
            channelUrl: self.baseChannel?.channelUrl,
            message: preSendMessage
        )
        
        self.sortAllMessageList(needReload: true)
        self.messageInputView.endTypingMode()
        self.scrollToBottom(animated: false)
        if let channel = self.baseChannel as? SBDGroupChannel {
            channel.endTyping()
        }
    }
    
    /// Sends a file message with file data, file name, mime type.
    /// - Parameters:
    ///   - fileData: `Data` class object
    ///   - fileName: file name. Used when displayed in channel list.
    ///   - mimeType: file's mime type.
    /// - Since: 1.0.9
    public func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        guard let fileData = fileData else { return }
        let messageParams = SBDFileMessageParams(file: fileData)!
        messageParams.fileName = fileName
        messageParams.mimeType = mimeType
        messageParams.fileSize = UInt(fileData.count)
        
        if let image = UIImage(data: fileData) {
            let thumbnailSize = SBDThumbnailSize.make(withMaxCGSize: image.size)
            messageParams.thumbnailSizes = [thumbnailSize]
        }
        
        SBUGlobalCustomParams.fileMessageParamsSendBuilder?(messageParams)
        
        self.sendFileMessage(messageParams: messageParams)
    }
    
    /// Sends a file message with messageParams.
    ///
    /// You can send a file message by setting various properties of MessageParams.
    /// - Parameter messageParams: `SBDFileMessageParams` class object
    /// - Since: 1.0.9
    public func sendFileMessage(messageParams: SBDFileMessageParams) {
        guard let channel = self.baseChannel else { return }
        
        SBULog.info("[Request] Send file message")
        var preSendMessage: SBDFileMessage?
        preSendMessage = channel.sendFileMessage(
            with: messageParams,
            progressHandler: { bytesSent, totalBytesSent, totalBytesExpectedToSend in
                //// If need reload cell for progress, call reload action in here.
                guard let requestId = preSendMessage?.requestId else { return }
                let fileTransferProgress = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
                SBULog.info("File message transfer progress: \(requestId) - \(fileTransferProgress)")
            },
            completionHandler: { [weak self] fileMessage, error in
                if (error != nil) {
                    SBUPendingMessageManager.shared.upsertPendingMessage(
                        channelUrl: fileMessage?.channelUrl,
                        message: fileMessage
                    )
                } else {
                    SBUPendingMessageManager.shared.removePendingMessage(
                        channelUrl: fileMessage?.channelUrl,
                        requestId: fileMessage?.requestId
                    )
                }
                
                guard let self = self else { return }
                if let error = error {
                    self.sortAllMessageList(needReload: true)
                    self.didReceiveError(error.localizedDescription)
                    SBULog.error("""
                        [Failed] Send file message request:
                        \(error.localizedDescription)
                        """)
                    return
                }
                
                guard let message = fileMessage else { return }
                
                SBULog.info("[Succeed] Send file message: \(message.description)")
                
                self.upsertMessagesInList(messages: [message], needReload: true)
                
                if let channel = self.baseChannel as? SBDGroupChannel {
                    channel.markAsRead()
                }
            })
        
        SBUPendingMessageManager.shared.upsertPendingMessage(
            channelUrl: self.baseChannel?.channelUrl,
            message: preSendMessage
        )
        
        SBUPendingMessageManager.shared.addFileInfo(
            requestId: preSendMessage?.requestId,
            params: messageParams
        )
        
        self.sortAllMessageList(needReload: true)
    }
    
    /// Updates a user message with message object.
    /// - Parameters:
    ///   - message: `SBDUserMessage` object to update
    ///   - text: String to be updated
    /// - Since: 1.0.9
    public func updateUserMessage(message: SBDUserMessage, text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParams = SBDUserMessageParams(message: text) else { return }
        
        SBUGlobalCustomParams.userMessageParamsUpdateBuilder?(messageParams)
        
        self.updateUserMessage(message: message, messageParams: messageParams)
    }
    
    /// Updates a user message with message object and messageParams.
    ///
    /// You can update messages by setting various properties of MessageParams.
    /// - Parameters:
    ///   - message: `SBDUserMessage` object to update
    ///   - messageParams: `SBDUserMessageParams` class object
    /// - Since: 1.0.9
    public func updateUserMessage(message: SBDUserMessage, messageParams: SBDUserMessageParams) {
        SBULog.info("[Request] Update user message")
        
        self.baseChannel?.updateUserMessage(
            withMessageId: message.messageId,
            userMessageParams: messageParams) { [weak self] updatedMessage, error in
                guard let self = self else { return }
                if let error = error {
                    self.didReceiveError(error.localizedDescription)
                    SBULog.error("""
                        [Failed] Send user message request:
                        \(String(error.localizedDescription))
                        """)
                    return
                }
                
                guard let updatedMessage = updatedMessage else {
                    SBULog.error("[Failed] Update user message is nil")
                    return
                }
                
                SBULog.info("[Succeed] Update user message: \(updatedMessage.description)")
                
                self.deleteMessagesInList(messageIds: [message.messageId], needReload: false)
                self.upsertMessagesInList(messages: [updatedMessage], needReload: true)
                self.setEditMode(for: nil)
            }
    }
    
    /// Resends a message with failedMessage object.
    /// - Parameter failedMessage: `SBDBaseMessage` class based failed object
    /// - Since: 1.0.9
    public func resendMessage(failedMessage: SBDBaseMessage) {
        if let failedMessage = failedMessage as? SBDUserMessage {
            SBULog.info("[Request] Resend failed user message")
            
            let pendingMessage = self.baseChannel?.resendUserMessage(
                with: failedMessage,
                completionHandler: { [weak self] userMessage, error in
                    if (error != nil) {
                        SBUPendingMessageManager.shared.upsertPendingMessage(
                            channelUrl: userMessage?.channelUrl,
                            message: userMessage
                        )
                    } else {
                        SBUPendingMessageManager.shared.removePendingMessage(
                            channelUrl: userMessage?.channelUrl,
                            requestId: userMessage?.requestId
                        )
                    }
                    
                    guard let self = self else { return }
                    if let error = error {
                        self.sortAllMessageList(needReload: true)
                        self.didReceiveError(error.localizedDescription)
 
                        SBULog.error("""
                            [Failed] Resend failed user message request:
                            \(error.localizedDescription)\n
                            \(failedMessage)
                            """)
                        return
                    }
                    
                    guard let message = userMessage else { return }
                    
                    self.upsertMessagesInList(messages: [message], needReload: true)
                    
                    if let channel = self.baseChannel as? SBDGroupChannel {
                        channel.markAsRead()
                    }
            })
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.baseChannel?.channelUrl,
                message: pendingMessage
            )
            
            if let failedMessage = pendingMessage {
                self.deleteMessagesInList(
                    messageIds: [failedMessage.messageId],
                    excludeResendableMessages: true,
                    needReload: true
                )
            }
            
        } else if let failedMessage = failedMessage as? SBDFileMessage {
            var data: Data? = nil

            if let fileInfo = SBUPendingMessageManager.shared.getFileInfo(
                requestId: failedMessage.requestId) {
                data = fileInfo.file
            }

            SBULog.info("[Request] Resend failed file message")
            
            let pendingMessage = self.baseChannel?.resendFileMessage(
                with: failedMessage,
                binaryData: data,
                progressHandler: { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                    //// If need reload cell for progress, call reload action in here.
                    // self.tableView.reloadData()
                },
                completionHandler: { [weak self] (fileMessage, error) in
                    if (error != nil) {
                        SBUPendingMessageManager.shared.upsertPendingMessage(
                            channelUrl: fileMessage?.channelUrl,
                            message: fileMessage
                        )
                    } else {
                        SBUPendingMessageManager.shared.removePendingMessage(
                            channelUrl: fileMessage?.channelUrl,
                            requestId: fileMessage?.requestId
                        )
                    }
                    
                    guard let self = self else { return }
                    if let error = error {
                        self.sortAllMessageList(needReload: true)
                        self.didReceiveError(error.localizedDescription)
                        SBULog.error("""
                            [Failed] Resend failed file message request:
                            \(error.localizedDescription)\n
                            \(failedMessage)
                            """)
                        return
                    }
                    
                    guard let message = fileMessage else { return }
                    SBULog.info("[Succeed] Resend failed file message: \(message.description)")

                    self.upsertMessagesInList(messages: [message], needReload: true)
                    
                    if let channel = self.baseChannel as? SBDGroupChannel {
                        channel.markAsRead()
                    }
                })
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.baseChannel?.channelUrl,
                message: pendingMessage
            )
            
            if let failedMessage = pendingMessage {
                self.deleteMessagesInList(
                    messageIds: [failedMessage.messageId],
                    excludeResendableMessages: true,
                    needReload: true
                )
            }
        }
    }
    
    // MARK: - ScrollView
    
    func isScrollNearBottom() -> Bool {
        return self.tableView.contentOffset.y < 10
    }
    
    /// This function scrolls to bottom.
    /// - Parameter animated: Animated
    public func scrollToBottom(animated: Bool) {
        guard self.fullMessageList.count != 0 else { return }
        self.lastSeenIndexPath = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.inEditingMessage = nil
            self.messageInputView.endEditMode()
            
            if self.channelViewModel?.hasNext ?? false {
                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                self.createViewModel(startingPoint: nil, showIndicator: false)
                self.scrollTableViewTo(row: 0)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.scrollTableViewTo(row: indexPath.row, animated: animated)
                self.setNewMessageInfoView(hidden: true)
                self.setScrollBottomView(hidden: true)
            }
        }
    }
    
    public func setScrollBottomView(hidden: Bool?) {
        // implemented in inherited views
    }
    
    /// This shows new message view based on `hasNext`
    func setNewMessageInfoView(hidden: Bool) {
        // implemented in inherited views
    }
    
    // MARK: - Send action relations
    
    /// Sends a image file message.
    /// - Parameter info: Image information selected in `UIImagePickerController`
    public func sendImageFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        var tempImageUrl: URL? = nil
        if #available(iOS 11.0, *) {
            if let imageUrl = info[.imageURL] as? URL {
                // file:///~~~
                tempImageUrl = imageUrl
            }
        } else {
            if let imageUrl = info[.referenceURL] as? URL {
                // assets-library://~~~
                tempImageUrl = imageUrl
            }
        }
        
        guard let imageUrl = tempImageUrl else {
            let originalImage = info[.originalImage] as? UIImage
            // for Camera capture
            guard let image = originalImage?
                .fixedOrientation()
                .resize(with: SBUGlobals.imageResizingSize) else { return }
            
            let imageData = image.jpegData(
                compressionQuality: SBUGlobals.UsingImageCompression ?
                    SBUGlobals.imageCompressionRate : 1.0
            )
            
            self.sendFileMessage(
                fileData: imageData,
                fileName: "\(Date().toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                mimeType: "image/jpeg"
            )
            
            return
        }
        
        let imageName = imageUrl.lastPathComponent
        guard let mimeType = SBUUtils.getMimeType(url: imageUrl) else { return }
        
        switch mimeType {
        case "image/gif":
            let gifData = try? Data(contentsOf: imageUrl)
            self.sendFileMessage(fileData: gifData, fileName: imageName, mimeType: mimeType)
            
        default:
            let originalImage = info[.originalImage] as? UIImage
            guard let image = originalImage?
                .fixedOrientation()
                .resize(with: SBUGlobals.imageResizingSize) else { return }
            
            let imageData = image.jpegData(
                compressionQuality: SBUGlobals.UsingImageCompression ?
                    SBUGlobals.imageCompressionRate : 1.0
            )
            
            self.sendFileMessage(
                fileData: imageData,
                fileName: "\(Date().toString(format: .yyyyMMddhhmmss, localizedFormat: false)).jpg",
                mimeType: "image/jpeg"
            )
        }
    }
    
    /// Sends a video file message.
    /// - Parameter info: Video information selected in `UIImagePickerController`
    public func sendVideoFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        do {
            guard let videoUrl = info[.mediaURL] as? URL else { return }
            let videoFileData = try Data(contentsOf: videoUrl)
            let videoName = videoUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: videoUrl) else { return }
            
            self.sendFileMessage(
                fileData: videoFileData,
                fileName: videoName,
                mimeType: mimeType
            )
        } catch {
        }
    }
    
    /// Sends a document file message.
    /// - Parameter documentUrls: Document information selected in `UIDocumentPickerViewController`
    public func sendDocumentFileMessage(documentUrls: [URL]) {
        do {
            guard let documentUrl = documentUrls.first else { return }
            let documentData = try Data(contentsOf: documentUrl)
            let documentName = documentUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: documentUrl) else { return }
            self.sendFileMessage(
                fileData: documentData,
                fileName: documentName,
                mimeType: mimeType
            )
        } catch {
            self.didReceiveError(error.localizedDescription)
        }
    }
    
    // MARK: - Common
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {}
    
}

extension SBUBaseChannelViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
            -> Bool {
       return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SBUBaseChannelViewController: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fullMessageList.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        preconditionFailure("Needs to implement this method")
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        guard self.fullMessageList.count > 0 else { return }
        guard let channelViewModel = self.channelViewModel else { return }
        
        if indexPath.row >= (self.fullMessageList.count - self.messageListParams.previousResultSize / 2),
           channelViewModel.hasPrevious {
            self.channelViewModel?.loadPrevMessages(timestamp: self.messageList.last?.createdAt)
        } else if indexPath.row < 5,
                  channelViewModel.hasNext {
            self.channelViewModel?.loadNextMessages()
        }
    }
}

// MARK: - SBUUserProfileViewDelegate
extension SBUBaseChannelViewController: SBUUserProfileViewDelegate {
    open func didSelectMessage(userId: String?) {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SBUMain.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
    
    open func didSelectClose() {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
}


// MARK: - SBUEmptyViewDelegate
extension SBUBaseChannelViewController: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        self.loadChannel(channelUrl: self.baseChannel?.channelUrl ?? self.channelUrl)
    }
}

extension SBUBaseChannelViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        return false
    }
    
    open func shouldDismissLoadingIndicator() {}
}


// MARK: - UIViewControllerTransitioningDelegate
extension SBUBaseChannelViewController: UIViewControllerTransitioningDelegate {
    open func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return SBUBottomSheetController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}


// MARK: - UIImagePickerControllerDelegate
extension SBUBaseChannelViewController: UIImagePickerControllerDelegate {
    open func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            guard info[.mediaType] != nil else { return }
            let mediaType = info[.mediaType] as! CFString

            switch mediaType {
            case kUTTypeImage:
                self.sendImageFileMessage(info: info)
            case kUTTypeMovie:
                self.sendVideoFileMessage(info: info)
            default:
                break
            }
        }
    }
    
    open func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - UIDocumentPickerDelegate
extension SBUBaseChannelViewController: UIDocumentPickerDelegate {
    @available(iOS 11.0, *)
    open func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentsAt urls: [URL]) {
        self.sendDocumentFileMessage(documentUrls: urls)
    }
    
    open func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) { return }
        self.sendDocumentFileMessage(documentUrls: [url])
    }
}


// MARK: - SBUMessageInputViewDelegate
extension SBUBaseChannelViewController: SBUMessageInputViewDelegate {
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectSend text: String) {
        guard text.count > 0 else { return }
        self.sendUserMessage(text: text)
    }

    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectResource type: MediaResourceType) {
        if type == .document {
            let documentPicker = UIDocumentPickerViewController(
                documentTypes: ["public.content"],
                in: UIDocumentPickerMode.import
            )
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        }
        else {
            var sourceType: UIImagePickerController.SourceType = .photoLibrary
            let mediaType: [String] = [
                String(kUTTypeImage),
                String(kUTTypeGIF),
                String(kUTTypeMovie)
            ]
            
            switch type {
            case .camera:
                sourceType = .camera
            case .library:
                sourceType = .photoLibrary
            default:
                break
            }
            
            if UIImagePickerController.isSourceTypeAvailable(sourceType) {
                let imagePickerController = UIImagePickerController()
                imagePickerController.delegate = self
                imagePickerController.sourceType = sourceType
                imagePickerController.mediaTypes = mediaType
                self.present(imagePickerController, animated: true, completion: nil)
            }
        }
    }

    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectEdit text: String) {
        guard let message = self.inEditingMessage else { return }

        self.updateUserMessage(message: message, text: text)
    }
    
    open func messageInputViewDidStartTyping() {
        self.channelViewModel?.startTypingMessage()
    }
    
    open func messageInputViewDidEndTyping() {
        self.channelViewModel?.endTypingMessage()
    }
}


// MARK: - SBUFileViewerDelegate
extension SBUBaseChannelViewController: SBUFileViewerDelegate {
    open func didSelectDeleteImage(message: SBDFileMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        
        self.baseChannel?.delete(message) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                self.didReceiveError(error.localizedDescription)
                SBULog.error("[Failed] Delete message request: \(error.localizedDescription)")
                return
            }

            SBULog.info("[Succeed] Delete message: \(message.description)")
            self.deleteMessagesInList(messageIds: [message.messageId], needReload: true)
        }
    }
}

