//
//  UINavigationController+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/04/09.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

extension UINavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}
