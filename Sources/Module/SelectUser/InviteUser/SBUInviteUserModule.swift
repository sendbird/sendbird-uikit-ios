//
//  SBUInviteUserModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUInviteUserModule

/// The class that represents the invite user module.
extension SBUInviteUserModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUInviteUserModule.Header.Type = SBUInviteUserModule.Header.self
    /// The module component that shows the list of the user to invite to the channel
    /// - Since: 3.6.0
    public static var ListComponent: SBUInviteUserModule.List.Type = SBUInviteUserModule.List.self
}

// MARK: Header
extension SBUInviteUserModule.Header {
    
}

// MARK: List
extension SBUInviteUserModule.List {
    
}
