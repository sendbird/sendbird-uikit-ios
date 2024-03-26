//
//  SBUToastView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/01/15.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Typealias for a closure that handles the dismissal of the toast view. 
/// This closure, ``SBUToastViewHandler``, does not return a value and does not take any parameters.
public typealias SBUToastViewHandler = () -> Void

/// Toast view delegate
/// - Since: 3.15.0
public protocol SBUToastViewDelegate: NSObjectProtocol {
    func didDismissToastView()
}

extension SBUToastViewDelegate {
    /// This function is called when the toast view is dismissed.
    public func didDismissToastView() {}
}

/// Toast view item for setting data.
/// - Since: 3.15.0
public class SBUToastViewItem: SBUCommonItem {
    var position: Position
    var duration: Double
    var completionHandler: SBUToastViewHandler?
    
    /// This function initializes toast view item.
    /// - Parameters:
    ///   - position: Toast position
    ///   - duration: Toast duration (default: 1.5 second)
    ///   - image: Item image
    ///   - title: Title text
    ///   - color: Title color
    ///   - font: Title font
    ///   - textAlignment: Title alignment
    ///   - tag: Item tag
    ///   - completionHandler: Item's completion handler
    public init(
        position: Position = .center,
        duration: Double = 1.5,
        title: String? = nil,
        color: UIColor? = nil,
        image: UIImage? = nil,
        font: UIFont? = nil,
        textAlignment: NSTextAlignment = .left,
        tag: Int? = nil
    ) {

        self.position = position
        self.duration = duration
        self.completionHandler = nil
        super.init(
            title: title,
            color: color,
            image: image,
            font: font,
            tintColor: nil,
            textAlignment: textAlignment,
            tag: tag
        )
    }
        
    /// Toast View position
    public enum Position {
        case top(padding: CGFloat? = nil)
        case center
        case bottom(padding: CGFloat? = nil)
//        case custom(CGPoint) // TODO
    }
}

/// A toast view window object, used as a singleton.
/// - Since: 3.15.0
public class SBUToastView: NSObject {
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    static private let shared = SBUToastView()
    
    weak var delegate: SBUToastViewDelegate?
    
    private var item: SBUToastViewItem?
    private var dismissHandler: SBUToastViewHandler?
    
    private var safeAreaInset: UIEdgeInsets {
        self.window?.safeAreaInsets ?? .zero
    }
    
    var identifier: Int = -1
    var window: UIWindow?
    var baseView = UIView()
    
    let contianerAlpha: CGFloat = 0.64
    let itemSpacing: CGFloat = 8.0
    let basePadding: UIEdgeInsets = .init(top: 30, left: 12, bottom: 30, right: 12)
    let itemHeight: CGFloat = 48.0
    let itemPadding: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    let itemWithIconPadding: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 16)

    var prevOrientation: UIDeviceOrientation = .unknown
    
    var isShowing: Bool = false
    
    private override init() {
        super.init()
    }
    
    /// This static function shows the toast view.
    ///
    /// See the example below for params generation.
    /// ```
    /// SBUToastView.show(
    ///     items: SBUToastViewItem(title: TITLE1, image: IMAGE1)
    /// )
    /// ```
    /// - Parameters:
    ///   - items: Item array
    ///   - cancelItem: Cancel item
    ///   - identifier: Toast view identifier
    ///   - oneTimetheme: One-time theme setting
    ///   - delegate: Toast view delegate
    public static func show(
        item: SBUToastViewItem,
        identifier: Int = -1,
        oneTimetheme: SBUComponentTheme? = nil,
        delegate: SBUToastViewDelegate? = nil,
        dismissHandler: SBUToastViewHandler? = nil
    ) {
        Thread.executeOnMain {
            SBUToastView.shared.show(
                item: item,
                identifier: identifier,
                oneTimetheme: oneTimetheme,
                delegate: delegate,
                dismissHandler: dismissHandler
            )
        }
    }
    
    /// This static function dismissed.
    public static func dismiss() {
        Thread.executeOnMain {
            SBUToastView.shared.dismiss()
        }
    }

    private func show(
        item: SBUToastViewItem,
        identifier: Int = -1,
        oneTimetheme: SBUComponentTheme? = nil,
        delegate: SBUToastViewDelegate?,
        dismissHandler: SBUToastViewHandler?
    ) {
        
        self.handleDismiss(isUserInitiated: false)
        
        self.prevOrientation = UIDevice.current.orientation
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(orientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
        
        if let oneTimetheme = oneTimetheme {
            self.theme = oneTimetheme
        }
        
        self.window = UIApplication.shared.currentWindow
        guard let window = self.window else { return }
        self.identifier = identifier
        self.delegate = delegate
        self.item = item
        self.dismissHandler = dismissHandler
        
        self.baseView = UIView()
        self.baseView.isUserInteractionEnabled = false
        // Set item
        let container = UIView()
        container.alpha = self.contianerAlpha
        container.backgroundColor = oneTimetheme?.toastContainerColor ?? theme.toastContainerColor
        container.layer.cornerRadius = 24
        
        let stackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 8)
        
        let label = UILabel()
        label.font = item.font
        label.textColor = item.color ?? oneTimetheme?.toastTitleColor ?? theme.toastTitleColor
        label.text = item.title
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(UILayoutPriority(1000), for: .horizontal)
        stackView.addArrangedSubview(label)
        
        if let image = item.image {
            let imageView = UIImageView()
            imageView.image = image
            stackView.insertArrangedSubview(imageView, at: 0)
            imageView.sbu_constraint(width: 24, height: 24)
        }
        
        window.addSubview(self.baseView)
        
        self.baseView.addSubview(container)
        container.addSubview(stackView)
        
        if item.image != nil {
            stackView.sbu_constraint(
                equalTo: container,
                left: itemWithIconPadding.left,
                right: itemWithIconPadding.right,
                top: itemWithIconPadding.top,
                bottom: itemWithIconPadding.bottom
            )
        } else {
            stackView.sbu_constraint(
                equalTo: container,
                left: itemPadding.left,
                right: itemPadding.right,
                top: itemPadding.top,
                bottom: itemPadding.bottom
            )
        }

        container
            .sbu_constraint(equalTo: self.baseView, centerX: self.baseView.bounds.width / 2, priority: .defaultHigh)
            .sbu_constraint(height: itemHeight, priority: .defaultLow)
            .sbu_constraint(
                greaterThanOrEqualTo: self.baseView,
                left: basePadding.left,
                right: basePadding.right,
                priority: .defaultLow
            )

        self.baseView.sbu_constraint(equalTo: window, left: 0, right: 0, top: 0, bottom: 0)

        switch self.item?.position {
        case .top(let padding):
            let top = safeAreaInset.top + (padding ?? self.basePadding.top)
            container.sbu_constraint(equalTo: self.baseView, top: top, priority: .defaultHigh)
        case .bottom(let padding):
            let bottom = safeAreaInset.bottom + (padding ?? self.basePadding.bottom)
            container.sbu_constraint(equalTo: self.baseView, bottom: bottom, priority: .defaultHigh)
        case .center:
            container.sbu_constraint(equalTo: self.baseView, centerY: self.baseView.bounds.height / 2, priority: .defaultHigh)
            
        case .none:
            container.sbu_constraint(equalTo: self.baseView, centerY: self.baseView.bounds.height / 2, priority: .defaultHigh)
        }
        
        // Animation
        let baseFrame = self.baseView.frame
        self.baseView.frame = CGRect(
            origin: CGPoint(x: baseFrame.origin.x, y: window.frame.height),
            size: baseFrame.size
        )
        self.isShowing = true
        self.baseView.alpha = 0.0
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.baseView.alpha = 1.0
            },
            completion: { _ in
                self.baseView.frame = baseFrame
                self.isShowing = false
                let duration = self.item?.duration ?? 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    self.dismiss()
                }
            })
    }
    
    @objc
    private func dismiss() {
        guard !isShowing else { return }

        self.handleDismiss(isUserInitiated: true)
    }
    
    @objc
    private func handleDismiss(isUserInitiated: Bool = true) {
        self.item = nil
        self.baseView.alpha = 1.0
        
        if isUserInitiated == true {
            self.baseView.alpha = 1.0
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.baseView.alpha = 0.0
                },
                completion: { _ in
                    self.baseView.removeFromSuperview()
                })
        } else {
            self.baseView.alpha = 0.0
            self.baseView.removeFromSuperview()
        }
        
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
        
        if isUserInitiated {
            self.delegate?.didDismissToastView()
            let handler = self.dismissHandler
            self.dismissHandler = nil
            handler?()
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

extension SBUToastView {
    static func show(type: SBUToastType) {
        show(item: type.item)
    }
}
