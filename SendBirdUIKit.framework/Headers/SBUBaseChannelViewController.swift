//
//  SBUBaseChannelViewController.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/11/17.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
open class SBUBaseChannelViewController: UIViewController {
    
    // MARK: - Properties (View)
    
    public private(set) lazy var tableView = UITableView()
    public lazy var messageInputView: SBUMessageInputView = _messageInputView
    
    /// To use the custom user profile view, set this to the custom view created using `SBUUserProfileViewProtocol`.
    /// And, if you do not want to use the user profile feature, please set this value to nil.
    public lazy var userProfileView: UIView? = _userProfileView
    
    private lazy var _messageInputView: SBUMessageInputView = {
        return SBUMessageInputView()
    }()
    
    private lazy var _userProfileView: SBUUserProfileView = {
       let userProfileView = SBUUserProfileView(delegate: self)
        return userProfileView
    }()
    
    // MARK: - Properties
    
    private var isKeyboardShowing: Bool = false
    
    // MARK: - Constraints
    // for constraint
    var messageInputViewBottomConstraint: NSLayoutConstraint!
    var tableViewTopConstraint: NSLayoutConstraint!
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNeedsStatusBarAppearanceUpdate()

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
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        SBUUtils.dismissPresentedOnDisappear(presentedViewController: self.presentedViewController)
        
        SBULoading.stop()
        SBUMenuView.dismiss()
        SBUAlertView.dismiss()
        SBUActionSheet.dismiss()
        
        if let userProfileView = userProfileView as? SBUUserProfileView {
            userProfileView.dismiss()
        }
    }
    
    open override func loadView() {
        super.loadView()
        
        // tableview
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.allowsSelection = false
        self.tableView.keyboardDismissMode = .interactive
    }
    
    open func setupAutolayout() {}
    
    open func setupStyles() {}
    
    open func updateStyles() {
        if let userProfileView = self.userProfileView as? SBUUserProfileView {
            userProfileView.setupStyles()
        }
    }
    
    /// This function sets the user profile tap gesture handling.
    ///
    /// If you do not want to use the user profile function, override this function and leave it empty.
    /// - Parameter user: `SBUUser` object used for user profile configuration
    ///
    /// - Since: 1.2.2
    open func setUserProfileTapGestureHandler(_ user: SBUUser) {
        if let userProfileView = self.userProfileView as? SBUUserProfileView,
            let baseView = self.navigationController?.view,
            SBUGlobals.UsingUserProfile
        {
            userProfileView.show(
                baseView: baseView,
                user: user
            )
        }
    }
    
    // MARK: - Keyboard
    /// This function changes the messageInputView bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Since: 1.2.5
    public func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[
            UIResponder.keyboardFrameEndUserInfoKey
            ] as? NSValue else { return }
        
        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue
        
        // iOS 14 bug, keyboardWillShow is called instead of keyboardWillHide.
        if endFrame.origin.y >= UIScreen.main.bounds.height {
            self.keyboardWillHide(notification)
            return
        }
        
        if (beginFrame.origin.equalTo(endFrame.origin)
                && beginFrame.height != endFrame.height) {
            return
        }
        
        self.isKeyboardShowing = true
        
        //NOTE: needs this on show as well to prevent bug on switching orientation as show&hide will be called simultaneously.
        setKeyboardWindowFrame(origin: .zero)
        
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        self.messageInputViewBottomConstraint.constant = -keyboardHeight
        self.view.layoutIfNeeded()
    }
    
    /// This function changes the messageInputView bottom constraint using keyboard height.
    /// - Parameter notification: Notification object with keyboardFrame information
    /// - Since: 1.2.5
    public func keyboardWillHide(_ notification: Notification) {
        self.isKeyboardShowing = false
        
        setKeyboardWindowFrame(origin: CGPoint(x: 0, y: 50))
        
        self.messageInputViewBottomConstraint.constant = 0
        self.view.layoutIfNeeded()
    }
    
    /// This function dismisses the keyboard.
    /// - Since: 1.2.5
    public func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    // To hide autocorrection view on keyboard hidden.
    // https://stackoverflow.com/questions/59278526/keyboard-dismiss-very-buggy-on-tableview-interactive
    private func setKeyboardWindowFrame(origin: CGPoint, size: CGSize = UIScreen.main.bounds.size) {
        var keyboardWindow: UIWindow? = nil
        for window in UIApplication.shared.windows {
            if (NSStringFromClass(type(of: window).self) == "UIRemoteKeyboardWindow") {
                keyboardWindow = window
            }
        }
        
        keyboardWindow?.frame = CGRect(origin: origin, size: size)
    }
    
    private var initialMessageInputBottomConstraint: CGFloat = 0
    private var initialMessageInputOrigin: CGPoint = .zero
    
    @objc private func dismissKeyboardIfTouchInput(sender: UIPanGestureRecognizer) {
        // no needs to listen to pan gesture if keyboard is not showing.
        guard self.isKeyboardShowing else {
            cancel(gestureRecognizer: sender)
            return
        }
        
        switch sender.state {
        case .began:
            initialMessageInputOrigin = self.view.convert(self.messageInputView.frame.origin, to: self.view)
            initialMessageInputBottomConstraint = self.messageInputViewBottomConstraint.constant
        case .changed:
            switch self.tableView.keyboardDismissMode {
            case .interactive:
                let initialMessageInputBottomY = initialMessageInputOrigin.y + self.messageInputView.frame.size.height
                let point = sender.location(in: view)
                
                // calculate how much the point is diverged with the initial message input's bottom.
                let diffBetweenPointYMessageInputBottomY = point.y - initialMessageInputBottomY
                
                // add the diff value to initial message bottom constraint, but keep minimum value as it's initial constraint as
                // keyboard can't go any higher.
                self.messageInputViewBottomConstraint.constant =
                    max(initialMessageInputBottomConstraint + diffBetweenPointYMessageInputBottomY, initialMessageInputBottomConstraint)
                break
            default:
                self.cancel(gestureRecognizer: sender)
            }
        case .ended:
            // defense code to prevent bottom constant to be set as some other value
            self.messageInputViewBottomConstraint.constant = self.isKeyboardShowing ? initialMessageInputBottomConstraint : 0
            break
        default:
            break
        }
    }
    
    private func cancel(gestureRecognizer: UIGestureRecognizer) {
        gestureRecognizer.isEnabled = false
        gestureRecognizer.isEnabled = true
    }
    
    /// This functions adds the hide keyboard gesture in tableView.
    /// - Since: 1.2.5
    public func addGestureHideKeyboard() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        tableView.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(dismissKeyboardIfTouchInput))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        tableView.addGestureRecognizer(pan)
    }
}

extension SBUBaseChannelViewController: UIGestureRecognizerDelegate {
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer)
            -> Bool {
       return true
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SBUBaseChannelViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        preconditionFailure("Needs to implement this method")
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        preconditionFailure("Needs to implement this method")
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //NOTE: do not bounds to bottom if size is less than content size
        if scrollView.contentSize.height < scrollView.frame.height {
            scrollView.contentOffset.y = 0
        }
    }
}

// MARK: - SBUUserProfileViewDelegate
extension SBUBaseChannelViewController: SBUUserProfileViewDelegate {
    open func didSelectMessage(userId: String?) {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
            if let userId = userId {
                SBUMain.createAndMoveToChannel(userIds: [userId])
            }
        }
    }
    
    open func didSelectClose() {
        if let userProfileView = self.userProfileView
            as? SBUUserProfileViewProtocol {
            userProfileView.dismiss()
        }
    }
}
