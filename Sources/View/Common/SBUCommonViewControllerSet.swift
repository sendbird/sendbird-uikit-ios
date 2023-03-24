//
//  SBUCommonViewControllerSet.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2023/03/21.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The set of the supported view controllers that are commonly used in ``SendbirdUIKit``
/// - Since: 3.5.2
public class SBUCommonViewControllerSet {
    /// The type of file view controller that overrides ``SBUFileViewController``.
    /// ```swift
    /// SBUCommonViewControllerSet.FileViewController = MyAppFileViewController.self
    /// ```
    /// - Since: 3.5.2
    public static var FileViewController: SBUFileViewController.Type = SBUFileViewController.self
    
    // TODO:
    static var MenuSheetViewController: SBUMenuSheetViewController.Type = SBUMenuSheetViewController.self
}
