//
//  CGSize+SBUIKit.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/01.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

extension CGSize {
    init(value: CGFloat) {
        self.init(width: value, height: value)
    }
    
    var value: CGFloat { self.width }
}
