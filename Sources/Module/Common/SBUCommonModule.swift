//
//  SBUCommonModule.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 5/9/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation

// MARK: SBUCommonModule
/// The class that represents the common module
open class SBUCommonModule {
    /// The module component for the toast view. The default is ``SBUToastView`` type.
    /// ```swift
    /// SBUModuleSet.CommonModule.ToastView = SBUToastView.self
    /// ```
    /// - Since: 3.28.0
    public static var ToastView: SBUToastView.Type = SBUToastView.self {
        didSet { SBUModuleSet.CommonModule.ToastView.resetInstance() }
    }

    /// The module component for the actionSheet. The default is ``SBUActionSheet`` type.
    /// ```swift
    /// SBUModuleSet.CommonModule.ActionSheet = SBUActionSheet.self
    /// ```
    /// - Since: 3.28.0
    public static var ActionSheet: SBUActionSheet.Type = SBUActionSheet.self {
        didSet { SBUModuleSet.CommonModule.ActionSheet.resetInstance() }
    }
    
    /// The module component for the alert view. The default is ``SBUAlertView`` type.
    /// ```swift
    /// SBUModuleSet.CommonModule.AlertView = SBUAlertView.self
    /// ```
    /// - Since: 3.28.0
    public static var AlertView: SBUAlertView.Type = SBUAlertView.self {
        didSet { SBUModuleSet.CommonModule.AlertView.resetInstance() }
    }

    /// The module component for th loading indicator. The default is ``SBULoading`` type.
    /// ```swift
    /// SBUModuleSet.CommonModule.Loading = SBULoading.self
    /// ```
    /// - Since: 3.28.0
    public static var Loading: SBULoading.Type = SBULoading.self {
        didSet { SBUModuleSet.CommonModule.Loading.resetInstance() }
    }
}
