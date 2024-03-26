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
open class SBUInviteUserModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBUInviteUserModule.Header.Type = SBUInviteUserModule.Header.self
    /// The module component that shows the list of the user to invite to the channel
    /// - Since: 3.6.0
    public static var ListComponent: SBUInviteUserModule.List.Type = SBUInviteUserModule.List.self
    
    // MARK: Properties (Public)
    // swiftlint:disable missing_docs

    @available(*, deprecated, message: "Use `SBUInviteUserModule.HeaderComponent` instead.")
    public var headerComponent: SBUInviteUserModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    @available(*, deprecated, message: "Use `SBUInviteUserModule.ListComponent` instead.")
    public var listComponent: SBUInviteUserModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUInviteUserModule.Header?
    private var _listComponent: SBUInviteUserModule.List?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.InviteUserModule")
    public required init(
        headerComponent: SBUInviteUserModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.InviteUserModule")
    public required init(
        listComponent: SBUInviteUserModule.List?
    ) {
        self.listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.InviteUserModule")
    public required init(
        headerComponent: SBUInviteUserModule.Header?,
        listComponent: SBUInviteUserModule.List?
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
