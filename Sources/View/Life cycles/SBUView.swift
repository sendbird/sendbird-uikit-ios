//
//  SBUView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The `UIView` conforming to `SBUViewLifeCycle`
/// - Since: 2.2.0

@IBDesignable
open class SBUView: UIView, SBUViewLifeCycle {
    /// Initializes `UIView` and set up subviews, auto layouts and actions for SendbirdUIKit.
    public init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }
    
    /// Initializes `UIView` and set up subviews, auto layouts and actions for SendbirdUIKit.
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
    
    // MARK: - SBUViewLifeCycle
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func updateLayouts() { }
    
    open func setupStyles() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }
}
