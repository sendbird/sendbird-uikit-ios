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
open class SBUChannelViewController: UIViewController, UINavigationControllerDelegate {

    // MARK:- UI properties (Public)
    public var channelName: String? = nil
    
    // You can use the customized view and a view that inherits `SBUNewMessageInfo`. If you use a view that inherits SBUNewMessageInfo, you can change the button and their action.
    public lazy var newMessageInfoView: UIView? = _newMessageInfoView
    
    public lazy var messageInputView: SBUMessageInputView = _messageInputView
    
    public lazy var titleView: UIView? = _titleView
    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    public lazy var channelStateBanner: UIView? = _channelStateBanner
    
    public lazy var emptyView: UIView? = _emptyView
    
    
    // MARK:- UI properties (Private)
    var theme: SBUChannelTheme = SBUTheme.channelTheme

    private lazy var tableView = UITableView()

    private lazy var _titleView: SBUChannelTitleView = {
        var titleView: SBUChannelTitleView
        if #available(iOS 11, *) {
            titleView = SBUChannelTitleView()
        } else {
            titleView = SBUChannelTitleView(
                frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50)
            )
        }
        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSet.iconBack,
            style: .plain,
            target: self,
            action: #selector(onClickBack)
        )
    }()

    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSet.iconInfo,
            style: .plain,
            target: self,
            action: #selector(onClickSetting)
        )
    }()
    
    private lazy var _channelStateBanner: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = self.theme.channelStateBannerTextColor
        label.font = self.theme.channelStateBannerFont
        label.backgroundColor = self.theme.channelStateBannerBackgroundColor
        label.text = SBUStringSet.Channel_State_Banner_Frozen
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.isHidden = true
        return label
    }()
    
    private lazy var _messageInputView: SBUMessageInputView = {
        return SBUMessageInputView.sbu_loadViewFromNib() as! SBUMessageInputView
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

    private var messageInputViewBottomConstraint: NSLayoutConstraint!
    private var tableViewTopConstraint: NSLayoutConstraint!

    private var newMessagesCount: Int = 0
    private var touchedPoint: CGPoint = .zero

    
    // MARK:- Logic properties (Public)
    
    /// This object is used to import a list of messages, send messages, modify messages, and so on, and is created during initialization.
    public private(set) var channel: SBDGroupChannel?

    /// This object has a list of all success messages synchronized with the server.
    @SBUAtomic public private(set) var messageList: [SBDBaseMessage] = []
    
    /// This object that has resendable messages, including `pending messages` and `failed messages`.
    public private(set) var resendableMessages: [String:SBDBaseMessage] = [:]
    
    /// This is a params used to get a list of messages. Only getter is provided, please use initialization function to set params directly.
    /// - note: For params properties, see `SBDMessageListParams` class.
    /// - Since: 1.0.11
    public private(set) var messageListParams = SBDMessageListParams()
    
    
    // MARK:- Logic properties (Private)
    private var channelUrl: String?
    
    var customizedMessageListParams: SBDMessageListParams? = nil
    
    @SBUAtomic var fullMessageList: [SBDBaseMessage] = []
    var preSendMessages: [String:SBDBaseMessage] = [:] // for use before response from the server
    
    // Pending, Failed messaged
    var inEditingMessage: SBDUserMessage? = nil // for editing

    // preSend -> error: resendable / succeeded: messageList -> fullMessageList
    var preSendFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    var resendableFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    var fileTransferProgress: [String:CGFloat] = [:] // Key: requestId, If have value, file message status is sending

    var lastUpdatedTimestamp: Int64 = 0
    var firstLoad = true
    var hasPrevious = true
    var isLoading = false
    var limit: UInt = 20
    var isRequestingLoad = false

    var lastSeenIndexPath: IndexPath?

    // for cell
    var adminMessageCell: SBUBaseMessageCell?
    var userMessageCell: SBUBaseMessageCell?
    var fileMessageCell: SBUBaseMessageCell?
    var customMessageCell: SBUBaseMessageCell?
    var unknownMessageCell: SBUBaseMessageCell?
  
  
    // MARK:- Lifecycle
    @available(*, unavailable, renamed: "SBUChannelViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        SBULog.info("")
    }
    
    @available(*, unavailable, renamed: "SBUChannelViewController.init(channelUrl:)")
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        SBULog.info("")
    }

    /// If you have channel object, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ````
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeReplies = true
    ///     ...
    /// ````
    /// - note: The `reverse` and the `nextResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channel: Channel object
    /// - Since: 1.0.11
    public init(channel: SBDGroupChannel, messageListParams: SBDMessageListParams? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channel = channel
        self.channelUrl = channel.channelUrl

        self.customizedMessageListParams = messageListParams
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function. And, if you have own message list params, please set it. If not set, it is used as the default value.
    ///
    /// See the example below for params generation.
    /// ````
    ///     let params = SBDMessageListParams()
    ///     params.includeMetaArray = true
    ///     params.includeReactions = true
    ///     params.includeReplies = true
    ///     ...
    /// ````
    /// - note: The `reverse` and the `nextResultSize` properties in the `SBDMessageListParams` are set in the UIKit. Even though you set that property it will be ignored.
    /// - Parameter channelUrl: Channel url string
    /// - Since: 1.0.11
    public init(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {
        super.init(nibName: nil, bundle: nil)
        SBULog.info("")
        
        self.channelUrl = channelUrl

        self.customizedMessageListParams = messageListParams
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()
        SBULog.info("")
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton

        let spacer = UIView()
        let constraint = spacer.widthAnchor.constraint(
            greaterThanOrEqualToConstant: CGFloat.greatestFiniteMagnitude
        )
        constraint.isActive = true
        constraint.priority = .defaultLow

        var stack = UIStackView()
        if let titleView = self.titleView {
            stack = UIStackView(arrangedSubviews: [titleView, spacer])
            stack.axis = .horizontal
        }
        
        self.navigationItem.titleView = stack
        if #available(iOS 13.0, *) {
            self.navigationController?.isModalInPresentation = true
        }
        
        // Message Input View
        self.messageInputView.delegate = self
        
        // tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.bounces = false
        self.tableView.alwaysBounceVertical = false
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false

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
        
        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }
    
    open func setupAutolayout() {
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
                    constant: -17
                ),
                newMessageInfoView.centerXAnchor.constraint(
                    equalTo: self.view.centerXAnchor,
                    constant: 0
                )
            ])
        }
    }
    
    open func setupStyles() {
        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: theme.navigationBarTintColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: theme.navigationBarShadowColor
        )
        
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        self.rightBarButton?.tintColor = theme.rightBarButtonTintColor
        
        self.view.backgroundColor = theme.backgroundColor
        self.tableView.backgroundColor = theme.backgroundColor
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

        if let channelUrl = self.channel?.channelUrl {
            self.loadChannel(channelUrl: channelUrl)
        }

        self.addGestureHideKeyboard()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        self.setupStyles()

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
        
        if let channel = self.channel {
            guard let titleView = titleView as? SBUChannelTitleView else { return }
            titleView.updateChannelStatus(channel: channel)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        SBULog.info("")
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)

        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK:- SDK relations
    private func loadPrevMessageList(reset: Bool) {
        if self.isLoading { return }
        self.setLoading(true, false)
        
        guard let channel = self.channel else {
            self.setLoading(false, false)
            return
        }
        
        if reset {
            self.firstLoad = true
            self.messageList = []
            self.hasPrevious = true
            self.inEditingMessage = nil
            self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            
            SBULog.info("[Request] markAsRead")
            channel.markAsRead()
            
            SBULog.info("[Request] Message List")
        } else {
            SBULog.info("[Request] Next message List")
        }
        
        if self.firstLoad {
            self.messageListParams = SBDMessageListParams()
            if let customizedMessageListParams = self.customizedMessageListParams?.copy()
                as? SBDMessageListParams {
                self.messageListParams = customizedMessageListParams
            }
            let prevResultSize = self.customizedMessageListParams?.previousResultSize ?? 0
            self.messageListParams.previousResultSize = prevResultSize == 0
                ? Int(self.limit)
                : prevResultSize
            self.messageListParams.reverse = true
            self.firstLoad = false
        }
        
        self.isRequestingLoad = true
        
        let timestamp: Int64 = self.messageList.last?.createdAt ?? LLONG_MAX
        channel.getMessagesByTimestamp(timestamp, params: self.messageListParams)
        { [weak self] (messages, error) in
            defer { self?.setLoading(false, false) }
            
            if let error = error {
                SBULog.error("[Failed] Message list request: \(error.localizedDescription)")
                self?.isRequestingLoad = false;
                self?.didReceiveError(error.localizedDescription)
                return
            }
            guard let messages = messages else { self?.isRequestingLoad = false; return }
            
            SBULog.info("[Response] \(messages.count) messages")
            
            guard messages.count != 0 else {
                if let emptyView = self?.emptyView as? SBUEmptyView {
                    emptyView.reloadData(.noMessages)
                }
                self?.hasPrevious = false
                self?.isRequestingLoad = false
                
                SBULog.info("All previous messages have been loaded.")
                return
            }
            
            self?.upsertMessagesForSync(messages: messages, needReload: true)
            self?.lastUpdatedTimestamp = self?.channel?.lastMessage?.createdAt
                ?? Int64(Date().timeIntervalSince1970*1000)
        }
    }
    
    private func loadNextMessages(hasNext: Bool) {
        guard hasNext else {
            SBULog.info("All messages have been loaded.")
            
            self.sortAllMessageList(needReload: true)
            self.lastUpdatedTimestamp = self.channel?.lastMessage?.createdAt
                ?? Int64(Date().timeIntervalSince1970*1000)
            return
        }
        
        SBULog.info("[Request] Next message List")
        
        let limit = 20
        self.channel?.getNextMessages(
            byTimestamp: self.lastUpdatedTimestamp,
            limit: limit,
            reverse: true,
            messageType: .all,
            customType: nil,
            completionHandler: { [weak self] messages, error in
                
                if let error = error {
                    SBULog.error("[Failed] Message list request: \(error.localizedDescription)")
                    self?.sortAllMessageList(needReload: true)
                    self?.didReceiveError(error.localizedDescription)
                    return
                }
                
                guard let messages = messages else { return }
                
                SBULog.info("[Response] \(messages.count) messages")
                
                if messages.count > 0 {
                    self?.lastUpdatedTimestamp = messages[0].createdAt
                    self?.upsertMessagesForSync(messages: messages, needReload: false)
                }
                
                self?.loadNextMessages(hasNext: (messages.count == limit))
        })
    }
    
    private func loadMessageChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore else {
            SBULog.info("All next message changes have been loaded.")
            self.loadNextMessages(hasNext: true)
            return
        }
        
        let changeLogsParams = SBDMessageChangeLogsParams.create(with: self.messageListParams)

        if let token = token {
            SBULog.info("[Request] Message change logs with token")
            self.channel?.getMessageChangeLogs(sinceToken: token, params: changeLogsParams)
            { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
                if let error = error {
                    SBULog.error("""
                        [Failed] Message change logs request:
                        \(error.localizedDescription)
                        """)
                    self?.didReceiveError(error.localizedDescription)
                }
                
                SBULog.info("""
                    [Response]
                    \(String(format: "%d updated messages", updatedMessages?.count ?? 0)),
                    \(String(format: "%d deleted messages", deletedMessageIds?.count ?? 0))
                    """)
                
                self?.upsertMessagesForSync(messages: updatedMessages, needReload: false)
                self?.deleteMessagesForSync(messageIds: deletedMessageIds as! [Int64],
                                            needReload: false)
                self?.loadMessageChangeLogs(hasMore: hasMore, token: token)
            }
        }
        else {
            SBULog.info("[Request] Message change logs with last updated timestamp")
            self.channel?.getMessageChangeLogs(
                sinceTimestamp: self.lastUpdatedTimestamp,
                params: changeLogsParams
            ) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
                if let error = error {
                    SBULog.error("""
                        [Failed] Message change logs request:
                        \(error.localizedDescription)
                        """)
                    self?.didReceiveError(error.localizedDescription)
                }
                
                SBULog.info("""
                    [Response]
                    \(String(format: "%d updated messages", updatedMessages?.count ?? 0)),
                    \(String(format: "%d deleted messages", deletedMessageIds?.count ?? 0))
                    """)
                
                self?.upsertMessagesForSync(messages: updatedMessages, needReload: false)
                self?.deleteMessagesForSync(messageIds: deletedMessageIds as! [Int64],
                                            needReload: false)
                self?.loadMessageChangeLogs(hasMore: hasMore, token: token)
            }
        }
    }
    
    /// Sends a user message with only text.
    /// - Parameter text: String value
    /// - Since: 1.0.9
    public func sendUserMessage(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParam = SBDUserMessageParams(message: text) else { return }
        self.sendUserMessage(messageParams: messageParam)
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
            guard let self = self else { return }
            
            if let error = error {
                guard let requestId = userMessage?.requestId else { return }
                self.preSendMessages.removeValue(forKey: requestId)
                self.resendableMessages[requestId] = userMessage
                self.sortAllMessageList(needReload: true)
                self.didReceiveError(error.localizedDescription)
                SBULog.error("[Failed] Send user message request: \(error.localizedDescription)")
                return
            }
            
            guard let message = userMessage else { return }
            guard let requestId = userMessage?.requestId else { return }
            
            SBULog.info("[Succeed] Send user message: \(message.description)")
            
            self.preSendMessages.removeValue(forKey: requestId)
            self.resendableMessages.removeValue(forKey: requestId)
            self.upsertMessagesForSync(messages: [message], needReload: true)
            
            self.channel?.markAsRead()
        }
        
        guard let unwrappedPreSendMessage = preSendMessage else { return }
        SBULog.info("Presend user message: \(unwrappedPreSendMessage.description)")
        let requestId = unwrappedPreSendMessage.requestId
        self.preSendMessages[requestId] = unwrappedPreSendMessage
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
    public func sendFileMessage(fileData: Data, fileName: String, mimeType: String) {
        let messageParams = SBDFileMessageParams(file: fileData)!
        messageParams.fileName = fileName
        messageParams.mimeType = mimeType
        messageParams.fileSize = UInt(fileData.count)
        
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
                // [weak self]
                
                //// If need reload cell for progress, call reload action in here.
                guard let requestId = preSendMessage?.requestId else { return }
                let fileTransferProgress = CGFloat(totalBytesSent/totalBytesExpectedToSend)
                SBULog.info("File message transfer progress: \(requestId) - \(fileTransferProgress)")
                
                
                // self.fileTransferProgress[requestId] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                // DispatchQueue.main.async {
                //     let visibleCell = self.tableView.visibleCells.first {
                //         (($0 as? SBUFileMessageCell)?.message as? SBDFileMessage)?.requestId == preSendMessage?.requestId
                //
                //     }
                //     guard let fileMessageCell = visibleCell else { return }
                //     guard let indexPath = self.tableView.indexPath(for: fileMessageCell) else { return }
                //
                //     self.tableView.reloadRows(at: [indexPath], with: .automatic)
                // }
        },
            completionHandler: { [weak self] fileMessage, error in
                if let error = error {
                    guard let requestId = fileMessage?.requestId else { return }
                    self?.resendableMessages[requestId] = fileMessage
                    if let fileData = messageParams.file,
                        let mimeType = messageParams.mimeType,
                        let fileName = messageParams.fileName {
                        
                        self?.resendableFileData[requestId] = [
                            "data": fileData,
                            "type": mimeType,
                            "filename": fileName
                            ] as [String : AnyObject]
                    }
                    self?.preSendMessages.removeValue(forKey: requestId)
                    self?.preSendFileData.removeValue(forKey: requestId)
                    self?.sortAllMessageList(needReload: true)
                    
                    self?.didReceiveError(error.localizedDescription)
                    SBULog.error("""
                        [Failed] Send file message request:
                        \(error.localizedDescription)
                        """)
                    return
                }
                
                guard let message = fileMessage else { return }
                guard let requestId = fileMessage?.requestId else { return }
                
                SBULog.info("[Succeed] Send file message: \(message.description)")
                
                self?.preSendMessages.removeValue(forKey: requestId)
                self?.preSendFileData.removeValue(forKey: requestId)
                self?.resendableMessages.removeValue(forKey: requestId)
                self?.resendableFileData.removeValue(forKey: requestId)
                self?.fileTransferProgress.removeValue(forKey: requestId)
                self?.upsertMessagesForSync(messages: [message], needReload: true)
                
                self?.channel?.markAsRead()
        })
        
        guard let unwrappedPreSendMessage = preSendMessage else { return }
        SBULog.info("Presend file message: \(unwrappedPreSendMessage.description)")
        let requestId = unwrappedPreSendMessage.requestId
        self.preSendMessages[requestId] = unwrappedPreSendMessage
        if let fileData = messageParams.file,
            let mimeType = messageParams.mimeType,
            let fileName = messageParams.fileName {
            self.preSendFileData[requestId] = [
                "data": fileData,
                "type": mimeType,
                "filename": fileName
                ] as [String : AnyObject]
        }
        self.fileTransferProgress[requestId] = 0
        self.sortAllMessageList(needReload: true)
    }
    
    /// Resends a message with failedMessage object.
    /// - Parameter failedMessage: `SBDBaseMessage` class based failed object
    /// - Since: 1.0.9
    public func resendMessage(failedMessage: SBDBaseMessage) {
        if let failedMessage = failedMessage as? SBDUserMessage {
            SBULog.info("[Request] Resend failed user message")
            
            self.channel?.resendUserMessage(with: failedMessage,
                                            completionHandler:
                { [weak self] userMessage, error in
                    if let error = error {
                        self?.sortAllMessageList(needReload: true)
                        self?.didReceiveError(error.localizedDescription)
                        SBULog.error("""
                            [Failed] Resend failed user message request:
                            \(error.localizedDescription)\n
                            \(failedMessage)
                            """)
                        return
                    }
                    
                    guard let message = userMessage else { return }
                    guard let requestId = userMessage?.requestId else { return }
                    
                    SBULog.info("[Succeed] Resend failed user message: \(message.description)")
                    
                    self?.preSendMessages.removeValue(forKey: requestId)
                    self?.resendableMessages.removeValue(forKey: requestId)
                    self?.upsertMessagesForSync(messages: [message], needReload: true)
                    
                    self?.channel?.markAsRead()
            })
        } else if let failedMessage = failedMessage as? SBDFileMessage {
            var data: Data? = nil
            let requestId = failedMessage.requestId
            if let fileData = self.resendableFileData[requestId], fileData["data"] is Data {
                data = fileData["data"] as? Data
            }
            
            SBULog.info("[Request] Resend failed file message")
            
            self.channel?.resendFileMessage(
                with: failedMessage,
                binaryData: data,
                progressHandler:
                { [weak self] (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                    
                    self?.fileTransferProgress[requestId] = CGFloat(
                        totalBytesSent/totalBytesExpectedToSend
                    )
                    //// If need reload cell for progress, call reload action in here.
                    // self?.tableView.reloadData()
                },
                completionHandler: { [weak self] (fileMessage, error) in
                    if let error = error {
                        self?.sortAllMessageList(needReload: true)
                        self?.didReceiveError(error.localizedDescription)
                        SBULog.error("""
                            [Failed] Resend failed file message request:
                            \(error.localizedDescription)\n
                            \(failedMessage)
                            """)
                        return
                    }
                    
                    guard let message = fileMessage else { return }
                    guard let requestId = fileMessage?.requestId else { return }
                    
                    SBULog.info("[Succeed] Resend failed file message: \(message.description)")
                    
                    self?.preSendMessages.removeValue(forKey: requestId)
                    self?.preSendFileData.removeValue(forKey: requestId)
                    self?.resendableMessages.removeValue(forKey: requestId)
                    self?.resendableFileData.removeValue(forKey: requestId)
                    self?.fileTransferProgress.removeValue(forKey: requestId)
                    self?.upsertMessagesForSync(messages: [message], needReload: true)
                    
                    self?.channel?.markAsRead()
            })
        }
    }
    
    /// Updates a user message with message object.
    /// - Parameters:
    ///   - message: `SBDUserMessage` object to update
    ///   - text: String to be updated
    /// - Since: 1.0.9
    public func updateUserMessage(message: SBDUserMessage, text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParam = SBDUserMessageParams(message: text) else { return }
        self.updateUserMessage(message: message, messageParams: messageParam)
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
                if let error = error {
                    self?.didReceiveError(error.localizedDescription)
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
                
                self?.deleteMessagesForSync(messageIds: [message.messageId], needReload: false)
                self?.upsertMessagesForSync(messages: [updatedMessage], needReload: true)
                self?.inEditingMessage = nil
                self?.messageInputView.endEditMode()
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
            SBULog.info("[Request] Delete message: \(message.description)")
            
            self?.channel?.delete(message, completionHandler: { [weak self] error in
                if let error = error {
                    self?.didReceiveError(error.localizedDescription)
                    SBULog.error("[Failed] Delete message request: \(error.localizedDescription)")
                    return
                }
                
                SBULog.info("[Succeed] Delete message: \(message.description)")
                
                self?.deleteMessagesForSync(messageIds: [message.messageId], needReload: true)
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
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in
            if let error = error { self?.didReceiveError(error.localizedDescription) }

            SBULog.info("[Request] Load channel: \(String(channelUrl))")
            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                if let error = error {
                    SBULog.error("[Failed] Load channel request: \(error.localizedDescription)")
                    self?.didReceiveError(error.localizedDescription)
                    return
                }
            
                self?.channel = channel

                SBULog.info("""
                    [Succeed] Load channel request:
                    \(String(format: "%@", self?.channel ?? ""))
                    """)
                
                SBUEmojiManager.shared.useReactionCurrnetChannel
                    = channel?.isSuper == false && channel?.isBroadcast == false
                
                self?.loadPrevMessageList(reset: true)
                
                if let titleView = self?.titleView as? SBUChannelTitleView {
                    titleView.configure(channel: self?.channel, title: self?.channelName)
                }
                
                self?.updateMessageInputModeState()
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


    // MARK:- List managing
    private func sortedFullMessageList() -> [SBDBaseMessage] {
        let presendMessages = self.preSendMessages.values
        let sendMessages = self.messageList
        let resendableMessages = self.resendableMessages.values
        
        return ([] + resendableMessages + presendMessages)
            .sorted { $0.createdAt > $1.createdAt }
            + sendMessages.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        self.fullMessageList = self.sortedFullMessageList()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if let emptyView = self.emptyView as? SBUEmptyView {
                emptyView.reloadData(self.fullMessageList.isEmpty ? .noMessages : .none)
            }
            
            guard needReload else { return }
            
            self.tableView.reloadData()
            
            guard let lastSeenIndexPath = self.lastSeenIndexPath else { return }
            self.tableView.scrollToRow(at: lastSeenIndexPath, at: .top, animated: false)
        }
    }

    private func updateMessagesForSync(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = self.messageList
                .firstIndex(where: { $0.messageId == message.messageId }) {
                self.messageList[index] = message
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    private func upsertMessagesForSync(messages: [SBDBaseMessage]?,
                                       needUpdateNewMessage: Bool = true,
                                       needReload: Bool) {
        messages?.forEach { message in
            if let index = self.messageList
                .firstIndex(where: { $0.messageId == message.messageId }) {
                self.messageList.remove(at: index)
            }
            self.messageList.append(message)
            
            switch message {
            case let userMessage as SBDUserMessage:
                if userMessage.requestId.count > 0 { break }
                if needUpdateNewMessage {
                    self.increaseNewMessageCount()
                }
            case let fileMessage as SBDFileMessage:
                if fileMessage.requestId.count > 0 { break }
                if needUpdateNewMessage {
                    self.increaseNewMessageCount()
                }
            default:
                break
            }
        }
        
        self.isRequestingLoad = false
        self.sortAllMessageList(needReload: needReload)
    }
    
    private func deleteMessagesForSync(messageIds: [Int64], needReload: Bool) {
        var toBeDeleteIndexes: [Int] = []
        var toBeDeleteRequestIds: [String] = []
        
        for (index, message) in self.messageList.enumerated() {
            for messageId in messageIds {
                guard message.messageId == messageId else { continue }
                toBeDeleteIndexes.append(index)
                
                switch message {
                case let userMessage as SBDUserMessage:
                    let requestId = userMessage.requestId
                    guard requestId.count > 0 else { break }
                    toBeDeleteRequestIds.append(requestId)

                case let fileMessage as SBDFileMessage:
                    let requestId = fileMessage.requestId
                    guard requestId.count > 0 else { break }
                    toBeDeleteRequestIds.append(requestId)
                    
                default:
                    break
                }
            }
        }
        
        // for remove from last
        let sortedIndexes = toBeDeleteIndexes.sorted().reversed()
        
        for index in sortedIndexes {
            self.messageList.remove(at: index)
        }
        
        for requestId in toBeDeleteRequestIds {
            self.preSendMessages.removeValue(forKey: requestId)
            self.preSendFileData.removeValue(forKey: requestId)
            self.resendableMessages.removeValue(forKey: requestId)
            self.resendableFileData.removeValue(forKey: requestId)
            self.fileTransferProgress.removeValue(forKey: requestId)
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    private func deleteResendableMessages(requestIds: [String], needReload: Bool) {
        for requestId in requestIds {
            self.preSendMessages.removeValue(forKey: requestId)
            self.preSendFileData.removeValue(forKey: requestId)
            self.resendableMessages.removeValue(forKey: requestId)
            self.resendableFileData.removeValue(forKey: requestId)
            self.fileTransferProgress.removeValue(forKey: requestId)
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    /// This function increases the new message count.
    public func increaseNewMessageCount() {
        guard self.tableView.contentOffset != .zero else {
            self.lastSeenIndexPath = nil
            return
        }
        guard self.isRequestingLoad == false else {
            self.lastSeenIndexPath = nil
            return
        }
        
        if let newMessageInfoView = self.newMessageInfoView {
            newMessageInfoView.isHidden = false
        }
        self.newMessagesCount += 1
        
        if let newMessageInfoView = self.newMessageInfoView as? SBUNewMessageInfo {
            newMessageInfoView.updateCount(count: self.newMessagesCount) { [weak self] in
                self?.scrollToBottom(animated: false)
            }
        }
        
        if let indexPath = self.tableView.indexPathsForVisibleRows?[0] {
            self.lastSeenIndexPath = IndexPath(row: indexPath.row + 1, section: 0)
        }
    }
    
    
    // MARK:- Send action relations
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
            guard let imageData = originalImage?
                .fixedOrientation()
                .jpegData(compressionQuality: 1.0) else { return }
            
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
            
            var asset: PHAsset?
            if #available(iOS 11.0, *) {
                asset = info[.phAsset] as? PHAsset
            } else {
                let result = PHAsset.fetchAssets(withALAssetURLs: [imageUrl], options: nil)
                asset = result.firstObject
            }
            
            guard let gifAsset = asset else { return }
            let requestOptions = PHImageRequestOptions()
            requestOptions.isSynchronous = true
            requestOptions.isNetworkAccessAllowed = true
            requestOptions.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImageData(for: gifAsset, options: requestOptions)
            { [weak self] imageData, dataUTI, orientation, info in
                
                guard let imageData = imageData else { return }
                self?.sendFileMessage(fileData: imageData,
                                      fileName: imageName,
                                      mimeType: mimeType)
            }
            
        default:
            guard let originalImage = info[.originalImage] as? UIImage else { return }
            guard let imageData = originalImage
                .fixedOrientation()
                .jpegData(compressionQuality: 1.0) else { return }
            
            self.sendFileMessage(
                fileData: imageData,
                fileName: "image.jpg",
                mimeType: "image/jpeg"
            )
        }
    }
    
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
    

    // MARK:- Custom viewController relations
    
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
            self?.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }
        self.present(emojiListVC, animated: true)
    }
    
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
            
            let retryItem = SBUActionSheetItem(
                title: SBUStringSet.Retry
            ) { [weak self] in
                self?.resendMessage(failedMessage: userMessage)
            }
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
                color: self.theme.cancelItemColor
            )

            SBUActionSheet.show(
                items: [retryItem, removeItem],
                cancelItem: cancelItem
            )
            
        case let fileMessage as SBDFileMessage:
            // File message type
            switch fileMessage.sendingStatus {
            case .pending:
                break
            case .failed:
                guard fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
                
                let retryItem = SBUActionSheetItem(
                    title: SBUStringSet.Retry
                ) { [weak self] in
                    self?.resendMessage(failedMessage: fileMessage)
                }
                let removeItem = SBUActionSheetItem(
                    title: SBUStringSet.Remove,
                    color: self.theme.alertRemoveColor
                ) { [weak self] in
                    self?.deleteResendableMessages(
                        requestIds: [fileMessage.requestId],
                        needReload: true
                    )
                }
                let cancelItem = SBUActionSheetItem(
                    title: SBUStringSet.Cancel,
                    color: self.theme.alertCancelColor
                )
                
                SBUActionSheet.show(
                    items: [retryItem, removeItem],
                    cancelItem: cancelItem
                )
                
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
            let isCurrentUser = userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
            let types: [SBUMenuItemType] = isCurrentUser ? [.copy, .edit, .delete] : [.copy]
            cell.isSelected = true
            
            if SBUEmojiManager.useReaction {
                self.showMenuViewController(cell, message: message, types: types)
            } else {
                self.showMenuModal(cell, indexPath: indexPath,  message: message, types: types)
            }
            
        case let fileMessage as SBDFileMessage:
            guard fileMessage.sendingStatus == .succeeded else { return }
            let isCurrentUser = fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
            let types: [SBUMenuItemType] = isCurrentUser ? [.save, .delete] : [.save]
            cell.isSelected = true
            
            if SBUEmojiManager.useReaction {
                self.showMenuViewController(cell, message: message, types: types)
            } else {
                self.showMenuModal(cell, indexPath: indexPath, message: message, types: types)
            }
            
        case _ as SBDAdminMessage:
            break
            
        default:
            // Unknown Message
            guard message.sender?.userId == SBUGlobals.CurrentUser?.userId else { return }
            
            let deleteItem = SBUMenuItem(
                title: SBUStringSet.Delete,
                color: self.theme.menuTextColor,
                image: SBUIconSet.iconDelete
            ) { [weak self] in
                self?.deleteMessage(message: message)
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
    open func setTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
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
    open func setLongTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
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
        self.updateBroadcastModeState()
        self.updateFrozenModeState()
        self.updateMutedModeState()
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


    // MARK:- Common
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
    
    func showNetworkError() {
        self.firstLoad = true
        self.messageList = []
        self.hasPrevious = true
        self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.error)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator else { return }
        
        if loadingState {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }
    
    /// This is a function that gets the location of the message to be grouped.
    /// Only successful messages can be grouped.
    /// - Parameter currentIndex: Index of current message in the message list
    /// - Returns: Position of a message when grouped
    ///
    /// - Since: 1.2.1
    public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
        guard currentIndex < self.fullMessageList.count-1 else { return .none }
        
        let prevMessage = self.fullMessageList.count+2 > currentIndex
            ? self.fullMessageList[currentIndex+1]
            : nil
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = currentIndex != 0
            ? self.fullMessageList[currentIndex-1]
            : nil
        
        let succeededPrevMsg = prevMessage?.sendingStatus == .succeeded
            ? prevMessage
            : nil
        let succeededCurrentMsg = currentMessage.sendingStatus == .succeeded
            ? currentMessage
            : nil
        let succeededNextMsg = nextMessage?.sendingStatus == .succeeded
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
    
    
    // MARK:- Actions
    public func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func onClickSetting() {
        self.showChannelSettings()
    }
    
    
    // MARK:- ScrollView
    public func scrollToBottom(animated: Bool) {
        guard self.fullMessageList.count != 0 else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableView.scrollToRow(at: indexPath, at: .top, animated: animated)
            self.newMessagesCount = 0
            self.lastSeenIndexPath = nil
            if let newMessageInfoView = self.newMessageInfoView {
                newMessageInfoView.isHidden = true
            }
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastSeenIndexPath = nil
        
        if scrollView.contentOffset.y < 10 {
            self.newMessagesCount = 0
            self.lastSeenIndexPath = nil
            if let newMessageInfoView = self.newMessageInfoView {
                newMessageInfoView.isHidden = true
            }
        }
    }
    

    // MARK:- Cell generator
    func setUserMessageCell(_ cell: SBUUserMessageCell,
                            userMessage: SBDUserMessage,
                            indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            self?.setTapGestureHandler(cell, message: userMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: userMessage, indexPath: indexPath)
        }
    }
    
    func setFileMessageCell(_ cell: SBUFileMessageCell,
                            fileMessage: SBDFileMessage,
                            indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            self?.setTapGestureHandler(cell, message: fileMessage)
        }

        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: fileMessage, indexPath: indexPath)
        }
        
        switch fileMessage.sendingStatus {
        case .canceled, .pending, .failed, .none:
            let requestID = fileMessage.requestId
            
            if let fileDict = self.preSendFileData[requestID] {
                guard let fileData = fileDict["data"] as? Data,
                    let typeString = fileDict["type"] as? String else { return }

                if SBUUtils.getFileType(by: typeString) == .image {
                    cell.setImage(fileData.toImage(), size: SBUConstant.thumbnailSize)
                }
            } else if let fileDict = self.resendableFileData[requestID] {
                guard let fileData = fileDict["data"] as? Data,
                    let typeString = fileDict["type"] as? String else { return }

                if SBUUtils.getFileType(by: typeString) == .image {
                    cell.setImage(fileData.toImage(), size: SBUConstant.thumbnailSize)
                }
            }
            
        case .succeeded:
            break

        @unknown default:
            self.didReceiveError("unknown Type")
        }
    }
    
    func setUnkownMessageCell(_ cell: SBUUnknownMessageCell,
                              unknownMessage: SBDBaseMessage,
                              indexPath: IndexPath) {
        cell.tapHandlerToContent = { [weak self] in
            self?.setTapGestureHandler(cell, message: unknownMessage)
        }
        
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.setLongTapGestureHandler(cell, message: unknownMessage, indexPath: indexPath)
        }
    }
    
    private func calculatorMenuPoint(indexPath: IndexPath,
                                     position: MessagePosition) -> CGPoint {
        let rowRect = self.tableView.rectForRow(at: indexPath)
        let rowRectInSuperview = self.tableView.convert(rowRect,
                                                        to: self.tableView.superview?.superview)
        let originX = (position == .right) ? rowRectInSuperview.width : 0
        let menuPoint = CGPoint(x: originX, y: (rowRectInSuperview.origin.y))
        
        return menuPoint
    }
    
    
    func showMenuViewController(_ cell: SBUBaseMessageCell,
                                message: SBDBaseMessage,
                                types: [SBUMenuItemType]) {
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
                    self.inEditingMessage = userMessage
                    self.messageInputView.startEditMode(text: userMessage.message)
                } else {
                    SBULog.info("This channel is frozen")
                }

            case .save:
                guard let fileMessage = message as? SBDFileMessage else { return }
                SBUDownloadManager.saveFile(with: fileMessage, parent: self)
            }
        }

        menuVC.dismissHandler = {
            cell.isSelected = false
        }

        menuVC.emojiTapHandler = { [weak self] emojiKey, setSelect in
            self?.setReaction(message: message, emojiKey: emojiKey, didSelect: setSelect)
        }

        menuVC.moreEmojiTapHandler = { [weak self] in
            DispatchQueue.main.async {
                self?.showEmojiListModal(message: message)
            }
        }
    }

    func showMenuModal(_ cell: SBUBaseMessageCell,
                       indexPath: IndexPath,
                       message: SBDBaseMessage,
                       types: [SBUMenuItemType]) {
        let items: [SBUMenuItem] = types.map {
            switch $0 {
            case .copy:
                return SBUMenuItem(
                    title: SBUStringSet.Copy,
                    color: self.theme.menuTextColor,
                    image: SBUIconSet.iconCopy
                ) {
                    guard let userMessage = message as? SBDUserMessage else { return }
                    
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = userMessage.message
                }
            case .edit:
                return SBUMenuItem(
                    title: SBUStringSet.Edit,
                    color: self.theme.menuTextColor,
                    image: SBUIconSet.iconEdit
                ) { [weak self] in
                    guard let userMessage = message as? SBDUserMessage else { return }
                    
                    if self?.channel?.isFrozen == false {
                        self?.inEditingMessage = userMessage
                        self?.messageInputView.startEditMode(text: userMessage.message)
                    } else {
                        SBULog.info("This channel is frozen")
                    }
                }
            case .delete:
                return SBUMenuItem(
                    title: SBUStringSet.Delete,
                    color: self.theme.menuTextColor,
                    image: SBUIconSet.iconDelete
                ) { [weak self] in
                    self?.deleteMessage(message: message)
                }
            case .save:
                return SBUMenuItem(
                    title: SBUStringSet.Save,
                    color: self.theme.menuTextColor,
                    image: SBUIconSet.iconDownload
                ) { [weak self] in
                    guard let self = self,
                        let fileMessage = message as? SBDFileMessage else { return }
                    
                    SBUDownloadManager.saveFile(with: fileMessage, parent: self)
                }
            }
        }

        let menuPoint = self.calculatorMenuPoint(indexPath: indexPath, position: cell.position)
        SBUMenuView.show(items: items, point: menuPoint) {
            cell.isSelected = false
        }
    }

    
    // MARK:- Keyboard
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue else { return }
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.messageInputViewBottomConstraint.constant = -keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        self.messageInputViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func addGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
    }
    

    // MARK:- Error handling
    open func didReceiveError(_ message: String?) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
}


// MARK:- UITableViewDelegate, UITableViewDataSource
extension SBUChannelViewController: UITableViewDelegate, UITableViewDataSource {
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = self.channel else {
            self.didReceiveError("Channel must exist!")
            return UITableViewCell()
        }
        
        let message = self.fullMessageList[indexPath.row]

        let cell = tableView.dequeueReusableCell(
            withIdentifier: self.getCellIdentifier(by: message)
            ) ?? UITableViewCell()
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        
        guard let messageCell = cell as? SBUBaseMessageCell else {
            self.didReceiveError("There are no message cells!")
            return cell
        }
        
        let isSameDay = self.checkSameDayAsNextMessage(currentIndex: indexPath.row)
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
                receiptState: SBUUtils.getReceiptState(channel: channel, message: unknownMessage)
            )
            self.setUnkownMessageCell(
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
                receiptState: SBUUtils.getReceiptState(channel: channel, message: message)
            )
            self.setUserMessageCell(
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
                receiptState: SBUUtils.getReceiptState(channel: channel, message: message)
            )
            
            self.setFileMessageCell(
                fileMessageCell,
                fileMessage: fileMessage,
                indexPath: indexPath
            )
            
        default:
            messageCell.configure(
                message: message,
                position: .center,
                hideDateView: isSameDay,
                receiptState: SBUUtils.getReceiptState(channel: channel, message: message)
            )
        }
        
        // Tap profile action
        messageCell.tapHandlerToProfileImage = {
        }

        // Reaction action
        messageCell.emojiTapHandler = { [weak messageCell, weak self] emojiKey in
            guard let cell = messageCell else { return }
            self?.setTapEmojiGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.emojiLongPressHandler = { [weak messageCell, weak self] emojiKey in
            guard let cell = messageCell else { return }
            self?.setLongTapEmojiGestureHandler(cell, emojiKey: emojiKey)
        }

        messageCell.moreEmojiTapHandler = { [weak self] in
            self?.dismissKeyboard()
            self?.showEmojiListModal(message: message)
        }

        return cell
    }
    
    open func tableView(_ tableView: UITableView,
                        willDisplay cell: UITableViewCell,
                        forRowAt indexPath: IndexPath) {
        if self.fullMessageList.count > 0,
            self.hasPrevious,
            indexPath.row == (self.fullMessageList.count - Int(self.limit)/2),
            self.isLoading == false,
            self.firstLoad == false {
            self.loadPrevMessageList(reset: false)
        }
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fullMessageList.count
    }
    
    open func getCellIdentifier(by message: SBDBaseMessage) -> String {
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


// MARK:- UIViewControllerTransitioningDelegate
extension SBUChannelViewController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return SBUBottomSheetController(
            presentedViewController: presented,
            presenting: presenting
        )
    }
}


// MARK:- UIImagePickerControllerDelegate
extension SBUChannelViewController: UIImagePickerControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [weak self] in
            guard info[.mediaType] != nil else { return }
            let mediaType = info[.mediaType] as! CFString

            switch mediaType {
            case kUTTypeImage:
                self?.sendImageFileMessage(info: info)
            case kUTTypeMovie:
                self?.sendVideoFileMessage(info: info)
            default:
                break
            }
        }
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK:- UIDocumentPickerDelegate
extension SBUChannelViewController: UIDocumentPickerDelegate {
    @available(iOS 11.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentsAt urls: [URL]) {
        self.sendDocumentFileMessage(documentUrls: urls)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController,
                               didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) { return }
        self.sendDocumentFileMessage(documentUrls: [url])
    }
}


// MARK:- SBUMessageInputViewDelegate
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


// MARK:- SBUFileViewerDelegate
extension SBUChannelViewController: SBUFileViewerDelegate {
    open func didSelectDeleteImage(message: SBDFileMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        
        self.channel?.delete(message) { [weak self] error in
            if let error = error {
                self?.didReceiveError(error.localizedDescription)
                SBULog.error("[Failed] Delete message request: \(error.localizedDescription)")
                return
            }

            SBULog.info("[Succeed] Delete message: \(message.description)")
            self?.deleteMessagesForSync(messageIds: [message.messageId], needReload: true)
        }
    }
}

// MARK:- SBUEmptyViewDelegate
extension SBUChannelViewController: SBUEmptyViewDelegate {
    public func didSelectRetry() {
        if let emptyView = self.emptyView as? SBUEmptyView {
            emptyView.reloadData(.noMessages)
        }
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
}


// MARK:- SBDChannelDelegate, SBDConnectionDelegate
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
        
        SBULog.info("[Request] markAsRead")
        self.channel?.markAsRead()
        self.upsertMessagesForSync(messages: [message], needReload: true)
    }
    
    // Updated message
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Did update message: \(message)")
        
        self.updateMessagesForSync(messages: [message], needReload: true)
    }
    
    // Deleted message
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Message was deleted: \(messageId)")
        
        self.deleteMessagesForSync(messageIds: [messageId], needReload: true)
    }

    // Updated Reaction
    open func channel(_ sender: SBDBaseChannel, updatedReaction reactionEvent: SBDReactionEvent) {
        guard let message = messageList
            .first(where: { $0.messageId == reactionEvent.messageId }) else { return }
        
        message.apply(reactionEvent)

        SBULog.info("Updated reaction, message:\(message.messageId), key: \(reactionEvent.key)")
        self.upsertMessagesForSync(
            messages: [message],
            needUpdateNewMessage: false,
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
            self?.tableView.reloadData()
        }
    }
    
    // Mark as delivered
    open func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        SBULog.info("Did update deliveryReceipt, ChannelUrl:\(sender.channelUrl)")
        
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
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
    
    public func channelWasFrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        SBULog.info("Channel was frozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    public func channelWasUnfrozen(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        SBULog.info("Channel was unfrozen, ChannelUrl:\(channel.channelUrl)")
        
        self.updateMessageInputModeState()
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are muted.")
            self.updateMessageInputModeState()
        }
    }
    
    public func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are unmuted.")
            self.updateMessageInputModeState()
        }
    }
    
    public func channelDidUpdateOperators(_ sender: SBDBaseChannel) {
        self.updateMessageInputModeState()
    }

    public func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {
        if user.userId == SBUGlobals.CurrentUser?.userId {
            SBULog.info("You are banned.")
            self.onClickBack()
        }
    }
    

    // MARK: SBDConnectionDelegate
    open func didSucceedReconnection() {
        SBULog.info("Did succeed reconnection")
        
        guard let channel = self.channel else { return }
        
        SBULog.info("[Request] Refresh channel")
        channel.refresh { [weak self] error in
            if let error = error {
                self?.didReceiveError(error.localizedDescription)
                SBULog.error("[Failed] Refresh channel request : \(error.localizedDescription)")
                return
            }
            
            SBULog.info("[Succeed] Refresh channel request")
            self?.loadMessageChangeLogs(hasMore: true, token: nil)
            
            self?.updateMessageInputModeState()
        }
    }
}
