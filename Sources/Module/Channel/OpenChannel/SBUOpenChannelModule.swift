//
//  SBUOpenChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUOpenChannelModule

/// The class that represents the open channel module
extension SBUOpenChannelModule {
    /// The module component that contains ``SBUBaseChannelModule/Header/titleView``, ``SBUBaseChannelModule/Header/leftBarButton``, and ``SBUBaseChannelModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUOpenChannelModule.Header.Type = SBUOpenChannelModule.Header.self
    /// The module component that shows the list of message in the open channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUOpenChannelModule.List.Type = SBUOpenChannelModule.List.self
    /// The module component that contains `messageInputView`.
    /// - Since: 3.6.0
    public static var InputComponent: SBUOpenChannelModule.Input.Type = SBUOpenChannelModule.Input.self
    /// The module component that represents the media in the open channel such as photo or video.
    /// - Since: 3.6.0
    public static var MediaComponent: SBUOpenChannelModule.Media.Type = SBUOpenChannelModule.Media.self
}

// MARK: Header
extension SBUOpenChannelModule.Header {
    /// Represents the type of left bar button on the open channel module.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of right bar button on the open channel module.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the type of title view on the open channel module.
    /// - Since: 3.28.0
    public static var TitleView: SBUChannelTitleView.Type = SBUChannelTitleView.self
}

// MARK: List
extension SBUOpenChannelModule.List {
    /// Represents the type of empty view on the open channel module.
    /// - Since: 3.28.0
    public static var EmptyView: SBUEmptyView.Type = SBUEmptyView.self
    
    /// Represents the type of admin message cell on the open channel module.
    /// - Since: 3.28.0
    public static var AdminMessageCell: SBUOpenChannelBaseMessageCell.Type = SBUOpenChannelAdminMessageCell.self
    
    /// Represents the type of user message cell on the open channel module.
    /// - Since: 3.28.0
    public static var UserMessageCell: SBUOpenChannelBaseMessageCell.Type = SBUOpenChannelUserMessageCell.self
    
    /// Represents the type of file message cell on the open channel module.
    /// - Since: 3.28.0
    public static var FileMessageCell: SBUOpenChannelBaseMessageCell.Type = SBUOpenChannelFileMessageCell.self
    
    /// Represents the type of unknown message cell on the open channel module.
    /// - Since: 3.28.0
    public static var UnknownMessageCell: SBUOpenChannelBaseMessageCell.Type = SBUOpenChannelUnknownMessageCell.self
    
    /// Represents the type of custom message cell on the open channel module.
    /// - Since: 3.28.0
    public static var CustomMessageCell: SBUOpenChannelBaseMessageCell.Type?
    
    /// Represents the type of channel state banner on the open channel module.
    /// - Since: 3.28.0
    public static var ChannelStateBanner: SBUChannelStateBanner.Type = SBUChannelStateBanner.self
    
    /// Represents the type of scroll bottom view on the open channel module.
    /// - Since: 3.28.0
    public static var ScrollBottomView: SBUScrollBottomView.Type = SBUScrollBottomView.self
    
    /// Represents the type of user profile view on the open channel module.
    /// - Since: 3.28.0
    public static var UserProfileView: SBUUserProfileView.Type = SBUUserProfileView.self
}

// MARK: Input
extension SBUOpenChannelModule.Input {
    /// The component property that the message input view.
    /// - Since: 3.28.0
    public static var MessageInputView: SBUMessageInputView.Type = SBUMessageInputView.self
}

// MARK: Media
extension SBUOpenChannelModule.Media {
    /// A view to shows media or other contents in the open channel.
    /// - Since: 3.28.0
    public static var MediaView: SBUMediaView.Type = SBUMediaView.self
    
}
