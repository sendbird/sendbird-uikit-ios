//
//  SBUBarButtonItem.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A class that displays an bar button item in SendbirdUIKit.
/// - Since: 3.28.0
open class SBUBarButtonItem: UIBarButtonItem {
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    required public override init() {
        super.init()
    }

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
