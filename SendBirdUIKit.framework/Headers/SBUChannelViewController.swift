//
//  SBUChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import Photos
import MobileCoreServices
import AVKit
import SafariServices
import SendBirdSDK

@objcMembers
open class SBUChannelViewController: SBUBaseChannelViewController {

    // MARK: - UI properties (Public)
    public var channelName: String? = nil
    
    /// You can use the customized view and a view that inherits `SBUNewMessageInfo`.
    /// If you use a view that inherits SBUNewMessageInfo, you can change the button and their action.
    public lazy var newMessageInfoView: UIView? = _newMessageInfoView

    public var titleView: UIView? = nil {
        didSet {
            var stack = UIStackView()
            if let titleView = self.titleView {
                stack = UIStackView(arrangedSubviews: [titleView, self.spacer])
                stack.axis = .horizontal
            }
            
            self.navigationItem.titleView = stack
        }
    }
    public var leftBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.leftBarButtonItem = self.leftBarButton
        }
    }
    public var rightBarButton: UIBarButtonItem? = nil {
        didSet {
            self.navigationItem.rightBarButtonItem = self.useRightBarButtonItem ? self.rightBarButton : nil
        }
    }
    public lazy var channelStateBanner: UIView? = _channelStateBanner
    public lazy var emptyView: UIView? = _emptyView
    public lazy var scrollBottomView: UIView? = {
        let view: UIView = UIView(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
        let theme = SBUTheme.componentTheme
        
        view.backgroundColor = .clear
        view.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 5)
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 5
        view.layer.masksToBounds = false
        
        let scrollBottomButton = UIButton(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
        scrollBottomButton.layer.cornerRadius = scrollBottomButton.frame.height / 2
        scrollBottomButton.clipsToBounds = true
        
        scrollBottomButton.setImage(SBUIconSetType.iconChevronDown.image(with: theme.scrollBottomButtonIconColor,
                                                                         to: SBUIconSetType.Metric.iconChevronDown),
                                    for: .normal)
        scrollBottomButton.backgroundColor = theme.scrollBottomButtonBackground
        scrollBottomButton.setBackgroundImage(UIImage.from(color: theme.scrollBottomButtonHighlighted), for: .highlighted)

        scrollBottomButton.addTarget(self, action: #selector(self.onClickScrollBottom(sender:)), for: .touchUpInside)
        view.addSubview(scrollBottomButton)
        
        scrollBottomButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            scrollBottomButton.topAnchor.constraint(equalTo: view.topAnchor),
            scrollBottomButton.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollBottomButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollBottomButton.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        return view
    }()
    
    public var theme: SBUChannelTheme = SBUTheme.channelTheme

    // for cell
    public private(set) var adminMessageCell: SBUBaseMessageCell?
    public private(set) var userMessageCell: SBUBaseMessageCell?
    public private(set) var fileMessageCell: SBUBaseMessageCell?
    public private(set) var customMessageCell: SBUBaseMessageCell?
    public private(set) var unknownMessageCell: SBUBaseMessageCell?
    
    
    // MARK: - UI properties (Private)
    private lazy var _titleView: SBUChannelTitleView = {
        var titleView: SBUChannelTitleView
        titleView = SBUChannelTitleView(
            frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
        )

        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        return SBUCommonViews.backButton(vc: self, selector: #selector(onClickBack))
    }()

    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSetType.iconInfo.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickSetting)
        )
    }()
    
    private lazy var _channelStateBanner: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.text = SBUStringSet.Channel_State_Banner_Frozen
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.isHidden = true
        return label
    }()
    
    private lazy var _newMessageInfoView: SBUNewMessageInfo = {
        return SBUNewMessageInfo()
    }()
    
    private lazy var _emptyView: SBUEmptyView = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()
    
    let spacer = UIView()

    private var newMessagesCount: Int = 0
    private var touchedPoint: CGPoint = .zero

    
    // MARK: - Logic properties (Public)
    
    /// This object is used to import a list of messages, send messages, modify messages, and so on, and is created during initialization.
    public private(set) var channel: SBDGroupChannel? {
        didSet {
            // set from channelUrl
            if channel != nil {
                self.initViewModel(startingPoint: self.startingPoint)
            }
        }
    }
    public private(set) var channelUrl: String?
    public let startingPoint: Int64?
    public var highlightInfo: SBUHighlightMessageInfo? = nil
    
    /// To decide whether to use right bar button item or not
    public var useRightBarButtonItem: Bool = true {
        didSet {
            self.navigationItem.rightBarButtonItem = useRightBarButtonItem ? self.rightBarButton : nil
        }
    }
    
    /// This object has a list of all success messages synchronized with the server.
    @SBUAtomic public private(set) var messageList: [SBDBaseMessage] = []
    /// This object has a list of all messages.
    @SBUAtomic public private(set) var fullMessageList: [SBDBaseMessage] = []
    
    /// This object is used in the user message in being edited.
    public private(set) var inEditingMessage: SBDUserMessage? = nil

    /// This object is used before response from the server
    @available(*, deprecated, message: "deprecated in 1.2.10")
    public private(set) var preSendMessages: [String:SBDBaseMessage] = [:]
    /// This object that has resendable messages, including `pending messages` and `failed messages`.
    @available(*, deprecated, message: "deprecated in 1.2.10")
    public private(set) var resendableMessages: [String:SBDBaseMessage] = [:]
    @available(*, deprecated, message: "deprecated in 1.2.10")
    public private(set) var preSendFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    @available(*, deprecated, message: "deprecated in 1.2.10")
    public private(set) var resendableFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    @available(*, deprecated, message: "deprecated in 1.2.10")
    public private(set) var fileTransferProgress: [String:CGFloat] = [:] // Key: requestId, If have value, file message status is sending
    
    
    // MARK: - Logic properties (Private)
    
    private var channelViewModel: SBUChannelViewModel? {
        willSet {
            channelViewModel?.dispose()
        }
        didSet {
            self.bindViewModel()
        }
    }
    
    /// This is a params used to get a list of messages. Only getter is provided, please use initialization function to set params directly.
    /// - note: For params properties, see `SBDMessageListParams` class.
    /// - Since: 1.0.11
    public var messageListParams: SBDMessageListParams {
        return self.channelViewModel?.messageListParams ?? self.customizedMessageListParams ?? SBDMessageListParams()
    }
    private var customizedMessageListParams: SBDMessageListParams? = nil

    var lastSeenIndexPath: IndexPath?
    
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelViewController(channelUrl:)")
    required public init?(coder: NSCoder) {
        self.startingPoint = nil
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUChannelViewController(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.startingPoint = nil
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
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
    public init(channel: SBDGroupChannel, messageListParams: SBDMessageListParams? = nil) {
        self.startingPoint = nil
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl

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
    public init(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
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
    public init(channelUrl: String, startingPoint: Int64, messageListParams: SBDMessageListParams? = nil) {
        self.startingPoint = startingPoint
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl
        self.customizedMessageListParams = messageListParams
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        if self.titleView == nil {
            self.titleView = _titleView
        }
        if self.leftBarButton == nil {
            self.leftBarButton = _leftBarButton
        }
        if self.rightBarButton == nil {
            self.rightBarButton = _rightBarButton
        }
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        if self.useRightBarButtonItem {
            self.navigationItem.rightBarButtonItem = self.rightBarButton
        }

        var stack = UIStackView()
        if let titleView = self.titleView {
            stack = UIStackView(arrangedSubviews: [titleView, self.spacer])
            stack.axis = .horizontal
        }
        
        self.navigationItem.titleView = stack
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
        
        // Message Input View
        self.messageInputView.delegate = self
        
        if self.adminMessageCell == nil {
            self.register(adminMessageCell: SBUAdminMessageCell())
        }
        if self.userMessageCell == nil {
            self.register(userMessageCell: SBUUserMessageCell())
        }
        if self.fileMessageCell == nil {
            self.register(fileMessageCell: SBUFileMessageCell())
        }
        if self.unknownMessageCell == nil {
            self.register(unknownMessageCell: SBUUnknownMessageCell())
        }

        self.emptyView?.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.backgroundView = self.emptyView
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // message input view
        self.view.addSubview(self.messageInputView)
        
        // new message info view
        if let newMessageInfoView = self.newMessageInfoView {
            newMessageInfoView.isHidden = true
            self.view.addSubview(newMessageInfoView)
        }
        
        // channel state banner
        if let stateBanner = self.channelStateBanner {
            self.view.addSubview(stateBanner)
        }
        
        // scroll bottom view
        if let scrollBottomView = self.scrollBottomView {
            scrollBottomView.isHidden = true
            self.view.addSubview(scrollBottomView)
        }
        
        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.spacer.translatesAutoresizingMaskIntoConstraints = false
        let constraint = self.spacer.widthAnchor.constraint(
            greaterThanOrEqualToConstant: self.view.bounds.width
        )
        constraint.priority = .defaultLow
        constraint.isActive = true
        
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewTopConstraint = self.tableView.topAnchor.constraint(
            equalTo: self.view.topAnchor,
            constant: 0
        )
        NSLayoutConstraint.activate([
            self.tableViewTopConstraint,
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(
                equalTo: self.messageInputView.topAnchor,
                constant: 0
            )
        ])
        
        self.channelStateBanner?
            .sbu_constraint(equalTo: self.view, leading: 8, trailing: -8, top: 8)
            .sbu_constraint(height: 24)
        
        self.messageInputView.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputViewBottomConstraint = self.messageInputView.bottomAnchor.constraint(
            equalTo: self.view.bottomAnchor,
            constant: 0
        )
        NSLayoutConstraint.activate([
            self.messageInputView.topAnchor.constraint(
                equalTo: self.tableView.bottomAnchor,
                constant: 0
            ),
            self.messageInputView.leftAnchor.constraint(
                equalTo: self.view.leftAnchor,
                constant: 0
            ),
            self.messageInputView.rightAnchor.constraint(
                equalTo: self.view.rightAnchor,
                constant: 0
            ),
            self.messageInputViewBottomConstraint
        ])
        
        if let newMessageInfoView = self.newMessageInfoView {
            newMessageInfoView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                newMessageInfoView.bottomAnchor.constraint(
                    equalTo: self.messageInputView.topAnchor,
                    constant: -8
                ),
                newMessageInfoView.centerXAnchor.constraint(
                    equalTo: self.view.centerXAnchor,
                    constant: 0
                )
            ])
        }
        
        if let scrollBottomView = self.scrollBottomView {
            scrollBottomView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                scrollBottomView.widthAnchor.constraint(equalToConstant: SBUConstant.scrollBottomButtonSize.width),
                scrollBottomView.heightAnchor.constraint(equalToConstant: SBUConstant.scrollBottomButtonSize.height),
                scrollBottomView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                scrollBottomView.bottomAnchor.constraint(equalTo: self.messageInputView.topAnchor, constant: -8)
            ])
        }
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.theme = SBUTheme.channelTheme
        
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        if let channelStateBanner = self.channelStateBanner as? UILabel {
            channelStateBanner.textColor = self.theme.channelStateBannerTextColor
            channelStateBanner.font = self.theme.channelStateBannerFont
            channelStateBanner.backgroundColor = self.theme.channelStateBannerBackgroundColor
        }
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
    }
    
    open override func updateStyles() {
        super.updateStyles()
        
        self.theme = SBUTheme.channelTheme
        
        self.setupStyles()
        
        if let titleView = self.titleView as? SBUChannelTitleView {
            titleView.setupStyles()
        }
        self.messageInputView.setupStyles()
        
        if let newMessageInfoView = self.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.setupStyles()
        }
        
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.setupStyles()
        }
        
        if let scrollBottomView = self.scrollBottomView {
            self.setupScrollBottomViewStyle(scrollBottomView: scrollBottomView)
        }
        
        self.reloadTableView()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.configureOffset()
        
        self.setupStyles()
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return theme.statusBarStyle
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        SBDMain.add(self as SBDChannelDelegate, identifier: self.description)
        SBDMain.add(self as SBDConnectionDelegate, identifier: self.description)

        if let channelUrl = self.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }

        self.addGestureHideKeyboard()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let channel = self.channel {
            guard let titleView = titleView as? SBUChannelTitleView else { return }
            titleView.updateChannelStatus(channel: channel)
        }
        
        self.updateStyles()
        self.refreshChannel(applyChangelog: true)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        SBULog.info("")
        self.disposeViewModel()
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - View Binding
    
    /// Recreates the view model, loading initial messages from given starting point.
    /// - Parameters:
    ///     - startingPoint: The starting point timestamp of the messages. `nil` to start from the latest.
    ///     - showIndicator: Whether to show loading indicator on loading the initial messages.
    private func initViewModel(startingPoint: Int64?, showIndicator: Bool = true) {
        guard let channel = self.channel else {
            SBULog.warning("Something wrong. Channel object is nil.")
            return
        }
        
        self.setEditMode(for: nil)
        
        let cachedMessages = self.channelViewModel?.messageCache.flush(with: [])

        self.channelViewModel = SBUChannelViewModel(channel: channel, customizedMessageListParams: self.customizedMessageListParams)
        self.channelViewModel?.loadInitialMessages(startingPoint: startingPoint,
                                                   showIndicator: showIndicator,
                                                   initialMessages: cachedMessages)
    }

    private func bindViewModel() {
        SBULog.info("bindViewModel")
        guard let channelViewModel = self.channelViewModel else { return }
        
        channelViewModel.loadingObservable.observe { [weak self] loadingState in
            guard let _ = self else { return }
            
            if loadingState {
                self?.shouldShowLoadingIndicator()
            } else {
                self?.shouldDismissLoadingIndicator()
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
            
            let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
            let firstRect = self.tableView.rectForRow(at: firstVisibleIndexPath)
            SBULog.error("firstVisibleIndexPath : \(firstVisibleIndexPath) firstrectg : \(firstRect), offset : \(self.tableView.contentOffset)")
            
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
        
        let preSendMessage = self.channel?.sendUserMessage(with: messageParams)
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
            self.channel?.markAsRead()
        }
               
        SBUPendingMessageManager.shared.upsertPendingMessage(
            channelUrl: self.channel?.channelUrl,
            message: preSendMessage
        )
        
        self.sortAllMessageList(needReload: true)
        self.messageInputView.endTypingMode()
        self.channel?.endTyping()
        self.scrollToBottom(animated: false)
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
        /*********************************
          Thumbnail is a premium feature.
        ***********************************/
        guard let channel = self.channel else { return }
        
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
                self.channel?.markAsRead()
            })
        
        SBUPendingMessageManager.shared.upsertPendingMessage(
            channelUrl: self.channel?.channelUrl,
            message: preSendMessage
        )
        
        SBUPendingMessageManager.shared.addFileInfo(
            requestId: preSendMessage?.requestId,
            params: messageParams
        )
        
        self.sortAllMessageList(needReload: true)
    }
    
    /// Resends a message with failedMessage object.
    /// - Parameter failedMessage: `SBDBaseMessage` class based failed object
    /// - Since: 1.0.9
    public func resendMessage(failedMessage: SBDBaseMessage) {
        if let failedMessage = failedMessage as? SBDUserMessage {
            SBULog.info("[Request] Resend failed user message")
            
            let pendingMessage = self.channel?.resendUserMessage(
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
                    self.channel?.markAsRead()
            })
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: pendingMessage
            )
        } else if let failedMessage = failedMessage as? SBDFileMessage {
            var data: Data? = nil

            if let fileInfo = SBUPendingMessageManager.shared.getFileInfo(
                requestId: failedMessage.requestId) {
                data = fileInfo.file
            }

            SBULog.info("[Request] Resend failed file message")
            
            let pendingMessage = self.channel?.resendFileMessage(
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
                    self.channel?.markAsRead()
                })
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: pendingMessage
            )
        }
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
        
        self.channel?.updateUserMessage(
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
    
    /// Deletes a message with message object.
    /// - Parameter message: `SBDBaseMessage` based class object
    /// - Since: 1.0.9
    public func deleteMessage(message: SBDBaseMessage) {
        let deleteButton = SBUAlertButtonItem(
            title: SBUStringSet.Delete,
            color: theme.alertRemoveColor
        ) { [weak self] info in
            guard let self = self else { return }
            SBULog.info("[Request] Delete message: \(message.description)")
            
            self.channel?.delete(message, completionHandler: { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.didReceiveError(error.localizedDescription)
                    SBULog.error("[Failed] Delete message request: \(error.localizedDescription)")
                    return
                }
                
                SBULog.info("[Succeed] Delete message: \(message.description)")
                
                self.deleteMessagesInList(messageIds: [message.messageId], needReload: true)
            })
        }
        
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }
        
        SBUAlertView.show(
            title: SBUStringSet.Alert_Delete,
            confirmButtonItem: deleteButton,
            cancelButtonItem: cancelButton
        )
    }
    
    /// This function is used to load channel information.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information. 
    public override func loadChannel(channelUrl: String?, messageListParams: SBDMessageListParams? = nil) {
        guard let channelUrl = channelUrl else { return }
        self.shouldShowLoadingIndicator()
        
        //NOTE: this load channel do too much work...
        if let messageListParams = messageListParams {
            self.customizedMessageListParams = messageListParams
        } else if self.customizedMessageListParams == nil {
            let messageListParams = SBDMessageListParams()
            SBUGlobalCustomParams.messageListParamsBuilder?(messageListParams)
            self.customizedMessageListParams = messageListParams
        }
        
        SBUMain.connectionCheck { [weak self] user, error in
            guard let self = self else { return }
            if let error = error {
                self.didReceiveError(error.localizedDescription)
                // do not proceed to getChannel()
                return
            }

            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard let self = self else { return }
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    
                    if self.messageList.isEmpty {
                        if let emptyView = self.emptyView as? SBUEmptyView {
                            emptyView.reloadData(.error)
                        }
                    }
                    
                    self.didReceiveError(error.localizedDescription)
                    // don't return to allow failed UI
                }
                
                self.channel = channel
                
                guard self.canProceed(with: self.channel, error: error) else { return }

                SBULog.info("""
                    [Succeed] Load channel request:
                    \(String(format: "%@", self.channel ?? ""))
                    """)
                
                // background refresh to check if user is banned or not.
                self.refreshChannel()
                
                SBUEmojiManager.shared.useReactionCurrentChannel
                    = channel?.isSuper == false && channel?.isBroadcast == false
                
                if let titleView = self.titleView as? SBUChannelTitleView {
                    titleView.configure(channel: self.channel, title: self.channelName)
                }
                self.updateMessageInputModeState()
            }
        }
    }
    
    /// This function is used to add or delete reactions.
    /// - Parameters:
    ///   - message: `SBDBaseMessage` object to update
    ///   - emojiKey: set emoji key
    ///   - didSelect: set reaction state
    /// - Since: 1.1.0
    public func setReaction(message: SBDBaseMessage, emojiKey: String, didSelect: Bool) {
        switch didSelect {
        case true:
            SBULog.info("[Request] Add Reaction")
            self.channel?.addReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    SBULog.error("[Failed] Add reaction : \(error.localizedDescription)")
                }
                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
            }
        case false:
            SBULog.info("[Request] Delete Reaction")
            self.channel?.deleteReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    SBULog.error("[Failed] Delete reaction : \(error.localizedDescription)")
                }

                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
            }
        }
    }


    // MARK: - List managing
    
    /// This function sorts the all message list. (Included `presendMessages`, `messageList` and `resendableMessages`.)
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData and, scroll to last seen index.
    /// - Since: 1.2.5
    public func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        let pendingMessages = SBUPendingMessageManager.shared.getPendingMessages(
            channelUrl: self.channel?.channelUrl
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
    
    /// This function updates the messages in the list.
    ///
    /// It is updated only if the messages already exist in the list, and if not, it is ignored.
    /// And, after updating the messages, a function to sort the message list is called.
    /// - Parameters:
    ///   - messages: Message array to update
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func updateMessagesInList(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList[index] = message
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
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
    
    /// This function deletes the messages in the list using the message ids.
    /// - Parameters:
    ///   - messageIds: Message id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteMessagesInList(messageIds: [Int64]?, needReload: Bool) {
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
        
        self.deleteResendableMessages(requestIds: toBeDeleteRequestIds, needReload: needReload)
    }
    
    /// This functions clears current message lists
    ///
    /// - Since: 2.1.0
    public func clearMessageList() {
        self.fullMessageList.removeAll(where: { SBUUtils.findIndex(of: $0, in: self.messageList) != nil })
        self.messageList = []
    }
    
    /// This functions deletes the resendable messages using the request ids.
    /// - Parameters:
    ///   - requestIds: Request id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteResendableMessages(requestIds: [String], needReload: Bool) {
        for requestId in requestIds {
            SBUPendingMessageManager.shared.removePendingMessage(
                channelUrl: self.channel?.channelUrl,
                requestId: requestId
            )
        }
        
        self.sortAllMessageList(needReload: needReload)
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
        
        self.setNewMessageInfoView(hidden: false)
        self.newMessagesCount += 1
        
        if let newMessageInfoView = self.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.updateCount(count: self.newMessagesCount) { [weak self] in
                guard let self = self else { return }
                self.scrollToBottom(animated: false)
            }
        }
        
        
        let firstVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first ?? IndexPath(row: 0, section: 0)
        self.lastSeenIndexPath = IndexPath(row: firstVisibleIndexPath.row + 1, section: 0)
    }
    
    // MARK: - Channel related
    
    private func refreshChannel(applyChangelog: Bool = false) {
        if let channel = channel {
            channel.refresh { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    self.didReceiveError(error.localizedDescription)
                    SBULog.error("[Failed] Refresh channel request : \(error.localizedDescription)")
                }
                 
                guard self.canProceed(with: self.channel, error: error) else { return }
                
                SBULog.info("[Succeed] Refresh channel request")
                if applyChangelog {
                    self.channelViewModel?.loadMessageChangeLogs()
                    self.updateMessageInputModeState()
                }
            }
        } else if let channelUrl = self.channelUrl {
            // channel hasn't been loaded before.
            self.loadChannel(channelUrl: channelUrl)
        }
    }
    
    /// Check if viewcontroller should proceed with drawing UI with this channel object.
    /// VC will finish if user can't fetch the channel object (not a member), or allow it to draw failed UI.
    private func canProceed(with channel: SBDGroupChannel?, error: SBDError?) -> Bool {
        if let error = error {
            SBULog.info("canProceed error : \(error.localizedDescription)")
            if !self.belongsToChannel(error: error) {
                self.onClickBack()
                return false
            }
        }
        
        if let channel = channel {
            if channel.myMemberState == .none {
                self.onClickBack()
                return false
            }
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
        
        return true
    }
    
    private func belongsToChannel(error: SBDError) -> Bool {
        return error.code != SBDErrorCode.nonAuthorized.rawValue
    }
    
    // MARK: - Send action relations
    
    /// Sends a image file message.
    /// - Parameter info: Image information selected in `UIImagePickerController`
    public func sendImageFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        var _imageUrl: URL? = nil
        if #available(iOS 11.0, *) {
            if let tempImageUrl = info[.imageURL] as? URL {
                // file:///~~~
                _imageUrl = tempImageUrl
            }
        } else {
            if let tempImageUrl = info[.referenceURL] as? URL {
                // assets-library://~~~
                _imageUrl = tempImageUrl
            }
        }
        
        guard let imageUrl = _imageUrl else {
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
                fileName: "image.jpg",
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
                fileName: "image.jpg",
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
    

    // MARK: - Custom viewController relations
    
    /// If you want to use a custom channelSettingsViewController, override it and implement it.
    open func showChannelSettings() {
        guard let channel = self.channel else { return }
        
        let channelSettingsVC = SBUChannelSettingsViewController(channel: channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    /// This function presents `SBUEmojiListViewController`
    /// - Parameter message: `SBDBaseMessage` object
    /// - Since: 1.1.0
    open func showEmojiListModal(message: SBDBaseMessage) {
        let emojiListVC = SBUEmojiListViewController(message: message)
        emojiListVC.modalPresentationStyle = .custom
        emojiListVC.transitioningDelegate = self

        emojiListVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            guard let self = self else { return }
            self.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }
        self.present(emojiListVC, animated: true)
    }
    
    /// Used to register a custom cell as a admin message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized admin message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.adminMessageCell = adminMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: adminMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: adminMessageCell),
                forCellReuseIdentifier: adminMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a user message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized user message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.userMessageCell = userMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: userMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: userMessageCell),
                forCellReuseIdentifier: userMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a file message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized file message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.fileMessageCell = fileMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: fileMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: fileMessageCell),
                forCellReuseIdentifier: fileMessageCell.sbu_className
            )
        }
    }

    /// Used to register a custom cell as a additional message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    public func register(customMessageCell: SBUBaseMessageCell?, nib: UINib? = nil) {
        self.customMessageCell = customMessageCell
        guard let customMessageCell = customMessageCell else { return }
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: customMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: customMessageCell),
                forCellReuseIdentifier: customMessageCell.sbu_className
            )
        }
    }
    
    /// Used to register a custom cell as a unknown message cell based on `SBUBaseMessageCell`.
    /// - Parameters:
    ///   - channelCell: Customized unknown message cell
    ///   - nib: nib information. If the value is nil, the nib file is not used.
    private func register(unknownMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.unknownMessageCell = unknownMessageCell
        if let nib = nib {
            self.tableView.register(
                nib,
                forCellReuseIdentifier: unknownMessageCell.sbu_className
            )
        } else {
            self.tableView.register(
                type(of: unknownMessageCell),
                forCellReuseIdentifier: unknownMessageCell.sbu_className
            )
        }
    }

    
    // MARK: Cell TapHandler
    /// This function sets the cell's tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    open func setTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage) {
        self.dismissKeyboard()
        
        switch message {
            
        case let userMessage as SBDUserMessage:
            // User message type, only fail case
            guard userMessage.sendingStatus == .failed,
                userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId  else { return }
            self.resendMessage(failedMessage: userMessage)
           
        case let fileMessage as SBDFileMessage:
            // File message type
            switch fileMessage.sendingStatus {
            case .pending:
                break
            case .failed:
                guard fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
                self.resendMessage(failedMessage: fileMessage)
            case .succeeded:
                switch SBUUtils.getFileType(by: fileMessage) {
                case .image:
                    let viewer = SBUFileViewer(fileMessage: fileMessage, delegate: self)
                    let naviVC = UINavigationController(rootViewController: viewer)
                    self.present(naviVC, animated: true)
                case .etc, .pdf:
                    guard let url = URL(string: fileMessage.url) else { return }
                    let safariVC = SFSafariViewController(url: url)
                    self.present(safariVC, animated: true, completion: nil)
                case .video, .audio:
                    guard let url = URL(string: fileMessage.url) else { return }
                    let vc = AVPlayerViewController()
                    vc.player = AVPlayer(url: url)
                    self.present(vc, animated: true) { vc.player?.play() }
                default:
                    break
                }
            default:
                break
            }
        case _ as SBDAdminMessage:
            // Admin message type
            break
        default:
            break
        }
    }

    /// This function sets the cell's long tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    ///   - indexPath: indexpath of cell
    open func setLongTapGestureHandler(_ cell: SBUBaseMessageCell,
                                       message: SBDBaseMessage,
                                       indexPath: IndexPath) {
        self.dismissKeyboard()
        
        switch message {
        case let userMessage as SBDUserMessage:
            switch userMessage.sendingStatus {
            case .none, .canceled, .pending:
                break
            case .failed:
                let removeItem = SBUActionSheetItem(
                    title: SBUStringSet.Remove,
                    color: self.theme.removeItemColor
                ) { [weak self] in
                    self?.deleteResendableMessages(
                        requestIds: [userMessage.requestId],
                        needReload: true
                    )
                }
                let cancelItem = SBUActionSheetItem(
                    title: SBUStringSet.Cancel,
                    color: self.theme.cancelItemColor,
                    completionHandler: nil
                )

                SBUActionSheet.show(
                    items: [removeItem],
                    cancelItem: cancelItem
                )
            case .succeeded:
                let isCurrentUser = userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                let types: [MessageMenuItem] = isCurrentUser ? [.copy, .edit, .delete] : [.copy]
                cell.isSelected = true
                
                if SBUEmojiManager.useReaction {
                    self.showMenuViewController(cell, message: message, types: types)
                } else {
                    self.showMenuModal(cell, indexPath: indexPath,  message: message, types: types)
                }
            @unknown default:
                break;
            }
            
        case let fileMessage as SBDFileMessage:
            switch fileMessage.sendingStatus {
            case .none, .canceled, .pending:
                break;
            case .failed:
                let removeItem = SBUActionSheetItem(
                    title: SBUStringSet.Remove,
                    color: self.theme.removeItemColor
                ) { [weak self] in
                    self?.deleteResendableMessages(
                        requestIds: [fileMessage.requestId],
                        needReload: true
                    )
                }
                let cancelItem = SBUActionSheetItem(
                    title: SBUStringSet.Cancel,
                    color: self.theme.cancelItemColor,
                    completionHandler: nil
                )

                SBUActionSheet.show(
                    items: [removeItem],
                    cancelItem: cancelItem
                )
            case .succeeded:
                let isCurrentUser = fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                let types: [MessageMenuItem] = isCurrentUser ? [.save, .delete] : [.save]
                cell.isSelected = true
                
                if SBUEmojiManager.useReaction {
                    self.showMenuViewController(cell, message: message, types: types)
                } else {
                    self.showMenuModal(cell, indexPath: indexPath, message: message, types: types)
                }
            @unknown default:
                break;
            }
            
        case _ as SBDAdminMessage:
            break
            
        default:
            // Unknown Message
            guard message.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
            
            let deleteItem = SBUMenuItem(
                title: SBUStringSet.Delete,
                color: self.theme.menuTextColor,
                image: SBUIconSetType.iconDelete.image(to: SBUIconSetType.Metric.iconActionSheetItem)
            ) { [weak self] in
                guard let self = self else { return }
                self.deleteMessage(message: message)
            }
            let menuPoint = self.calculatorMenuPoint(
                indexPath: indexPath,
                position: cell.position
            )
            let items = [deleteItem]
            
            cell.isSelected = true
            SBUMenuView.show(items: items, point: menuPoint) {
                cell.isSelected = false
            }
        }
    }

    /// This function sets the cell's tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.1.0
    @available(*, deprecated, message: "deprecated in 1.2.2", renamed: "setEmojiTapGestureHandler(_:emojiKey:)")
    open func setTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        self.setEmojiTapGestureHandler(cell, emojiKey: emojiKey)
    }
    
    /// This function sets the cell's tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.2.2
    open func setEmojiTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let currentUser = SBUGlobals.CurrentUser else { return }
        let message = cell.message
        let shouldSelect = message.reactions.first { $0.key == emojiKey }?
            .userIds.contains(currentUser.userId) == false
        self.setReaction(message: message, emojiKey: emojiKey, didSelect: shouldSelect)
    }

    /// This function sets the cell's long tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.1.0
    @available(*, deprecated, message: "deprecated in 1.2.2", renamed: "setEmojiLongTapGestureHandler(_:emojiKey:)")
    open func setLongTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        self.setEmojiLongTapGestureHandler(cell, emojiKey: emojiKey)
    }
    
    /// This function sets the cell's long tap emoji gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - emojiKey: emoji key
    /// - Since: 1.2.2
    open func setEmojiLongTapGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
        guard let channel = self.channel else { return }
        let message = cell.message
        let reaction = message.reactions.first { $0.key == emojiKey } ?? SBDReaction()
        let reactionsVC = SBUReactionsViewController(
            channel: channel,
            message: message,
            selectedReaction: reaction
        )
        reactionsVC.modalPresentationStyle = .custom
        reactionsVC.transitioningDelegate = self
        self.present(reactionsVC, animated: true)
    }

    
    // MARK: - Message input mode
    
    /// This is used to messageInputView state update.
    /// - Since: 1.2.0
    public func updateMessageInputModeState() {
        if let _ = self.channel {
            self.updateBroadcastModeState()
            self.updateFrozenModeState()
            self.updateMutedModeState()
        } else {
            self.messageInputView.setErrorState()
        }
    }
    
    func updateBroadcastModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        self.messageInputView.isHidden = !isOperator && isBroadcast
    }
    
    func updateFrozenModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isBroadcast = self.channel?.isBroadcast ?? false
        let isFrozen = self.channel?.isFrozen ?? false
        if !isBroadcast {
            self.messageInputView.setFrozenModeState(!isOperator && isFrozen)
            self.channelStateBanner?.isHidden = !isFrozen
        }
    }
    
    func updateMutedModeState() {
        let isOperator = self.channel?.myRole == .operator
        let isFrozen = self.channel?.isFrozen ?? false
        let isMuted = self.channel?.myMutedState == .muted
        if !isFrozen || (isFrozen && isOperator) {
            self.messageInputView.setMutedModeState(isMuted)
        }
    }
    
    /// Set/Unset edit mode for given userMessage.
    /// - Parameter userMessage : User message to edit, or nil to end edit mode.
    func setEditMode(for userMessage: SBDUserMessage?) {
        inEditingMessage = userMessage
        
        if let userMessage = userMessage {
            self.messageInputView.startEditMode(text: userMessage.message)
        } else {
            self.messageInputView.endEditMode()
        }
    }

    // MARK: - Common
    
    /// This function checks if the current message and the next message date have the same day.
    /// - Parameter currentIndex: Current message index
    /// - Returns: If `true`, the messages date is same day.
    public func checkSameDayAsNextMessage(currentIndex: Int) -> Bool {
        guard currentIndex < self.fullMessageList.count-1 else { return false }
        
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = self.fullMessageList[currentIndex+1]
        
        let curCreatedAt = currentMessage.createdAt
        let prevCreatedAt = nextMessage.createdAt
        
        return Date.from(prevCreatedAt).isSameDay(as: Date.from(curCreatedAt))
    }
    
    public func configureOffset() {
        guard self.tableView.contentOffset.y < 0,
            self.tableViewTopConstraint.constant <= 0 else { return }
      
        let tempOffset = self.tableView.contentOffset.y
        self.tableViewTopConstraint.constant -= tempOffset
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public override func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        if let channelViewModel = self.channelViewModel {
            channelViewModel.setLoading(loadingState, showIndicator)
        } else {
            guard showIndicator else { return }
            
            if loadingState {
                SBULoading.start()
            } else {
                SBULoading.stop()
            }
        }
    }
    
    /// This is a function that gets the location of the message to be grouped.
    ///
    /// Only successful messages can be grouped.
    /// - Parameter currentIndex: Index of current message in the message list
    /// - Returns: Position of a message when grouped
    /// - Since: 1.2.1
    public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
        guard currentIndex < self.fullMessageList.count else { return .none }
        
        let prevMessage = self.fullMessageList.count - 1 != currentIndex
            ? self.fullMessageList[currentIndex+1]
            : nil
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = currentIndex != 0
            ? self.fullMessageList[currentIndex-1]
            : nil
        
        let succeededPrevMsg = prevMessage?.sendingStatus != .failed
            ? prevMessage
            : nil
        let succeededCurrentMsg = currentMessage.sendingStatus != .failed
            ? currentMessage
            : nil
        let succeededNextMsg = nextMessage?.sendingStatus != .failed
            ? nextMessage
            : nil
        
        let prevSender = succeededPrevMsg?.sender?.userId ?? nil
        let currentSender = succeededCurrentMsg?.sender?.userId ?? nil
        let nextSender = succeededNextMsg?.sender?.userId ?? nil
        
        // Unit : milliseconds
        let prevTimestamp = Date.from(succeededPrevMsg?.createdAt ?? -1).toString(
            format: .yyyyMMddhhmm
        )
        let currentTimestamp = Date.from(succeededCurrentMsg?.createdAt ?? -1).toString(
            format: .yyyyMMddhhmm
        )
        let nextTimestamp = Date.from(succeededNextMsg?.createdAt ?? -1).toString(
            format: .yyyyMMddhhmm
        )
        
        if prevSender != currentSender && nextSender != currentSender {
            return .none
        }
        else if prevSender == currentSender && nextSender == currentSender {
            if prevTimestamp == nextTimestamp {
                return .middle
            }
            else if prevTimestamp == currentTimestamp {
                return .bottom
            }
            else if currentTimestamp == nextTimestamp {
                return .top
            }
        }
        else if prevSender == currentSender && nextSender != currentSender {
            return prevTimestamp == currentTimestamp ? .bottom : .none
        }
        else if prevSender != currentSender && nextSender == currentSender {
            return currentTimestamp == nextTimestamp ? .top : .none
        }
        
        return .none
    }
    
    /// To keep track of which reloads tableview.
    private func reloadTableView() {
        self.tableView.reloadData()
    }
    
    /// To keep track of which scrolls tableview.
    private func scrollTableViewTo(row: Int, at position: UITableView.ScrollPosition = .top, animated: Bool = false) {
        if self.fullMessageList.isEmpty {
            guard self.tableView.contentOffset != .zero else { return }
            
            self.tableView.setContentOffset(.zero, animated: false)
        } else {
            self.tableView.scrollToRow(at: IndexPath(row: row, section: 0), at: position, animated: animated)
        }
    }
    
    
    // MARK: - Actions
    
    /// This function shows channel settings.
    public func onClickSetting() {
        self.showChannelSettings()
    }
    
    @objc open func onClickScrollBottom(sender: UIButton?) {
        self.scrollToBottom(animated: false)
    }
    
    
    // MARK: - ScrollView
    
    /// This function scrolls to bottom.
    /// - Parameter animated: Animated
    public func scrollToBottom(animated: Bool) {
        guard self.fullMessageList.count != 0 else { return }
        self.newMessagesCount = 0
        self.lastSeenIndexPath = nil
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.inEditingMessage = nil
            self.messageInputView.endEditMode()
            
            if self.channelViewModel?.hasNext ?? false {
                self.tableView.setContentOffset(self.tableView.contentOffset, animated: false)
                self.initViewModel(startingPoint: nil, showIndicator: false)
                self.scrollTableViewTo(row: 0)
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.scrollTableViewTo(row: indexPath.row, animated: animated)
                self.setNewMessageInfoView(hidden: true)
                self.setScrollBottomView(hidden: true)
            }
        }
    }
    
    public override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        self.lastSeenIndexPath = nil
        
        if isScrollNearBottom() {
            self.newMessagesCount = 0
            self.setNewMessageInfoView(hidden: true)
        }
        self.setScrollBottomView(hidden: isScrollNearBottom())
    }
    
    // MARK: - Floating Buttons
    
    /// This shows new message view based on `hasNext`
    private func setNewMessageInfoView(hidden: Bool) {
        guard let newMessageInfoView = self.newMessageInfoView else { return }
        guard hidden != newMessageInfoView.isHidden else { return }
        guard let channelViewModel = self.channelViewModel else { return }
        
        newMessageInfoView.isHidden = hidden && !channelViewModel.hasNext
    }
    
    public func setScrollBottomView(hidden: Bool?) {
        let hasNext = self.channelViewModel?.hasNext ?? false
        let shouldHide = hidden ?? isScrollNearBottom()
        let hide = shouldHide && !hasNext
        
        guard hide != self.scrollBottomView?.isHidden else { return }
        self.scrollBottomView?.isHidden = hide
    }
    

    // MARK: - Cell generator
    
    /// This function sets gestures in user message cell.
    /// - Parameters:
    ///   - cell: User message cell
    ///   - userMessage: User message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setUserMessageCellGestures(_ cell: SBUUserMessageCell,
                                         userMessage: SBDUserMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
            self.setTapGestureHandler(cell, message: userMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: userMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets gestures in file message cell.
    /// - Parameters:
    ///   - cell: File message cell
    ///   - fileMessage: File message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setFileMessageCellGestures(_ cell: SBUFileMessageCell,
                                         fileMessage: SBDFileMessage,
                                         indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
            self.setTapGestureHandler(cell, message: fileMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: fileMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets gestures in unknown message cell.
    /// - Parameters:
    ///   - cell: Unknown message cell
    ///   - unknownMessage: message object
    ///   - indexPath: Cell's indexPath
    /// - Since: 1.2.5
    open func setUnkownMessageCellGestures(_ cell: SBUUnknownMessageCell,
                                           unknownMessage: SBDBaseMessage,
                                           indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }
            self.setTapGestureHandler(cell, message: unknownMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: unknownMessage, indexPath: indexPath)
        }
    }
    
    /// This function sets images in file message cell.
    /// - Parameters:
    ///   - cell: File message cell
    ///   - fileMessage: File message object
    /// - Since: 1.2.5
    func setFileMessageCellImages(_ cell: SBUFileMessageCell,
                                  fileMessage: SBDFileMessage) {
        switch fileMessage.sendingStatus {
        case .canceled, .pending, .failed, .none:
            if let fileInfo = SBUPendingMessageManager.shared.getFileInfo(requestId: fileMessage.requestId),
               let type = fileInfo.mimeType, let fileData = fileInfo.file {
                if SBUUtils.getFileType(by: type) == .image {
                    let image = UIImage.createImage(from: fileData)
                    let isAnimatedImage = image?.isAnimatedImage() == true
                    
                    cell.setImage(isAnimatedImage ? image?.images?.first : image, size: SBUConstant.thumbnailSize)
                }
            }
        case .succeeded:
            break
        @unknown default:
            self.didReceiveError("unknown Type")
        }
    }
    
    
    // MARK: - Cell's menu
    
    /// This function calculates the point at which to draw the menu.
    /// - Parameters:
    ///   - indexPath: IndexPath
    ///   - position: Message position
    /// - Returns: `CGPoint` value
    /// - Since: 1.2.5
    public func calculatorMenuPoint(indexPath: IndexPath,
                                    position: MessagePosition) -> CGPoint {
        let rowRect = self.tableView.rectForRow(at: indexPath)
        let rowRectInSuperview = self.tableView.convert(rowRect,
                                                        to: self.tableView.superview?.superview)
        let originX = (position == .right) ? rowRectInSuperview.width : 0
        let menuPoint = CGPoint(x: originX, y: (rowRectInSuperview.origin.y))
        
        return menuPoint
    }
    
    /// This function shows cell's menu. This is used when the reaction feature is activated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    public func showMenuViewController(_ cell: SBUBaseMessageCell,
                                       message: SBDBaseMessage,
                                       types: [MessageMenuItem]) {
        let menuVC = SBUMenuViewController(message: message, itemTypes: types)
        menuVC.modalPresentationStyle = .custom
        menuVC.transitioningDelegate = self
        self.present(menuVC, animated: true)

        menuVC.tapHandlerToMenu = { [weak self] item in
            guard let self = self else { return }
            switch item {
            case .copy:
                guard let userMessage = message as? SBDUserMessage else { return }
                let pasteboard = UIPasteboard.general
                pasteboard.string = userMessage.message

            case .delete:
                self.deleteMessage(message: message)

            case .edit:
                guard let userMessage = message as? SBDUserMessage else { return }
                if self.channel?.isFrozen == false {
                    self.setEditMode(for: userMessage)
                } else {
                    SBULog.info("This channel is frozen")
                }

            case .save:
                guard let fileMessage = message as? SBDFileMessage else { return }
                SBUDownloadManager.save(fileMessage: fileMessage, parent: self)
            }
        }

        menuVC.dismissHandler = {
            cell.isSelected = false
        }

        menuVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            guard let self = self else { return }
            self.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }

        menuVC.moreEmojiTapHandler = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.showEmojiListModal(message: message)
            }
        }
    }

    /// This function shows cell's menu. This is used when the reaction feature is inactivated.
    /// - Parameters:
    ///   - cell: Message cell
    ///   - indexPath: IndexPath
    ///   - message: Message object
    ///   - types: Type array of menu items to use
    /// - Since: 1.2.5
    public func showMenuModal(_ cell: SBUBaseMessageCell,
                              indexPath: IndexPath,
                              message: SBDBaseMessage,
                              types: [MessageMenuItem]) {
        let items: [SBUMenuItem] = types.map {
            switch $0 {
            case .copy:
                return SBUMenuItem(
                    title: SBUStringSet.Copy,
                    color: self.theme.menuTextColor,
                    image: SBUIconSetType.iconCopy.image(
                        with: SBUTheme.componentTheme.alertButtonColor,
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
                    color: self.theme.menuTextColor,
                    image: SBUIconSetType.iconEdit.image(
                        with: SBUTheme.componentTheme.alertButtonColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    guard let userMessage = message as? SBDUserMessage else { return }
                    
                    if self.channel?.isFrozen == false {
                        self.setEditMode(for: userMessage)
                    } else {
                        SBULog.info("This channel is frozen")
                    }
                }
            case .delete:
                return SBUMenuItem(
                    title: SBUStringSet.Delete,
                    color: self.theme.menuTextColor,
                    image: SBUIconSetType.iconDelete.image(
                        with: SBUTheme.componentTheme.alertButtonColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    self.deleteMessage(message: message)
                }
            case .save:
                return SBUMenuItem(
                    title: SBUStringSet.Save,
                    color: self.theme.menuTextColor,
                    image: SBUIconSetType.iconDownload.image(
                        with: SBUTheme.componentTheme.alertButtonColor,
                        to: SBUIconSetType.Metric.iconActionSheetItem
                    )
                ) { [weak self] in
                    guard let self = self else { return }
                    guard let fileMessage = message as? SBDFileMessage else { return }
                    
                    SBUDownloadManager.save(fileMessage: fileMessage, parent: self)
                }
            }
        }

        let menuPoint = self.calculatorMenuPoint(indexPath: indexPath, position: cell.position)
        SBUMenuView.show(items: items, point: menuPoint) {
            cell.isSelected = false
        }
    }
    

    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }


    // MARK: - UITableViewDelegate, UITableViewDataSource
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = self.channel else {
            self.didReceiveError("Channel must exist!")
            return UITableViewCell()
        }
        
        let message = self.fullMessageList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: self.generateCellIdentifier(by: message)
            ) ?? UITableViewCell()
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        
        guard let messageCell = cell as? SBUBaseMessageCell else {
            self.didReceiveError("There are no message cells!")
            return cell
        }
        
        //NOTE: to disable unwanted animation while configuring cells
        UIView.setAnimationsEnabled(false)
        
        let isSameDay = self.checkSameDayAsNextMessage(currentIndex: indexPath.row)
        let receiptState = SBUUtils.getReceiptStateIfExists(for: channel, message: message)
        switch (message, messageCell) {
            
        // Amdin Message
        case let (adminMessage, adminMessageCell) as (SBDAdminMessage, SBUAdminMessageCell):
            adminMessageCell.configure(
                adminMessage,
                hideDateView: isSameDay
            )
        // Unknown Message
        case let (unknownMessage, unknownMessageCell) as (SBDBaseMessage, SBUUnknownMessageCell):
            unknownMessageCell.configure(
                unknownMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState
            )
            self.setUnkownMessageCellGestures(
                unknownMessageCell,
                unknownMessage: unknownMessage,
                indexPath: indexPath
            )
            
        // User Message
        case let (userMessage, userMessageCell) as (SBDUserMessage, SBUUserMessageCell):
            userMessageCell.configure(
                userMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState
            )
            userMessageCell.configure(highlightInfo: self.highlightInfo)
            
            self.setUserMessageCellGestures(
                userMessageCell,
                userMessage: userMessage,
                indexPath: indexPath
            )
            
        // File Message
        case let (fileMessage, fileMessageCell) as (SBDFileMessage, SBUFileMessageCell):
            fileMessageCell.configure(
                fileMessage,
                hideDateView: isSameDay,
                groupPosition: self.getMessageGroupingPosition(currentIndex: indexPath.row),
                receiptState: receiptState
            )
            fileMessageCell.configure(highlightInfo: self.highlightInfo)
            
            self.setFileMessageCellGestures(
                fileMessageCell,
                fileMessage: fileMessage,
                indexPath: indexPath
            )
            
            self.setFileMessageCellImages(fileMessageCell, fileMessage: fileMessage)
            
        default:
            messageCell.configure(
                message: message,
                position: .center,
                hideDateView: isSameDay,
                receiptState: receiptState ?? .none
            )
        }
        
        UIView.setAnimationsEnabled(true)
        
        // Tap profile action
        messageCell.userProfileTapHandler = { [weak messageCell, weak self] in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            guard let sender = cell.message.sender else { return }
            self.setUserProfileTapGestureHandler(SBUUser.init(sender: sender))
        }

        // Reaction action
        messageCell.emojiTapHandler = { [weak messageCell, weak self] emojiKey in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            self.setEmojiTapGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.emojiLongPressHandler = { [weak messageCell, weak self] emojiKey in
            guard let self = self else { return }
            guard let cell = messageCell else { return }
            self.setEmojiLongTapGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.moreEmojiTapHandler = { [weak self] in
            guard let self = self else { return }
            self.dismissKeyboard()
            self.showEmojiListModal(message: message)
        }

        return cell
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
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fullMessageList.count
    }
    
    /// This function generates cell's identifier.
    /// - Parameter message: Message object
    /// - Returns: Identifier
    open func generateCellIdentifier(by message: SBDBaseMessage) -> String {
        switch message {
        case is SBDFileMessage:
            return fileMessageCell?.sbu_className ?? SBUFileMessageCell.sbu_className
        case is SBDUserMessage:
            return userMessageCell?.sbu_className ?? SBUUserMessageCell.sbu_className
        case is SBDAdminMessage:
            return adminMessageCell?.sbu_className ?? SBUAdminMessageCell.sbu_className
        default:
            return unknownMessageCell?.sbu_className ?? SBUUnknownMessageCell.sbu_className
        }
    }
}


// MARK: - UIViewControllerTransitioningDelegate
extension SBUChannelViewController: UIViewControllerTransitioningDelegate {
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
extension SBUChannelViewController: UIImagePickerControllerDelegate {
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
extension SBUChannelViewController: UIDocumentPickerDelegate {
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
extension SBUChannelViewController: SBUMessageInputViewDelegate {
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
        self.channel?.startTyping()
    }
    
    open func messageInputViewDidEndTyping() {
        SBULog.info("[Request] End typing")
        self.channel?.endTyping()
    }
}


// MARK: - SBUFileViewerDelegate
extension SBUChannelViewController: SBUFileViewerDelegate {
    open func didSelectDeleteImage(message: SBDFileMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        
        self.channel?.delete(message) { [weak self] error in
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


// MARK: - SBUEmptyViewDelegate
extension SBUChannelViewController: SBUEmptyViewDelegate {
    open func didSelectRetry() {
        
        self.loadChannel(channelUrl: self.channel?.channelUrl ?? self.channelUrl)
    }
}


// MARK: - SBDChannelDelegate, SBDConnectionDelegate
extension SBUChannelViewController: SBDChannelDelegate, SBDConnectionDelegate {
    // MARK: SBDChannelDelegate
    // Received message
    open func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        switch message {
        case is SBDUserMessage:
            //// If need specific logic for user message, implement here
            SBULog.info("Did receive user message: \(message)")
            break
            
        case is SBDFileMessage:
            //// If need specific logic for file message, implement here
            SBULog.info("Did receive file message: \(message)")
            break
            
        case is SBDAdminMessage:
            //// If need specific logic for admin message, implement here
            SBULog.info("Did receive admin message: \(message)")
            break
            
        default:
            break
        }
        
        let hasNext = channelViewModel?.hasNext ?? false
        if !hasNext {
            self.channel?.markAsRead()
            self.upsertMessagesInList(messages: [message], needUpdateNewMessage: true, needReload: true)
        } else {
            if message is SBDUserMessage ||
                message is SBDFileMessage {
                // message is not added.
                // reset lastSeenIndexPath to not keep scroll in `increaseNewMessageCount`.
                self.lastSeenIndexPath = nil
                self.increaseNewMessageCount()
            }
            self.channelViewModel?.messageCache.add(messages: [message])
        }
    }
    
    // Updated message
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Did update message: \(message)")
        
        self.updateMessagesInList(messages: [message], needReload: true)
    }
    
    // Deleted message
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Message was deleted: \(messageId)")
        
        self.deleteMessagesInList(messageIds: [messageId], needReload: true)
    }

    // Updated Reaction
    open func channel(_ sender: SBDBaseChannel, updatedReaction reactionEvent: SBDReactionEvent) {
        guard let message = messageList
            .first(where: { $0.messageId == reactionEvent.messageId }) else { return }
        
        message.apply(reactionEvent)

        SBULog.info("Updated reaction, message:\(message.messageId), key: \(reactionEvent.key)")
        self.upsertMessagesInList(
            messages: [message],
            needReload: true
        )
    }
    
    // Mark as read
    open func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if let titleView = titleView as? SBUChannelTitleView {
            titleView.updateChannelStatus(channel: sender)
        }
        
        SBULog.info("Did update readReceipt, ChannelUrl:\(sender.channelUrl)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.reloadTableView()
        }
    }
    
    // Mark as delivered
    open func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Did update deliveryReceipt, ChannelUrl:\(sender.channelUrl)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.reloadTableView()
        }
    }
    
    open func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Did update typing status")
        
        if let titleView = titleView as? SBUChannelTitleView {
            titleView.updateChannelStatus(channel: sender)
        }
    }
    
    open func channelWasChanged(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        SBULog.info("Channel was changed, ChannelUrl:\(channel.channelUrl)")

        if let titleView = titleView as? SBUChannelTitleView {
            titleView.configure(channel: channel, title: self.channelName)
        }
    }
    
    open func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        SBULog.info("Channel was frozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    open func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        SBULog.info("Channel was unfrozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    open func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are muted.")
            self.updateMessageInputModeState()
        }
    }
    
    open func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are unmuted.")
            self.updateMessageInputModeState()
        }
    }
    
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.updateMessageInputModeState()
    }

    open func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are banned.")
            self.onClickBack()
        }
    }

    // MARK: SBDConnectionDelegate
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        
        SBULog.info("[Request] Refresh channel")
        self.refreshChannel(applyChangelog: true)
    }
}

extension SBUChannelViewController: LoadingIndicatorDelegate {
    @discardableResult
    open func shouldShowLoadingIndicator() -> Bool {
        return false
    }
    
    open func shouldDismissLoadingIndicator() {}
}
