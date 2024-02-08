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

public class SBULoading: NSObject {
    static private let shared = SBULoading()
    
    var window: UIWindow?
    var baseView = UIView()
    var backgroundView = SBULoadingDimView()
    var spinner = UIImageView()
    
    private var rotationLayer: CAAnimation = {
        let rotation = CABasicAnimation(keyPath: "transform.rotation")
        rotation.fromValue = 0
        rotation.toValue = 2 * Double.pi
        rotation.duration = 1.1
        rotation.repeatCount = Float.infinity
        return rotation
    }()
    private var rectLayer: CAShapeLayer = CAShapeLayer()
    
    let itemSize: CGFloat = 100.0
    let spinnerSize: CGFloat = 64.0
    
    private override init() {
        super.init()
    }
    
    /// This static function starts the loading indicator.
    public static func start() {
        guard !SBULoading.shared.isShowing else { return }
        SBULoading.shared.show()
    }
    
    /// This static function stops the loading indicator.
    public static func stop() {
        SBULoading.shared.dismiss()
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
    
    private func setupStyles() {
        let theme = SBUTheme.componentTheme
        
        self.backgroundView.backgroundColor = theme.loadingBackgroundColor
        self.baseView.backgroundColor = theme.loadingPopupBackgroundColor
        
        self.spinner.image = SBUIconSetType.iconSpinner.image(with: theme.loadingSpinnerColor, to: SBUIconSetType.Metric.iconSpinnerLarge)
    }
    
    private func show() {
        self.window = UIApplication.shared.currentWindow
        guard let window = self.window else { return }
        
        // Set backgroundView
        self.backgroundView.frame = self.window?.bounds ?? .zero
        
        // BaseView
        self.baseView.frame = CGRect(x: 0, y: 0, width: itemSize, height: itemSize)
        
        self.spinner.frame = CGRect(x: 0, y: 0, width: spinnerSize, height: spinnerSize)
        self.spinner.center = baseView.center
        self.baseView.addSubview(self.spinner)
        
        // RoundRect
        rectLayer.bounds = self.baseView.frame
        rectLayer.position = self.baseView.center
        rectLayer.path = UIBezierPath(
            roundedRect: self.baseView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 5, height: 5)
        ).cgPath
        self.baseView.layer.mask = self.rectLayer
        
        self.spinner.layer.add(self.rotationLayer, forKey: SBUAnimation.Key.spin.identifier)
        
        self.setupStyles()
        
        // Add to window
        window.addSubview(self.backgroundView)
        self.baseView.center = window.center
        window.addSubview(self.baseView)
        
        self.baseView.alpha = 0.0
        UIView.animate(withDuration: 0.2, animations: {
            self.baseView.alpha = 1.0
        })
    }
    
    private var isShowing: Bool {
        self.baseView.superview != nil
    }
    
    @objc private func dismiss() {
        self.spinner.layer.removeAnimation(forKey: SBUAnimation.Key.spin.identifier)
        for subView in self.baseView.subviews {
            subView.removeFromSuperview()
        }
        
        self.backgroundView.removeFromSuperview()
        self.baseView.removeFromSuperview()
    }
}

class SBULoadingDimView: UIView {
    weak var dataSource: SBULoadingDataSource?

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let dataSource = self.dataSource else { return super.hitTest(point, with: event) }
        
        if  dataSource.shouldPassTouchHit(point, with: event) == false {
            return super.hitTest(point, with: event)
        } else {
            return nil
        }
    }
}
