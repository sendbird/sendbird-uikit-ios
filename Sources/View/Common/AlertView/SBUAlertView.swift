//
//  SBUAlertView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This typealias is used for handling alert button actions. It takes an optional parameter of type `Any`.
/// - Since: 3.28.0
public typealias SBUAlertButtonHandler = (_ info: Any?) -> Void

/// This typealias is used for handling alert button actions. It takes an optional parameter of type `Any`.
@available(*, deprecated, renamed: "SBUAlertButtonHandler") // 3.28.0
public typealias AlertButtonHandler = SBUAlertButtonHandler

/// SBUAlertViewDelegate is a delegate that defines methods for handling alert view events.
public protocol SBUAlertViewDelegate: AnyObject {
    /// Called when `SBUAlertView` is dismiss
    func didDismissAlertView()
}

/// `SBUAlertView` is a class that displays an alert view in the SendbirdUIKit.
open class SBUAlertView: NSObject, SBUViewLifeCycle {
    // Public
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    public private(set) weak var delegate: SBUAlertViewDelegate?
    
    public private(set) var isShowing: Bool = false
    public private(set) var confirmButtonItem: SBUAlertButtonItem?
    public private(set) var cancelButtonItem: SBUAlertButtonItem?
    
    /// The parent view where the alert view will be presented. By default, it is set to the application's current window.
    public var parentView: UIView? = UIApplication.shared.currentWindow
    public private(set) var backgroundView = UIButton()
    public private(set) var containerView = UIView()
    public private(set) var titleLabel = UILabel()
    public private(set) var messageLabel: UILabel?
    public private(set) var inputField: UITextField?
    public private(set) var separator = UIView()
 
    public private(set) var title: String = ""
    public private(set) var message: String?
    public private(set) var needInputField: Bool = false
    public private(set) var inputText: String?
    public private(set) var placeHolder: String?
    public private(set) var confirmButton = UIButton()
    public private(set) var cancelButton: UIButton?
    
    public private(set) var centerYRatio: CGFloat = 1.0
    
    public var containerCornerRadius: CGFloat = 10.0
    
    // MARK: Private properties
    /// Timer for countdown.
    /// - Since: 3.32.4
    private var countdownTimer: Timer?
    /// The remaining seconds for countdown.
    /// - Since: 3.32.4
    private var countdownRemainingSeconds: Int?
    /// Base text template for message with countdown.
    /// - Since: 3.32.4
    private var baseCountdownMessage: String?
    /// Flag option that enables/ disables dismiss on background tap.
    /// - Since: 3.32.4
    private var enableBackgroundTapToDismiss: Bool = true
    
    static private var shared = SBUModuleSet.CommonModule.AlertView.init()
    
    static func resetInstance() {
        shared.dismiss()
        shared = SBUModuleSet.CommonModule.AlertView.init()
    }
    
    private var dismissHandler: (() -> Void)?
    
    // TODO: static var?
    let itemWidth: CGFloat = 270.0
    let textInsideMargin: CGFloat = 3.0
    let textTopBottomMargin: CGFloat = 20.0
    let inputAreaHeight: CGFloat = 32.0
    let inputAreaMargin: CGFloat = 20.0
    let inputBottomMargin: CGFloat = 16
    let buttonHeight: CGFloat = 44.0
    let sideMargin: CGFloat = 16.0
    
    var prevOrientation: UIDeviceOrientation = .unknown
    
    required public override init() {
        super.init()
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// This static function shows the alertView.
    /// - Parameters:
    ///   - title: Title text
    ///   - message: Message text (default: nil).
    ///   - needInputField: If an input field is required, set value to `true`.
    ///   - inputText: If an input field has pre-defined text  set value `text`.
    ///   - placeHolder: Placeholder text (default: "")
    ///   - centerYRatio: AlertView's centerY ratio.
    ///   - oneTimetheme: One-time theme setting
    ///   - confirmButtonItem: Confirm button item
    ///   - cancelButtonItem: Cancel button item (nullable)
    ///   - delegate: AlertView delegate
    ///   - countDownSeconds: Optional number of seconds for displaying a live countdown in the message
    ///   - dismissHandler: Called when the alert is dismissed by user interaction
    open class func show(
        title: String,
        message: String? = nil,
        needInputField: Bool = false,
        inputText: String? = nil,
        placeHolder: String? = "",
        centerYRatio: CGFloat? = 1.0,
        oneTimetheme: SBUComponentTheme? = nil,
        confirmButtonItem: SBUAlertButtonItem,
        cancelButtonItem: SBUAlertButtonItem?,
        delegate: SBUAlertViewDelegate? = nil,
        dismissHandler: (() -> Void)? = nil
    ) {
        Thread.executeOnMain {
            self.shared.show(
                title: title,
                message: message,
                needInputField: needInputField,
                inputText: inputText,
                placeHolder: placeHolder,
                centerYRatio: centerYRatio,
                oneTimetheme: oneTimetheme,
                confirmButtonItem: confirmButtonItem,
                cancelButtonItem: cancelButtonItem,
                delegate: delegate,
                dismissHandler: dismissHandler
            )
        }
    }
    
    /// This static function shows the alertView with a countdown message.
    /// - Parameters:
    ///   - title: Title text
    ///   - message: Message text (default: nil).
    ///   - needInputField: If an input field is required, set value to `true`.
    ///   - inputText: If an input field has pre-defined text  set value `text`.
    ///   - placeHolder: Placeholder text (default: "")
    ///   - centerYRatio: AlertView's centerY ratio.
    ///   - oneTimetheme: One-time theme setting
    ///   - confirmButtonItem: Confirm button item (optional)
    ///   - cancelButtonItem: Cancel button item (optional)
    ///   - delegate: AlertView delegate
    ///   - countDownSeconds: Optional number of seconds for displaying a live countdown in the message
    ///   - enableBackgroundTapToDismiss: If set to `false`, the alert view is not dismissed when the user taps on the background. Defaults to `true`.
    ///   - dismissHandler: Called when the alert is dismissed by user interaction
    /// - Since: 3.32.4
    open class func show(
        title: String,
        message: String? = nil,
        needInputField: Bool = false,
        inputText: String? = nil,
        placeHolder: String? = "",
        centerYRatio: CGFloat? = 1.0,
        oneTimetheme: SBUComponentTheme? = nil,
        confirmButtonItem: SBUAlertButtonItem? = nil,
        cancelButtonItem: SBUAlertButtonItem?,
        delegate: SBUAlertViewDelegate? = nil,
        countDownSeconds: UInt? = nil,
        enableBackgroundTapToDismiss: Bool = true,
        dismissHandler: (() -> Void)? = nil
    ) {
        Thread.executeOnMain {
            self.shared.show(
                title: title,
                message: message,
                needInputField: needInputField,
                inputText: inputText,
                placeHolder: placeHolder,
                centerYRatio: centerYRatio,
                oneTimetheme: oneTimetheme,
                confirmButtonItem: confirmButtonItem,
                cancelButtonItem: cancelButtonItem,
                delegate: delegate,
                countDownSeconds: countDownSeconds,
                enableBackgroundTapToDismiss: enableBackgroundTapToDismiss,
                dismissHandler: dismissHandler
            )
        }
    }
    
    /// This static function dismissed the alert.
    open class func dismiss() {
        Thread.executeOnMain {
            self.shared.dismiss()
        }
    }
    
    // MARK: Lifecycle
    /// Configures the view with necessary alertView buttons and layout.
    open func configureView() {
        self.containerView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: self.itemWidth, height: self.calculateTotalHeight())
        )
        
        // title
        self.titleLabel = self.createTitleLabel()
        self.containerView.addSubview(self.titleLabel)

        var originY = self.titleLabel.frame.maxY
        
        // message
        if let messageLabel = self.createMessageLabel(originY: originY) {
            self.messageLabel = messageLabel
            self.containerView.addSubview(messageLabel)

            originY = messageLabel.frame.maxY
        }
        
        // input field
        if let inputField = self.createInputField(originY: originY) {
            self.inputField = inputField
            self.containerView.addSubview(inputField)
            
            originY = inputField.frame.maxY + inputBottomMargin
        } else {
            originY += textTopBottomMargin
        }
        
        guard confirmButtonItem != nil || cancelButtonItem != nil else {
            return
        }
        
        // separator
        self.separator = self.createSeparator(originY: originY)
        self.containerView.addSubview(self.separator)

        // Buttons
        var buttonOriginX: CGFloat = 0.0
        let buttonWidth = (cancelButtonItem == nil) ? itemWidth : itemWidth/2

        if let cancelButton = self.createCancelButton(
            originY: originY,
            buttonOriginX: buttonOriginX
        ) {
            self.cancelButton = cancelButton
            self.containerView.addSubview(cancelButton)
            buttonOriginX += buttonWidth
        }
        
        if let confirmButton = self.createConfirmButton(
            originY: originY,
            buttonOriginX: buttonOriginX
        ) {
            self.confirmButton = confirmButton
            self.containerView.addSubview(confirmButton)
        }
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.prevOrientation = UIDevice.current.orientation
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
    }
    
    /// This function updates styles.
    open func updateStyles() {
        self.backgroundView.backgroundColor = theme.overlayColor
        self.containerView.backgroundColor = theme.backgroundColor
        
        self.titleLabel.numberOfLines = 0
        self.titleLabel.font = theme.alertTitleFont
        self.titleLabel.textColor = theme.alertTitleColor
        self.titleLabel.textAlignment = .center
        
        self.messageLabel?.numberOfLines = 0
        self.messageLabel?.font = theme.alertDetailFont
        self.messageLabel?.textColor = theme.alertDetailColor
        self.messageLabel?.textAlignment = .center
        self.applyBoldFontOnTimer()
        
        self.inputField?.backgroundColor = theme.alertTextFieldBackgroundColor
        self.inputField?.font = theme.alertTextFieldFont
        self.inputField?.textColor = theme.alertTitleColor
        self.inputField?.attributedPlaceholder = NSAttributedString(
            string: placeHolder ?? "",
            attributes: [NSAttributedString.Key.foregroundColor: theme.alertDetailColor]
        )
        
        self.separator.backgroundColor = theme.separatorColor
        
        self.cancelButton?.titleLabel?.font = theme.alertButtonFont
        self.cancelButton?.titleLabel?.textColor = theme.alertButtonColor
        self.cancelButton?.setTitleColor(self.cancelButtonItem?.color ?? theme.alertButtonColor, for: .normal)
        self.cancelButton?.setBackgroundImage(UIImage.from(color: theme.backgroundColor), for: .normal)
        self.cancelButton?.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
        
        self.confirmButton.titleLabel?.font = theme.alertButtonFont
        self.confirmButton.setTitleColor(self.confirmButtonItem?.color ?? theme.alertButtonColor, for: .normal)
        self.confirmButton.setBackgroundImage(UIImage.from(color: theme.backgroundColor), for: .normal)
        self.confirmButton.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() {
    }
    
    /// This function updates layouts.
    open func updateLayouts() {
        guard let parentView = self.parentView else { return }

        self.backgroundView.frame = parentView.bounds
        self.containerView.layer.masksToBounds = true
        
        setRoundRectOnContainerView()
        
        // inputField: RoundRect
        if self.needInputField,
            let inputField = self.inputField {
            let rectShape = CAShapeLayer()
            rectShape.bounds = inputField.frame
            rectShape.position = inputField.center
            rectShape.path = UIBezierPath(
                roundedRect: inputField.bounds,
                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 5, height: 5)
            ).cgPath
            inputField.layer.mask = rectShape
        }
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() {
        self.backgroundView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
    }
    
    func updateActions() {
        if self.enableBackgroundTapToDismiss == false {
            self.backgroundView.removeTarget(self, action: #selector(dismiss), for: .touchUpInside)
        }
    }
}

// MARK: - Public
extension SBUAlertView {
    /// Dismisses the alert view.
    @objc
    public func dismiss() {
        guard !isShowing else { return }

        self.handleDismiss(isUserInitiated: true)
    }
    
    /// This function calculates the total height of the alert.
    public func calculateTotalHeight() -> CGFloat {
        var totalHeight: CGFloat = 0.0
        
        totalHeight += self.titleHeight

        if self.message != nil {
            totalHeight += (self.textInsideMargin + self.messageHeight)
        }
        
        if self.needInputField {
             // top, text-input, input, input-button
            totalHeight += (inputAreaMargin + inputAreaMargin + inputAreaHeight + inputBottomMargin)
        } else {
             // top, text-button
            totalHeight += (textTopBottomMargin + textTopBottomMargin)
        }
        
        if confirmButtonItem != nil || cancelButtonItem != nil {
            totalHeight += self.buttonHeight
        }
        
        return totalHeight
    }
    
    // MARK: Common
    /// This function calculates the height of the text.
    public func getTextHeight(text: String, maxSize: CGSize, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(
            with: maxSize,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return rect.height
    }
    
    /// This function calculates the inside width of the item.
    public var insideItemWidth: CGFloat {
        self.itemWidth - self.sideMargin*2
    }
    
    /// This function calculates the height of the title.
    public var titleHeight: CGFloat {
        self.getTextHeight(
            text: title,
            maxSize: CGSize(width: insideItemWidth, height: CGFloat.greatestFiniteMagnitude),
            font: theme.alertTitleFont
        )
    }
    
    /// This function calculates the height of the message.
    public var messageHeight: CGFloat {
        guard let message = self.message else { return 0 }
        
        return self.getTextHeight(
            text: message,
            maxSize: CGSize(width: insideItemWidth, height: CGFloat.greatestFiniteMagnitude),
            font: theme.alertDetailFont
        )
    }
    
    public func setRoundRectOnContainerView() {
        setRoundRect(
            on: self.containerView,
            cornerRadii: CGSize(
                width: containerCornerRadius,
                height: containerCornerRadius
            )
        )
    }
    
    public func setRoundRect(
        on targetView: UIView,
        cornerRadii: CGSize
    ) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = targetView.frame
        rectShape.position = targetView.center
        rectShape.path = UIBezierPath(
            roundedRect: targetView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: cornerRadii
        ).cgPath
        
        targetView.layer.mask = rectShape
    }
    
    // MARK: Button action
    /// This function is called when the button is clicked.
    /// - Since: 3.28.0
    @objc
    public func onClickAlertButton(sender: UIButton) {
        let index = sender.tag
        if cancelButtonItem != nil, index == 0 {
            self.cancelButtonItem?.completionHandler?(nil)
            dismiss()
        } else {
            self.confirmButtonItem?.completionHandler?(self.inputField?.text)
            dismiss()
        }
    }
}

// MARK: - Private
extension SBUAlertView {
    private func show(
        title: String,
        message: String? = nil,
        needInputField: Bool = false,
        inputText: String? = nil,
        placeHolder: String? = "",
        centerYRatio: CGFloat? = 1.0,
        oneTimetheme: SBUComponentTheme? = nil,
        confirmButtonItem: SBUAlertButtonItem? = nil,
        cancelButtonItem: SBUAlertButtonItem?,
        delegate: SBUAlertViewDelegate?,
        countDownSeconds: UInt? = nil,
        enableBackgroundTapToDismiss: Bool? = nil,
        dismissHandler: (() -> Void)? = nil
    ) {
        self.storeProperties(
            title: title,
            message: message,
            needInputField: needInputField,
            inputText: inputText,
            placeHolder: placeHolder,
            centerYRatio: centerYRatio,
            oneTimetheme: oneTimetheme,
            confirmButtonItem: confirmButtonItem,
            cancelButtonItem: cancelButtonItem,
            delegate: delegate,
            countDownSeconds: countDownSeconds,
            enableBackgroundTapToDismiss: enableBackgroundTapToDismiss,
            dismissHandler: dismissHandler
        )

        self.prepareForDisplay()
        self.configureView()
        self.updateStyles()
        self.updateLayouts()
        self.presentView()
        
        self.updateActions()
    }
    
    /// Stores properties for the toast view.
    private func storeProperties(
        title: String,
        message: String? = nil,
        needInputField: Bool = false,
        inputText: String? = nil,
        placeHolder: String? = "",
        centerYRatio: CGFloat? = 1.0,
        oneTimetheme: SBUComponentTheme? = nil,
        confirmButtonItem: SBUAlertButtonItem? = nil,
        cancelButtonItem: SBUAlertButtonItem?,
        delegate: SBUAlertViewDelegate?,
        countDownSeconds: UInt? = nil,
        enableBackgroundTapToDismiss: Bool? = nil,
        dismissHandler: (() -> Void)? = nil
    ) {
        self.invalidateCountdown()
        
        if let oneTimetheme = oneTimetheme {
            self.theme = oneTimetheme
        }
        
        self.title = title
        
        // AlertView has a countdown.
        if let countDownSeconds {
            let remaining = Int(countDownSeconds)
            self.countdownRemainingSeconds = remaining
            self.baseCountdownMessage = message
            self.message = self.countdownMessage(for: remaining)
        } else {
            // A normal AlertView (without a countdown).
            self.countdownRemainingSeconds = nil
            self.baseCountdownMessage = nil
            self.message = message
        }

        self.needInputField = needInputField
        self.inputText = inputText
        self.placeHolder = placeHolder
        self.confirmButtonItem = confirmButtonItem
        self.cancelButtonItem = cancelButtonItem
        self.delegate = delegate
        self.dismissHandler = dismissHandler
        if let enableBackgroundTapToDismiss,
           enableBackgroundTapToDismiss == false {
            self.enableBackgroundTapToDismiss = false
        }
        
        if let centerYRatio = centerYRatio {
            self.centerYRatio = centerYRatio
        }
    }

    private func prepareForDisplay() {
        self.parentView = UIApplication.shared.currentWindow
        
        self.handleDismiss(isUserInitiated: false)
        self.addObserverForOrientation()
        self.addObserverForKeyboardWillShow()
        self.addObserverForKeyboardWillHide()
        
        self.parentView?.addSubview(self.backgroundView)
        self.parentView?.addSubview(self.containerView)
    }

    private func presentView() {
        guard let parentView = self.parentView else { return }
        
        self.containerView.center = CGPoint(
            x: parentView.center.x,
            y: parentView.center.y * self.centerYRatio
        )
        
        // Animation
        let baseFrame = self.containerView.frame
        self.containerView.frame = CGRect(
            origin: CGPoint(x: baseFrame.origin.x, y: parentView.frame.height),
            size: baseFrame.size
        )
        self.backgroundView.alpha = 0.0
        self.isShowing = true
        
        // Support RTL
        if UIView.getCurrentLayoutDirection().isRTL {
            self.containerView.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.containerView.subviews.forEach({
                $0.transform = CGAffineTransform(scaleX: -1, y: 1)
            })
        }
        
        UIView.animate(withDuration: 0.1) {
            self.backgroundView.alpha = 1.0
        } completion: { _ in
            self.containerView.frame = baseFrame
            
            if self.needInputField {
                self.inputField?.becomeFirstResponder()
            }
            self.isShowing = false
            
            // Count down if seconds remain.
            if self.countdownRemainingSeconds != nil {
                self.startCountdownIfNeeded()
            }
        }
    }
    
    // MARK: Common
    func addObserverForOrientation() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    func addObserverForKeyboardWillShow() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    func addObserverForKeyboardWillHide() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func removeObserverForOrientation() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    func removeObserverForKeyboardWillShow() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
    }
    
    func removeObserverForKeyboardWillHide() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: Countdown
    /// Starts countdown.
    private func startCountdownIfNeeded() {
        guard countdownTimer == nil,
              let remaining = countdownRemainingSeconds,
              remaining > 0 else { return }
        
        self.updateCountdownMessage(with: remaining)
        
        let timer = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.handleCountdownTick()
        }
        timer.tolerance = 0.1
        RunLoop.main.add(timer, forMode: .common)
        self.countdownTimer = timer
    }
    
    /// Counts down by one second, and updates `messageLabel` at each second.
    private func handleCountdownTick() {
        guard let current = countdownRemainingSeconds else {
            invalidateCountdown()
            return
        }
        
        guard current >= 0 else {
            invalidateCountdown()
            return
        }
        
        let updated = current - 1
        countdownRemainingSeconds = updated
        self.updateCountdownMessage(with: max(updated, -1))
        
        if updated < 0 {
            invalidateCountdown()
        }
    }
    
    /// Updates `messageLabel` with remaining seconds.
    private func updateCountdownMessage(with remaining: Int) {
        Thread.executeOnMain { [weak self] in
            guard let self = self else { return }

            let shouldHideMessageLabel = (remaining < 0)
            
            if shouldHideMessageLabel {
                self.message = nil
                self.messageLabel?.attributedText = nil
                self.messageLabel?.text = nil
                self.messageLabel?.isHidden = true
            } else {
                let newMessage = self.countdownMessage(for: remaining)
                self.message = newMessage
                self.messageLabel?.text = newMessage
                self.applyBoldFontOnTimer()
                self.messageLabel?.isHidden = false
            }
            
            // Update containerView.
            UIView.animate(withDuration: 0.3) {
                // update containerView height
                self.containerView.frame.size.height = self.calculateTotalHeight()
                
                // update containerView's roundRect
                self.setRoundRectOnContainerView()
                
                self.containerView.layoutIfNeeded()
             }
        }
    }
    
    /// Turns off the timer.
    private func invalidateCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        countdownRemainingSeconds = nil
    }
    
    /// Creates a message with the countdown seconds.
    private func countdownMessage(for remaining: Int) -> String {
        let formattedTime = self.formattedTime(from: remaining)
        let baseMessage = self.baseCountdownMessage ?? ""
        
        return "\(baseMessage) \(formattedTime)"
    }
    
    /// Formats the seconds into `mm:ss` format.
    private func formattedTime(from totalSeconds: Int) -> String {
        let clampedSeconds = max(totalSeconds, 0)
        let minutes = clampedSeconds / 60
        let seconds = clampedSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    // MARK: Action
    @objc
    private func handleDismiss(isUserInitiated: Bool) {
        if isUserInitiated {
            self.invalidateCountdown()
        } else {
            self.countdownTimer?.invalidate()
            self.countdownTimer = nil
        }
        
        for subView in self.containerView.subviews {
            subView.removeFromSuperview()
        }
        
        self.inputField = UITextField()
        self.backgroundView.removeFromSuperview()
        self.containerView.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.removeObserver(
            self,
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        if isUserInitiated {
            self.delegate?.didDismissAlertView()
            let handler = self.dismissHandler
            self.dismissHandler = nil

            self.message = nil
            self.inputText = nil
            self.placeHolder = nil
            self.centerYRatio = 1.0
            self.theme = SBUTheme.componentTheme
            self.confirmButtonItem = nil
            self.cancelButtonItem = nil
            self.theme = SBUTheme.componentTheme
            
            handler?()
        }
    }
    
    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        UIView.animate(withDuration: 0.1, animations: {
            guard let parentView = self.parentView else { return }
            
            self.containerView.center.y = ((parentView.frame.height - keyboardFrame.cgRectValue.height) / 2) * self.centerYRatio
        })
    }
    
    @objc
    private func keyboardWillHide() {
        UIView.animate(withDuration: 0.1, animations: {
            guard let parentView = self.parentView else { return }
            
            self.containerView.center.y = parentView.center.y * self.centerYRatio
        })
    }
    
    // MARK: Create items
    /// This function creates a title label.
    /// - Since: 3.28.0
    private func createTitleLabel() -> UILabel {
        let label = UILabel(frame: CGRect(
            origin: CGPoint(
                x: self.sideMargin,
                y: (self.needInputField ? inputAreaMargin : self.textTopBottomMargin)
            ),
            size: CGSize(width: self.insideItemWidth, height: self.titleHeight)
        ))
        label.text = self.title
        return label
    }
    
    /// This function creates a message label.
    /// - Since: 3.28.0
    private func createMessageLabel(originY: CGFloat) -> UILabel? {
        guard self.message != nil else { return nil }
        
        let label = UILabel(frame: CGRect(
            origin: CGPoint(
                x: self.sideMargin,
                y: originY + self.textInsideMargin
            ),
            size: CGSize(width: insideItemWidth, height: messageHeight)
        ))
        label.text = self.message
        
        return label
    }
    
    /// Applies bold font to the countdown part of the `messageLabel`.
    /// - Since: 3.32.4
    private func applyBoldFontOnTimer() {
        guard
            let label = self.messageLabel,
            let text = self.message,
            let remaining = self.countdownRemainingSeconds,
            remaining >= 0
        else {
            return
        }

        let countdownText = self.formattedTime(from: remaining)
        let nsText = text as NSString
        let range = nsText.range(of: countdownText, options: .backwards)
        
        guard range.location != NSNotFound else {
            return
        }
        
        let attributed = NSMutableAttributedString(string: text)
        let baseFont = self.theme.alertDetailFont
        let baseColor = self.theme.alertDetailColor
        attributed.addAttributes(
            [.font: baseFont, .foregroundColor: baseColor],
            range: NSRange(location: 0, length: nsText.length)
        )
        attributed.addAttributes(
            [.font: self.boldFont(basedOn: baseFont), .foregroundColor: baseColor],
            range: range
        )
        
        label.attributedText = attributed
    }
    
    /// Returns a bold font based on the provided font.
    /// - Since: 3.32.4
    private func boldFont(basedOn font: UIFont) -> UIFont {
        if let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) {
            return UIFont(descriptor: descriptor, size: font.pointSize)
        } else {
            return UIFont.boldSystemFont(ofSize: font.pointSize)
        }
    }
    
    /// This function creates a inputFiled.
    /// - Since: 3.28.0
    private func createInputField(originY: CGFloat) -> UITextField? {
        if self.needInputField {
            let textField = UITextField()
            textField.frame = CGRect(
                origin: CGPoint(x: self.sideMargin, y: originY + self.inputAreaMargin),
                size: CGSize(width: self.insideItemWidth, height: self.inputAreaHeight)
            )
            textField.text = self.inputText
            
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            textField.placeholder = self.placeHolder
            textField.leftView = paddingView
            textField.leftViewMode = .always
            textField.rightView = paddingView
            textField.rightViewMode = .always
            
            return textField
        }
        
        return nil
    }
    
    /// This function creates a separator.
    /// - Since: 3.28.0
    private func createSeparator(originY: CGFloat) -> UIView {
        let view = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: originY-0.5),
            size: CGSize(width: self.itemWidth, height: 0.5)
        ))
        return view
    }
    
    /// This function creates a cancel button.
    /// - Since: 3.28.0
    private func createCancelButton(
        originY: CGFloat,
        buttonOriginX: CGFloat = 0.0
    ) -> UIButton? {
        let buttonWidth = (cancelButtonItem == nil) ? itemWidth : itemWidth/2
        
        if let cancelButtonItem = cancelButtonItem {
            let cancelButton = UIButton(
                frame: CGRect(
                    origin: CGPoint(x: buttonOriginX, y: originY),
                    size: CGSize(width: buttonWidth, height: buttonHeight)
                )
            )
            cancelButton.setTitle(cancelButtonItem.title, for: .normal)
            cancelButton.addTarget(self, action: #selector(onClickAlertButton), for: .touchUpInside)
            cancelButton.tag = 0
            
            let separatorLine = UIView(frame: CGRect(
                origin: CGPoint(x: cancelButton.bounds.maxX - 0.5, y: 0),
                size: CGSize(width: 5, height: buttonHeight))
            )
            separatorLine.backgroundColor = theme.separatorColor
            cancelButton.addSubview(separatorLine)
            
            return cancelButton
        }
        
        return nil
    }
    
    /// This function creates a confirm button.
    /// - Since: 3.28.0
    private func createConfirmButton(
        originY: CGFloat,
        buttonOriginX: CGFloat = 0.0
    ) -> UIButton? {
        let buttonWidth = (cancelButtonItem == nil) ? itemWidth : itemWidth/2
        let confirmButton = UIButton(frame: CGRect(
            origin: CGPoint(x: buttonOriginX, y: originY),
            size: CGSize(width: buttonWidth, height: buttonHeight))
        )
        confirmButton.setTitle(confirmButtonItem?.title, for: .normal)
        confirmButton.addTarget(self, action: #selector(onClickAlertButton), for: .touchUpInside)
        confirmButton.tag = 1
        return confirmButton
    }
    
    // MARK: Orientation
    @objc
    func orientationChanged(_ notification: NSNotification) {
        let currentOrientation = UIDevice.current.orientation
        
        if prevOrientation.isPortrait && currentOrientation.isLandscape ||
            prevOrientation.isLandscape && currentOrientation.isPortrait {
            dismiss()
        }

        self.prevOrientation = currentOrientation
    }
}
