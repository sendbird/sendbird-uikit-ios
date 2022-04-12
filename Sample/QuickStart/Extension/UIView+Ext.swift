//
//  UIView+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/01.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIView {
    func animateBorderColor(toColor: UIColor, duration: Double) {
        let animation:CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        animation.fromValue = layer.borderColor
        animation.toValue = toColor.cgColor
        animation.duration = duration
        layer.add(animation, forKey: "borderColor")
        layer.borderColor = toColor.cgColor
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.3
        animation.values = [-10.0, 10.0, -5.0, 5.0, -2.5, 2.5, 0.0 ].map { $0 * 0.7 }
        layer.add(animation, forKey: "shake")
    }
    
    func highlight() {
        UIView.highlight(self)
    }
    
    static func highlight(_ view: UIView) {
        view.layer.cornerRadius = 5
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 2
        for v in view.subviews { highlight(v) }
    }
}
