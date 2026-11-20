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
    
    /// 뒤로 가기 제스처의 delegate를 nil 대신 `SBUInteractivePopGestureGuard`로 둔다.
    /// nil이면 루트 화면에서도 제스처가 시작되어 다음 push가 끝나지 않고 화면이 멈춘다(iOS 17.5에서 확인, QU-234).
    /// 루트 보호를 navigation delegate의 `didShow`에만 맡기면 고객 앱이 delegate를 가져갈 때 보호가 빠진다.
    func sbu_setInteractivePopGestureGuard() {
        let popGestureGuard: SBUInteractivePopGestureGuard
        if let existing = objc_getAssociatedObject(self, &sbuInteractivePopGestureGuardKey) as? SBUInteractivePopGestureGuard {
            popGestureGuard = existing
        } else {
            popGestureGuard = SBUInteractivePopGestureGuard(navigationController: self)
            // 제스처의 delegate는 weak이라 navigation controller가 guard를 붙잡아 둔다.
            objc_setAssociatedObject(self, &sbuInteractivePopGestureGuardKey, popGestureGuard, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        self.interactivePopGestureRecognizer?.delegate = popGestureGuard
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

private var sbuInteractivePopGestureGuardKey: UInt8 = 0

/// 뒤로 가기 제스처 delegate. 화면이 둘 이상이고 전환 중이 아닐 때만 제스처를 시작한다.
/// 나머지 delegate 메서드는 구현하지 않아 delegate가 nil일 때와 같게 동작한다.
final class SBUInteractivePopGestureGuard: NSObject, UIGestureRecognizerDelegate {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let navigationController = self.navigationController else { return false }
        return navigationController.viewControllers.count > 1
            && navigationController.transitionCoordinator == nil
    }
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
