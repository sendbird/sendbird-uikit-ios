//
//  SBUBaseChannelViewModel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/07/22.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import AVKit
import SendbirdChatSDK

/// Methods to get data source for the `SBUBaseChannelViewModel`.
public protocol SBUBaseChannelViewModelDataSource: AnyObject {
    /// Asks to data source whether the channel is scrolled to bottom.
    /// - Parameters:
    ///    - viewModel: `SBUBaseChannelViewModel` object.
    ///    - channel: `BaseChannel` object.
    /// - Returns:
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        isScrollNearBottomInChannel channel: BaseChannel?
    ) -> Bool
}

/// Methods for notifying the data updates from the `SBUBaseChannelViewModel`.
public protocol SBUBaseChannelViewModelDelegate: SBUCommonViewModelDelegate {
    /// Called when the the channel has been changed.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeChannel channel: BaseChannel?,
        withContext context: MessageContext
    )
    
    /// Called when the channel has received a new message.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didReceiveNewMessage message: BaseMessage,
        forChannel channel: BaseChannel
    )
    
    /// Called when the channel should finish editing mode
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldFinishEditModeForChannel channel: BaseChannel
    )
    
    /// Called when the channel should be dismissed.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldDismissForChannel channel: BaseChannel?
    )
    
    /// Called when the messages has been changed. If they're the first loaded messages, `initialLoad` is `true`.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didChangeMessageList messages: [BaseMessage],
        needsToReload: Bool,
        initialLoad: Bool
    )
    
    /// Called when the messages has been deleted.
    /// - Since: 3.4.0
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        deletedMessages messages: [BaseMessage]
    )
    
    /// Called when it should be updated scroll status for messages.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        shouldUpdateScrollInMessageList messages: [BaseMessage],
        forContext context: MessageContext?,
        keepsScroll: Bool
    )
    
    /// Called when it has updated the reaction event for a message.
    func baseChannelViewModel(
        _ viewModel: SBUBaseChannelViewModel,
        didUpdateReaction reaction: ReactionEvent,
        forMessage message: BaseMessage
    )
}

open class SBUBaseChannelViewModel: NSObject {
    // MARK: - Constant
    let defaultFetchLimit: Int = 30
    let initPolicy: MessageCollectionInitPolicy = .cacheAndReplaceByApi
    
    // MARK: - Logic properties (Public)
    /// The current channel object. It's `BaseChannel` type.
    public internal(set) var channel: BaseChannel?
    /// The URL of the current channel.
    public internal(set) var channelURL: String?
    /// The starting point of the message list in the `channel`.
    public internal(set) var startingPoint: Int64?
    
    /// This user message object that is being edited.
    public internal(set) var inEditingMessage: UserMessage?
    
    /// This object has a list of all success messages synchronized with the server.
    @SBUAtomic public internal(set) var messageList: [BaseMessage] = []
    /// This object has a list of all messages.
    @SBUAtomic public internal(set) var fullMessageList: [BaseMessage] = []
    
    /// This object is used to check if current user is an operator.
    public var isOperator: Bool {
        if let groupChannel = self.channel as? GroupChannel {
            return groupChannel.myRole == .operator
        } else if let openChannel = self.channel as? OpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return false }
            return openChannel.isOperator(userId: userId)
        }
        return false
    }

    /// Custom param set by user.
    public var customizedMessageListParams: MessageListParams?
    public internal(set) var messageListParams = MessageListParams()
    
    public var sendFileMessageCompletionHandler: SendbirdChatSDK.FileMessageHandler?
    public var sendUserMessageCompletionHandler: SendbirdChatSDK.UserMessageHandler?
    
    public var pendingMessageManager = SBUPendingMessageManager.shared
    
    /// Manages the typing bubble message.
    /// - Since: 3.12.0
    public var typingMessageManager = SBUTypingIndicatorMessageManager.shared
    
    // MARK: - Logic properties (Private)
    weak var baseDataSource: SBUBaseChannelViewModelDataSource?
    weak var baseDelegate: SBUBaseChannelViewModelDelegate?
    
    let prevLock = NSLock()
    let nextLock = NSLock()
    let initialLock = NSLock()
    
    var isInitialLoading = false
    var isScrollToInitialPositionFinish = false
    
    @SBUAtomic var isLoadingNext = false
    @SBUAtomic var isLoadingPrev = false

    /// Memory cache of newest messages to be used when message has loaded from specific timestamp.
    var messageCache: SBUMessageCache?
    
    var isTransformedList: Bool = true
    var isThreadMessageMode: Bool = false
    
    // MARK: - LifeCycle
    public override init() {
        super.init()
        
        SendbirdChat.addConnectionDelegate(
            self,
            identifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    func reset() {
        self.messageCache = nil
        self.resetMessageListParams()
        self.isScrollToInitialPositionFinish = false
    }
    
    deinit {
        self.baseDelegate = nil
        self.baseDataSource = nil
        
        SendbirdChat.removeConnectionDelegate(
            forIdentifier: "\(SBUConstant.connectionDelegateIdentifier).\(self.description)"
        )
    }
    
    // MARK: - Channel related
    
    /// This function loads channel information and message list.
    /// - Parameters:
    ///   - channelURL: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information.
    public func loadChannel(channelURL: String, messageListParams: MessageListParams? = nil, completionHandler: ((BaseChannel?, SBError?) -> Void)? = nil) {}
    
    /// This function refreshes channel.
    public func refreshChannel() {}
    
    // MARK: - Load Messages
    
    /// Loads initial messages in channel.
    /// `NOT` using `initialMessages` here since `MessageCollection` handles messages from db.
    /// Only used in `SBUOpenChannelViewModel` where `MessageCollection` is not suppoorted.
    ///
    /// - Parameters:
    ///   - startingPoint: Starting point to load messages from, or `nil` to load from the latest. (`Int64.max`)
    ///   - showIndicator: Whether to show indicator on load or not.
    ///   - initialMessages: Custom messages to start the messages from.
    public func loadInitialMessages(
        startingPoint: Int64?,
        showIndicator: Bool,
        initialMessages: [BaseMessage]?
    ) {}
    
    /// Loads previous messages.
    public func loadPrevMessages() {}
    
    /// Loads next messages from `lastUpdatedTimestamp`.
    public func loadNextMessages() {}
    
    /// This function resets list and reloads message lists.
    public func reloadMessageList() {
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
    open func sendUserMessage(text: String, parentMessage: BaseMessage? = nil) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let messageParams = UserMessageCreateParams(message: text)
        
        if let parentMessage = parentMessage,
            SendbirdUI.config.groupChannel.channel.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)

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
    open func sendUserMessage(text: String, mentionedMessageTemplate: String, mentionedUserIds: [String], parentMessage: BaseMessage? = nil) {
        let messageParams = UserMessageCreateParams(message: text)
        
        if let parentMessage = parentMessage,
           SendbirdUI.config.groupChannel.channel.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        
        SBUGlobalCustomParams.userMessageParamsSendBuilder?(messageParams)

        messageParams.mentionedMessageTemplate = mentionedMessageTemplate
        messageParams.mentionedUserIds = mentionedUserIds
        self.sendUserMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a user messag with messageParams.
    ///
    /// You can send a message by setting various properties of MessageParams.
    /// - Parameters:
    ///    - messageParams: `UserMessageCreateParams` class object
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    /// - Since: 1.0.9
    open func sendUserMessage(messageParams: UserMessageCreateParams, parentMessage: BaseMessage? = nil) {
        SBULog.info("[Request] Send user message")
        
        let preSendMessage = self.channel?.sendUserMessage(params: messageParams) { [weak self] userMessage, error in
            self?.sendUserMessageCompletionHandler?(userMessage, error)
        }
               
        if let preSendMessage = preSendMessage,
           self.messageListParams.belongsTo(preSendMessage) {
            preSendMessage.parentMessage = parentMessage
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: self.channel?.channelURL,
                message: preSendMessage,
                forMessageThread: self.isThreadMessageMode
            )
        } else {
            SBULog.info("A filtered user message has been sent.")
        }
        
        self.sortAllMessageList(needReload: true)
        
        if let channel = self.channel as? GroupChannel {
            channel.endTyping()
        }
        
        let context = MessageContext(source: .eventMessageSent, sendingStatus: .succeeded)
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
    open func sendFileMessage(fileData: Data?, fileName: String, mimeType: String, parentMessage: BaseMessage? = nil) {
        guard let fileData = fileData else { return }
        let messageParams = FileMessageCreateParams(file: fileData)
        messageParams.fileName = fileName
        messageParams.mimeType = mimeType
        messageParams.fileSize = UInt(fileData.count)
        
        // Image size
        if let image = UIImage(data: fileData) {
            let thumbnailSize = ThumbnailSize.make(maxSize: image.size)
            messageParams.thumbnailSizes = [thumbnailSize]
        }
        
        // Video thumbnail size
        else if let asset = fileData.getAVAsset() {
            let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            avAssetImageGenerator.appliesPreferredTrackTransform = true
            let cmTime = CMTimeMake(value: 2, timescale: 1)
            if let cgImage = try? avAssetImageGenerator.copyCGImage(at: cmTime, actualTime: nil) {
                let image = UIImage(cgImage: cgImage)
                let thumbnailSize = ThumbnailSize.make(maxSize: image.size)
                messageParams.thumbnailSizes = [thumbnailSize]
            }
        }
        
        if let parentMessage = parentMessage,
           SendbirdUI.config.groupChannel.channel.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }
        
        SBUGlobalCustomParams.fileMessageParamsSendBuilder?(messageParams)
        
        self.sendFileMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a voice message with ``SBUVoiceFileInfo`` object that contains essential information of a voice message.
    /// - Parameters:
    ///   - voiceFileInfo: ``SBUVoiceFileInfo`` class object
    ///   - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    open func sendVoiceMessage(voiceFileInfo: SBUVoiceFileInfo, parentMessage: BaseMessage? = nil) {
        guard let filePath = voiceFileInfo.filePath,
              let fileName = voiceFileInfo.fileName,
              let fileData = SBUCacheManager.File.diskCache.get(fullPath: filePath) else { return }
        let playtime = String(Int(voiceFileInfo.playtime ?? 0))
        let durationMetaArray = MessageMetaArray(key: SBUConstant.voiceMessageDurationKey, value: [playtime])
        let typeMetaArray = MessageMetaArray(key: SBUConstant.internalMessageTypeKey, value: [SBUConstant.voiceMessageType])
        
        let messageParams = FileMessageCreateParams(file: fileData)
        messageParams.fileName = fileName // Maintain the file name used for recording to erase the recording file cache
        messageParams.mimeType = "\(SBUConstant.voiceMessageType);\(SBUConstant.voiceMessageTypeVoiceParameter)"
        messageParams.fileSize = UInt(fileData.count)
        messageParams.metaArrays = [durationMetaArray, typeMetaArray]

        if let parentMessage = parentMessage,
           SendbirdUI.config.groupChannel.channel.replyType != .none {
            messageParams.parentMessageId = parentMessage.messageId
            messageParams.isReplyToChannel = true
        }

        SBUGlobalCustomParams.voiceFileMessageParamsSendBuilder?(messageParams)

        self.sendFileMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    /// Sends a file message with messageParams.
    ///
    /// You can send a file message by setting various properties of MessageParams.
    /// - Parameters:
    ///    - messageParams: `FileMessageCreateParams` class object
    ///    - parentMessage: The parent message. The default value is `nil` when there's no parent message.
    /// - Since: 1.0.9
    open func sendFileMessage(messageParams: FileMessageCreateParams, parentMessage: BaseMessage? = nil) {
        guard let channel = self.channel else { return }
        
        SBULog.info("[Request] Send file message")
        
        // for voice message
        let fileName = messageParams.fileName ?? ""
        
        if SBUUtils.getFileType(by: messageParams.mimeType ?? "") == .voice {
            let extensiontype = URL(fileURLWithPath: fileName).pathExtension
            if extensiontype.count > 0 {
                messageParams.fileName = "\(SBUStringSet.VoiceMessage.fileName).\(extensiontype)"
            } else {
                messageParams.fileName = "\(SBUStringSet.VoiceMessage.fileName)"
            }
        }
        
        var preSendMessage: FileMessage?
        preSendMessage = channel.sendFileMessage(
            params: messageParams,
            progressHandler: { requestId, _, totalBytesSent, totalBytesExpectedToSend in
                //// If need reload cell for progress, call reload action in here.
                guard let requestId = requestId, !requestId.isEmpty else { return }
                let fileTransferProgress = CGFloat(totalBytesSent)/CGFloat(totalBytesExpectedToSend)
                SBULog.info("File message transfer progress: \(requestId) - \(fileTransferProgress)")
            },
            completionHandler: { [weak self] fileMessage, error in
                if let error = error {
                    SBULog.error(error.localizedDescription)
                }
                self?.sendFileMessageCompletionHandler?(fileMessage, error)
            }
        )
        
        if let preSendMessage = preSendMessage {
            switch SBUUtils.getFileType(by: preSendMessage) {
            case .image:
                SBUCacheManager.Image.preSave(fileMessage: preSendMessage)
            case .video:
                SBUCacheManager.Image.preSave(fileMessage: preSendMessage) // for Thumbnail
                SBUCacheManager.File.preSave(fileMessage: preSendMessage, fileName: messageParams.fileName)
            case .voice:
                // voice file's fileName is "Voice message". not have path extension.
                let extensiontype = URL(fileURLWithPath: fileName).pathExtension
                let voiceFileName = "\(SBUStringSet.VoiceMessage.fileName).\(extensiontype)"
                let tempFileName = "\(fileName).\(extensiontype)"
                
                SBUCacheManager.File.preSave(fileMessage: preSendMessage, fileName: voiceFileName)
                SBUCacheManager.File.removeVoiceTemp(fileName: tempFileName)
            default:
                SBUCacheManager.File.preSave(fileMessage: preSendMessage, fileName: messageParams.fileName)
            }
        }
        
        if let preSendMessage = preSendMessage, self.messageListParams.belongsTo(preSendMessage) {
            preSendMessage.parentMessage = parentMessage
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: self.channel?.channelURL,
                message: preSendMessage,
                forMessageThread: self.isThreadMessageMode
            )
            
            self.pendingMessageManager.addFileInfo(
                requestId: preSendMessage.requestId,
                params: messageParams,
                forMessageThread: self.isThreadMessageMode
            )
        } else {
            SBULog.info("A filtered file message has been sent.")
        }
        
        self.sortAllMessageList(needReload: true)
        
        let context = MessageContext(source: .eventMessageSent, sendingStatus: .succeeded)
        self.baseDelegate?.baseChannelViewModel(
            self,
            shouldUpdateScrollInMessageList: self.fullMessageList,
            forContext: context,
            keepsScroll: false
        )
    }
    
    /// Updates a user message with message object.
    /// - Parameters:
    ///   - message: `UserMessage` object to update
    ///   - text: String to be updated
    /// - Since: 1.0.9
    public func updateUserMessage(message: UserMessage, text: String) {
        let text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let messageParams = UserMessageUpdateParams(message: text)
        
        SBUGlobalCustomParams.userMessageParamsUpdateBuilder?(messageParams)
        messageParams.mentionedMessageTemplate = ""
        messageParams.mentionedUserIds = []
        
        self.updateUserMessage(message: message, messageParams: messageParams)
    }
    
    /// Sends a user message with mentionedMessageTemplate and mentionedUserIds.
    /// - Parameters:
    ///   - message: `UserMessage` object to update
    ///   - text: A `String` value to update `message.message`
    ///   - mentionedMessageTemplate: Mentioned message string value that is generated by `text` and `mentionedUsers`
    ///   - mentionedUserIds: Mentioned user Id array
    /// ```swift
    /// print(text) // "Hi @Nickname"
    /// print(mentionedMessageTemplate) // "Hi @{UserID}"
    /// print(mentionedUserIds) // ["{UserID}"]
    /// ```
    open func updateUserMessage(message: UserMessage, text: String, mentionedMessageTemplate: String, mentionedUserIds: [String]) {
        let messageParams = UserMessageUpdateParams(message: text)
        
        SBUGlobalCustomParams.userMessageParamsUpdateBuilder?(messageParams)
        
        messageParams.mentionedMessageTemplate = mentionedMessageTemplate
        messageParams.mentionedUserIds = mentionedUserIds
        self.updateUserMessage(message: message, messageParams: messageParams)
    }
    
    /// Updates a user message with message object and messageParams.
    ///
    /// You can update messages by setting various properties of MessageParams.
    /// - Parameters:
    ///   - message: `UserMessage` object to update
    ///   - messageParams: `UserMessageUpdateParams` class object
    /// - Since: 1.0.9
    public func updateUserMessage(message: UserMessage, messageParams: UserMessageUpdateParams) {
        SBULog.info("[Request] Update user message")
        self.channel?.updateUserMessage(
            messageId: message.messageId,
            params: messageParams
        ) { [weak self] _, _ in
            guard let self = self else { return }
            guard let channel = self.channel else { return }
            self.baseDelegate?.baseChannelViewModel(self, shouldFinishEditModeForChannel: channel)
        }
    }
    
    func handlePendingResendableMessage<Message: BaseMessage>(_ message: Message?, _ error: SBError?) { }
    
    /// Resends a message with failedMessage object.
    /// - Parameter failedMessage: `BaseMessage` class based failed object
    /// - Since: 1.0.9
    public func resendMessage(failedMessage: BaseMessage) {
        if let failedMessage = failedMessage as? UserMessage {
            SBULog.info("[Request] Resend failed user message")
            
            let pendingMessage = self.channel?.resendUserMessage(
                failedMessage
            ) { [weak self] message, error in
                guard let self = self else { return }
                self.handlePendingResendableMessage(message, error)
            }
            
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: self.channel?.channelURL,
                message: pendingMessage,
                forMessageThread: self.isThreadMessageMode
            )
            
            if let failedMessage = pendingMessage {
                self.deleteMessagesInList(
                    messageIds: [failedMessage.messageId],
                    excludeResendableMessages: true,
                    needReload: true
                )
            }
            
        } else if let failedMessage = failedMessage as? FileMessage {
            var data: Data?

            if let fileInfo = self.pendingMessageManager.getFileInfo(
                requestId: failedMessage.requestId,
                forMessageThread: self.isThreadMessageMode
            ) {
                data = fileInfo.file
            }

            SBULog.info("[Request] Resend failed file message")
            
            let pendingMessage = self.channel?.resendFileMessage(
                failedMessage,
                binaryData: data
            ) { (_, _, _, _) in
                //// If need reload cell for progress, call reload action in here.
                // self.tableView.reloadData()
            } completionHandler: { [weak self] message, error in
                guard let self = self else { return }
                self.handlePendingResendableMessage(message, error)
            }
            
            self.pendingMessageManager.upsertPendingMessage(
                channelURL: self.channel?.channelURL,
                message: pendingMessage,
                forMessageThread: self.isThreadMessageMode
            )
            
            if let failedMessage = pendingMessage {
                self.deleteMessagesInList(
                    messageIds: [failedMessage.messageId],
                    excludeResendableMessages: true,
                    needReload: true
                )
            }
        } else if let failedMessage = failedMessage as? MultipleFilesMessage {
            let groupChannel = self.channel as? GroupChannel
            groupChannel?.resendMultipleFilesMessage(
                failedMessage,
                fileUploadHandler: { _, _, _, _ in },
                completionHandler: { [weak self] message, error in
                    guard let self = self else { return }
                    self.handlePendingResendableMessage(message, error)
            })
        }
    }    
    
    /// Deletes a message with message object.
    /// - Parameter message: `BaseMessage` based class object
    /// - Since: 1.0.9
    public func deleteMessage(message: BaseMessage) {
        SBULog.info("[Request] Delete message: \(message.description)")
        self.channel?.deleteMessage(message, completionHandler: nil)
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
    public func updateMessagesInList(messages: [BaseMessage]?, needReload: Bool) {
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                if !self.messageListParams.belongsTo(message) {
                    self.messageList.remove(at: index)
                } else {
                    self.messageList[index] = message
                }
            }
        }
        
        self.sortAllMessageList(needReload: needReload)
    }
    
    // TODO: Not used
    func filteredForThreadMessageView(messages: [BaseMessage]?) -> [BaseMessage]? {
        let pendingMessages = self.pendingMessageManager.getPendingMessages(
            channelURL: self.channelURL,
            forMessageThread: true
        )
        let refinedResult = messages?.filter { message in
            var existInPendingThreadMessage = false
            pendingMessages.forEach {
                if $0.requestId == message.requestId {
                    existInPendingThreadMessage = true
                }
            }
            return !existInPendingThreadMessage
        }
        return refinedResult
    }
    
    /// This function upserts the messages in the list.
    /// - Parameters:
    ///   - messages: Message array to upsert
    ///   - needUpdateNewMessage: If set to `true`, increases new message count.
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func upsertMessagesInList(
        messages: [BaseMessage]?,
        needUpdateNewMessage: Bool = false,
        needReload: Bool
    ) {
        SBULog.info("First : \(String(describing: messages?.first)), Last : \(String(describing: messages?.last))")
        
        var needMarkAsRead = false
        
        messages?.forEach { message in
            if let index = SBUUtils.findIndex(of: message, in: self.messageList) {
                self.messageList.remove(at: index)
            }
            
            guard self.messageListParams.belongsTo(message) else {
                self.sortAllMessageList(needReload: needReload)
                return
            }
            
            guard message is UserMessage || message is FileMessage || message is MultipleFilesMessage else {
                // when message is AdminMessage or unknown message.
                self.messageList.append(message)
                return
            }
            
            if needUpdateNewMessage {
                guard let channel = self.channel else { return }
                self.baseDelegate?.baseChannelViewModel(self, didReceiveNewMessage: message, forChannel: channel)
            }
            
            if message.sendingStatus == .succeeded {
                self.messageList.append(message)

                self.pendingMessageManager.removePendingMessageAllTypes(
                    channelURL: channelURL,
                    requestId: message.requestId
                )
                
                needMarkAsRead = true
                
            } else if message.sendingStatus == .failed ||
                        message.sendingStatus == .pending {
                if !self.isThreadMessageMode, message.parentMessageId > 0 { return }
                self.pendingMessageManager.upsertPendingMessage(
                    channelURL: channelURL,
                    message: message,
                    forMessageThread: self.isThreadMessageMode
                )
            }
        }
        
        let sortAllMessageListBlock = { [weak self] in
            self?.sortAllMessageList(needReload: needReload)
        }
        
        if needMarkAsRead,
           let channel = self.channel as? GroupChannel,
           !self.isThreadMessageMode,
            SendbirdChat.getConnectState() == .open {
            channel.markAsRead { _ in
                sortAllMessageListBlock()
            }
        } else {
            sortAllMessageListBlock()
        }
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
                guard message.messageId == messageId,
                      message.isMessageIdValid else { continue }
                toBeDeleteIndexes.append(index)
                
                guard message.isRequestIdValid else { continue }
                
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
            self.messageList.remove(at: index)
        }
        
        if excludeResendableMessages {
            self.sortAllMessageList(needReload: needReload)
        } else {
            self.deleteResendableMessages(requestIds: toBeDeleteRequestIds, needReload: needReload)
        }
    }

    /// This functions deletes the resendable message.
    /// If `baseChannel` is type of `GroupChannel`, it deletes the message by using local caching.
    /// If `baseChannel` is not type of `GroupChannel` that not using local caching, it calls `deleteResendableMessages(requestIds:needReload:)`.
    /// - Parameters:
    ///   - message: The resendable`BaseMessage` object such as failed message.
    ///   - needReload: If `true`, the table view will call `reloadData()`.
    /// - Since: 2.2.1
    public func deleteResendableMessage(_ message: BaseMessage, needReload: Bool) {
        self.deleteResendableMessages(requestIds: [message.requestId], needReload: needReload)
    }

    /// This functions deletes the resendable messages using the request ids.
    /// - Parameters:
    ///   - requestIds: Request id array to delete
    ///   - needReload: If set to `true`, the tableview will be call reloadData.
    /// - Since: 1.2.5
    public func deleteResendableMessages(requestIds: [String], needReload: Bool) {
        for requestId in requestIds {
            if requestId.isEmpty { continue }
            
            self.pendingMessageManager.removePendingMessageAllTypes(
                channelURL: self.channel?.channelURL,
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
        let pendingMessages = self.pendingMessageManager.getPendingMessages(
            channelURL: self.channel?.channelURL,
            forMessageThread: self.isThreadMessageMode
        )
        
        let refinedPendingMessages = pendingMessages.filter { pendingMessage in
            var isInMessageList = false
            self.messageList.forEach { message in
                if message.requestId == pendingMessage.requestId {
                    isInMessageList = true
                    return
                }
            }
            return !isInMessageList
        }
        
        let typingMessageArray = [typingMessageManager.getTypingMessage(for: self.channel)].compactMap { $0 }
        
        if isTransformedList {
            self.messageList.sort { $0.createdAt > $1.createdAt }
            
            self.fullMessageList = typingMessageArray
                                    + refinedPendingMessages.sorted { $0.createdAt > $1.createdAt }
                                    + self.messageList
        } else {
            self.messageList.sort { $0.createdAt < $1.createdAt }
            self.fullMessageList = self.messageList
                                    + refinedPendingMessages.sorted { $0.createdAt < $1.createdAt }
                                    + typingMessageArray
        }
        
        self.baseDelegate?.shouldUpdateLoadingState(false)
        self.baseDelegate?.baseChannelViewModel(
            self,
            didChangeMessageList: self.fullMessageList,
            needsToReload: needReload,
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
        self.messageListParams = self.customizedMessageListParams?.copy() as? MessageListParams
            ?? MessageListParams()
        
        if self.messageListParams.previousResultSize <= 0 {
            self.messageListParams.previousResultSize = self.defaultFetchLimit
        }
        if self.messageListParams.nextResultSize <= 0 {
            self.messageListParams.nextResultSize = self.defaultFetchLimit
        }
        
        self.messageListParams.reverse = true
        self.messageListParams.includeReactions = SBUEmojiManager.isReactionEnabled(channel: channel)
        
        self.messageListParams.includeThreadInfo = SBUGlobals.reply.includesThreadInfo
        self.messageListParams.includeParentMessageInfo = SBUGlobals.reply.includesParentMessageInfo
        
        if SendbirdUI.config.groupChannel.channel.replyType.filterValue == .none {
            self.messageListParams.replyType = SendbirdUI.config.groupChannel.channel.replyType.filterValue
        }
        
        self.messageListParams.includeMetaArray = true
    }
    
    // MARK: - Reactions
    /// This function is used to add or delete reactions.
    /// - Parameters:
    ///   - message: `BaseMessage` object to update
    ///   - emojiKey: set emoji key
    ///   - didSelect: set reaction state
    /// - Since: 1.1.0
    public func setReaction(message: BaseMessage, emojiKey: String, didSelect: Bool) {
        if didSelect {
            SBULog.info("[Request] Add Reaction")
            self.channel?.addReaction(with: message, key: emojiKey) { reactionEvent, error in
                // INFO:
                // In **super group channel limited mode**, current user can only addReaction and never deleteReaction.
                // If currentUser reacts to an already reacted emoji, the request succeeds, but Chat SDK returns a decoding error (80000).
                // (the response doesn't contain "updated_at" field, but Chat SDK tries to decode this as a non-optional property)
                if let error = error {
                    self.baseDelegate?.didReceiveError(error, isBlocker: false)
                }
                
                SBULog.info("[Response] \(reactionEvent?.key ?? "") reaction")
                guard let reactionEvent = reactionEvent else { return }
                if reactionEvent.messageId == message.messageId {
                    message.apply(reactionEvent)
                }
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
                if reactionEvent.messageId == message.messageId {
                    message.apply(reactionEvent)
                }
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
    
    public func getStartingPoint() -> Int64? { return .max }
    
    // MARK: - Cache
    func setupCache() {
        guard let channel = channel else { return }
        self.messageCache = SBUMessageCache(
            channel: channel,
            messageListParam: self.messageListParams
        )
        self.messageCache?.loadInitial()
    }
    
    func flushCache(with messages: [BaseMessage]) -> [BaseMessage] {
        SBULog.info("flushing cache with : \(messages.count)")
        guard let messageCache = self.messageCache else { return messages }
        
        let mergedList = messageCache.flush(with: messages)
        self.messageCache = nil
        
        return mergedList
    }
}

// MARK: - ConnectionDelegate
extension SBUBaseChannelViewModel: ConnectionDelegate {
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
extension SBUBaseChannelViewModel: BaseChannelDelegate {
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
    
    // If channel type is Group, please do not use belows any more.
    open func channel(_ channel: BaseChannel, didUpdate message: BaseMessage) {}
    open func channel(_ channel: BaseChannel, messageWasDeleted messageId: Int64) {}
    open func channel(_ channel: BaseChannel, didUpdateThreadInfo threadInfoUpdateEvent: ThreadInfoUpdateEvent) {}
    open func channel(_ channel: BaseChannel, updatedReaction reactionEvent: ReactionEvent) {}
//    open func channelDidUpdateReadReceipt(_ channel: GroupChannel) {}
//    open func channelDidUpdateDeliveryReceipt(_ channel: GroupChannel) {}
//    open func channelDidUpdateTypingStatus(_ channel: GroupChannel) {}
    open func channelWasChanged(_ channel: BaseChannel) {}
    open func channelWasFrozen(_ channel: BaseChannel) {}
    open func channelWasUnfrozen(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, userWasMuted user: RestrictedUser) {}
    open func channel(_ channel: BaseChannel, userWasUnmuted user: User) {}
    open func channelDidUpdateOperators(_ channel: BaseChannel) {}
    open func channel(_ channel: BaseChannel, userWasBanned user: RestrictedUser) {}
    open func channel(_ channel: BaseChannel, userWasUnbanned user: User) {}
    open func channelWasDeleted(_ channelURL: String, channelType: ChannelType) {}
}
