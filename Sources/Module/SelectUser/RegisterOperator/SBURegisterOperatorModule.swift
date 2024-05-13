//
//  SBURegisterOperatorModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: SBURegisterOperatorModule

/// This class is responsible for registering operators in the Sendbird UIKit.
extension SBURegisterOperatorModule {
    /// The module component that contains ``SBUBaseSelectUserModule/Header/titleView``, ``SBUBaseSelectUserModule/Header/leftBarButton`` and ``SBUBaseSelectUserModule/Header/rightBarButton``
    /// - Since: 3.6.0
    public static var HeaderComponent: SBURegisterOperatorModule.Header.Type = SBURegisterOperatorModule.Header.self
    /// The module component that shows the list of the operators in the channel
    /// - Since: 3.6.0
    public static var ListComponent: SBURegisterOperatorModule.List.Type = SBURegisterOperatorModule.List.self
}

// MARK: Header
extension SBURegisterOperatorModule.Header {
    
}

// MARK: List
extension SBURegisterOperatorModule.List {
    
}
