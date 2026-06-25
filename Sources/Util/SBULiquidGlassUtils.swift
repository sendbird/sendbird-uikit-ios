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
        createGlassEffectView(tintColor: nil, isInteractive: isInteractive)
    }

    /// Tint-aware factory, config-gated. Internal-only overload so the public
    /// ABI surface stays the same; new tint-aware callers in the SDK route
    /// through here.
    /// - Parameters:
    ///   - tintColor: Color applied to `UIGlassEffect.tintColor`. `nil` keeps
    ///     the system default material.
    ///   - isInteractive: Whether the glass effect should be interactive.
    ///     Default is `false`.
    /// - Returns: A UIVisualEffectView with glass effect, or `nil` if Liquid
    ///   Glass is disabled, or compile-/runtime-unavailable.
    /// - Since: 3.35.4
    static func createGlassEffectView(
        tintColor: UIColor?,
        isInteractive: Bool = false
    ) -> UIVisualEffectView? {
        guard SendbirdUI.config.common.shouldApplyLiquidGlass else { return nil }

        #if compiler(>=6.2)
        guard #available(iOS 26.0, *) else { return nil }

        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = isInteractive
        if let tintColor {
            glassEffect.tintColor = tintColor
        }

        let view = UIVisualEffectView(effect: glassEffect)
        view.overrideUserInterfaceStyle = sbuThemeOverrideStyle
        return view
        #else
        return nil
        #endif
    }

    /// Resolves the `overrideUserInterfaceStyle` that should be applied to any
    /// `UIVisualEffectView` rendering `UIGlassEffect`. Without this override
    /// the system glass material follows `traitCollection.userInterfaceStyle`
    /// (OS-level appearance) and ignores `SBUTheme.colorScheme`, so a dark
    /// SBU theme on a light-mode device still renders a light glass base.
    /// - Since: 3.35.4
    private static var sbuThemeOverrideStyle: UIUserInterfaceStyle {
        SBUTheme.colorScheme == .dark ? .dark : .light
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
        glassEffectView.overrideUserInterfaceStyle = sbuThemeOverrideStyle

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
