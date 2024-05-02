//
//  SBUStackView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUStackView: UIStackView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public init(
        axis: NSLayoutConstraint.Axis = .horizontal,
        alignment: UIStackView.Alignment = .fill,
        spacing: CGFloat = 0.0
    ) {
        super.init(frame: .zero)
        
        self.axis = axis
        self.alignment = alignment
        self.spacing = spacing
        self.isUserInteractionEnabled = true
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        if view is HitPassView { return nil }
        return view
    }
}

class HitPassView: UIView { }
