//
//  SBUCommonViews.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUCommonViews {
    
    public static func backButton(vc: UIViewController, selector: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: SBUIconSetType.iconBack.image(to: CGSize(value: 34)),
                               style: .plain,
                               target: vc,
                               action: selector)
    }
}
