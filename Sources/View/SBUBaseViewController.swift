//
//  SBUBaseViewController.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/05.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// TODO: SBUBaseViewController -> SBUViewController

@objcMembers
open class SBUBaseViewController: UIViewController, UINavigationControllerDelegate, SBULoadingIndicatorProtocol, SBUCommonViewModelDelegate {
    open func didReceiveError(_ error: SendbirdChatSDK.SBError?, isBlocker: Bool) {
        
    }
    
    public func shouldUpdateLoadingState(_ isLoading: Bool) {
        
    }
    
    public func baseViewModel(_ viewModel: SBUBaseViewModel, retryAfter: UInt) {
        self.showBusyServerCountdownAlert(retryAfter: retryAfter)
    }
    
    public func baseViewModelDidSucceedReconnection(_ viewModel: SBUBaseViewModel) {
        self.dismissBusyServerCountdownAlert()
    }
    
    public func baseViewModelDidFailReconnection(_ viewModel: SBUBaseViewModel) {
        self.dismissBusyServerCountdownAlert()
    }

    /// - Since: 3.8.0
    var prevNavigationBarSettings: SBUPrevNavigationBarSettings? = SBUPrevNavigationBarSettings()
    
    /// This value is used to check if the properties of the navigationBar need to be initialized. The default value is `true`.
    ///
    /// - NOTE: If you are presenting a ViewController with the `modalPresentationStyle` set to `.fullScreen` within a Sendbird function, please set this value to `false` before presenting.
    /// - Since: 3.11.2
    public var needRollbackNavigationBarSetting: Bool = true
    
    /// Caches previous navigation bar background color.
    /// Used to check if navigation bar update is needed.
    /// - Since: 3.33.1
    var previousNavBarBackgroundColor = UIColor()
    /// Caches previous navigation bar shadow color.
    /// Used to check if navigation bar update is needed.
    /// - Since: 3.33.1
    var previousNavBarShadowColor = UIColor()
    
    // MARK: - Lifecycle
    open override func loadView() {
        super.loadView()
        
        self.setupViews()
        self.setupLayouts()
        
        self.needRollbackNavigationBarSetting = false
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()
        
        self.navigationController?.delegate = self
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let navigationController = self.navigationController, needRollbackNavigationBarSetting {
            self.prevNavigationBarSettings?.rollback(to: navigationController)
        }
        SBUUtils.dismissPresentedOnDisappear(presentedViewController: self.presentedViewController)
        
        if self is SBUMenuSheetViewController == false {
            SBULoading.stop()
            SBUMenuView.dismiss()
            SBUAlertView.dismiss()
            SBUActionSheet.dismiss()
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.setupStyles()
    }
    
    // MARK: - Sendbird UIKit Life cycle
    
    /// This function setups views.
    open func setupViews() { }
    
    /// This function setups layouts.
    open func setupLayouts() { }
    
    /// This function updates layouts.
    open func updateLayouts() { }
    
    /// This function setups styles.
    open func setupStyles() { }
    
    /// This function updates styles.
    open func updateStyles() { }
    
    /// This function updates styles with boolean parameter value that represents whether layout or not
    open func updateStyles(needsToLayout: Bool) { }
    
    /// This function setups navigationBar's background color and shadow color.
    /// - Parameters:
    ///   - backgroundColor: background color
    ///   - shadowColor: shadow color
    open func setupNavigationBar(backgroundColor: UIColor, shadowColor: UIColor) {
        if let navigationController = self.navigationController {
            self.prevNavigationBarSettings?.save(with: navigationController)
        }
        
        // Check if navigation bar update is needed.
        guard self.shouldUpdateNavigationBar(
            backgroundColor: backgroundColor,
            shadowColor: shadowColor
        ) else { return }

        // update
        self.previousNavBarBackgroundColor = backgroundColor
        self.previousNavBarShadowColor = shadowColor

        self.navigationController?.navigationBar.setBackgroundImage(
            UIImage.from(color: backgroundColor),
            for: .default
        )
        self.navigationController?.navigationBar.shadowImage = UIImage.from(
            color: shadowColor
        )
        
        // For iOS 13
        self.navigationController?.sbu_setupNavigationBarAppearance(
            tintColor: backgroundColor,
            shadowColor: shadowColor
        )
    }
    
    /// Checks if navigation bar update is needed.
    /// - Since: 3.33.1
    func shouldUpdateNavigationBar(
        backgroundColor: UIColor,
        shadowColor: UIColor
    ) -> Bool {
        backgroundColor != previousNavBarBackgroundColor || shadowColor != previousNavBarShadowColor
    }
    
    // MARK: - Actions
    var dismissAction: (() -> Void)?

    /// This is to pop or dismiss (depending on current view controller) the search view controller.
    open func onClickBack() {
        if dismissAction != nil {
            dismissAction?()
        } else {
            if let navigationController = self.navigationController,
               navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    // MARK: - Error handling
    
    /// If an error occurs in viewController, a message is sent through here.
    /// If necessary, override to handle errors.
    /// - Parameters:
    ///   - message: error message
    ///   - code: error code
    open func errorHandler(_ message: String?, _ code: NSInteger? = nil) {
        SBULog.error("Did receive error: \(message ?? "")")
    }
    
    // MARK: UINavigationController
    func isLastInNavigationStack() -> Bool {
        if self.navigationController?.viewControllers.last == self {
            return true
        }
        #if SWIFTUI
        // In SwiftUI, a UIViewController is wrapped inside a UIHostingController.
        // The navigationController has access to the UIHostingController and not the UIViewController.
        if self.navigationController?.viewControllers.last == self.parent {
            return true
        }
        #endif
        return false
    }
    
    // MARK: - UINavigationControllerDelegate
    open func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // prevent swipe to pop if current vc is the first one. App freezes (https://sendbird.atlassian.net/browse/QU-234)
        if navigationController.viewControllers.count > 1 {
            navigationController.interactivePopGestureRecognizer?.isEnabled = true
        } else {
            navigationController.interactivePopGestureRecognizer?.isEnabled = false
        }
    }
    
    // MARK: - SBULoadingIndicatorProtocol
    open func showLoading(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading {
                SBULoading.start()
            } else {
                SBULoading.stop()
            }
        }
    }
    
    func showBusyServerCountdownAlert(retryAfter: UInt) {
        SBUAlertView.show(
            title: SBUStringSet.Alert_Busy_Server_Title,
            message: SBUStringSet.Alert_Busy_Server_Message,
            cancelButtonItem: nil,
            delegate: nil,
            countDownSeconds: retryAfter,
            enableBackgroundTapToDismiss: false
        )
    }
    
    func dismissBusyServerCountdownAlert() {
        SBUAlertView.dismiss()
    }
}

extension SBUBaseViewController {
    /// - Since: 3.8.0
    struct SBUPrevNavigationBarSettings {
        var isSet: Bool = false
        
        var backgroundImage: UIImage?
        var shadowImage: UIImage?
        
        var standardAppearanceWrapper: Any?
        var scrollEdgeAppearanceWrapper: Any?

        var standardAppearance: UINavigationBarAppearance? {
            get {
                standardAppearanceWrapper as? UINavigationBarAppearance
            }
            set {
                standardAppearanceWrapper = newValue
            }
        }
        var scrollEdgeAppearance: UINavigationBarAppearance? {
            get {
                scrollEdgeAppearanceWrapper as? UINavigationBarAppearance
            }
            set {
                scrollEdgeAppearanceWrapper = newValue
            }
        }
        
        mutating func save(with navigationController: UINavigationController) {
            guard isSet == false else { return }
            
            self.backgroundImage = navigationController.navigationBar.backgroundImage(for: .default)
            self.shadowImage = navigationController.navigationBar.shadowImage
            
            self.standardAppearance = navigationController.navigationBar.standardAppearance
            self.scrollEdgeAppearance = navigationController.navigationBar.scrollEdgeAppearance
            
            self.isSet = true
        }
        
        func rollback(to navigationController: UINavigationController) {
            guard isSet else { return }
            
            navigationController.navigationBar.setBackgroundImage(self.backgroundImage, for: .default)
            navigationController.navigationBar.shadowImage = self.shadowImage
            
            if let standardAppearance = self.standardAppearance {
                navigationController.navigationBar.standardAppearance = standardAppearance
            }
            navigationController.navigationBar.scrollEdgeAppearance = self.scrollEdgeAppearance
        }
    }
}
