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

/// This class is used to create and manage toast view in the application.
/// - Since: 3.15.0
open class SBUToastView: NSObject, SBUViewLifeCycle {
    // Public
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    public private(set)weak var delegate: SBUToastViewDelegate?
    
    /// The parent view where the toast view will be presented. By default, it is set to the application's current window.
    public var parentView: UIView? = UIApplication.shared.currentWindow
    public private(set) var identifier: Int = -1
    public private(set) var isShowing: Bool = false
    public private(set) var item: SBUToastViewItem?

    public private(set) var backgroundView = UIView()
    public private(set) var containerView = UIView()
    public private(set) var stackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 8)
    public private(set) var label = UILabel()
    
    public var containerAlpha: CGFloat = 0.64
    public var containerCornerRadius: CGFloat = 24.0
    
    public var basePadding: UIEdgeInsets = .init(top: 30, left: 12, bottom: 30, right: 12)
    public var itemHeight: CGFloat = 48.0
    public var itemPadding: UIEdgeInsets = .init(top: 12, left: 16, bottom: 12, right: 16)
    public var itemWithIconPadding: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 16)
    
    // Private
    static private var shared = SBUModuleSet.CommonModule.ToastView.init()
    
    static func resetInstance() {
        shared.dismiss()
        shared = SBUModuleSet.CommonModule.ToastView.init()
    }
    
    private var dismissHandler: SBUToastViewHandler?
    private var dismissWorkItem: DispatchWorkItem?
    
    private var safeAreaInset: UIEdgeInsets {
        self.parentView?.safeAreaInsets ?? .zero
    }
    
    var prevOrientation: UIDeviceOrientation = UIDevice.current.orientation
    
    required public override init() {
        super.init()
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        self.setupActions()
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
    ///   - item: Item array
    ///   - identifier: Toast view identifier
    ///   - oneTimetheme: One-time theme setting
    ///   - delegate: Toast view delegate
    ///   - dismissHandler: Toast view dismiss handler
    open class func show(
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
    open class func dismiss() {
        Thread.executeOnMain {
            SBUToastView.shared.dismiss()
        }
    }
    
    // MARK: Lifecycle
    open func configureView() {
        self.label.text = self.item?.title

        if let image = self.item?.image {
            let imageView = UIImageView()
            imageView.image = image
            stackView.insertArrangedSubview(imageView, at: 0)
            imageView.sbu_constraint(width: 24, height: 24)
        }
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        guard let parentView = self.parentView else { return }
        
        self.backgroundView.isUserInteractionEnabled = false
        
        self.label.numberOfLines = 0
        
        self.stackView.addArrangedSubview(self.label)
        self.containerView.addSubview(self.stackView)
        self.backgroundView.addSubview(self.containerView)
        parentView.addSubview(self.backgroundView)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.containerView.alpha = self.containerAlpha
        self.containerView.layer.cornerRadius = containerCornerRadius
    }
    
    /// This function updates styles.
    open func updateStyles() {
        self.containerView.backgroundColor = self.theme.toastContainerColor

        label.font = self.item?.font
        label.textColor = self.item?.color ?? self.theme.toastTitleColor
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() {
        self.label.setContentCompressionResistancePriority(UILayoutPriority(751), for: .horizontal)
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// This function updates layouts.
    open func updateLayouts() {
        if let parentView = self.parentView {
            self.backgroundView.sbu_constraint(
                equalTo: parentView,
                left: 0,
                right: 0,
                top: 0,
                bottom: 0
            )
        }
        
        self.containerView
            .sbu_constraint(
                equalTo: self.backgroundView,
                centerX: 0
            )
            .sbu_constraint(height: itemHeight, priority: .defaultLow)
            .sbu_constraint(
                greaterThanOrEqualTo: self.backgroundView,
                left: basePadding.left
            )
            .sbu_constraint(
                lessThanOrEqualTo: self.backgroundView,
                right: basePadding.right
            )

        let padding = self.item?.image != nil ? itemWithIconPadding : itemPadding
        self.stackView.sbu_constraint(
            equalTo: self.containerView,
            left: padding.left,
            right: padding.right,
            top: padding.top,
            bottom: padding.bottom
        )
        
        switch self.item?.position {
        case .top(let padding):
            let top = safeAreaInset.top + (padding ?? self.basePadding.top)
            self.containerView.sbu_constraint(
                equalTo: self.backgroundView,
                top: top,
                priority: .defaultHigh
            )
        case .bottom(let padding):
            let bottom = safeAreaInset.bottom + (padding ?? self.basePadding.bottom)
            self.containerView.sbu_constraint(
                equalTo: self.backgroundView,
                bottom: bottom,
                priority: .defaultHigh
            )
        case .center:
            self.containerView.sbu_constraint(
                equalTo: self.backgroundView,
                centerY: 0,
                priority: .defaultHigh
            )
        case .none:
            self.containerView.sbu_constraint(
                equalTo: self.backgroundView,
                centerY: 0,
                priority: .defaultHigh
            )
        }
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() { }
}

// MARK: - Private
extension SBUToastView {
    private func show(
        item: SBUToastViewItem,
        identifier: Int = -1,
        oneTimetheme: SBUComponentTheme? = nil,
        delegate: SBUToastViewDelegate?,
        dismissHandler: SBUToastViewHandler?
    ) {
        self.storeProperties(
            item: item,
            identifier: identifier,
            oneTimetheme: oneTimetheme,
            delegate: delegate,
            dismissHandler: dismissHandler
        )
        self.prepareForDisplay()
        self.configureView()
        self.updateStyles()
        self.updateLayouts()
        self.presentView()
    }

    /// Stores properties for the toast view.
    private func storeProperties(
        item: SBUToastViewItem,
        identifier: Int,
        oneTimetheme: SBUComponentTheme?,
        delegate: SBUToastViewDelegate?,
        dismissHandler: SBUToastViewHandler?
    ) {
        if let oneTimetheme = oneTimetheme {
            self.theme = oneTimetheme
        }

        self.identifier = identifier
        self.delegate = delegate
        self.item = item
        self.dismissHandler = dismissHandler
    }

    private func prepareForDisplay() {
        self.parentView = UIApplication.shared.currentWindow
        
        self.handleDismiss(isUserInitiated: false)
        self.addObserverForOrientation()

        self.stackView.addArrangedSubview(self.label)
        
        self.parentView?.addSubview(self.backgroundView)
    }

    private func resetDismissWork() {
        self.cancelDismissWork()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismiss()
        }
        self.dismissWorkItem = workItem
    }
    
    private func presentView() {
        self.resetDismissWork()
        
        self.isShowing = true
        self.backgroundView.alpha = 0.0
        UIView.animate(
            withDuration: 0.15,
            animations: {
                self.backgroundView.alpha = 1.0
            }, completion: { _ in
                self.isShowing = false
                let duration = self.item?.duration ?? 1.5
                guard let dismissWorkItem = self.dismissWorkItem else { return }
                DispatchQueue.main.asyncAfter(
                    deadline: .now() + duration,
                    execute: dismissWorkItem
                )
            }
        )
    }
    
    @objc
    private func dismiss() {
        guard !isShowing else { return }

        self.handleDismiss(isUserInitiated: true)
    }
    
    private func cancelDismissWork() {
        self.dismissWorkItem?.cancel()
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
    
    func removeObserverForOrientation() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    // MARK: Action
    @objc
    private func handleDismiss(isUserInitiated: Bool = true) {
        self.backgroundView.alpha = 1.0
        
        let resetConstraints = {
            // Reset layouts
            self.backgroundView.constraints.forEach {
                self.backgroundView.removeConstraint($0)
            }

            self.containerView.constraints.forEach {
                self.containerView.removeConstraint($0)
            }
            
            self.stackView.constraints.forEach {
                self.stackView.removeConstraint($0)
            }
        }
        
        let resetViews = {
            self.stackView.subviews.forEach {
                $0.removeFromSuperview()
            }
        }
        
        if isUserInitiated == true {
            self.backgroundView.alpha = 1.0
            UIView.animate(
                withDuration: 0.25,
                animations: {
                    self.backgroundView.alpha = 0.0
                },
                completion: { _ in
                    resetConstraints()
                    resetViews()
                })
        } else {
            self.backgroundView.alpha = 0.0
            resetConstraints()
            resetViews()
        }
        
        self.removeObserverForOrientation()
        
        if isUserInitiated {
            self.delegate?.didDismissToastView()
            let handler = self.dismissHandler
            self.dismissHandler = nil
            self.item = nil
            self.identifier = -1
            self.theme = SBUTheme.componentTheme
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
