//
//  UILabel+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/01.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UILabel {
    func changeColor(_ color: UIColor, duration: TimeInterval) {
        UIView.transition(
            with: self,
            duration: duration,
            options: .transitionCrossDissolve,
            animations: {
                self.textColor = color
            },
            completion: nil)
    }
}
