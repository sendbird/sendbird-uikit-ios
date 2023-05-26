//
//  SBUBaseChannelViewController.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/13.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUBaseChannelViewController {
    // MARK: - (Deprecated) UI Properties
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.Header`", renamed: "headerComponent.titleView")
    public var titleView: UIView? {
        get { baseHeaderComponent?.titleView }
        set { baseHeaderComponent?.titleView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.Header`", renamed: "headerComponent.leftBarButton")
    public var leftBarButton: UIBarButtonItem? {
        get { self.baseHeaderComponent?.leftBarButton }
        set { self.baseHeaderComponent?.leftBarButton = newValue }
    }
    
    @available(*, deprecated, message: "`This property has been moved to `SBUBaseChannelModule.Header`", renamed: "headerComponent.rightBarButton")
    public var rightBarButton: UIBarButtonItem? {
        get { self.baseHeaderComponent?.rightBarButton }
        set { self.baseHeaderComponent?.rightBarButton = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.Input`", renamed: "inputComponent.messageInputView")
    public var messageInputView: SBUMessageInputView? {
        get {
            if let messageInputView = self.baseInputComponent?.messageInputView as? SBUMessageInputView {
                return messageInputView
            }
            return nil
        }
        set {
            self.baseInputComponent?.messageInputView = newValue
        }
    }
    
    @available(*, unavailable, message: "This property has been moved to `SBUGroupChannelModule.Input`", renamed: "inputComponent.currentQuotedMessage")
    public var currentQuotedMessage: BaseMessage? {
        get {
            guard let inputComponent = self.baseInputComponent as? SBUGroupChannelModule.Input else { return nil }
            return inputComponent.currentQuotedMessage
        }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.tableView")
    public var tableView: UITableView {
        get { self.baseListComponent?.tableView ?? UITableView() }
        set { self.baseListComponent?.tableView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.channelStateBanner")
    public var channelStateBanner: UIView? {
        get { self.baseListComponent?.channelStateBanner }
        set { self.baseListComponent?.channelStateBanner = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.emptyView")
    public var emptyView: UIView? {
        get { self.baseListComponent?.emptyView }
        set { self.baseListComponent?.emptyView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.newMessageInfoView")
    public var newMessageInfoView: UIView? {
        get { self.baseListComponent?.newMessageInfoView }
        set { self.baseListComponent?.newMessageInfoView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.scrollBottomView")
    public var scrollBottomView: UIView? {
        get { self.baseListComponent?.scrollBottomView }
        set { self.baseListComponent?.scrollBottomView = newValue }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.userProfileView")
    public var userProfileView: UIView? {
        get { self.baseListComponent?.userProfileView }
        set { self.baseListComponent?.userProfileView = newValue }
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelModule.List`", renamed: "listComponent.reloadTableView")
    public func reloadTableView() {
        self.baseListComponent?.reloadTableView()
    }
    
    @available(*, deprecated, renamed: "setMessageInputViewMode(_:message:)")
    public func setEditMode(for userMessage: UserMessage?) {
        self.setMessageInputViewMode(
            userMessage != nil ? .edit : .none,
            message: userMessage
        )
    }
    
    // MARK: - Input mode
    /// This is used to messageInputView state update.
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelModule.List`.", renamed: "inputComponent.updateMessageInputModeState()")
    public func updateMessageInputModeState() {
        if let inputComponent = self.baseInputComponent {
            inputComponent.updateMessageInputModeState()
        }
    }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.channel")
    /// This object is used to import a list of messages, send messages, modify messages, and so on, and is created during initialization.
    @objc
    public var channel: BaseChannel? { baseViewModel?.channel }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.channelURL")
    public var channelUrl: String? { baseViewModel?.channelURL }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.startingPoint")
    public var startingPoint: Int64? { baseViewModel?.startingPoint }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.inEditingMessage")
    public var inEditingMessage: UserMessage? { baseViewModel?.inEditingMessage }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.messageListParams")
    public var messageListParams: MessageListParams { baseViewModel?.messageListParams ?? MessageListParams() }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.customizedMessageListParams")
    public var customizedMessageListParams: MessageListParams? { baseViewModel?.customizedMessageListParams ?? MessageListParams() }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.messageList")
    public var messageList: [BaseMessage] { baseViewModel?.messageList ?? [] }
    
    @available(*, deprecated, message: "This property has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.fullMessageList")
    public var fullMessageList: [BaseMessage] { baseViewModel?.fullMessageList ?? [] }
    
    // MARK: - Channel
    
    /// This function is used to load channel information.
    /// - Parameters:
    ///   - channelUrl: channel url
    ///   - messageListParams: (Optional) The parameter to be used when getting channel information.
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.loadChannel(channelURL:messageListParams:)")
    public func loadChannel(channelUrl: String, messageListParams: MessageListParams? = nil) {
        self.baseViewModel?.loadChannel(
            channelURL: channelUrl,
            messageListParams: messageListParams
        )
    }
    
    /// This function clears current message lists
    /// - Since: 2.1.0
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.clearMessageList()")
    public func clearMessageList() {
        self.baseViewModel?.clearMessageList()
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.setReaction(message:emojiKey:didSelect:)")
    public func setReaction(message: BaseMessage, emojiKey: String, didSelect: Bool) {
        self.baseViewModel?.setReaction(message: message, emojiKey: emojiKey, didSelect: didSelect)
    }
    
    // MARK: List
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.updateMessagesInList(messages:needReload:)")
    public func updateMessagesInList(messages: [BaseMessage]?, needReload: Bool) {
        self.baseViewModel?.updateMessagesInList(messages: messages, needReload: true)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.upsertMessagesInList(messages:needUpdateNewMessage:needReload:)")
    public func upsertMessagesInList(messages: [BaseMessage]?,
                                     needUpdateNewMessage: Bool = false,
                                     needReload: Bool) {
        self.baseViewModel?.upsertMessagesInList(
            messages: messages,
            needUpdateNewMessage: needUpdateNewMessage,
            needReload: needReload
        )
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel` and replaced to `deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)`.")
    public func deleteMessagesInList(messageIds: [Int64]?, needReload: Bool) {
        self.baseViewModel?.deleteMessagesInList(
            messageIds: messageIds,
            excludeResendableMessages: false,
            needReload: needReload
        )
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.deleteMessagesInList(messageIds:excludeResendableMessages:needReload:)")
    public func deleteMessagesInList(messageIds: [Int64]?,
                                     excludeResendableMessages: Bool,
                                     needReload: Bool) {
        self.baseViewModel?.deleteMessagesInList(
            messageIds: messageIds,
            excludeResendableMessages: excludeResendableMessages,
            needReload: needReload
        )
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.deleteResendableMessage(_:needReload:)")
    public func deleteResendableMessage(_ message: BaseMessage, needReload: Bool) {
        self.baseViewModel?.deleteResendableMessage(message, needReload: needReload)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.deleteResendableMessages(requestIds:needReload:)")
    public func deleteResendableMessages(requestIds: [String], needReload: Bool) {
        self.baseViewModel?.deleteResendableMessages(requestIds: requestIds, needReload: needReload)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.sortAllMessageList(needReload:)")
    public func sortAllMessageList(needReload: Bool) {
        self.baseViewModel?.sortAllMessageList(needReload: needReload)
    }
    
    // MARK: Sending messages
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel` and replaced to `sendUserMessage(text:)`.")
    open func sendUserMessage(text: String) {
        self.baseViewModel?.sendUserMessage(text: text)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func sendUserMessage(text: String, parentMessage: BaseMessage? = nil) {
        self.baseViewModel?.sendUserMessage(text: text, parentMessage: parentMessage)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func sendUserMessage(messageParams: UserMessageCreateParams, parentMessage: BaseMessage? = nil) {
        self.baseViewModel?.sendUserMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func sendFileMessage(fileData: Data?, fileName: String, mimeType: String) {
        self.baseViewModel?.sendFileMessage(fileData: fileData, fileName: fileName, mimeType: mimeType)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func sendFileMessage(fileData: Data?, fileName: String, mimeType: String, parentMessage: BaseMessage? = nil) {
        self.baseViewModel?.sendFileMessage(fileData: fileData, fileName: fileName, mimeType: mimeType, parentMessage: parentMessage)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`. Use `sendFileMessage(messageParams:parentMessage:)` of `SBUBaseChannelViewModel` instead.")
    open func sendFileMessage(messageParams: FileMessageCreateParams, parentMessage: BaseMessage? = nil) {
        self.baseViewModel?.sendFileMessage(messageParams: messageParams, parentMessage: parentMessage)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.updateUserMessage(message:text:)")
    public func updateUserMessage(message: UserMessage, text: String) {
        self.baseViewModel?.updateUserMessage(message: message, text: text)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.updateUserMessage(message:messageParams:)")
    public func updateUserMessage(message: UserMessage, messageParams: UserMessageUpdateParams) {
        self.baseViewModel?.updateUserMessage(message: message, messageParams: messageParams)
    }
    
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelViewModel`.", renamed: "viewModel.resendMessage(failedMessage:)")
    public func resendMessage(failedMessage: BaseMessage) {
        self.baseViewModel?.resendMessage(failedMessage: failedMessage)
        self.scrollToBottom(animated: true)
    }
    
    // MARK: Common
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelModule.List` and replaced to `checkSameDayAsNextMessage(currentIndex:fullMessageList:)`.", renamed: "listComponent.checkSameDayAsNextMessage(currentIndex:fullMessageList:)")
    public func checkSameDayAsNextMessage(currentIndex: Int) -> Bool {
        guard let fullMessageList = self.baseViewModel?.fullMessageList else { return false }
        return baseListComponent?.checkSameDayAsNextMessage(
            currentIndex: currentIndex,
            fullMessageList: fullMessageList
        ) ?? false
    }
    
    @available(*, deprecated, renamed: "showChannelSettings()")
    public func onClickSetting() { showChannelSettings() }
    
    // MARK: - Scroll
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelModule.List`.", renamed: "listComponent.setScrollBottomView(hidden:)")
    /// Sets the scroll to bottom view.
    /// - Parameter hidden: whether to hide the view. `nil` to handle it automatically depending on the current scroll position.
    public func setScrollBottomView(hidden: Bool?) {
        // implemented in inherited views
        let isScrollNearByBottom = self.baseListComponent?.isScrollNearByBottom ?? true
        self.baseListComponent?.setScrollBottomView(hidden: hidden ?? isScrollNearByBottom)
    }
    
    /// This function scrolls to bottom.
    /// - Parameter animated: Animated
    @available(*, deprecated, message: "This function has been moved to `SBUBaseChannelModuleListDelegate`.", renamed: "baseChannelModuleDidTapScrollToButton(_:animated:)")
    public func scrollToBottom(animated: Bool) {
        guard let baseListComponent = baseListComponent else { return }
        self.baseChannelModuleDidTapScrollToButton(baseListComponent, animated: animated)
    }
    
}
