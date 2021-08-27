//
//  SBUCommonViews.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUCommonViews {
    
    static func backButton(vc: UIViewController, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: vc,
            action: selector
        )
    }
}
