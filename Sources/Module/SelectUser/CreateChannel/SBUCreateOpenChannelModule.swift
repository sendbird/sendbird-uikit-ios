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
    
}

// MARK: List
extension SBUCreateOpenChannelModule.ProfileInput {
    
}
