//
//  LiquidGlassAppearanceCustomManager.swift
//  SendbirdUIKit-Sample
//
//  Created by Celine Moon on 2026/08/25.
//  Copyright © 2026 SendBird, Inc. All rights reserved.
//

import UIKit

/// Two ways to keep the Liquid Glass chrome in sync with light/dark. Which one
/// fits depends on how the app supplies its theme colors.
///
/// | The app themes SendbirdUIKit with | Use |
/// | --- | --- |
/// | static colors, one per color scheme | ``applyStaticColorTheme(isDark:visibleViewController:)`` |
/// | trait-based dynamic `UIColor`s | ``applyDynamicColorTheme()`` |
///
/// Nothing here runs by default. Call one of the two entry points from your own
/// app code.
class LiquidGlassAppearanceCustomManager: NSObject {

    // MARK: - Case 1. Static colors

    /// Keeps the glass in sync when the app themes SendbirdUIKit with static
    /// colors — one color per color scheme.
    ///
    /// `SBUTheme.liquidGlassAppearance` stays at its default `.theme`, so the
    /// glass follows `SBUTheme.colorScheme`. The app owns the sync and has to
    /// call this on every appearance change.
    ///
    /// Wire it up from the container that hosts the Sendbird screens:
    ///
    /// ```swift
    /// registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _) in
    ///     LiquidGlassAppearanceCustomManager.applyStaticColorTheme(
    ///         isDark: self.traitCollection.userInterfaceStyle == .dark,
    ///         visibleViewController: self.visibleSendbirdViewController
    ///     )
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - isDark: Whether the app should render in dark.
    ///   - visibleViewController: The Sendbird screen currently on display, if any.
    static func applyStaticColorTheme(
        isDark: Bool,
        visibleViewController: SBUBaseViewController? = nil
    ) {
        // 1. Set the color scheme first.
        //    This resets every component theme to the SDK defaults, so the app's
        //    own colors have to be re-applied after it, never before.
        SBUTheme.set(colorScheme: isDark ? .dark : .light)

        // 2. Re-apply the app's colors. One concrete color per scheme.
        let navigationBarGradientTint = isDark
            ? UIColor(hex: "#2A1F4D")
            : UIColor(hex: "#EDE7FF")

        SBUTheme.groupChannelListTheme.navigationBarGradientTint = navigationBarGradientTint
        SBUTheme.openChannelListTheme.navigationBarGradientTint = navigationBarGradientTint
        SBUTheme.channelTheme.navigationBarGradientTint = navigationBarGradientTint

        // 3. Restyle the screen that is already on display.
        //    The navigation bar picks the change up on the next layout pass on its
        //    own, because `setupStyles()` runs there. Message cells, the header and
        //    the input view only repaint when `updateStyles()` runs.
        visibleViewController?.updateStyles()
    }

    // MARK: - Case 2. Dynamic colors

    /// Keeps the glass in sync when the app themes SendbirdUIKit with trait-based
    /// dynamic `UIColor`s.
    ///
    /// Call this once at launch. There is nothing to do afterwards — no appearance
    /// observer, no `SBUTheme.set(colorScheme:)`, no `updateStyles()`. UIKit
    /// re-resolves a dynamic `UIColor` when the device appearance changes, and
    /// `.system` lets the glass follow the device the same way.
    ///
    /// - NOTE: A later `SBUTheme.set(theme:)` or `SBUTheme.set(colorScheme:)` call
    /// replaces every component theme with the SDK defaults, which drops the colors
    /// assigned below. Re-apply them if the app calls either one.
    static func applyDynamicColorTheme() {
        // 1. Let Liquid Glass follow the device instead of `SBUTheme.colorScheme`.
        if #available(iOS 26.0, *) {
            SBUTheme.liquidGlassAppearance = .system
        }

        // 2. Hand the SDK dynamic colors. UIKit resolves them per appearance.
        let navigationBarGradientTint = UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? UIColor(hex: "#2A1F4D")
            : UIColor(hex: "#EDE7FF")
        }

        SBUTheme.groupChannelListTheme.navigationBarGradientTint = navigationBarGradientTint
        SBUTheme.openChannelListTheme.navigationBarGradientTint = navigationBarGradientTint
        SBUTheme.channelTheme.navigationBarGradientTint = navigationBarGradientTint
    }
}
