//
//  SBUCreateChannelModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUCreateChannelModule

/// The class that represents the module for creating a new channel.
extension SBUCreateChannelModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUCreateChannelModule.Header.Type = SBUCreateChannelModule.Header.self
    /// The module component that shows the list of users to create a new channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUCreateChannelModule.List.Type = SBUCreateChannelModule.List.self
}

// MARK: Header
extension SBUCreateChannelModule.Header {
    
}

// MARK: List
extension SBUCreateChannelModule.List {
    
}
