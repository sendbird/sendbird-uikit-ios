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
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUInviteUserModule.Header.Type = SBUInviteUserModule.Header.self
    /// The module component that shows the list of the user to invite to the channel
    /// - Since: 3.6.0
    public static var ListComponent: SBUInviteUserModule.List.Type = SBUInviteUserModule.List.self
    
    // MARK: Properties (Public)
    @available(*, deprecated, message: "Use `SBUInviteUserModule.HeaderComponent` instead.")
    public var headerComponent: SBUInviteUserModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    @available(*, deprecated, message: "Use `SBUInviteUserModule.ListComponent` instead.")
    public var listComponent: SBUInviteUserModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUInviteUserModule.Header?
    private var _listComponent: SBUInviteUserModule.List?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.InviteUserModule")
    public required init(headerComponent: SBUInviteUserModule.Header? = nil,
                listComponent: SBUInviteUserModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
