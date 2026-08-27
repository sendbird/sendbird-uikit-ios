//
//  UINavigationController+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/04/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import SwiftUI

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
    
    #if SWIFTUI
    /// Push view controller with hiding navigation bar. Method to hide and show navigationBar in swiftui (ui timing issue)
    /// - Since: 3.28.0
    public func pushViewControllerNonFlickering<T>(
        _ viewController: UIHostingController<T>,
        animated: Bool
    ) {
        // Remove SwiftUI's basic back button
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem()
        self.pushViewController(viewController, animated: animated)
    }
    #endif
}

#if SWIFTUI
/// A hosting controller that hides the navigation bar while this screen is on
/// screen. On entry it saves whether the bar was visible, then hides it; on exit
/// it puts the bar back to that saved state (so the previous screen keeps its bar
/// if it had one, and stays bar-less if it didn't).
///
/// SwiftUI key function views (e.g. `GroupChannelView`) render their header inside
/// the content, not through `navigationItem`. When such a view is wrapped in a plain
/// `UIHostingController` and pushed onto a `UINavigationController`, the navigation
/// bar stays visible as an empty strip above the in-content header. (SBISSUE-21868)
class SBUSwiftUIHostingController<Content: View>: UIHostingController<Content> {
    /// The bar state to put back on exit, captured the first time this screen appears.
    /// It is captured once and never re-read: a cancelled swipe-back gesture calls
    /// `viewWillAppear` again while the bar is still hidden, so re-reading here would
    /// save `true` and later "restore" the previous screen into a bar-less state.
    private var wasNavigationBarHidden: Bool?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navigationController = self.navigationController {
            if self.wasNavigationBarHidden == nil {
                self.wasNavigationBarHidden = navigationController.isNavigationBarHidden
            }
            navigationController.setNavigationBarHidden(true, animated: animated)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let navigationController = self.navigationController,
              let wasNavigationBarHidden = self.wasNavigationBarHidden else { return }

        // Toggling the bar mid-flight leaves an interactive pop with a visible but
        // empty bar, so wait for the gesture to settle. A cancelled gesture keeps
        // this screen on top, so the bar must stay hidden.
        if let coordinator = self.transitionCoordinator, coordinator.isInteractive {
            coordinator.animate(alongsideTransition: nil) { context in
                guard !context.isCancelled else { return }
                navigationController.setNavigationBarHidden(wasNavigationBarHidden, animated: false)
            }
        } else {
            navigationController.setNavigationBarHidden(wasNavigationBarHidden, animated: animated)
        }
    }
}
#endif
