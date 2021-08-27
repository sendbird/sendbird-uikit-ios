//
//  UIViewController+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // Not using now
    @objc func sbu_loadViewFromNib() {
        guard let view = Bundle(identifier: "com.sendbird.uikit")?.loadNibNamed(
            String(describing: type(of: self)),
            owner: self,
            options: nil
            )?.first as? UIView else { return }
        
        view.frame = self.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(view, at: 0)
    }
}
