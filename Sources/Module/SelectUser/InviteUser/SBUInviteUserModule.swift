//
//  SBUInviteUserModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUInviteUserModule

open class SBUInviteUserModule {
    // MARK: Properties (Public)
    public var headerComponent: SBUInviteUserModule.Header? {
        get { _headerComponent ?? SBUInviteUserModule.Header() }
        set { _headerComponent = newValue }
    }
    public var listComponent: SBUInviteUserModule.List? {
        get { _listComponent ?? SBUInviteUserModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUInviteUserModule.Header?
    private var _listComponent: SBUInviteUserModule.List?
    
    
    // MARK: -
    public init(headerComponent: SBUInviteUserModule.Header? = nil,
                listComponent: SBUInviteUserModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
