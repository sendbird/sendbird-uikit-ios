//
//  SBULoading.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 28/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBULoading: NSObject {
    static private let shared = SBULoading()
    private override init() {}
    
    var window: UIWindow? = nil
    var baseView = UIView()
    var backgroundView = UIButton()
    var spinner = UIImageView()

    private var label: UILabel = UILabel()
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
    
    
    /// This static function starts the loading indicator.
    public static func start() {
        guard !SBULoading.shared.isShowing() else { return }
        SBULoading.shared.show()
    }
    
    /// This static function stops the loading indicator.
    public static func stop() {
        SBULoading.shared.dismiss()
    }
    
    private func setupStyles() {
        let theme = SBUTheme.componentTheme
        
        self.backgroundView.backgroundColor = theme.loadingBackgroundColor
        self.baseView.backgroundColor = theme.loadingPopupBackgroundColor
        
        self.label.font = theme.loadingFont
        self.label.textColor = theme.loadingTextColor
        
        self.spinner.image = SBUIconSetType.iconSpinner.image(with: theme.loadingSpinnerColor, to: SBUIconSetType.Metric.iconSpinnerLarge)
    }
    
    private func show() {
        self.window = UIApplication.shared.keyWindow
        guard let window = self.window else { return }
        
        // Set backgroundView
        self.backgroundView.frame = self.window?.bounds ?? .zero
//        self.backgroundView.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        // BaseView
        self.baseView.frame = CGRect(x: 0, y: 0, width: itemSize, height: itemSize)
        
        self.spinner.frame = CGRect(x: 30, y: 16, width: 40, height: 40)
        self.baseView.addSubview(self.spinner)
        
        self.label.frame = CGRect(x: 14, y: self.spinner.frame.maxY + 8, width: 72, height: 24)
        label.text = SBUStringSet.Loading
        self.baseView.addSubview(label)
                
        // RoundRect
        rectLayer.bounds = self.baseView.frame
        rectLayer.position = self.baseView.center
        rectLayer.path = UIBezierPath(
            roundedRect: self.baseView.bounds,
            byRoundingCorners: [.topLeft, .topRight, .bottomLeft, .bottomRight],
            cornerRadii: CGSize(width: 5, height: 5)
        ).cgPath
        self.baseView.layer.mask = self.rectLayer
        
        self.spinner.layer.add(self.rotationLayer, forKey: SBUAnimation.Key.spin.rawValue)
        
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
    
    private func isShowing() -> Bool {
        return self.baseView.superview != nil
    }
    
    @objc private func dismiss() {
        self.spinner.layer.removeAnimation(forKey: SBUAnimation.Key.spin.rawValue)
        for subView in self.baseView.subviews {
            subView.removeFromSuperview()
        }
        
        self.backgroundView.removeFromSuperview()
        self.baseView.removeFromSuperview()
    }
}
