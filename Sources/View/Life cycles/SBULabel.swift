//
//  SBULabel.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 5/16/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The `UILabel` conforming to `SBUViewLifeCycle`
/// - Since: 3.28.0
open class SBULabel: UILabel {
    
    /// Initializes `UILabel` and set up subviews, auto layouts and actions for SendbirdUIKit.
    public init() {
        super.init(frame: .zero)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// Initializes `UILabel` and set up subviews, auto layouts and actions for SendbirdUIKit.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    @available(*, unavailable, renamed: "init(frame:)")
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// Lays out subviews and set up styles for SendbirdUIKit.
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
}

extension SBULabel: SBUViewLifeCycle {
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func updateLayouts() { }
    
    open func setupStyles() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }
}
