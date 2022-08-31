//
//  UIApplication+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/03/15.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    public var currentWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let window = windowScene?.windows.first { $0.isKeyWindow }
            return window
        } else {
            return UIApplication.shared.keyWindow
        }
    }
}
