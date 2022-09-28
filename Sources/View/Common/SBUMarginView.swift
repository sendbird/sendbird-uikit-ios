//
//  SBUMarginView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/09/08.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUMarginView: UIView {
    /// ``SBUMarginView`` pass through the UIEvent.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }
}
