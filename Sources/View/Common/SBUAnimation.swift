//
//  SBUAnimation.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/08/20.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - Animation
// TODO: Change to public when a several animations are ready.
/**
 The class provides several animation for `UIView`.
 
 To add custom animation, declare a new `SBUAnimation` instance as static.
 
 ```swift
 extension SBUAnimation {
    static let custom: SBUAnimation = {
        let animation = SBUAnimation { view in
            startToPlayCustomAnimation(on: View)
        }
    }
 }
 ```
 */
class SBUAnimation {
    enum Key: String {
        case spin = "spin"
        
        var identifier: String {
            "\(SBUConstant.bundleIdentifier).animation.key.\(self.rawValue)"
        }
    }
    /**
     Shakes view vertically.
     
     | Direction | Type | Duration (sec) |
     | --- | --- | --- |
     | up | ease in&out | 0.5 |
     | down | ease in&out | 0.1 |
     | up | ease in&out | 0.2 |
     | down | ease in&out | 0.1 |
     
     ```swift
     someView.animate(.shakeUpDown)
     */
    static let shakeUpDown: SBUAnimation = {
        let animation = SBUAnimation { view in
            SBUAnimation.shakeUpDown(on: view)
        }
        return animation
    }()
    
    let animate: (_ view: UIView) -> Void
    
    init(animate: @escaping (_ view: UIView) -> Void) {
        self.animate = animate
    }
    
    private struct UpDownShake {
        private let view: UIView
        private let moveCount: Int
        private let timeline: [Double]
        private let originalTransform: CGAffineTransform
        private let translatedTransform: CGAffineTransform
        
        init(view: UIView) {
            self.view = view
            self.moveCount = 4
            self.timeline = [0.5, 0.1, 0.2, 0.1]
            self.originalTransform = view.transform
            self.translatedTransform = originalTransform.translatedBy(x: 0, y: -10.0)
        }
        
        func startToAnimate() {
            self.shakeUpDown(0)
        }
        
        private func shakeUpDown(_ count: Int) {
            UIView.animate(withDuration: timeline[count], delay: 0.0, options: .curveEaseInOut) {
                view.transform = count % 2 == 0
                ? translatedTransform
                : originalTransform
            } completion: { _ in
                let nextCount = count + 1
                guard nextCount < moveCount else { return }
                self.shakeUpDown(nextCount)
            }
        }
    }
    
    private static func shakeUpDown(on view: UIView) {
        let animation = UpDownShake(view: view)
        animation.startToAnimate()
    }
}

extension UIView {
    /**
     Animates a specific animation that is defined in `SBUAnimation`
     
     ```swift
     messageView.animate(.shakeUpDown)
     ```
     
     To customize animation, refer to `SBUAnimation`
     
     - version: 2.2.0
     */
    func animate(_ animation: SBUAnimation) {
        animation.animate(self)
    }
}
