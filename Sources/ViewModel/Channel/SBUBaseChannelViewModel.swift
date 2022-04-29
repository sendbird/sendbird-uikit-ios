//
//  SBUBaseChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/07/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVKit
import SendBirdSDK

/// Methods to get data source for the `SBUBaseChannelViewModel`.
public protocol SBUBaseChannelViewModelDataSource: AnyObject {
    /// Asks to data source whether the channel is scrolled to bottom.
    /// - Parameters:
    ///    - viewModel: `SBUBaseChannelViewModel` object.
    ///    - channel: `SBDBaseChannel` object.
    /// - Returns:
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        isScrollNearBottomInChannel channel: SBDBaseChannel?
    ) -> Bool
}

/// Methods for notifying the data updates from the `SBUBaseChannelViewModel`.
public protocol SBUBaseChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the the channel has been changed.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: SBDBaseChannel?,
        withContext context: SBDMessageContext
    )
    
    /// Called when the channel has received a new message.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didReceiveNewMessage message: SBDBaseMessage,
        forChannel channel: SBDBaseChannel
    )
    
    /// Called when the channel should finish editing mode
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldFinishEditModeForChannel channel: SBDBaseChannel
    )
    
    /// Called when the channel should be dismissed.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldDismissForChannel channel: SBDBaseChannel?
    )
    
    /// Called when the messages has been changed. If they're the first loaded messages, `initialLoad` is `true`.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeMessageList messages: [SBDBaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    )
    
    /// Called when it should be updated scroll status for messages.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldUpdateScrollInMessageList messages: [SBDBaseMessage],
        forContext context: SBDMessageContext?,
        keepsScroll: Bool
    )
    
    /// Called when it has updated the reaction event for a message.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didUpdateReaction reaction: SBDReactionEvent,
        forMessage message: SBDBaseMessage
    )
}



open class SBUBaseChannelViewModel: NSObject {
    // MARK: - Constant
    let defaultFetchLimit: Int = 30
    let initPolicy: SBDMessageCollectionInitPolicy = .cacheAndReplaceByApi

    
    // MARK: - Logic properties (Public)
    /// The current channel object. It's `SBDBaseChannel` type.
    public internal(set) var channel: SBDBaseChannel?
    /// The URL of the current channel.
    public internal(set) var channelUrl: String?
    /// The starting point of the message list in the `channel`.
    public internal(set) var startingPoint: Int64? = LLONG_MAX
    
    /// This user message object that is being edited.
    public internal(set) var inEditingMessage: SBDUserMessage? = nil
    
    /// This object has a list of all success messages synchronized with the server.
    @SBUAtomic public internal(set) var messageList: [SBDBaseMessage] = []
    /// This object has a list of all messages.
    @SBUAtomic public internal(set) var fullMessageList: [SBDBaseMessage] = []
    
    /// This object is used to check if current user is an operator.
    public var isOperator: Bool {
        if let groupChannel = self.channel as? SBDGroupChannel {
            return groupChannel.myRole == .operator
        } else if let openChannel = self.channel as? SBDOpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return false }
            return openChannel.isOperator(withUserId: userId)
        }
        return false
    }

    /// Custom param set by user.
    public var customizedMessageListParams: SBDMessageListParams?
    public internal(set) var messageListParams = SBDMessageListParams()

    
    // MARK: - Logic properties (Private)
    weak var baseDataSource: SBUBaseChannelViewModelDataSource?
    weak var baseDelegate: SBUBaseChannelViewModelDelegate?
    
    let prevLock = NSLock()
    let nextLock = NSLock()
    let initialLock = NSLock()
    
    var isInitialLoading = false
    
    @SBUAtomic var isLoadingNext = false

    /// Memory cache of newest messages to be used when message has loaded from specific timestamp.
    var messageCache: SBUMessageCache?
    
    
    // MARK: - LifeCycle
    public override init() {
        super.init()
        
        SBDMain.add(
            self as SBDChannelDelegate,
            identifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
        SBDMain.add(
            self as SBDConnectionDelegate,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    func reset() {
        self.messageCache = nil
        self.resetMessageListParams()
    }
    
    deinit {
        self.baseDelegate = nil
        self.baseDataSource = nil
        
        SBDMain.removeChannelDelegate(
            forIdentifier: "\(SBUConstant.channelDelegateIdentifier).\(self.description)"
        )
        SBDMain.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    
    // MARK: - Channel related
    
    /// This function loads channel information and message list.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information.
    public func loadChannel(channelUrl: String, messageListParams: SBDMessageListParams? = nil) {}
    
    
    /// This function refreshes channel.
    public func refreshChannel() {}
    
    
    // MARK: - Load Messages
    
    /// Loads initial messages in channel.
    /// `NOT` using `initialMessages` here since `SBDMessageCollection` handles messages from db.
    /// Only used in `SBUOpenChannelViewModel` where `SBDMessageCollection` is not suppoorted.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`LLONG_MAX`)
    ///   - showIndicator: Whether to show indicator on load or not.
    ///   - initialMessages: Custom messages to start the messages from.
    public func loadInitialMessages(startingPoint: Int64?,
                             showIndicator: Bool,
                             initialMessages: [SBDBaseMessage]?) {}
    
    /// Loads previous messages.
    public func loadPrevMessages() {}
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    public func loadNextMessages() {}
    
    /// This function resets list and reloads message lists.
    public func reloadMessageList() {
        self.reset()
        self.loadInitialMessages(
            startingPoint: nil,
            showIndicator: false,
            initialMessages: []
        )
    }
    
    
    // MARK: - Message
    
    /// Sends a user message with text and parentMessageId.
    /// - Parameters:
    ///    - text: String value
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    open func sendUserMessage(text: String, parentMessage: SBDBaseMessage? = nil) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let messageParams = SBDUserMessageParams(message: text) else { return }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
        
        if let parentMessage = parentMessage, SBUGlobals.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        messageParams.mentionedMessageTemplate = ""
        messageParams.mentionedUserIds = []
        self.sendUserMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a user message with mentionedMessageTemplate and mentionedUserIds.
    /// - Parameters:
    ///    - mentionedMessageTemplate: Mentioned message string value that is generated by `text` and `mentionedUsers`.
    ///    - mentionedUserIds: Mentioned user Id array
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    /// ```swift
    /// print(text) // "Hi @Nickname"
    /// print(mentionedMessageTemplate) // "Hi @{UserID}"
    /// print(mentionedUserIds) // ["{UserID}"]
    /// ```
    open func sendUserMessage(text: String, mentionedMessageTemplate: String, mentionedUserIds: [String], parentMessage: SBDBaseMessage? = nil) {
        guard let messageParams = SBDUserMessageParams(message: text) else { return }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
        
        if let parentMessage = parentMessage, SBUGlobals.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        messageParams.mentionedMessageTemplate = mentionedMessageTemplate
        messageParams.mentionedUserIds = mentionedUserIds
        self.sendUserMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a user messag with messageParams.
    ///
    /// You can send a message by setting various properties of MessageParams.
    /// - Parameters:
    ///    - messageParams: `SBDUserMessageParams` class object
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    /// - Since: 1.0.9
    open func sendUserMessage(messageParams: SBDUserMessageParams, parentMessage: SBDBaseMessage? = nil) {
        SBULog.info("[Request] Send user message")
        
        let preSendMessage = self.channel?.sendUserMessage(with: messageParams)
        { [weak self] userMessage, error in
            // For open channel
            guard let self = self else { return }
            guard self.channel is SBDOpenChannel else { return }
            
            if let error = error {
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: userMessage?.channelUrl,
                    message: userMessage
                )
                
                self.sortAllMessageList(needReload: true)
                
                self.baseDelegate?.didReceiveError(error)
                SBULog.error("[Failed] Send user message request: \(error.localizedDescription)")
                return
            }
            
            SBUPendingMessageManager.shared.removePendingMessage(
                channelUrl: userMessage?.channelUrl,
                requestId: userMessage?.requestId
            )
            
            guard let userMessage = userMessage else { return }
            SBULog.info("[Succeed] Send user message: \(userMessage.description)")
            self.upsertMessagesInList(messages: [userMessage], needReload: true)
        }
               
        if let preSendMessage = preSendMessage,
           self.messageListParams.belongs(to: preSendMessage)
        {
            preSendMessage.parent = parentMessage
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: preSendMessage
            )
        } else {
            SBULog.info("A filtered user message has been sent.")
        }
        
        self.sortAllMessageList(needReload: true)
        
        if let channel = self.channel as? SBDGroupChannel {
            channel.endTyping()
        }
        
        let context = SBDMessageContext()
        context.source = .eventMessageSent
        self.baseDelegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: self.fullMessageList,
            forContext: context,
            keepsScroll: false
        )
    }
    
    /// Sends a file message with file data, file name, mime type.
    /// - Parameters:
    ///   - fileData: `Data` class object
    ///   - fileName: file name. Used when displayed in channel list.
    ///   - mimeType: file's mime type.
    ///   - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    open func sendFileMessage(fileData: Data?, fileName: String, mimeType: String, parentMessage: SBDBaseMessage? = nil) {
        guard let fileData = fileData else { return }
        let messageParams = SBDFileMessageParams(file: fileData)!
        messageParams.fileName = fileName
        messageParams.mimeType = mimeType
        messageParams.fileSize = UInt(fileData.count)
        
        // Image size
        if let image = UIImage(data: fileData) {
            let thumbnailSize = SBDThumbnailSize.make(withMaxCGSize: image.size)
            messageParams.thumbnailSizes = [thumbnailSize]
        }
        
        // Video thumbnail size
        else if let asset = fileData.getAVAsset() {
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let cmTime = CMTimeMake(value: 2, timescale: 1)
            if let cgImage = try? avAssetImageGenerator.copyCGImage(at: cmTime, actualTime: nil) {
                let image = UIImage(cgImage: cgImage)
                let thumbnailSize = SBDThumbnailSize.make(withMaxCGSize: image.size)
                messageParams.thumbnailSizes = [thumbnailSize]
            }
        }
        
        SBUGlobalCustomParams.fileMessageParamsSendBuilder?(messageParams)
        
        if let parentMessage = parentMessage, SBUGlobals.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        self.sendFileMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a file message with messageParams.
    ///
    /// You can send a file message by setting various properties of MessageParams.
    /// - Parameters:
    ///    - messageParams: `SBDFileMessageParams` class object
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    /// - Since: 1.0.9
    open func sendFileMessage(messageParams: SBDFileMessageParams, parentMessage: SBDBaseMessage? = nil) {
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
                // For Open channel
                guard let self = self else { return }
                guard self.channel is SBDOpenChannel else { return }
                
                if let error = error {
                    if let fileMessage = fileMessage, self.messageListParams.belongs(to: fileMessage) {
                        SBUPendingMessageManager.shared.upsertPendingMessage(
                            channelUrl: fileMessage.channelUrl,
                            message: fileMessage
                        )
                    }
                    
                    self.sortAllMessageList(needReload: true)

                    self.baseDelegate?.didReceiveError(error)
                    SBULog.error(
                        """
                        [Failed] Send file message request:
                        \(error.localizedDescription)
                        """
                    )
                    return
                }
                
                SBUPendingMessageManager.shared.removePendingMessage(
                    channelUrl: fileMessage?.channelUrl,
                    requestId: fileMessage?.requestId
                )
                
                guard let message = fileMessage else { return }
                
                SBULog.info("[Succeed] Send file message: \(message.description)")
                
                self.upsertMessagesInList(messages: [message], needReload: true)
            }
        )
        
        if let preSendMessage = preSendMessage,
           self.messageListParams.belongs(to: preSendMessage)
        {
            preSendMessage.parent = parentMessage
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
                message: preSendMessage
            )
            
            SBUPendingMessageManager.shared.addFileInfo(
                requestId: preSendMessage.requestId,
                params: messageParams
            )
        } else {
            SBULog.info("A filtered file message has been sent.")
        }
        
        self.sortAllMessageList(needReload: true)
        
        let context = SBDMessageContext()
        context.source = .eventMessageSent
        self.baseDelegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: self.fullMessageList,
            forContext: context,
            keepsScroll: false
        )
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
        messageParams.mentionedMessageTemplate = ""
        messageParams.mentionedUserIds = []
        
        self.updateUserMessage(message: message, messageParams: messageParams)
    }
    
    /// Sends a user message with mentionedMessageTemplate and mentionedUserIds.
    /// - Parameters:
    ///   - message: `SBDUserMessage` object to update
    ///   - text: A `String` value to update `message.message`
    ///   - mentionedMessageTemplate: Mentioned message string value that is generated by `text` and `mentionedUsers`
    ///   - mentionedUserIds: Mentioned user Id array
    /// ```swift
    /// print(text) // "Hi @Nickname"
    /// print(mentionedMessageTemplate) // "Hi @{UserID}"
    /// print(mentionedUserIds) // ["{UserID}"]
    /// ```
    open func updateUserMessage(message: SBDUserMessage, text: String, mentionedMessageTemplate: String, mentionedUserIds: [String]) {
        guard let messageParams = SBDUserMessageParams(message: text) else { return }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)
        
        messageParams.mentionedMessageTemplate = mentionedMessageTemplate
        messageParams.mentionedUserIds = mentionedUserIds
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
            userMessageParams: messageParams
        ) { [weak self] updatedMessage, error in
            guard let self = self else { return }
            guard let channel = self.channel else { return }
            self.baseDelegate?.baseChannelViewModel(self, shouldFinishEditModeForChannel: channel)
        }
    }
    
    func handlePendingResendableMessage<Message: SBDBaseMessage>(_ message: Message?, _ error: SBDError?) {
        guard self.channel is SBDOpenChannel else { return }
        if let error = error {
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: message?.channelUrl,
                message: message
            )
            
            self.sortAllMessageList(needReload: true)
            
            self.baseDelegate?.didReceiveError(error, isBlocker: false)
            
            SBULog.error("[Failed] Resend failed user message request: \(error.localizedDescription)")
            return
            
        } else {
            SBUPendingMessageManager.shared.removePendingMessage(
                channelUrl: message?.channelUrl,
                requestId: message?.requestId
            )
            
            guard let message = message else { return }
            
            SBULog.info("[Succeed] Resend failed file message: \(message.description)")
            
            self.upsertMessagesInList(messages: [message], needReload: true)
        }
    }
    
    /// Resends a message with failedMessage object.
    /// - Parameter failedMessage: `SBDBaseMessage` class based failed object
    /// - Since: 1.0.9
    public func resendMessage(failedMessage: SBDBaseMessage) {
        if let failedMessage = failedMessage as? SBDUserMessage {
            SBULog.info("[Request] Resend failed user message")
            
            let pendingMessage = self.channel?.resendUserMessage(
                with: failedMessage
            ) { [weak self] message, error in
                guard let self = self else { return }
                self.handlePendingResendableMessage(message, error)
            }
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
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
            
            let pendingMessage = self.channel?.resendFileMessage(
                with: failedMessage,
                binaryData: data
            ) { (bytesSent, totalBytesSent, totalBytesExpectedToSend) in
                //// If need reload cell for progress, call reload action in here.
                // self.tableView.reloadData()
            } completionHandler: { [weak self] message, error in
                guard let self = self else { return }
                self.handlePendingResendableMessage(message, error)
            }
            
            SBUPendingMessageManager.shared.upsertPendingMessage(
                channelUrl: self.channel?.channelUrl,
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
    
    /// Deletes a message with message object.
    /// - Parameter message: `SBDBaseMessage` based class object
    /// - Since: 1.0.9
    public func deleteMessage(message: SBDBaseMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        
        self.channel?.delete(message, completionHandler: nil)
    }
    
    
    // MARK: - List
    
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
                if !self.messageListParams.belongs(to: message) {
                    self.messageList.remove(at: index)
                } else {
                    self.messageList[index] = message
                }
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
        var needMarkAsRead = false
        
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList.remove(at: index)
            }

            guard self.messageListParams.belongs(to: message) else {
                self.sortAllMessageList(needReload: needReload)
                return
            }
            
            guard message is SBDUserMessage || message is SBDFileMessage else {
                if message is SBDAdminMessage {
                    self.messageList.append(message)
                }
                return
            }
            
            if needUpdateNewMessage {
                guard let channel = self.channel else { return }
                self.baseDelegate?.baseChannelViewModel(self, didReceiveNewMessage: message, forChannel: channel)
            }
            
            if message.sendingStatus == .succeeded {
                self.messageList.append(message)

                SBUPendingMessageManager.shared.removePendingMessage(
                    channelUrl: channelUrl,
                    requestId: message.requestId
                )
                
                needMarkAsRead = true
                
            } else if message.sendingStatus == .failed ||
                        message.sendingStatus == .pending {
                SBUPendingMessageManager.shared.upsertPendingMessage(
                    channelUrl: channelUrl,
                    message: message
                )
            }
        }
        
        if needMarkAsRead, let channel = self.channel as? SBDGroupChannel {
            channel.markAsRead(completionHandler: nil)
        }
        
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
           messageIds.contains(editMessage.messageId),
           let channel = self.channel {
            self.baseDelegate?.baseChannelViewModel(self, shouldFinishEditModeForChannel: channel)
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

    /// This functions deletes the resendable message.
    /// If `baseChannel` is type of `SBDGroupChannel`, it deletes the message by using local caching.
    /// If `baseChannel` is not type of `SBDGroupChannel` that not using local caching, it calls `deleteResendableMessages(requestIds:needReload:)`.
    /// - Parameters:
    ///   - message: The resendable`SBDBaseMessage` object such as failed message.
    ///   - needReload: If `true`, the table view will call `reloadData()`.
    /// - Since: 2.2.1
    public func deleteResendableMessage(_ message: SBDBaseMessage, needReload: Bool) {
        self.deleteResendableMessages(requestIds: [message.requestId], needReload: needReload)
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
    
    /// This function sorts the all message list. (Included `presendMessages`, `messageList` and `resendableMessages`.)
    /// - Parameter needReload: If set to `true`, the tableview will be call reloadData and, scroll to last seen index.
    /// - Since: 1.2.5
    public func sortAllMessageList(needReload: Bool) {
        // Generate full list for draw
        let pendingMessages = SBUPendingMessageManager.shared.getPendingMessages(
            channelUrl: self.channel?.channelUrl
        )
        
        self.messageList.sort { $0.createdAt > $1.createdAt }
        self.fullMessageList = pendingMessages
            .sorted { $0.createdAt > $1.createdAt }
            + self.messageList
        
        self.baseDelegate?.shouldUpdateLoadingState(false)
        self.baseDelegate?.baseChannelViewModel(
            self,
            didChangeMessageList: self.fullMessageList,
            needsToReload: true,
            initialLoad: self.isInitialLoading
        )
    }
    
    /// This functions clears current message lists
    ///
    /// - Since: 2.1.0
    public func clearMessageList() {
        self.fullMessageList.removeAll(where: { SBUUtils.findIndex(of: $0, in: messageList) != nil })
        self.messageList = []
    }
    
    
    // MARK: - MessageListParams
    private func resetMessageListParams() {
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
        
        self.messageListParams.includeThreadInfo = SBUGlobals.replyType.includesThreadInfo
        self.messageListParams.includeParentMessageInfo = SBUGlobals.replyType.includesParentMessageInfo
        self.messageListParams.replyType = SBUGlobals.replyType.filterValue
    }
    
    
    // MARK: - Reactions
    /// This function is used to add or delete reactions.
    /// - Parameters:
    ///   - message: `SBDBaseMessage` object to update
    ///   - emojiKey: set emoji key
    ///   - didSelect: set reaction state
    /// - Since: 1.1.0
    public func setReaction(message: SBDBaseMessage, emojiKey: String, didSelect: Bool) {
        if didSelect {
            SBULog.info("[Request] Add Reaction")
            self.channel?.addReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    self.baseDelegate?.didReceiveError(error, isBlocker: false)
                }
                
                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
                guard let reactionEvent = reactionEvent else { return }
                self.baseDelegate?.baseChannelViewModel(self, didUpdateReaction: reactionEvent, forMessage: message)
            }
        } else {
            SBULog.info("[Request] Delete Reaction")
            self.channel?.deleteReaction(with: message, key: emojiKey) { reactionEvent, error in
                if let error = error {
                    self.baseDelegate?.didReceiveError(error, isBlocker: false)
                }

                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
                guard let reactionEvent = reactionEvent else { return }
                self.baseDelegate?.baseChannelViewModel(self, didUpdateReaction: reactionEvent, forMessage: message)
            }
        }
    }

    
    // MARK: - Common
    
    /// This function checks that have the following list.
    /// - Returns: This function returns `true` if there is the following list.
    public func hasNext() -> Bool { return false }
    
    /// This function checks that have the previous list.
    /// - Returns: This function returns `true` if there is the previous list.
    public func hasPrevious() -> Bool { return false }
    
    func getStartingPoint() -> Int64? { return LLONG_MAX }
    
    
    // MARK: - Cache
    func setupCache() {
        guard let channel = channel else { return }
        self.messageCache = SBUMessageCache(
            channel: channel,
            messageListParam: self.messageListParams
        )
        self.messageCache?.loadInitial()
    }
    
    func flushCache(with messages: [SBDBaseMessage]) -> [SBDBaseMessage] {
        SBULog.info("flushing cache with : \(messages.count)")
        guard let messageCache = self.messageCache else { return messages }
        
        let mergedList = messageCache.flush(with: messages)
        self.messageCache = nil
        
        return mergedList
    }
}


// MARK: - SBDConnectionDelegate
extension SBUBaseChannelViewModel: SBDConnectionDelegate {
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


// MARK: - SBDChannelDelegate
extension SBUBaseChannelViewModel: SBDChannelDelegate {
    // Received message
    open func channel(_ sender: SBDBaseChannel, didReceive message: SBDBaseMessage) {
        guard self.channel?.channelUrl == sender.channelUrl else { return }
        
        switch message {
        case is SBDUserMessage:
            SBULog.info("Did receive user message: \(message)")
        case is SBDFileMessage:
            SBULog.info("Did receive file message: \(message)")
        case is SBDAdminMessage:
            SBULog.info("Did receive admin message: \(message)")
        default:
            break
        }
    }
 
    
    // If channel type is Group, please do not use belows any more.
    open func channel(_ sender: SBDBaseChannel, didUpdate message: SBDBaseMessage) {}
    open func channel(_ sender: SBDBaseChannel, messageWasDeleted messageId: Int64) {}
    open func channel(_ sender: SBDBaseChannel, updatedReaction reactionEvent: SBDReactionEvent) {}
    open func channelDidUpdateReadReceipt(_ sender: SBDGroupChannel) {}
    open func channelDidUpdateDeliveryReceipt(_ sender: SBDGroupChannel) {}
    open func channelDidUpdateTypingStatus(_ sender: SBDGroupChannel) {}
    open func channelWasChanged(_ sender: SBDBaseChannel) {}
    open func channelWasFrozen(_ sender: SBDBaseChannel) {}
    open func channelWasUnfrozen(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, userWasMuted user: SBDUser) {}
    open func channel(_ sender: SBDBaseChannel, userWasUnmuted user: SBDUser) {}
    open func channelDidUpdateOperators(_ sender: SBDBaseChannel) {}
    open func channel(_ sender: SBDBaseChannel, userWasBanned user: SBDUser) {}
    open func channelWasDeleted(_ channelUrl: String, channelType: SBDChannelType) {}
}
