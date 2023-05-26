//
//  SBUBaseChannelViewController.Unavailable.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/15.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUBaseChannelViewController {
    // MARK: - Unavailable 3.0.0
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModel`", renamed: "viewModel.didSucceedReconnection()")
    open func didSucceedReconnection() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDataSource`. Use `baseChannelViewModel(_:isScrollNearBottomInChannel:)` of `SBUBaseChannelViewModelDataSource` instead.")
    open func isScrollNearBottom() -> Bool { return false }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:didChangeChannel:withContext:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func channelDidChange(_ channel: BaseChannel?, context: MessageContext) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:didReceiveNewMessage:forChannel:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func channelDidReceiveNewMessage(_ channel: BaseChannel, message: BaseMessage) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:shouldFinishEditModeForChannel:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func channelShouldFinishEditMode(_ channel: BaseChannel) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:shouldDismissForChannel:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func channelShouldDismiss(_ channel: BaseChannel?) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:didChangeMessageList:needsToReload:initialLoad:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func messageListDidChange(_ messages: [BaseMessage], needToReload: Bool, isInitialLoad: Bool) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:shouldUpdateScrollInMessageList:forContext:keepsScroll:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func messageListShouldUpdateScroll(_ messages: [BaseMessage], context: MessageContext?, keepScroll: Bool) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate`. Use `baseChannelViewModel(_:didUpdateReaction:forMessage:)` of `SBUBaseChannelViewModelDelegate` instead.")
    open func message(_ message: BaseMessage, didUpdateReaction reaction: ReactionEvent) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelModule.List` (or `SBUOpenChannelModule.List`).")
    public func getMessageGroupingPosition(currentIndex: Int) -> MessageGroupPosition {
        return .none
    }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleListDelegate`. Use `channelModule(_:didTapMessage:forRowAt:)` of `SBUBaseChannelModuleListDelegate` instead.")
    open func setTapGestureHandler(_ cell: UITableViewCell, message: BaseMessage) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleListDelegate`. Use `channelModule(_:didLongTapMessage:forRowAt:)` of `SBUBaseChannelModuleListDelegate` instead.")
    open func setLongTapGestureHandler(
        _ cell: UITableViewCell,
        message: BaseMessage,
        indexPath: IndexPath
    ) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleListDelegate` and replaced to  `baseChannelModule(_:didTapUserProfile:)`.")
    open func setUserProfileTapGestureHandler(_ user: SBUUser) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUChannelModule.Input`. Use `pickImageFile(info:)` of `SBUChannelModule.Input` instead.")
    public func sendImageFileMessage(info: [UIImagePickerController.InfoKey: Any]) {
        
    }
    
    @available(*, unavailable, message: "This function has been moved to `SBUChannelModule.Input`. Use `pickVideoFile(info:)` of `SBUChannelModule.Input` instead.")
    public func sendVideoFileMessage(info: [UIImagePickerController.InfoKey: Any]) {
        
    }
    
    @available(*, unavailable, message: "This function has been moved to `SBUChannelModule.Input`. Use `pickDocumentFile(documentURLs:)` of `SBUChannelModule.Input` instead.")
    public func sendDocumentFileMessage(documentUrls: [URL]) {
        
    }
    
    // MARK: - Unavailable
    @available(*, unavailable, renamed: "showLoading(_:)")
    public func setLoading(_ loadingState: Bool, _ showIndicator: Bool) { showLoading(loadingState) }
    
    @available(*, unavailable, renamed: "errorHandler(_:_:)")
    public func didReceiveError(_ message: String?, _ code: NSInteger? = nil) {
        self.errorHandler(message, code)
    }
    
    @available(*, unavailable, renamed: "listComponent.didSelectMessage(userId:)")
    open func didSelectMessage(userId: String?) { }
    
    @available(*, unavailable, renamed: "listComponent.didSelectClose()")
    open func didSelectClose() { }
    
    @available(*, unavailable, renamed: "listComponent.didSelectRetry()")
    open func didSelectRetry() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUCommonViewModelDelegate`. Use `shouldUpdateLoadingState(_:)` of `SBUCommonViewModelDelegate` instead.")
    open func shouldShowLoadingIndicator() -> Bool { return true }
    
    @available(*, unavailable, message: "This function has been moved to `SBUCommonViewModelDelegate`. Use `shouldUpdateLoadingState(_:)` of `SBUCommonViewModelDelegate` instead.")
    open func shouldDismissLoadingIndicator() {}
    
    // MARK: - SBUMessageInputViewDelegate
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:didTapSend:parentMessage:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectSend text: String) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:didTapResource:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectResource type: MediaResourceType) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:didSelectEdit:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didSelectEdit text: String) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:didChangeText:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didChangeText text: String) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:willChangeMode:message:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               willChangeMode mode: SBUMessageInputMode,
                               message: BaseMessage?) {
    }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModule(_:didChangeMode:)`.")
    open func messageInputView(_ messageInputView: SBUMessageInputView,
                               didChangeMode mode: SBUMessageInputMode,
                               message: BaseMessage?) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModuleDidStartTyping(_:)`.")
    open func messageInputViewDidStartTyping() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleInputDelegate` and replaced to `baseChannelModuleDidEndTyping(_:)`.")
    open func messageInputViewDidEndTyping() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func channel(_ sender: BaseChannel, didReceive message: BaseMessage) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUOpenChannelViewModel`.")
    open func channel(_ sender: BaseChannel, didUpdate message: BaseMessage) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModel`.")
    open func channel(_ sender: BaseChannel, messageWasDeleted messageId: Int64) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channelWasChanged(_ sender: BaseChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channelWasFrozen(_ sender: BaseChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channelWasUnfrozen(_ sender: BaseChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channel(_ sender: BaseChannel, userWasMuted user: User) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channel(_ sender: BaseChannel, userWasUnmuted user: User) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channelDidUpdateOperators(_ sender: BaseChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channel(_ sender: BaseChannel, userWasBanned user: User) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channel(_ sender: OpenChannel, userDidEnter user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channel(_ sender: OpenChannel, userDidExit user: User) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelViewModelDelegate` and replaced to `baseChannelViewModel(_:didChangeChannel:withContext:)`.")
    open func channelWasDeleted(_ channelUrl: String, channelType: ChannelType) {}

}
