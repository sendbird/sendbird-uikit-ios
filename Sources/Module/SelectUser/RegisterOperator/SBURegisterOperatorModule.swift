//
//  SBURegisterOperatorModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBURegisterOperatorModule

open class SBURegisterOperatorModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBURegisterOperatorModule.Header.Type = SBURegisterOperatorModule.Header.self
    /// The module component that shows the list of the operators in the channel
    /// - Since: 3.6.0
    public static var ListComponent: SBURegisterOperatorModule.List.Type = SBURegisterOperatorModule.List.self
    
    // MARK: Properties (Public)
    @available(*, deprecated, message: "Use `SBURegisterOperatorModule.HeaderComponent` instead.")
    public var headerComponent: SBURegisterOperatorModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set { _headerComponent = newValue }
    }
    @available(*, deprecated, message: "Use `SBURegisterOperatorModule.ListComponent` instead.")
    public var listComponent: SBURegisterOperatorModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBURegisterOperatorModule.Header?
    private var _listComponent: SBURegisterOperatorModule.List?
    
    // MARK: -
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupRegisterOperatorModule` or `SBUModuleSet.OpenRegisterOperatorModule`")
    public required init(headerComponent: SBURegisterOperatorModule.Header? = nil,
                listComponent: SBURegisterOperatorModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}
