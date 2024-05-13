//
//  SBUMessageSearchModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUMessageSearchModule

/// The class that represents the message search module.
extension SBUMessageSearchModule {
    /// The module component that contains ``SBUMessageSearchModule/Header/titleView``, ``SBUMessageSearchModule/Header/leftBarButton``, and ``SBUMessageSearchModule/Header/rightBarButton``.
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUMessageSearchModule.Header.Type = SBUMessageSearchModule.Header.self
    /// The module component that shows the list of searched message in the channel.
    /// - Since: 3.6.0
    public static var ListComponent: SBUMessageSearchModule.List.Type = SBUMessageSearchModule.List.self
}

// MARK: Header
extension SBUMessageSearchModule.Header {
    
}

// MARK: List
extension SBUMessageSearchModule.List {
    
}
