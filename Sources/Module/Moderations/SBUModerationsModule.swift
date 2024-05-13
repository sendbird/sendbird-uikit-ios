//
//  SBUModerationsModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/04.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUModerationsModule

/// The class that represents the moderation module.
extension SBUModerationsModule {
    /// The module component that contains ``SBUModerationsModule/Header/titleView``, ``SBUModerationsModule/Header/leftBarButton``, and ``SBUModerationsModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUModerationsModule.Header.Type = SBUModerationsModule.Header.self
    /// The module component that shows the list of moderation items in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUModerationsModule.List.Type = SBUModerationsModule.List.self
}

// MARK: Header
extension SBUModerationsModule.Header {
    
}

// MARK: List
extension SBUModerationsModule.List {
    
}
