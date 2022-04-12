//
//  UIViewController+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    // Not using now
    func sbu_loadViewFromNib() {
        guard let view = Bundle(identifier: SBUConstant.bundleIdentifier)?.loadNibNamed(
            String(describing: type(of: self)),
            owner: self,
            options: nil
            )?.first as? UIView else { return }
        
        view.frame = self.view.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.insertSubview(view, at: 0)
    }
}
