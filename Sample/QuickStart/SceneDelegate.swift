//
//  SceneDelegate.swift
//  SendbirdUIKit-Sample
//
//  Copyright © 2026 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Apps built with the iOS 27 SDK must adopt the UIScene life cycle, or launch fails.
/// The window is created from `Main.storyboard` via `UISceneStoryboardFile` in Info.plist.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // With the scene life cycle, `applicationDidBecomeActive(_:)` is no longer called.
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
