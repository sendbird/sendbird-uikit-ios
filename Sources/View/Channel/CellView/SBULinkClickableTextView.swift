//
//  SBULinkClickableTextView.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/13/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBULinkClickableTextView: UITextView {
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard self.bounds.contains(point) else { return nil }
        guard let pos = closestPosition(to: point) else { return nil }
        guard let range = tokenizer.rangeEnclosingPosition(
            pos, with: .character,
            inDirection: .layout(.left)) else { return nil }

        let startIndex = offset(from: beginningOfDocument, to: range.start)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil ? self : nil
    }
    
    // make it not selectable
    public override var selectedTextRange: UITextRange? {
        get { nil }
        set {}
    }
}
