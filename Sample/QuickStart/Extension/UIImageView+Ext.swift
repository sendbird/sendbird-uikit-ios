//
//  UIImageView+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/23.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UIImageView {
    open override var isAccessibilityElement: Bool {
        get { true }
        set { super.isAccessibilityElement = true }
    }
    
    func updateImage(urlString: String?) {
        guard let urlString = urlString, !urlString.isEmpty else {
            self.image = UIImage(named: "iconAvatar")
            return
        }
        
        self.loadImage(urlString: urlString)
    }
}
