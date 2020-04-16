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

@objcMembers
open class SBUChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SBDChannelDelegate, SBDConnectionDelegate, SBUMessageInputViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIDocumentPickerDelegate, SBUEmptyViewDelegate, SBUFileViewerDelegate {

    // MARK: - Public property
    // for UI
    public var channelName: String? = nil
    
    public lazy var messageInputView: SBUMessageInputView = _messageInputView
    public lazy var newMessageInfoView: SBUNewMessageInfo = _newMessageInfoView

    public lazy var leftBarButton: UIBarButtonItem? = _leftBarButton
    public lazy var rightBarButton: UIBarButtonItem? = _rightBarButton
    
  
    // MARK: - Private property
    // for UI
    var theme: SBUChannelTheme = SBUTheme.channelTheme

    private lazy var titleView: SBUChannelTitleView = _titleView
    private lazy var tableView = UITableView()

    private lazy var _titleView: SBUChannelTitleView = {
        let titleView = SBUChannelTitleView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 50))
        return titleView
    }()

    private lazy var _leftBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: nil,
                               style: .plain,
                               target: self,
                               action: #selector(onClickBack))
    }()

    private lazy var _rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(image: nil,
                               style: .plain,
                               target: self,
                               action: #selector(onClickSetting))
    }()
    
    private lazy var _messageInputView: SBUMessageInputView = {
        return SBUMessageInputView.loadViewFromNib() as! SBUMessageInputView
    }()
    
    private lazy var _newMessageInfoView: SBUNewMessageInfo = {
        return SBUNewMessageInfo()
    }()

    private lazy var emptyView: SBUEmptyView = {
        let emptyView = SBUEmptyView()
        emptyView.type = EmptyViewType.none
        emptyView.delegate = self
        return emptyView
    }()

    private var messageInputViewBottomConstraint: NSLayoutConstraint!
    private var tableViewTopConstraint: NSLayoutConstraint!

    private var newMessagesCount: Int = 0
    private var touchedPoint: CGPoint = .zero

    // for Logic

    /// One of two must be set.
    private var channel: SBDGroupChannel?
    private var channelUrl: String?

    @SBUAtomic var fullMessageList: [SBDBaseMessage] = []
    @SBUAtomic var messageList: [SBDBaseMessage] = []
    var preSendMessages: [String:SBDBaseMessage] = [:] // for use before response from the server
    var resendableMessages: [String:SBDBaseMessage] = [:] // Pending, Failed messaged
    var inEditingMessage: SBDUserMessage? = nil // for editing

    // preSend -> error: resendable / succeeded: messageList -> fullMessageList
    var preSendFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    var resendableFileData: [String:[String:AnyObject]] = [:] // Key: requestId
    var fileTransferProgress: [String:CGFloat] = [:] // Key: requestId, If have value, file message status is sending

    var messageListQuery: SBDPreviousMessageListQuery?
    var lastUpdatedTimestamp: Int64 = 0
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
  
  
    // MARK: - Lifecycle
    @available(*, unavailable, renamed: "SBUChannelViewController.init(channelUrl:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// If you have channel object, use this initialize function.
    /// - Parameter channel: Channel object
    public init(channel: SBDGroupChannel) {
        super.init(nibName: nil, bundle: nil)
        
        self.channel = channel
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    /// If you don't have channel object and have channelUrl, use this initialize function.
    /// - Parameter channelUrl: Channel url string
    public init(channelUrl: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.channelUrl = channelUrl
        
        self.loadChannel(channelUrl: channelUrl)
    }
    
    open override func loadView() {
        super.loadView()
        
        // navigation bar
        self.navigationItem.leftBarButtonItem = self.leftBarButton
        self.navigationItem.rightBarButtonItem = self.rightBarButton

        let spacer = UIView()
        let constraint = spacer.widthAnchor.constraint(greaterThanOrEqualToConstant: CGFloat.greatestFiniteMagnitude)
        constraint.isActive = true
        constraint.priority = .defaultLow

        let stack = UIStackView(arrangedSubviews: [self.titleView, spacer])
        stack.axis = .horizontal
        
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

        self.emptyView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.backgroundView = self.emptyView
        self.tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 44.0
        self.view.addSubview(self.tableView)
        
        // message input view
        self.view.addSubview(self.messageInputView)
        
        // new message info view
        self.newMessageInfoView.isHidden = true
        self.view.addSubview(self.newMessageInfoView)
        
        // autolayout
        self.setupAutolayout()

        // Styles
        self.setupStyles()
    }
    
    open func setupAutolayout() {
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableViewTopConstraint = self.tableView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0)
        NSLayoutConstraint.activate([
            self.tableViewTopConstraint,
            self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.tableView.bottomAnchor.constraint(equalTo: self.messageInputView.topAnchor, constant: 0),
        ])
        
        self.messageInputView.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputViewBottomConstraint = self.messageInputView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            self.messageInputView.topAnchor.constraint(equalTo: self.tableView.bottomAnchor, constant: 0),
            self.messageInputView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0),
            self.messageInputView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0),
            self.messageInputViewBottomConstraint,
        ])
        
        self.newMessageInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.newMessageInfoView.bottomAnchor.constraint(equalTo: self.messageInputView.topAnchor, constant: -17),
            self.newMessageInfoView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0),
        ])
    }
    
    open func setupStyles() {
        self.navigationController?.navigationBar.backgroundColor = .clear
        self.navigationController?.navigationBar.barTintColor = theme.navigationBarTintColor
        self.navigationController?.navigationBar.shadowImage = .from(color: theme.navigationBarShadowColor)
        
        self.leftBarButton?.image = SBUIconSet.iconBack
        self.leftBarButton?.tintColor = theme.leftBarButtonTintColor
        
        self.rightBarButton?.image = SBUIconSet.iconInfo
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

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        if let channel = self.channel {
            titleView.updateChannelStatus(channel: channel)
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        SBDMain.removeChannelDelegate(forIdentifier: self.description)
        SBDMain.removeConnectionDelegate(forIdentifier: self.description)

        NotificationCenter.default.removeObserver(self)
    }

    
    // MARK: - Custom viewController relations
    
    /// If you want to use a custom channelSettingsViewController, override it and implement it.
    open func showChannelSettings() {
        let channelSettingsVC = SBUChannelSettingsViewController(channel: self.channel)
        self.navigationController?.pushViewController(channelSettingsVC, animated: true)
    }
    
    
    // MARK: - SDK relations
    private func loadPrevMessageList(reset: Bool) {
        if self.isLoading { return }
        self.setLoading(true, false)
        
        guard let channel = self.channel else {
            self.setLoading(false, false)
            return
        }
        
        if reset {
            self.messageListQuery = nil
            self.messageList = []
            self.hasPrevious = true
            self.inEditingMessage = nil
            self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
            self.channel?.markAsRead()
        }
        
        if self.messageListQuery == nil {
            self.messageListQuery = channel.createPreviousMessageListQuery()
            self.messageListQuery?.limit = self.limit
            self.messageListQuery?.reverse = true
            self.messageListQuery?.messageTypeFilter = .all
        }
        
        self.isRequestingLoad = true
        self.messageListQuery?.load(completionHandler: { [weak self] messages, error in
            defer { self?.setLoading(false, false) }
            
            guard error == nil else {
                self?.isRequestingLoad = false;
                self?.didReceiveError(error?.localizedDescription)
                return
            }
            guard let messages = messages else { self?.isRequestingLoad = false; return }
            
            guard messages.count != 0 else {
                self?.emptyView.updateType(.noChannels)
                self?.hasPrevious = false
                self?.isRequestingLoad = false
                return
            }
            
            self?.upsertMessages(messages: messages, needReload: true)
            self?.lastUpdatedTimestamp = self?.channel?.lastMessage?.createdAt ?? Int64(Date().timeIntervalSince1970*1000)
        })
    }
    
    private func loadNextMessages(hasNext: Bool) {
        guard hasNext == true else {
            self.sortAllMessageList(needReload: true)
            self.lastUpdatedTimestamp = self.channel?.lastMessage?.createdAt ?? Int64(Date().timeIntervalSince1970*1000)
            
            return
        }
        
        let limit = 20
        self.channel?.getNextMessages(byTimestamp: self.lastUpdatedTimestamp, limit: limit, reverse: true, messageType: .all, customType: nil, completionHandler: { [weak self] messages, error in
            guard error == nil else {
                self?.sortAllMessageList(needReload: true)
                self?.didReceiveError(error?.localizedDescription)
                return
            }

            guard let messages = messages else { return }
            if messages.count > 0 {
                self?.lastUpdatedTimestamp = messages[0].createdAt
                self?.upsertMessages(messages: messages, needReload: false)
            }
            
            self?.loadNextMessages(hasNext: (messages.count == limit))
        })
    }
    
    private func loadMessageChangeLogs(hasMore: Bool, token: String?) {
        guard hasMore == true else {
            self.loadNextMessages(hasNext: true)
            return
        }
        
        if let token = token {
            self.channel?.getMessageChangeLogs(withToken: token) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
                
                self?.upsertMessages(messages: updatedMessages, needReload: false)
                self?.deleteMessages(messageIds: deletedMessageIds as! [Int64], needReload: false)
                
                self?.loadMessageChangeLogs(hasMore: hasMore, token: token)
            }
        }
        else {
            self.channel?.getMessageChangeLogs(byTimestamp: self.lastUpdatedTimestamp) { [weak self] updatedMessages, deletedMessageIds, hasMore, token, error in
                if let error = error { self?.didReceiveError(error.localizedDescription) }
                
                self?.upsertMessages(messages: updatedMessages, needReload: false)
                self?.deleteMessages(messageIds: deletedMessageIds as! [Int64], needReload: false)
                
                self?.loadMessageChangeLogs(hasMore: hasMore, token: token)
            }
        }
    }
    
    private func sendUserMessage(text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        var preSendMessage: SBDUserMessage?
        guard let messageParam = SBDUserMessageParams(message: text) else { return }
        
        self.scrollToTop()
        
        preSendMessage = self.channel?.sendUserMessage(with: messageParam) { [weak self] userMessage, error in
            guard let self = self else { return }
            guard error == nil else {
                guard let requestId = userMessage?.requestId else { return }
                self.preSendMessages.removeValue(forKey: requestId)
                self.resendableMessages[requestId] = userMessage
                self.sortAllMessageList(needReload: true)
                self.didReceiveError(error?.localizedDescription)
                return
            }
            
            guard let message = userMessage else { return }
            guard let requestId = userMessage?.requestId else { return }

            self.preSendMessages.removeValue(forKey: requestId)
            self.resendableMessages.removeValue(forKey: requestId)
            self.upsertMessages(messages: [message], needReload: true)
            
            self.channel?.markAsRead()
        }
        
        guard let unwrappedPreSendMessage = preSendMessage, let requestId = unwrappedPreSendMessage.requestId else { return }
        self.preSendMessages[requestId] = unwrappedPreSendMessage
        self.sortAllMessageList(needReload: true)
        self.messageInputView.endTypingMode()
        self.channel?.endTyping()
    }
    
    private func sendFileMessage(fileData: Data, fileName: String, mimeType: String) {
        /*********************************
          Thumbnail is a premium feature.
        ***********************************/
        
        var preSendMessage: SBDFileMessage?
        
        let fileMessageParams = SBDFileMessageParams(file: fileData)!
        fileMessageParams.fileName = fileName
        fileMessageParams.mimeType = mimeType
        fileMessageParams.fileSize = UInt(fileData.count)
        guard let channel = self.channel else { return }
        
        preSendMessage = channel.sendFileMessage(with: fileMessageParams,
                                                 progressHandler: {
                                                    // [weak self]
                                                    bytesSent, totalBytesSent, totalBytesExpectedToSend in
                                                    
                                                    //// If need reload cell for progress, call reload action in here.
                                                    // guard let self = self else { return }
                                                    // guard let requestId = preSendMessage?.requestId else { return }
                                                    
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
            }, completionHandler: { [weak self] fileMessage, error in
                guard error == nil else {
                    guard let requestId = fileMessage?.requestId else { return }
                    self?.resendableMessages[requestId] = fileMessage
                    self?.resendableFileData[requestId] = ["data": fileData, "type": mimeType, "filename": fileName] as [String : AnyObject]
                    self?.preSendMessages.removeValue(forKey: requestId)
                    self?.preSendFileData.removeValue(forKey: requestId)
                    self?.sortAllMessageList(needReload: true)
                    
                    self?.didReceiveError(error?.localizedDescription)
                    return
                }
                
                guard let message = fileMessage else { return }
                guard let requestId = fileMessage?.requestId else { return }
                
                self?.preSendMessages.removeValue(forKey: requestId)
                self?.preSendFileData.removeValue(forKey: requestId)
                self?.resendableMessages.removeValue(forKey: requestId)
                self?.resendableFileData.removeValue(forKey: requestId)
                self?.fileTransferProgress.removeValue(forKey: requestId)
                self?.upsertMessages(messages: [message], needReload: true)
                
                self?.channel?.markAsRead()
        })
        
        guard let unwrappedPreSendMessage = preSendMessage, let requestId = unwrappedPreSendMessage.requestId else { return }
        self.preSendMessages[requestId] = unwrappedPreSendMessage
        self.preSendFileData[requestId] = ["data": fileData, "type": mimeType, "filename": fileName] as [String : AnyObject]
        self.fileTransferProgress[requestId] = 0
        self.sortAllMessageList(needReload: true)
    }
    
    private func resendMessage(failedMessage: SBDBaseMessage) {
        if let failedMessage = failedMessage as? SBDUserMessage {
            self.channel?.resendUserMessage(with: failedMessage, completionHandler: { [weak self] userMessage, error in
                guard error == nil else {
                    self?.sortAllMessageList(needReload: true)
                    self?.didReceiveError(error?.localizedDescription)
                    return
                }
                
                guard let message = userMessage else { return }
                guard let requestId = userMessage?.requestId else { return }

                self?.preSendMessages.removeValue(forKey: requestId)
                self?.resendableMessages.removeValue(forKey: requestId)
                self?.upsertMessages(messages: [message], needReload: true)
                
                self?.channel?.markAsRead()
            })
        } else if let failedMessage = failedMessage as? SBDFileMessage, let requestId = failedMessage.requestId {
            var data: Data? = nil
            if let fileData = self.resendableFileData[requestId], fileData["data"] is Data {
                data = fileData["data"] as? Data
            }
            
            self.channel?.resendFileMessage(with: failedMessage, binaryData: data,
                                            progressHandler: { [weak self] (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                                                self?.fileTransferProgress[requestId] = CGFloat(totalBytesSent) / CGFloat(totalBytesExpectedToSend)
                                                //// If need reload cell for progress, call reload action in here.
                                                // self?.tableView.reloadData()
                }, completionHandler: { [weak self] (fileMessage, error) in
                    guard error == nil else {
                        self?.sortAllMessageList(needReload: true)
                        self?.didReceiveError(error?.localizedDescription)
                        return
                    }
                    
                    guard let message = fileMessage else { return }
                    guard let requestId = fileMessage?.requestId else { return }
                    
                    self?.preSendMessages.removeValue(forKey: requestId)
                    self?.preSendFileData.removeValue(forKey: requestId)
                    self?.resendableMessages.removeValue(forKey: requestId)
                    self?.resendableFileData.removeValue(forKey: requestId)
                    self?.fileTransferProgress.removeValue(forKey: requestId)
                    self?.upsertMessages(messages: [message], needReload: true)
                    
                    self?.channel?.markAsRead()
            })
        }
    }
    
    private func removeMessage(message: SBDBaseMessage) {
        let deleteButton = SBUAlertButtonItem(title: SBUStringSet.Delete, color: theme.alertRemoveColor) { [weak self] info in
            self?.channel?.delete(message, completionHandler: { [weak self] error in
                guard error == nil else {
                    self?.didReceiveError(error?.localizedDescription)
                    return
                }
                
                self?.deleteMessages(messageIds: [message.messageId], needReload: true)
            })
        }
        let cancelButton = SBUAlertButtonItem(title: SBUStringSet.Cancel) {_ in }
        
        SBUAlertView.show(title: SBUStringSet.Alert_Delete, confirmButtonItem: deleteButton, cancelButtonItem: cancelButton)
    }
    
    /// This function is used to load channel information.
    /// - Parameter channelUrl: channel url
    public func loadChannel(channelUrl: String?) {
        guard let channelUrl = channelUrl else { return }
        
        SBUMain.connectionCheck { [weak self] user, error in
            if let error = error { self?.didReceiveError(error.localizedDescription) }

            SBDGroupChannel.getWithUrl(channelUrl) { [weak self] channel, error in
                guard error == nil else {
                    self?.didReceiveError(error?.localizedDescription)
                    return
                }
                
                self?.channel = channel
                self?.loadPrevMessageList(reset: true)
                
                self?.titleView.configure(channel: self?.channel, title: self?.channelName)
            }
        }
    }
    
    // MARK: - List managing
    private func sortedFullMessageList() -> [SBDBaseMessage] {
        let presendMessages = self.preSendMessages.values
        let sendMessages = self.messageList
        let resendableMessages = self.resendableMessages.values
        
        return ([] + resendableMessages + presendMessages).sorted { $0.createdAt > $1.createdAt } + sendMessages.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        self.fullMessageList = self.sortedFullMessageList()
        
        DispatchQueue.main.async {
            self.emptyView.updateType(self.fullMessageList.isEmpty ? .noChannels : .none)
            
            guard needReload == true else { return }
            
            self.tableView.reloadData()
            
            guard let lastSeenIndexPath = self.lastSeenIndexPath else { return }
            self.tableView.scrollToRow(at: lastSeenIndexPath, at: .top, animated: false)
        }
    }

    private func editMessages(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = self.messageList.firstIndex(where: { $0.messageId == message.messageId }) {
                self.messageList[index] = message
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    private func upsertMessages(messages: [SBDBaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = self.messageList.firstIndex(where: { $0.messageId == message.messageId }) {
                self.messageList.append(self.messageList.remove(at: index))
            } else {
                self.messageList.append(message)
            }
            
            switch message {
            case let userMessage as SBDUserMessage:
                if let requestId = userMessage.requestId, requestId.count > 0 { break }
                self.countUpNewMessageInfo()
            case let fileMessage as SBDFileMessage:
                if let requestId = fileMessage.requestId, requestId.count > 0 { break }
                self.countUpNewMessageInfo()
                
            default:
                break
            }
        }
        
        self.isRequestingLoad = false
        self.sortAllMessageList(needReload: needReload)
    }
    
    private func updateMessage(messageString: String) {
        guard let message = self.inEditingMessage else { return }
        guard let messageParam = SBDUserMessageParams(message: messageString) else { return }
        
        self.channel?.updateUserMessage(
            withMessageId: message.messageId,
            userMessageParams: messageParam)
        { [weak self] updatedMessage, error in
            if let error = error { self?.didReceiveError(error.localizedDescription) }
            
            guard let updatedMessage = updatedMessage else { return }
            self?.deleteMessages(messageIds: [message.messageId], needReload: false)
            self?.upsertMessages(messages: [updatedMessage], needReload: true)
            
            self?.messageInputView.endEditMode()
        }
    }
    
    private func deleteMessages(messageIds: [Int64], needReload: Bool) {
        var toBeDeleteIndexes: [Int] = []
        var toBeDeleteRequestIds: [String] = []
        
        for (index, message) in self.messageList.enumerated() {
            for messageId in messageIds {
                guard message.messageId == messageId else { continue }
                toBeDeleteIndexes.append(index)
                
                switch message {
                case let userMessage as SBDUserMessage:
                    guard let requestId = userMessage.requestId, requestId.count > 0 else { break }
                    toBeDeleteRequestIds.append(requestId)

                case let fileMessage as SBDFileMessage:
                    guard let requestId = fileMessage.requestId, requestId.count > 0 else { break }
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
    
    private func countUpNewMessageInfo() {
        guard self.tableView.contentOffset != .zero else {
            self.lastSeenIndexPath = nil
            return
        }
        guard self.isRequestingLoad == false else {
            self.lastSeenIndexPath = nil
            return
        }
        
        self.newMessageInfoView.isHidden = false
        self.newMessagesCount += 1
        self.newMessageInfoView.updateTitle(count: self.newMessagesCount) { [weak self] in
            self?.scrollToTop()
        }
        if let indexPath = self.tableView.indexPathsForVisibleRows?[0] {
            self.lastSeenIndexPath = IndexPath(row: indexPath.row + 1, section: 0)
        }
    }


    // MARK: - Common
    
    public func checkSameDayAsNextMessage(currentIndex: Int) -> Bool {
        guard currentIndex < self.fullMessageList.count-1 else { return false }
        
        let currentMessage = self.fullMessageList[currentIndex]
        let nextMessage = self.fullMessageList[currentIndex+1]
        
        let curCreatedAt = currentMessage.createdAt
        let prevCreatedAt = nextMessage.createdAt
        
        return Date.checkSameDayBetweenOldAndNew(oldTimestamp: prevCreatedAt, newTimestamp: curCreatedAt)
    }
    
    public func configureOffset() {
        guard self.tableView.contentOffset.y < 0 else { return }
        let tempOffset = self.tableView.contentOffset.y
        
        guard self.tableViewTopConstraint.constant <= 0 else { return }
        self.tableViewTopConstraint.constant -= tempOffset
    }
    
    func showNetworkError() {
        self.messageListQuery = nil
        self.messageList = []
        self.hasPrevious = true
        self.lastUpdatedTimestamp = Int64(Date().timeIntervalSince1970*1000)
        self.emptyView.updateType(.error)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// This is used to check the loading status and control loading indicator.
    /// - Parameters:
    ///   - loadingState: Set to true when the list is loading.
    ///   - showIndicator: If true, the loading indicator is started, and if false, the indicator is stopped.
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) {
        self.isLoading = loadingState
        guard showIndicator == true else { return }
        
        if loadingState == true {
            SBULoading.start()
        } else {
            SBULoading.stop()
        }
    }
    
    
    // MARK: - Send action relations
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
            guard let imageData = originalImage?.fixedOrientation().jpegData(compressionQuality: 1.0) else { return }
            self.sendFileMessage(fileData: imageData, fileName: "image.jpg", mimeType: "image/jpeg")
            
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
            { imageData, dataUTI, orientation, info in
                guard let imageData = imageData else { return }
                self.sendFileMessage(fileData: imageData, fileName: imageName, mimeType: mimeType)
                
            }
            
        default:
            
            guard let originalImage = info[.originalImage] as? UIImage else { return }
            guard let imageData = originalImage.fixedOrientation().jpegData(compressionQuality: 1.0) else { return }
            self.sendFileMessage(fileData: imageData, fileName: "image.jpg", mimeType: "image/jpeg")
        }
        
    }
    
    public func sendVideoFileMessage(info: [UIImagePickerController.InfoKey : Any]) {
        do {
            guard let videoUrl = info[.mediaURL] as? URL else { return }
            let videoFileData = try Data(contentsOf: videoUrl)
            let videoName = videoUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: videoUrl) else { return }
            
            self.sendFileMessage(fileData: videoFileData, fileName: videoName, mimeType: mimeType)
        } catch {
        }
    }
    
    public func sendDocumentFileMessage(documentUrls: [URL]) {
        do {
            guard let documentUrl = documentUrls.first else { return }
            let documentData = try Data(contentsOf: documentUrl)
            let documentName = documentUrl.lastPathComponent
            guard let mimeType = SBUUtils.getMimeType(url: documentUrl) else { return }
            self.sendFileMessage(fileData: documentData, fileName: documentName, mimeType: mimeType)
        } catch {
            self.didReceiveError(error.localizedDescription)
        }
    }
    
    
    // MARK: - Actions
    public func onClickBack() {
        if let navigationController = self.navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    public func onClickSetting() {
        self.showChannelSettings()
    }
    
    public func scrollToTop() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, animations: {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
            }) { _ in
                self.newMessagesCount = 0
                self.lastSeenIndexPath = nil
                self.newMessageInfoView.isHidden = true
            }
        }
    }
    
    
    // MARK: - UITableView relations
    public func register(adminMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.adminMessageCell = adminMessageCell
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: adminMessageCell.className)
        } else {
            self.tableView.register(type(of: adminMessageCell), forCellReuseIdentifier: adminMessageCell.className)
        }
    }

    public func register(userMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.userMessageCell = userMessageCell
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: userMessageCell.className)
        } else {
            self.tableView.register(type(of: userMessageCell), forCellReuseIdentifier: userMessageCell.className)
        }
    }

    public func register(fileMessageCell: SBUBaseMessageCell, nib: UINib? = nil) {
        self.fileMessageCell = fileMessageCell
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: fileMessageCell.className)
        } else {
            self.tableView.register(type(of: fileMessageCell), forCellReuseIdentifier: fileMessageCell.className)
        }
    }

    public func register(customMessageCell: SBUBaseMessageCell?, nib: UINib? = nil) {
        self.customMessageCell = customMessageCell
        guard let customMessageCell = customMessageCell else { return }
        if let nib = nib {
            self.tableView.register(nib, forCellReuseIdentifier: customMessageCell.className)
        } else {
            self.tableView.register(type(of: customMessageCell), forCellReuseIdentifier: customMessageCell.className)
        }
    }

    open func getCellIdentifier(by message: SBDBaseMessage) -> String {
        switch message {
        case is SBDFileMessage:  return fileMessageCell?.className ?? SBUFileMessageCell.className
        case is SBDUserMessage:  return userMessageCell?.className ?? SBUUserMessageCell.className
        case is SBDAdminMessage: return adminMessageCell?.className ?? SBUAdminMessageCell.className

        default:
            return ""
        }
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let channel = self.channel else {
            self.didReceiveError("Channel must exist!")
            return UITableViewCell()
        }
        
        let message = self.fullMessageList[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: self.getCellIdentifier(by: message)) ?? UITableViewCell()
        cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
        cell.selectionStyle = .none
        
        guard let messageCell = cell as? SBUBaseMessageCell else {
            self.didReceiveError("There are no message cells!")
            return cell
        }
        switch (message, messageCell) {
            
        // Amdin Message
        case let (adminMessage, adminMessageCell) as (SBDAdminMessage, SBUAdminMessageCell):
            adminMessageCell.configure(adminMessage,
                                       hideDateView: self.checkSameDayAsNextMessage(currentIndex: indexPath.row))
            
        // User Message
        case let (userMessage, userMessageCell) as (SBDUserMessage, SBUUserMessageCell):
            userMessageCell.configure(userMessage,
                                      hideDateView: self.checkSameDayAsNextMessage(currentIndex: indexPath.row),
                                      receiptState: SBUUtils.getReceiptState(channel: channel, message: message))
            self.setUserMessageCell(userMessageCell, userMessage: userMessage, indexPath: indexPath)
            
        // File Message
        case let (fileMessage, fileMessageCell) as (SBDFileMessage, SBUFileMessageCell):
            fileMessageCell.configure(fileMessage,
                                      hideDateView: self.checkSameDayAsNextMessage(currentIndex: indexPath.row),
                                      receiptState: SBUUtils.getReceiptState(channel: channel, message: message))
            
            self.setFileMessageCell(fileMessageCell, fileMessage: fileMessage, indexPath: indexPath)
            
        default:
            messageCell.configure(message: message,
                                  position: .center,
                                  hideDateView: self.checkSameDayAsNextMessage(currentIndex: indexPath.row),
                                  receiptState: SBUUtils.getReceiptState(channel: channel, message: message))
        }
        
        // Tap profile action
        messageCell.tapHandlerToProfileImage = {
            print("tapHandlerToProfileImage")
        }


        return cell
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.fullMessageList.count > 0,
            self.hasPrevious == true,
            indexPath.row == (self.fullMessageList.count - Int(self.limit)/2),
            self.isLoading == false,
            self.messageListQuery != nil
        {
            self.loadPrevMessageList(reset: false)
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fullMessageList.count
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.lastSeenIndexPath = nil
        
        if scrollView.contentOffset.y < 10 {
            self.newMessagesCount = 0
            self.lastSeenIndexPath = nil
            self.newMessageInfoView.isHidden = true
        }
    }
    
    // MARK: - Cell generator
    func setUserMessageCell(_ cell: SBUUserMessageCell, userMessage: SBDUserMessage, indexPath: IndexPath) {
        self.setTapGestureHandler(cell, message: userMessage)
        
        self.setLongTabGestureHandler(cell, message: userMessage, indexPath: indexPath)
    }
    
    func setFileMessageCell(_ cell: SBUFileMessageCell, fileMessage: SBDFileMessage, indexPath: IndexPath) {
        self.setTapGestureHandler(cell, message: fileMessage)

        self.setLongTabGestureHandler(cell, message: fileMessage, indexPath: indexPath)
        
        switch fileMessage.sendingStatus {
        case .canceled, .pending, .failed, .none:
            guard let requestID = fileMessage.requestId else { return }

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
    
    private func calculatorMenuPoint(indexPath: IndexPath, position: MessagePosition) -> CGPoint {
        let rowRect = self.tableView.rectForRow(at: indexPath)
        let rowRectInSuperview = self.tableView.convert(rowRect, to: self.tableView.superview?.superview)
        let originX = (position == .right) ? rowRectInSuperview.width : 0
        let menuPoint = CGPoint(x: originX, y: (rowRectInSuperview.origin.y))
        
        return menuPoint
    }
    
    
    // MARK: - Cell TapHandler
    
    /// This function sets the cell's tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    open func setTapGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage) {
        cell.tapHandlerToContent = { [weak self] in
            guard let self = self else { return }

            self.dismissKeyboard()
            
            switch message {
            case let userMessage as SBDUserMessage:
                // User message type
                if userMessage.sendingStatus == .failed, userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId {
                    let retryItem = SBUActionSheetItem(title: SBUStringSet.Retry) {
                        self.resendMessage(failedMessage: userMessage)
                    }
                    let removeItem = SBUActionSheetItem(title: SBUStringSet.Remove, color: self.theme.removeItemColor) {
                        self.deleteResendableMessages(requestIds: [userMessage.requestId ?? ""], needReload: true)
                    }
                    let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, color: self.theme.cancelItemColor)
                    SBUActionSheet.show(items: [retryItem, removeItem], cancelItem: cancelItem)
                }
            case let fileMessage as SBDFileMessage:
                // File message type
                switch fileMessage.sendingStatus {
                case .pending:
                    break
                case .failed:
                    if fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId {
                        let retryItem = SBUActionSheetItem(title: SBUStringSet.Retry) {
                            self.resendMessage(failedMessage: fileMessage)
                        }
                        let removeItem = SBUActionSheetItem(title: SBUStringSet.Remove, color: self.theme.alertRemoveColor) {
                            self.deleteResendableMessages(requestIds: [fileMessage.requestId ?? ""], needReload: true)
                        }
                        let cancelItem = SBUActionSheetItem(title: SBUStringSet.Cancel, color: self.theme.alertCancelColor)
                        SBUActionSheet.show(items: [retryItem, removeItem], cancelItem: cancelItem)
                    }
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
//            case let adinMessage as SBDAdminMessage:
//                // Admin message type
//                break
            default:
                break
            }
        }
    }
    /// This function sets the cell's long tap gesture handling.
    /// - Parameters:
    ///   - cell: Message cell object
    ///   - message: Message object
    ///   - indexPath: indexpath of cell
    open func setLongTabGestureHandler(_ cell: SBUBaseMessageCell, message: SBDBaseMessage, indexPath: IndexPath) {
        cell.longPressHandlerToContent = { [weak self, weak cell] in
            guard let self = self, let cell = cell else { return }
            self.dismissKeyboard()


            switch message {
            case let userMessage as SBDUserMessage:
                // User message type

                let copyItem = SBUMenuItem(title: SBUStringSet.Copy, color: self.theme.menuTextColor, image: SBUIconSet.iconCopy) {
                    let pasteboard = UIPasteboard.general
                    pasteboard.string = userMessage.message
                }
                
                let editItem = SBUMenuItem(title: SBUStringSet.Edit, color: self.theme.menuTextColor, image: SBUIconSet.iconEdit) {
                    self.inEditingMessage = userMessage
                    self.messageInputView.startEditMode(text: userMessage.message ?? "")
                }
                
                let deleteItem = SBUMenuItem(title: SBUStringSet.Delete, color: self.theme.menuTextColor, image: SBUIconSet.iconDelete) {
                    self.removeMessage(message: userMessage)
                }
                
                let menuPoint = self.calculatorMenuPoint(indexPath: indexPath, position: cell.position)
                let isCurrentUser = userMessage.sender?.userId == SBUGlobals.CurrentUser?.userId

                let items = isCurrentUser ? [copyItem, editItem, deleteItem] : [copyItem]

                cell.isSelected = true
                SBUMenuView.show(items: items, point: menuPoint) {
                    cell.isSelected = false
                }


            case let fileMessage as SBDFileMessage:
                // File message type
                let saveItem = SBUMenuItem(title: SBUStringSet.Save, color: self.theme.menuTextColor, image: SBUIconSet.iconDownload) {
                    SBUDownloadManager.saveFile(with: fileMessage, parent: self)
                }
                let deleteItem = SBUMenuItem(title: SBUStringSet.Delete, color: self.theme.menuTextColor, image: SBUIconSet.iconDelete) {
                    self.removeMessage(message: fileMessage)
                }
                
                let menuPoint = self.calculatorMenuPoint(indexPath: indexPath, position: cell.position)
                
                switch fileMessage.sendingStatus {
                case .succeeded:
                    let isCurrentUser = fileMessage.sender?.userId == SBUGlobals.CurrentUser?.userId
                    let items = isCurrentUser ? [saveItem, deleteItem] : [saveItem]

                    cell.isSelected = true
                    SBUMenuView.show(items: items, point: menuPoint) {
                        cell.isSelected = false
                    }

                case .none:
                    break
                case .pending:
                    break
                case .failed:
                    break
                case .canceled:
                    break
                @unknown default:
                    break
                }
//            case let adinMessage as SBDAdminMessage:
//                // Admin message type
//                break
            default:
                break
            }
        }
    }
    
    
    // MARK: - SBDChannelDelegate
    // Received message
    open func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        switch message {
        case is SBDUserMessage:
            //// If need specific logic for user message, implement here
            break
            
        case is SBDFileMessage:
            //// If need specific logic for file message, implement here
            break
            
        case is SBDAdminMessage:
            //// If need specific logic for admin message, implement here
            break
            
        default:
            break
        }
        
        self.channel?.markAsRead()
        self.upsertMessages(messages: [message], needReload: true)
    }
    
    // Updated message
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        self.editMessages(messages: [message], needReload: true)
    }
    
    // Deleted message
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        self.deleteMessages(messageIds: [messageId], needReload: true)
    }
    
    // Mark as read
    open func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        titleView.updateChannelStatus(channel: sender)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // Mark as delivered
    open func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    open func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        titleView.updateChannelStatus(channel: sender)
    }
    
    open func channelWasChanged(_ sender: SBDBaseChannel) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        guard let channel = sender as? SBDGroupChannel else { return }
        
        titleView.configure(channel: channel, title: self.channelName)
    }
    
    
    // MARK: - SBDConnectionDelegate
    open func didSucceedReconnection() {
        guard let channel = self.channel else { return }
        channel.refresh { error in
            guard error == nil else {
                self.didReceiveError(error?.localizedDescription)
                return
            }
            self.loadMessageChangeLogs(hasMore: true, token: nil)
        }
    }


    // MARK: - Keyboard
    func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
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
    

    // MARK: - SBUMessageInputViewDelegate
    open func messageInputView(_ messageInputView: SBUMessageInputView, didSelectSend text: String) {
        guard text.count > 0 else { return }
        self.sendUserMessage(text: text)
    }

    open func messageInputView(_ messageInputView: SBUMessageInputView, didSelectResource type: MediaResourceType) {
        if type == .document {
            let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content"], in: UIDocumentPickerMode.import)
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            self.present(documentPicker, animated: true, completion: nil)
        }
        else {
            var sourceType: UIImagePickerController.SourceType = .photoLibrary
            let mediaType: [String] = [String(kUTTypeImage), String(kUTTypeGIF), String(kUTTypeMovie)]
            
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

    open func messageInputView(_ messageInputView: SBUMessageInputView, didSelectEdit text: String) {
        self.updateMessage(messageString: text)
    }
    
    open func messageInputViewDidStartTyping() {
        self.channel?.startTyping()
    }
    
    open func messageInputViewDidEndTyping() {
        self.channel?.endTyping()
    }
    
    
    // MARK: - UIImagePickerViewControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
    
    
    // MARK: - UIDocumentPickerDelegate
    @available(iOS 11.0, *)
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.sendDocumentFileMessage(documentUrls: urls)
    }
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if #available(iOS 11.0, *) { return }
        self.sendDocumentFileMessage(documentUrls: [url])
    }
    
    
    // MARK: - SBUEmptyViewDelegate
    public func didSelectRetry() {
        self.emptyView.updateType(.noChannels)
        
        self.loadChannel(channelUrl: self.channel?.channelUrl)
    }
    
    
    // MARK: - SBUFileViewerDelegate
    open func didSelectDeleteImage(message: SBDFileMessage) {
        self.channel?.delete(message) { [weak self] error in
            guard error == nil else {
                self?.didReceiveError(error?.localizedDescription)
                return
            }

            self?.deleteMessages(messageIds: [message.messageId], needReload: true)
        }
    }
    
    // MARK: - Error handling
    open func didReceiveError(_ message: String?) {

    }
}
