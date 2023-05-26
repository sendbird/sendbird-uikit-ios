//
//  UINavigationController+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        topViewController?.preferredStatusBarStyle ?? .default
    }
    
    /// Set up navigation bar with tint color. This method sets up `standardAppearance` and `scrollEdgeAppearance` with the tint color.
    /// - Parameter tintColor: `UIColor` value. It's recommended that you use `SBUTheme navigationBarTintColor`.
    /// - Parameter shadowColor: `UIColor` value. It's recommended that you use `SBUTheme navigationBarShadowColor`.
    /// - Since: 2.1.14
    @objc
    open func sbu_setupNavigationBarAppearance(tintColor: UIColor, shadowColor: UIColor? = nil) {
        guard #available(iOS 13.0, *) else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = tintColor
        if let shadowColor = shadowColor {
            appearance.shadowImage = UIImage.from(
                color: shadowColor
            )
        }
        self.navigationBar.standardAppearance = appearance
        self.navigationBar.scrollEdgeAppearance = appearance
    }
}
