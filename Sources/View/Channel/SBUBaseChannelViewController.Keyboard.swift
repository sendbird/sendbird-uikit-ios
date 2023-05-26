//
//  SBUBaseChannelViewController.Keyboard.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/01/15.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - Keyboard

extension SBUBaseChannelViewController {
    /// This function registers keyboard notifications.
    /// - Since: 3.0.0
    public func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: *
    /// This functions adds the hide keyboard gesture in tableView.
    /// - Since: 1.2.5
    public func addGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.baseListComponent?.tableView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboardIfTouchInput))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        self.baseListComponent?.tableView.addGestureRecognizer(pan)
    }
    
    /// This function dismisses the keyboard.
    /// - Since: 1.2.5
    @objc
    public func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // To hide autocorrection view on keyboard hidden.
    // https://stackoverflow.com/questions/59278526/keyboard-dismiss-very-buggy-on-tableview-interactive
    public func setKeyboardWindowFrame(origin: CGPoint, size: CGSize? = nil) {
        let windowBounds = UIApplication.shared.currentWindow?.bounds ?? .zero
        let screenSize: CGSize = size ?? windowBounds.size
        var keyboardWindow: UIWindow?
        for window in UIApplication.shared.windows {
            if NSStringFromClass(type(of: window).self) == "UIRemoteKeyboardWindow" {
                keyboardWindow = window
            }
        }
        
        keyboardWindow?.frame = CGRect(origin: origin, size: screenSize)
    }
    
    /// Updates layouts of ``baseInputComponent`` bottom anchor with keyboard height from notifications: ``keyboardWillShow(_:)``, ``keyboardWillShow(_:)``
    /// - Since: 3.2.3
    public func updateLayoutsWithKeyboard(isHidden: Bool, notification: Notification) {
        switch isHidden {
        case true:
            // When the keyboard will hide
            self.isKeyboardShowing = false
            
            self.setKeyboardWindowFrame(origin: CGPoint(x: 0, y: 50))
            
            if let messageInputViewBottomConstraint = self.messageInputViewBottomConstraint {
                messageInputViewBottomConstraint.constant = 0
            }
        case false:
            // When the keyboard will show
            guard let keyboardFrame = notification.userInfo?[
                UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue else { return }
            
            let userInfo = notification.userInfo!
            let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
            let beginFrame = beginFrameValue.cgRectValue
            let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
            let endFrame = endFrameValue.cgRectValue
            
            // iOS 14 bug, keyboardWillShow is called instead of keyboardWillHide.
            let windowBounds = UIApplication.shared.currentWindow?.bounds ?? .zero
            if endFrame.origin.y >= windowBounds.height {
                self.keyboardWillHide(notification)
                return
            }
            
            if beginFrame.origin.equalTo(endFrame.origin) && beginFrame.height != endFrame.height {
                return
            }
            
            self.isKeyboardShowing = true
            
            // NOTE: needs this on show as well to prevent bug on switching orientation as show&hide will be called simultaneously.
            self.setKeyboardWindowFrame(origin: .zero)
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            // If the `isTranslucent=false` option is used, the tabbar’s height is calculated unnecessarily, which is problematic.
            var tabBarHeight: CGFloat = 0.0
            if self.tabBarController?.tabBar.isTranslucent == false {
                tabBarHeight = tabBarController?.tabBar.frame.height ?? 0.0
            }
            
            self.messageInputViewBottomConstraint.constant = -(keyboardHeight-tabBarHeight)
        }
        self.view.layoutIfNeeded()
    }
    
    @objc
    private func dismissKeyboardIfTouchInput(sender: UIPanGestureRecognizer) {
        guard let tableView = self.baseListComponent?.tableView else { return }
        // no needs to listen to pan gesture if keyboard is not showing.
        guard self.isKeyboardShowing else {
            sender.isEnabled = false
            sender.isEnabled = true
            return
        }
        
        switch sender.state {
            case .began:
                initialMessageInputOrigin = self.view.convert(
                    self.baseInputComponent?.frame.origin ?? CGPoint(x: 0, y: self.view.frame.height),
                    to: self.view
                )
                initialMessageInputBottomConstraint = self.messageInputViewBottomConstraint.constant
            case .changed:
                switch tableView.keyboardDismissMode {
                    case .interactive:
                        let messageInputViewHeight = self.baseInputComponent?.frame.size.height ?? 0
                        
                        let initialMessageInputBottomY = initialMessageInputOrigin.y + messageInputViewHeight
                        let point = sender.location(in: view)
                        
                        // calculate how much the point is diverged with the initial message input's bottom.
                        let diffBetweenPointYMessageInputBottomY = point.y - initialMessageInputBottomY
                        
                        // add the diff value to initial message bottom constraint, but keep minimum value as it's initial constraint as
                        // keyboard can't go any higher.
                        self.messageInputViewBottomConstraint.constant =
                        max(initialMessageInputBottomConstraint + diffBetweenPointYMessageInputBottomY,
                            initialMessageInputBottomConstraint)
                        break
                    default:
                        sender.isEnabled = false
                        sender.isEnabled = true
                }
            case .ended:
                // defense code to prevent bottom constant to be set as some other value
                self.messageInputViewBottomConstraint.constant = self.isKeyboardShowing
                ? initialMessageInputBottomConstraint
                : 0
                break
            default:
                break
        }
    }
}
