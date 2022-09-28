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
    // MARK: Properties (Public)
    public var headerComponent: SBURegisterOperatorModule.Header? {
        get { _headerComponent ?? SBURegisterOperatorModule.Header() }
        set { _headerComponent = newValue }
    }
    public var listComponent: SBURegisterOperatorModule.List? {
        get { _listComponent ?? SBURegisterOperatorModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBURegisterOperatorModule.Header?
    private var _listComponent: SBURegisterOperatorModule.List?
    
    
    // MARK: -
    public init(headerComponent: SBURegisterOperatorModule.Header? = nil,
                listComponent: SBURegisterOperatorModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

