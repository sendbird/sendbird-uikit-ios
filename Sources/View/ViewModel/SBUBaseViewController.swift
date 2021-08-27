//
//  SBUBaseViewController.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/05.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

@objcMembers
open class SBUBaseViewController: UIViewController {
    
    // MARK: - Lifecycle
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SBUUtils.dismissPresentedOnDisappear(presentedViewController: self.presentedViewController)
        
        SBULoading.stop()
        SBUMenuView.dismiss()
        SBUAlertView.dismiss()
        SBUActionSheet.dismiss()
    }
    
    // MARK: - Style & Layout
    
    open func setupAutolayout() {
    }
    
    open func setupStyles() {
    }
    
    open func updateStyles() {
    }
    
    /// This is to pop or dismiss (depending on current view controller) the search view controller.
    public func onClickBack() {
        if let navigationController = self.navigationController,
            navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
}

extension SBUBaseViewController: UINavigationControllerDelegate {
    
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // prevent swipe to pop if current vc is the first one. App freezes (https://sendbird.atlassian.net/browse/QU-234)
        if (navigationController.viewControllers.count > 1) {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
}
