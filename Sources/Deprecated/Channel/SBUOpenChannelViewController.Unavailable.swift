//
//  SBUOpenChannelViewController.Unavailable.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/19.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUOpenChannelViewController {
    // MARK: 3.0.0    
    @available(*, unavailable, message: "This function has been moved to `SBUOpenChannelModule.List` and replaced to `setMessageCellGestures(_:)`.")
    open func setUserMessageCellGestures(_ cell: SBUOpenChannelUserMessageCell,
                                         userMessage: UserMessage,
                                         indexPath: IndexPath) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUOpenChannelModule.List` and replaced to `setMessageCellGestures(_:)`.")
    open func setFileMessageCellGestures(_ cell: SBUOpenChannelFileMessageCell,
                                         fileMessage: FileMessage,
                                         indexPath: IndexPath) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUOpenChannelModule.List` and replaced to `setMessageCellGestures(_:)`.")
    open func setUnkownMessageCellGestures(_ cell: SBUOpenChannelUnknownMessageCell,
                                           unknownMessage: BaseMessage,
                                           indexPath: IndexPath) { }
    
    @available(*, unavailable, renamed: "updateMessageListRatio(to:)")
    public func updateRatio(mediaView: CGFloat?, messageList: CGFloat?) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleHeaderDelegate` and replaced to `channelModule(_:didTapRightItem:)`.")
    open func didSelectChannelInfo() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleHeaderDelegate` and replaced to `openChannelModuleDidTapParticipantList(_:)`.")
    open func didSelectChannelParticipants() { }
    
    /// This function shows channel settings.
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModule.Header` and replaced to `didSelectChannelParticipants()`.")
    @objc
    public func onClickParticipantsList() { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUBaseChannelModuleListDelegate` and replaced to `baseChannelModuleDidTapScrollToButton(_:animated:)`")
    @objc
    open func onClickScrollBottom(sender: UIButton?) { }
    
    @available(*, unavailable, message: "This function has been moved to `SBUOpenChannelModule.List` and replaced to `scrollViewDidSScroll(_:)`.")
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
