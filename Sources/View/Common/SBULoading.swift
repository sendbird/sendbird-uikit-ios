//
//  SBULoading.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 28/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// SBULoading DataSource
/// - Since: 3.16.0
public protocol SBULoadingDataSource: AnyObject {
    /// SBULoading DataSource method for determining touch event handling in background view.
    /// - Parameters:
    ///   - point: A point specified in the receiver’s local coordinate system (bounds).
    ///   - event: The event object passed in from `hitTest(:)` of the `backgroundview` of the `SBULoading`.
    /// - Returns: A value for whether touch events should be passed through. If true, touch events for views following the loading view are processed.
    ///
    /// ```swift
    /// extension ViewController: SBULoadingDataSource {
    ///    func shouldPassTouchHit(_ point: CGPoint, with event: UIEvent?) -> Bool {
    ///       if self.navigationController?.navigationBar.frame.contains(point) == true {
    ///          return true // Returning `true` means the touch passed.
    ///       }
    ///       return false
    ///    }
    /// ```
    func shouldPassTouchHit(_ point: CGPoint, with event: UIEvent?) -> Bool
}

extension SBULoadingDataSource {
    func shouldPassTouchHit(_ point: CGPoint, with event: UIEvent?) -> Bool { false }
}

/// This class is used to create and manage loading indicator in the application.
open class SBULoading: NSObject, SBUViewLifeCycle {
    // Public
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    /// The parent view where the loading indicator will be presented. By default, it is set to the application's current window.
    public var parentView: UIView? = UIApplication.shared.currentWindow
    
    public private(set) var backgroundView = SBULoadingDimView()
    public private(set) var containerView = UIView()
    public private(set) var indicatorImageView = UIImageView()
    
    public var indicatorAnimation: CAAnimation = {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        return rotation
    }()
    
    public var containerSize: CGFloat = 100.0
    public var containerCornerRadius: CGFloat = 5.0
    public var indicatorImageSize: CGFloat = 64.0
    
    // Private
    static private var shared = SBUModuleSet.CommonModule.Loading.init()
    
    static func resetInstance() {
        shared.dismiss()
        shared = SBUModuleSet.CommonModule.Loading.init()
    }

    private var rectLayer: CAShapeLayer = CAShapeLayer()

    //
    required public override init() {
        super.init()
        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// This static function starts the loading indicator.
    public static func start() {
        Thread.executeOnMain {
            guard !SBULoading.shared.isShowing else { return }
            SBULoading.shared.show()
        }
    }
    
    /// This static function stops the loading indicator.
    public static func stop() {
        Thread.executeOnMain {
            SBULoading.shared.dismiss()
        }
    }
    
    /// This static function checks loading view showing status.
    ///
    /// - Since: 3.2.1
    public static var isShowing: Bool {
        SBULoading.shared.isShowing
    }
    
    /// This static function set SBULoading dataSource
    /// - Parameter dataSource: `SBULoadingDataSource` protocol.
    /// - Since: 3.16.0
    public static func setDataSource(dataSource: SBULoadingDataSource) {
        SBULoading.shared.backgroundView.dataSource = dataSource
    }
    
    /// This static function remove SBULoading dataSource
    /// - Since: 3.16.0
    public static func removeDataSource() {
        SBULoading.shared.backgroundView.dataSource = nil
    }
    
    // MARK: Lifecycle
    open func configureView() {
        self.indicatorImageView.layer.add(
            self.indicatorAnimation,
            forKey: SBUAnimation.Key.spin.identifier
        )
        
        self.indicatorImageView.image = SBUIconSetType.iconSpinner.image(
            with: theme.loadingSpinnerColor,
            to: SBUIconSetType.Metric.iconSpinnerLarge
        )
    }
    
    open func setupViews() {}
    
    open func setupStyles() {}
    
    open func updateStyles() {
        self.backgroundView.backgroundColor = self.theme.loadingBackgroundColor
        self.containerView.backgroundColor = theme.loadingPopupBackgroundColor
    }
    
    open func setupLayouts() {}
    
    open func updateLayouts() {
        guard let parentView = self.parentView else { return }
        
        // Set backgroundView
        self.backgroundView.frame = parentView.bounds
        
        // containerView
        self.containerView.frame = CGRect(x: 0, y: 0, width: containerSize, height: containerSize)
        
        self.indicatorImageView.frame = CGRect(x: 0, y: 0, width: indicatorImageSize, height: indicatorImageSize)
        self.indicatorImageView.center = containerView.center
        
        self.containerView.center = parentView.center
        
        // Animation
        rectLayer.bounds = self.containerView.frame
        rectLayer.position = self.containerView.center
        rectLayer.path = UIBezierPath(
            roundedRect: self.containerView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: containerCornerRadius, height: containerCornerRadius)
        ).cgPath
        self.containerView.layer.mask = self.rectLayer
        
    }
    
    open func setupActions() {}
}

public class SBULoadingDimView: UIView {
    weak var dataSource: SBULoadingDataSource?

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let dataSource = self.dataSource else { return super.hitTest(point, with: event) }
        
        if  dataSource.shouldPassTouchHit(point, with: event) == false {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}

// MARK: - Private
extension SBULoading {
    private func show() {
        self.prepareForDisplay()
        self.configureView()
        self.updateStyles()
        self.updateLayouts()
        self.presentView()
    }
    
    private func prepareForDisplay() {
        self.parentView = UIApplication.shared.currentWindow
        
        self.containerView.addSubview(self.indicatorImageView)
        
        self.parentView?.addSubview(self.backgroundView)
        guard let parentView else {
           return
        }
        self.containerView.center = parentView.center
        self.parentView?.addSubview(self.containerView)
    }
    
    private func presentView() {
        self.containerView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.containerView.alpha = 1.0
        })
    }
    
    private var isShowing: Bool {
        self.containerView.superview != nil
    }
    
    @objc
    private func dismiss() {
        self.indicatorImageView.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        for subView in self.containerView.subviews {
            subView.removeFromSuperview()
        }
        
        self.backgroundView.removeFromSuperview()
        self.containerView.removeFromSuperview()
        
        self.indicatorImageView = UIImageView()
        
        self.indicatorAnimation = {
            let rotation = CABasicAnimation(keyPath: "transform.rotation")
            rotation.fromValue = 0
            rotation.toValue = 2 * Double.pi
            rotation.duration = 1.1
            rotation.repeatCount = Float.infinity
            return rotation
        }()
        
        self.containerSize = 100.0
        self.indicatorImageSize = 64.0
    }
}
