//
//  SBULiquidGlassUtils.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 1/20/26.
//

import UIKit

/// Utility for creating liquid glass effect views (iOS 26+)
/// - Since: 3.34.0
public enum SBULiquidGlassUtils {

    /// Creates a UIVisualEffectView with glass effect for iOS 26+
    /// - Parameter isInteractive: Whether the glass effect should be interactive. Default is `false`.
    /// - Returns: A UIVisualEffectView with glass effect, or `nil` if not available or not in liquid glass mode.
    public static func createGlassEffectView(
        isInteractive: Bool = false
    ) -> UIVisualEffectView? {
        guard SendbirdUI.config.common.shouldApplyLiquidGlass else { return nil }

        #if compiler(>=6.2)
        guard #available(iOS 26.0, *) else { return nil }

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = isInteractive

        return UIVisualEffectView(effect: glassEffect)
        #else
        return nil
        #endif
    }
    
    /// Util function that creates a glass effect view, and also sets up layout and style. 
    public static func createAndSetupGlassEffectView(
        isInteractive: Bool = false,
        // layout
        frame: CGRect?,
        autoresizingMask: UIView.AutoresizingMask?,
        // style
        cornerRadius: CGFloat?,
        cornerCurve: CALayerCornerCurve?,
        clipsToBounds: Bool?
    ) -> UIVisualEffectView? {
        guard SendbirdUI.config.common.shouldApplyLiquidGlass else { return nil }

        #if compiler(>=6.2)
        guard #available(iOS 26.0, *) else { return nil }

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = isInteractive

        let glassEffectView = UIVisualEffectView(effect: glassEffect)
        
        // layout
        glassEffectView.setupLayouts(
            frame: frame,
            autoresizingMask: autoresizingMask
        )
        
        // style
        glassEffectView.setupStyles(
            cornerRadius: cornerRadius,
            cornerCurve: cornerCurve,
            clipsToBounds: clipsToBounds
        )
        
        return glassEffectView
        
        #else
        return nil
        #endif
    }
}
