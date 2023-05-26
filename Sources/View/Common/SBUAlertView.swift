//
//  SBUAlertView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 16/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public typealias AlertButtonHandler = (_ info: Any?) -> Void

public protocol SBUAlertViewDelegate: AnyObject {
    /// Called when `SBUAlertView` is dismiss
    func didDismissAlertView()
}

public class SBUAlertButtonItem {
    var title: String
    var color: UIColor?
    var completionHandler: AlertButtonHandler?
    
    /// This function initializes alert button item.
    /// - Parameters:
    ///   - title: Button's title text
    ///   - color: Button's title color
    ///   - completionHandler: Button's completion handler
    public init(title: String,
                color: UIColor? = nil,
                completionHandler: @escaping AlertButtonHandler) {
        self.title = title
        self.color = color
        self.completionHandler = completionHandler
    }
}

public class SBUAlertView: NSObject {
    static private let shared = SBUAlertView()
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    var window: UIWindow?
    var baseView = UIView()
    var backgroundView = UIButton()
    var inputField = UITextField()
    var centerYRatio: CGFloat = 1.0
    
    var confirmItem: SBUAlertButtonItem?
    var cancelItem: SBUAlertButtonItem?
    var dismissHandler: (() -> Void)?
    
    let itemWidth: CGFloat = 270.0
    let textInsideMargin: CGFloat = 3.0
    let textTopBottomMargin: CGFloat = 20.0
    let inputAreaHeight: CGFloat = 32.0
    let inputAreaMargin: CGFloat = 32.0
    let inputBottomMargin: CGFloat = 18.5
    let buttonHeight: CGFloat = 44.0
    let sideMargin: CGFloat = 16.0
    
    let itemHeight: CGFloat = 40.0
    let leftMargin: CGFloat = 14.0
    let midMargin: CGFloat = 8.0
    let rightMargin: CGFloat = 18.0
    let topBottomMargin: CGFloat = 8.0
    
    let bufferMargin: CGFloat = 8.0
    
    var prevOrientation: UIDeviceOrientation = .unknown
    
    weak var delegate: SBUAlertViewDelegate?

    private override init() {
        super.init()
    }
    
    /// This static function shows the alertView.
    /// - Parameters:
    ///   - title: Title text
    ///   - message: Message text (default: nil)
    ///   - needInputField: If an input field is required, set value to `true`.
    ///   - placeHolder: Placeholder text (default: "")
    ///   - centerYRatio: AlertView's centerY ratio.
    ///   - oneTimetheme: One-time theme setting
    ///   - confirmButtonItem: Confirm button item
    ///   - cancelButtonItem: Cancel button item (nullable)
    ///   - delegate: AlertView delegate
    public static func show(title: String,
                            message: String? = nil,
                            needInputField: Bool = false,
                            placeHolder: String? = "",
                            centerYRatio: CGFloat? = 1.0,
                            oneTimetheme: SBUComponentTheme? = nil,
                            confirmButtonItem: SBUAlertButtonItem,
                            cancelButtonItem: SBUAlertButtonItem?,
                            delegate: SBUAlertViewDelegate? = nil,
                            dismissHandler: (() -> Void)? = nil) {
        self.shared.show(
            title: title,
            message: message,
            needInputField: needInputField,
            placeHolder: placeHolder,
            centerYRatio: centerYRatio,
            oneTimetheme: oneTimetheme,
            confirmButtonItem: confirmButtonItem,
            cancelButtonItem: cancelButtonItem,
            delegate: delegate,
            dismissHandler: dismissHandler
        )
    }
    
    /// This static function dismissed the alert.
    public static func dismiss() {
        self.shared.dismiss()
    }
    
    private func show(title: String,
                      message: String? = nil,
                      needInputField: Bool = false,
                      placeHolder: String? = "",
                      centerYRatio: CGFloat? = 1.0,
                      oneTimetheme: SBUComponentTheme? = nil,
                      confirmButtonItem: SBUAlertButtonItem,
                      cancelButtonItem: SBUAlertButtonItem?,
                      delegate: SBUAlertViewDelegate?,
                      dismissHandler: (() -> Void)? = nil) {
        
        self.delegate = delegate
        
        self.handleDismiss(isUserInitiated: false)
        
        self.prevOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
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
        
        if let oneTimetheme = oneTimetheme {
            self.theme = oneTimetheme
        }
        
        if let centerYRatio = centerYRatio {
            self.centerYRatio = centerYRatio
        }
        
        self.window = UIApplication.shared.currentWindow
        guard let window = self.window else { return }
        
        self.confirmItem = confirmButtonItem
        self.cancelItem = cancelButtonItem
        self.dismissHandler = dismissHandler
        
        // Set backgroundView
        self.backgroundView.frame = self.window?.bounds ?? .zero
        self.backgroundView.backgroundColor = theme.overlayColor
        self.backgroundView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        // Calc total height
        var totalHeight: CGFloat = 0.0
        let insideItemWidth = itemWidth - sideMargin*2
        
        let titleHeight = self.getTextHeight(
            text: title,
            maxSize: CGSize(width: insideItemWidth, height: CGFloat.greatestFiniteMagnitude),
            font: theme.alertTitleFont
        )
        totalHeight += titleHeight

        var messageHeight: CGFloat = 0.0
        if let message = message {
            messageHeight = self.getTextHeight(
                text: message,
                maxSize: CGSize(width: insideItemWidth, height: CGFloat.greatestFiniteMagnitude),
                font: theme.alertDetailFont
            )
            totalHeight += (textInsideMargin + messageHeight)
        }
        
        if needInputField {
             // top, text-input, input, input-button
            totalHeight += (inputAreaMargin + inputAreaMargin + inputAreaHeight + inputBottomMargin)
        } else {
             // top, text-button
            totalHeight += (textTopBottomMargin + textTopBottomMargin)
        }
        
        totalHeight += buttonHeight
        
        // Set baseView
        self.baseView.frame = CGRect(
            origin: .zero,
            size: CGSize(width: self.itemWidth, height: totalHeight)
        )
        self.baseView.backgroundColor = theme.backgroundColor
        
        // Set items
        let titleLabel = UILabel(frame: CGRect(
            origin: CGPoint(
                x: sideMargin,
                y: (needInputField ? inputAreaMargin : textTopBottomMargin)
            ),
            size: CGSize(width: insideItemWidth, height: titleHeight))
        )
        titleLabel.numberOfLines = 0
        titleLabel.font = theme.alertTitleFont
        titleLabel.textColor = theme.alertTitleColor
        titleLabel.text = title
        titleLabel.textAlignment = .center
        self.baseView.addSubview(titleLabel)
        
        var originY = titleLabel.frame.maxY
        
        if let message = message {
            let messageLabel = UILabel(frame: CGRect(
                origin: CGPoint(x: sideMargin, y: originY + textInsideMargin),
                size: CGSize(width: insideItemWidth, height: messageHeight))
            )
            messageLabel.numberOfLines = 0
            messageLabel.font = theme.alertDetailFont
            messageLabel.textColor = theme.alertDetailColor
            messageLabel.text = message
            messageLabel.textAlignment = .center
            self.baseView.addSubview(messageLabel)
            originY = messageLabel.frame.maxY
        }
        
        if needInputField {
            self.inputField = UITextField(frame: CGRect(
                origin: CGPoint(x: sideMargin, y: originY + inputAreaMargin),
                size: CGSize(width: insideItemWidth, height: inputAreaHeight))
            )
            inputField.backgroundColor = theme.alertTextFieldBackgroundColor
            inputField.font = theme.alertTextFieldFont
            inputField.textColor = theme.alertTitleColor
            let paddingView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
            inputField.placeholder = placeHolder
            inputField.leftView = paddingView
            inputField.leftViewMode = .always
            inputField.rightView = paddingView
            inputField.rightViewMode = .always
            inputField.attributedPlaceholder = NSAttributedString(
                string: placeHolder ?? "",
                attributes: [NSAttributedString.Key.foregroundColor: theme.alertDetailColor]
            )
            self.baseView.addSubview(inputField)
            originY = inputField.frame.maxY + inputBottomMargin
        } else {
            originY += textTopBottomMargin
        }
        
        let separator = UIView(frame: CGRect(
            origin: CGPoint(x: 0, y: originY-0.5),
            size: CGSize(width: itemWidth, height: 0.5))
        )
        separator.backgroundColor = theme.separatorColor
        self.baseView.addSubview(separator)

        let buttonWidth = (cancelButtonItem == nil) ? itemWidth : itemWidth/2
        var buttonOriginX: CGFloat = 0.0
        if let cancelButtonItem = cancelButtonItem {
            let cancelButton = UIButton(
                frame: CGRect(
                    origin: CGPoint(x: buttonOriginX, y: originY),
                    size: CGSize(width: buttonWidth, height: buttonHeight)
                )
            )
            cancelButton.titleLabel?.font = theme.alertButtonFont
            cancelButton.titleLabel?.textColor = theme.alertButtonColor
            cancelButton.setTitle(cancelButtonItem.title, for: .normal)
            cancelButton.setTitleColor(cancelButtonItem.color ?? theme.alertButtonColor, for: .normal)
            cancelButton.addTarget(self, action: #selector(onClickAlertButton), for: .touchUpInside)
            cancelButton.tag = 0
            cancelButton.setBackgroundImage(UIImage.from(color: theme.backgroundColor), for: .normal)
            cancelButton.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
            
            let separatorLine = UIView(frame: CGRect(
                origin: cancelButton.frame.origin,
                size: CGSize(width: 0.5, height: buttonHeight))
            )
            separatorLine.backgroundColor = theme.separatorColor
            cancelButton.addSubview(separatorLine)
            
            buttonOriginX += buttonWidth
            
            self.baseView.addSubview(cancelButton)
        }
        
        let confirmButton = UIButton(frame: CGRect(
            origin: CGPoint(x: buttonOriginX, y: originY),
            size: CGSize(width: buttonWidth, height: buttonHeight))
        )
        confirmButton.titleLabel?.font = theme.alertButtonFont
        confirmButton.setTitle(confirmButtonItem.title, for: .normal)
        confirmButton.setTitleColor(confirmButtonItem.color ?? theme.alertButtonColor, for: .normal)
        confirmButton.addTarget(self, action: #selector(onClickAlertButton), for: .touchUpInside)
        confirmButton.tag = 1
        confirmButton.setBackgroundImage(UIImage.from(color: theme.backgroundColor), for: .normal)
        confirmButton.setBackgroundImage(UIImage.from(color: theme.highlightedColor), for: .highlighted)
        self.baseView.addSubview(confirmButton)
        
        // RoundRect
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.baseView.frame
        rectShape.position = self.baseView.center
        rectShape.path = UIBezierPath(
            roundedRect: self.baseView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 10, height: 10)
        ).cgPath
        self.baseView.layer.mask = rectShape
        
        if needInputField {
            let rectShape = CAShapeLayer()
            rectShape.bounds = self.inputField.frame
            rectShape.position = self.inputField.center
            rectShape.path = UIBezierPath(
                roundedRect: self.inputField.bounds,
                byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
                cornerRadii: CGSize(width: 5, height: 5)
            ).cgPath
            self.inputField.layer.mask = rectShape
        }

        // Add to window
        window.addSubview(self.backgroundView)
        self.baseView.center = CGPoint(
            x: window.center.x,
            y: window.center.y * self.centerYRatio
        )
        window.addSubview(self.baseView)
        
        // Animation
        let baseFrame = self.baseView.frame
        self.baseView.frame = CGRect(
            origin: CGPoint(x: baseFrame.origin.x, y: window.frame.height),
            size: baseFrame.size
        )
        self.backgroundView.alpha = 0.0
        UIView.animate(withDuration: 0.1, animations: {
            self.backgroundView.alpha = 1.0
        }) { _ in
            self.baseView.frame = baseFrame
            
            if needInputField {
                self.inputField.becomeFirstResponder()
            }
        }
    }
    
    @objc private func dismiss() {
        handleDismiss(isUserInitiated: true)
    }
    
    @objc private func handleDismiss(isUserInitiated: Bool) {
        for subView in self.baseView.subviews {
            subView.removeFromSuperview()
        }
        
        self.confirmItem = nil
        self.cancelItem = nil
        
        self.inputField = UITextField()
        self.backgroundView.removeFromSuperview()
        self.baseView.removeFromSuperview()
        
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
            handler?()
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard  let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        UIView.animate(withDuration: 0.1, animations: {
            guard let window = self.window else { return }
            
            self.baseView.center.y = ((window.frame.height - keyboardFrame.cgRectValue.height) / 2) * self.centerYRatio
        })
    }
    
    @objc private func keyboardWillHide() {
        UIView.animate(withDuration: 0.1, animations: {
            guard let window = self.window else { return }
            
            self.baseView.center.y = window.center.y * self.centerYRatio
        })
    }
    
    // MARK: Common
    private func getTextHeight(text: String, maxSize: CGSize, font: UIFont) -> CGFloat {
        let rect = NSString(string: text).boundingRect(
            with: maxSize,
            options: NSStringDrawingOptions.usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: font],
            context: nil
        )
        return rect.height
    }
    
    // MARK: Button action
    @objc private func onClickAlertButton(sender: UIButton) {
        let index = sender.tag
        if cancelItem != nil, index == 0 {
            self.cancelItem?.completionHandler?(nil)
            dismiss()
        } else {
            self.confirmItem?.completionHandler?(self.inputField.text)
            dismiss()
        }
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
