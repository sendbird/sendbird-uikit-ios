//
//  SBUGroupChannelViewController.Unavailable.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUGroupChannelViewController {
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleListDelegate` and replaced to  `baseChannelModuleDidTapScrollToButton(_:animated:).`")
    @objc open func onClickScrollBottom(sender: UIButton?) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelModule.List`.")
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelViewModelDelegate` and replaced to  `baseChannelViewModel(_:didChangeChannel:withContext:)`")
    open func channel(_ sender: BaseChannel, updatedReaction reactionEvent: ReactionEvent) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelViewModelDelegate` and replaced to  `baseChannelViewModel(_:didChangeChannel:withContext:)`")
    open func channelDidUpdateReadReceipt(_ sender: GroupChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelViewModelDelegate` and replaced to  `baseChannelViewModel(_:didChangeChannel:withContext:)`")
    open func channelDidUpdateDeliveryReceipt(_ sender: GroupChannel) {}
    
    @available(*, unavailable, message: "This function has been moved to `SBUGroupChannelViewModelDelegate` and replaced to  `baseChannelViewModel(_:didChangeChannel:withContext:)`")
    open func channelDidUpdateTypingStatus(_ sender: GroupChannel) {}
    
    // MARK: - ~2.2.0
    @available(*, unavailable, message: "deprecated in 1.2.10")
    public var preSendMessages: [String: BaseMessage] { [:] }
    
    @available(*, unavailable, message: "deprecated in 1.2.10")
    public var resendableMessages: [String: BaseMessage] { [:] }
    
    @available(*, unavailable, message: "deprecated in 1.2.10")
    public var preSendFileData: [String: [String: AnyObject]] { [:] } // Key: requestId
    
    @available(*, unavailable, message: "deprecated in 1.2.10")
    public var resendableFileData: [String: [String: AnyObject]] { [:] } // Key: requestId
    
    @available(*, unavailable, message: "deprecated in 1.2.10")
    public var fileTransferProgress: [String: CGFloat] { [:] } // Key: requestId, If have value, file message status is sending
    
    @available(*, unavailable, message: "deprecated in 1.2.2", renamed: "setEmojiTapGestureHandler(_:emojiKey:)")
    open func setTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
    }
    
    @available(*, unavailable, message: "deprecated in 1.2.2", renamed: "setEmojiLongTapGestureHandler(_:emojiKey:)")
    open func setLongTapEmojiGestureHandler(_ cell: SBUBaseMessageCell, emojiKey: String) {
    }
}
