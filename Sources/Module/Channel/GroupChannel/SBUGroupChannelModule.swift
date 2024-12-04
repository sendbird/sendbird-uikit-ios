//
//  SBUGroupChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUGroupChannelModule

/// The class that represents the group channel module
extension SBUGroupChannelModule {
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUGroupChannelModule.Header.Type = SBUGroupChannelModule.Header.self
    /// The module component that shows the list of message in the group channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUGroupChannelModule.List.Type = SBUGroupChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUGroupChannelModule.Input.Type = SBUGroupChannelModule.Input.self
}

// MARK: Header
extension SBUGroupChannelModule.Header {
    /// Represents the type of left bar button on the group channel module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the group channel module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the group channel module.
    /// - Since: 3.28.0
    public static var TitleView: SBUChannelTitleView.Type = SBUChannelTitleView.self
}

// MARK: List
extension SBUGroupChannelModule.List {
    /// Represents the type of empty view on the group channel module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of admin message cell on the group channel module.
    /// - Since: 3.28.0
    public static var AdminMessageCell: SBUBaseMessageCell.Type = SBUAdminMessageCell.self
    
    /// Represents the type of user message cell on the group channel module.
    /// - Since: 3.28.0
    public static var UserMessageCell: SBUBaseMessageCell.Type = SBUUserMessageCell.self
    
    /// Represents the type of file message cell on the group channel module.
    /// - Since: 3.28.0
    public static var FileMessageCell: SBUBaseMessageCell.Type = SBUFileMessageCell.self
    
    /// Represents the type of multiple files message cell on the group channel module.
    /// - Since: 3.28.0
    public static var MultipleFilesMessageCell: SBUBaseMessageCell.Type = SBUMultipleFilesMessageCell.self
    
    /// Represents the type of typing indicator cell on the group channel module.
    /// - Since: 3.28.0
    public static var TypingIndicatorMessageCell: SBUBaseMessageCell.Type = SBUTypingIndicatorMessageCell.self
    
    /// Represents the type of unknown cell on the group channel module.
    /// - Since: 3.28.0
    public static var UnknownMessageCell: SBUBaseMessageCell.Type = SBUUnknownMessageCell.self
    
    /// Represents the type of custom cell on the group channel module.
    /// - Since: 3.28.0
    public static var CustomMessageCell: SBUBaseMessageCell.Type?
    
    /// Represents the type of channel state banner view on the group channel module.
    /// - Since: 3.28.0
    public static var ChannelStateBanner: SBUChannelStateBanner.Type = SBUChannelStateBanner.self
    
    /// Represents the type of scroll bottom view on the group channel module.
    /// - Since: 3.28.0
    public static var ScrollBottomView: SBUScrollBottomView.Type = SBUScrollBottomView.self
    
    /// Represents the type of message info view on the group channel module.
    /// - Since: 3.28.0
    public static var NewMessageInfo: SBUNewMessageInfo.Type = SBUNewMessageInfo.self
    
    /// Represents the type of profile view on the group channel module.
    /// - Since: 3.28.0
    public static var UserProfileView: SBUUserProfileView.Type = SBUUserProfileView.self
}

// MARK: Input
extension SBUGroupChannelModule.Input {
    /// The component property that the message input view.
    /// - Since: 3.28.0
    public static var MessageInputView: SBUMessageInputView.Type = SBUMessageInputView.self
    
    /// The component property that the voice message input view.
    /// - Since: 3.28.0
    public static var VoiceMessageInputView: SBUVoiceMessageInputView.Type = SBUVoiceMessageInputView.self
}
