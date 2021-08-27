//
//  URL+Extensions.swift
//  SendBirdUIKit
//
//  Created by Wooyoung Chung on 7/14/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

internal extension URL {
    func open() {
        UIApplication.shared.open(self, options: [.universalLinksOnly : true]) { (success) in
            if !success {
                //open normally
                UIApplication.shared.open(self, options: [:], completionHandler: nil)
            }
        }
    }
}
