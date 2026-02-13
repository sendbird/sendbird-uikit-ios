//
//  UIVisualEffectView+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 1/20/26.
//

import UIKit

// MARK: - Liquid Glass

extension UIVisualEffectView {

    /// Applies layout properties for liquid glass style.
    /// - Parameters:
    ///   - frame: The frame to set.
    ///   - autoresizingMask: The autoresizing mask to set.
    /// - Since: 3.34.0
    func setupLayouts(
        frame: CGRect?,
        autoresizingMask: UIView.AutoresizingMask?
    ) {
        if let frame = frame {
            self.frame = frame
        }
        if let autoresizingMask = autoresizingMask {
            self.autoresizingMask = autoresizingMask
        }
    }

    /// Applies style properties for liquid glass style.
    /// - Parameters:
    ///   - cornerRadius: The corner radius to apply.
    ///   - cornerCurve: The corner curve style.
    /// - Since: 3.34.0
    func setupStyles(
        cornerRadius: CGFloat?,
        cornerCurve: CALayerCornerCurve?,
        clipsToBounds: Bool?
    ) {
        if let cornerRadius {
            self.layer.cornerRadius = cornerRadius
        }
        if let cornerCurve {
            self.layer.cornerCurve = cornerCurve
        }
        if let clipsToBounds {
            self.clipsToBounds = clipsToBounds
        }
    }
}
