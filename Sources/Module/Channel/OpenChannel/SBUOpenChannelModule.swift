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
    
}

// MARK: List
extension SBUOpenChannelModule.List {
    
}

// MARK: Input
extension SBUOpenChannelModule.Input {
    
}

// MARK: Media
extension SBUOpenChannelModule.Media {
    
}
