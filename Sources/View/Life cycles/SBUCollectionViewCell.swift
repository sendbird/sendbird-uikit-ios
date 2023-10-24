//
//  SBUCollectionViewCell.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/08/04.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Collection view cell that conforms to ``SBUViewLifeCycle``.
/// - Since: 3.10.0
open class SBUCollectionViewCell: UICollectionViewCell {
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
}

extension SBUCollectionViewCell: SBUViewLifeCycle {
    public func setupViews() { }
    
    public func setupStyles() { }
    
    public func updateStyles() { }
    
    public func setupLayouts() { }
    
    public func updateLayouts() { }
    
    public func setupActions() { }
}
