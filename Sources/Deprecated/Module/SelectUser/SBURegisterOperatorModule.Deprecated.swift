//
//  SBURegisterOperatorModule.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/2/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

/// This class is responsible for registering operators in the Sendbird UIKit.
open class SBURegisterOperatorModule {
    // MARK: Properties (Public)
    // swiftlint:disable missing_docs
    @available(*, deprecated, message: "Use `SBURegisterOperatorModule.HeaderComponent` instead.")
    public var headerComponent: SBURegisterOperatorModule.Header? {
        get { _headerComponent ?? Self.HeaderComponent.init() }
        set {
            _headerComponent = newValue
            if let validNewValue = newValue {
                Self.HeaderComponent = type(of: validNewValue)
            }
        }
    }
    @available(*, deprecated, message: "Use `SBURegisterOperatorModule.ListComponent` instead.")
    public var listComponent: SBURegisterOperatorModule.List? {
        get { _listComponent ?? Self.ListComponent.init() }
        set {
            _listComponent = newValue
            if let validNewValue = newValue {
                Self.ListComponent = type(of: validNewValue)
            }
        }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBURegisterOperatorModule.Header?
    private var _listComponent: SBURegisterOperatorModule.List?
    
    // MARK: -
    /// Default initializer
    public required init() {}
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupRegisterOperatorModule` or `SBUModuleSet.OpenRegisterOperatorModule`")
    public required init(
        headerComponent: SBURegisterOperatorModule.Header?
    ) {
        self.headerComponent = headerComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupRegisterOperatorModule` or `SBUModuleSet.OpenRegisterOperatorModule`")
    public required init(
        listComponent: SBURegisterOperatorModule.List?
    ) {
        self.listComponent = listComponent
    }
    
    @available(*, deprecated, message: "Use `SBUModuleSet.GroupRegisterOperatorModule` or `SBUModuleSet.OpenRegisterOperatorModule`")
    public required init(
        headerComponent: SBURegisterOperatorModule.Header?,
        listComponent: SBURegisterOperatorModule.List?
    ) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
    // swiftlint:enable missing_docs
}
