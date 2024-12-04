//
//  SBUMessageThreadModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMessageThreadModule

/// The class that represents the message thread module.
extension SBUMessageThreadModule {
    // MARK: Properties (Public)
    /// The module component that contains ``SBUBaseChannelModule/Header/title``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageThreadModule.Header.Type = SBUMessageThreadModule.Header.self
    /// The module component that shows the list of thread message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageThreadModule.List.Type = SBUMessageThreadModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUMessageThreadModule.Input.Type = SBUMessageThreadModule.Input.self
}

// MARK: Header
extension SBUMessageThreadModule.Header {
    /// Represents the type of left bar button on the group channel module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the group channel module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the group channel module.
    /// - Since: 3.28.0
    public static var TitleView: SBUMessageThreadTitleView.Type = SBUMessageThreadTitleView.self
}

// MARK: List
extension SBUMessageThreadModule.List {
    /// Represents the type of empty view on the message thread module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self

    /// Represents the type of admin message cell on the message thread module.
    /// - Since: 3.28.0
    public static var AdminMessageCell: SBUBaseMessageCell.Type = SBUAdminMessageCell.self
    
    /// Represents the type of user message cell on the message thread module.
    /// - Since: 3.28.0
    public static var UserMessageCell: SBUBaseMessageCell.Type = SBUUserMessageCell.self
    
    /// Represents the type of file message cell on the message thread module.
    /// - Since: 3.28.0
    public static var FileMessageCell: SBUBaseMessageCell.Type = SBUFileMessageCell.self
    
    /// Represents the type of multiple files message cell on the message thread module.
    /// - Since: 3.28.0
    public static var MultipleFilesMessageCell: SBUBaseMessageCell.Type = SBUMultipleFilesMessageCell.self
    
    /// Represents the type of unknown message cell on the message thread module.
    /// - Since: 3.28.0
    public static var UnknownMessageCell: SBUBaseMessageCell.Type = SBUUnknownMessageCell.self
    
    /// Represents the type of custom message cell on the message thread module.
    /// - Since: 3.28.0
    public static var CustomMessageCell: SBUBaseMessageCell.Type?
    
    /// Represents the type of channel state banner on the message thread module.
    /// - Since: 3.28.0
    public static var ChannelStateBanner: SBUChannelStateBanner.Type = SBUChannelStateBanner.self
    
    /// Represents the type of user profile view on the message thread module.
    /// - Since: 3.28.0
    public static var UserProfileView: SBUUserProfileView.Type = SBUUserProfileView.self
    
    /// Represents the type of parent messag info view on the message thread module.
    /// - Since: 3.28.0
    public static var ParentMessageInfoView: SBUParentMessageInfoView.Type = SBUParentMessageInfoView.self
}

// MARK: Input
extension SBUMessageThreadModule.Input {
    /// The component property that the message input view.
    /// - Since: 3.28.0
    public static var MessageInputView: SBUMessageInputView.Type = SBUMessageInputView.self
    
    /// The component property that the voice message input view.
    /// - Since: 3.28.0
    public static var VoiceMessageInputView: SBUVoiceMessageInputView.Type = SBUVoiceMessageInputView.self
}
