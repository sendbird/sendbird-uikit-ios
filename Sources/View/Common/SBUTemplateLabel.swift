//
//  SBUTemplateLabel.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/10/17.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// https://stackoverflow.com/a/32368958

/// This class supports padding and 9 direction Align.
///
/// How to use
/// - Padding : `label.padding = edgeInsets`
/// - Align:
///     - horizontal: `label.textAlignment`
///     - vertical: `label.contentMode`
class SBUTemplateLabel: UILabel {
    var padding: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    
    override func drawText(in rect: CGRect) {
        var newRect = rect
        switch contentMode {
        case .top:
            newRect.size.height = sizeThatFits(rect.size).height
        case .bottom:
            let height = sizeThatFits(rect.size).height
            newRect.origin.y += rect.size.height - height
            newRect.size.height = height
        default:
            ()
        }
        
        super.drawText(in: newRect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.top + padding.bottom)
    }
    
    override var bounds: CGRect {
        didSet {
            preferredMaxLayoutWidth = bounds.width - (padding.left + padding.right)
        }
    }
}
