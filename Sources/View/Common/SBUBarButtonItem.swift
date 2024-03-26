//
//  SBUBarButtonItem.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUBarButtonItem {

    static func backButton(target: Any, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: target,
            action: selector
        )
    }
    
    static func emptyButton(target: Any, selector: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(
            image: SBUIconSetType.iconBack.image(with: .clear, to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: target,
            action: selector
        )
    }
}
