//
//  UIBarButtonItem+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2/4/26.
//

import UIKit

extension UIBarButtonItem {
    /// Checks if `UIBarButtonItem` is created via `.init()` with no content.
    /// - Since: 3.34.0
    var isEmpty: Bool {
        return image == nil && title == nil && customView == nil
    }
}
