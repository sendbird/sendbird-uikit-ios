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

        let rangeLeftDirection = tokenizer.rangeEnclosingPosition(
            pos,
            with: .character,
            inDirection: .layout(.left)
        )

        let rangeRightDirection = tokenizer.rangeEnclosingPosition(
            pos,
            with: .character,
            inDirection: .layout(.right)
        )
        
        guard let rangeStart = rangeLeftDirection?.start ?? rangeRightDirection?.start else { return nil }
        
        let startIndex = offset(from: beginningOfDocument, to: rangeStart)
        return attributedText.attribute(.link, at: startIndex, effectiveRange: nil) != nil ? self : nil
    }
    
    // make it not selectable
    public override var selectedTextRange: UITextRange? {
        get { nil }
        set {}
    }
}
