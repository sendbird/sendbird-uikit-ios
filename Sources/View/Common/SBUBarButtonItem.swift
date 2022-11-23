//
//  SBUBarButtonItem.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUBarButtonItem {

    static func backButton(vc: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: vc,
            action: selector
        )
    }
    
    static func emptyButton(vc: Any, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(with: .clear, to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: vc,
            action: selector
        )
    }
}
