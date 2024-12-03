//
//  SBUCreateOpenChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUCreateOpenChannelModul

/// The class that represents the module for creating a new open channel.
extension SBUCreateOpenChannelModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton``, and ``SBUBaseSelectUserModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUCreateOpenChannelModule.Header.Type = SBUCreateOpenChannelModule.Header.self
    /// The module component that shows the body to create a new channel.
    /// - Since: 3.6.0
    public static var ProfileInputComponent: SBUCreateOpenChannelModule.ProfileInput.Type = SBUCreateOpenChannelModule.ProfileInput.self
}

// MARK: Header
extension SBUCreateOpenChannelModule.Header {
    /// Represents the metatype of left bar button in ``SBUCreateOpenChannelModule.Header``.
    /// - Since: 3.28.0
    public static var LeftBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
    
    /// Represents the metatype of title view in ``SBUCreateOpenChannelModule.Header``.
    /// - Since: 3.28.0
    public static var TitleView: SBUNavigationTitleView.Type = SBUNavigationTitleView.self
    
    /// Represents the metatype of right bar button in ``SBUCreateOpenChannelModule.Header``.
    /// - Since: 3.28.0
    public static var RightBarButton: SBUBarButtonItem.Type = SBUBarButtonItem.self
}

// MARK: List
extension SBUCreateOpenChannelModule.ProfileInput {
    /// The view that displays the channel image in Create channel.
    /// - Since: 3.28.0
    public static var ChannelImageView: SBUCoverImageView.Type = SBUCoverImageView.self
    
    /// The view that displays the channel name inputField in Create channel.
    /// - Since: 3.28.0
    public static var ChannelNameInputField: SBUUnderLineTextField.Type = SBUUnderLineTextField.self
}
