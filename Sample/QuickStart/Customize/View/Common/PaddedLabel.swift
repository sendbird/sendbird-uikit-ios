//
//  PaddedLabel.swift
//  QuickStart
//
//  Created by Celine Moon on 12/5/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit

// Label with padding
class PaddedLabel: UILabel {
    var textInsets = UIEdgeInsets.zero {
        didSet { setNeedsDisplay() }
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                      height: size.height + textInsets.top + textInsets.bottom)
    }

    override func sizeToFit() {
        super.sizeToFit()
        self.frame.size = intrinsicContentSize
    }
}
