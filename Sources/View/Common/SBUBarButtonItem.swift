//
//  SBUBarButtonItem.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A class that displays an bar button item in SendbirdUIKit.
/// - Since: 3.28.0
open class SBUBarButtonItem: UIBarButtonItem {
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.disableLiquidGlassIfNeeded()
    }

    required public override init() {
        super.init()
        self.disableLiquidGlassIfNeeded()
    }

    static func backButton(target: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: target,
            action: selector
        )
    }
    
    static func emptyButton(target: Any, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(with: .clear, to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: target,
            action: selector
        )
    }
}

extension UIBarButtonItem {
    /// Hides the shared liquid glass background when liquid glass is disabled.
    /// - Since: 3.34.0
    func disableLiquidGlassIfNeeded() {
        guard !SendbirdUI.config.common.shouldApplyLiquidGlass else { return }
        #if compiler(>=6.2)
        if #available(iOS 26.0, *) {
            self.hidesSharedBackground = true
        }
        #endif
    }
}

extension Array where Element == UIBarButtonItem {
    /// Hides the shared liquid glass background on all items when liquid glass is disabled.
    /// - Since: 3.34.0
    func disableLiquidGlassIfNeeded() {
        self.forEach { $0.disableLiquidGlassIfNeeded() }
    }
}
