//
//  SBUPromoteMemberModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBUPromoteMemberModule

public class SBUPromoteMemberModule {
    // MARK: Properties (Public)
    public var headerComponent: SBUPromoteMemberModule.Header? {
        get { _headerComponent ?? SBUPromoteMemberModule.Header() }
        set { _headerComponent = newValue }
    }
    public var listComponent: SBUPromoteMemberModule.List? {
        get { _listComponent ?? SBUPromoteMemberModule.List() }
        set { _listComponent = newValue }
    }
    
    // MARK: Properties (Holder)
    private var _headerComponent: SBUPromoteMemberModule.Header?
    private var _listComponent: SBUPromoteMemberModule.List?
    
    
    // MARK: -
    public init(headerComponent: SBUPromoteMemberModule.Header? = nil,
                listComponent: SBUPromoteMemberModule.List? = nil) {
        self.headerComponent = headerComponent
        self.listComponent = listComponent
    }
}

