//
//  SBUTableViewCell.MessageCell.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The `UITableViewCell` conforming to `SBUViewLifeCycle`
/// - Since: 2.2.0
@objcMembers
@IBDesignable
open class SBUTableViewCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
}

extension SBUTableViewCell: SBUViewLifeCycle {
    /// This function handles the initialization of views.
    open func setupViews() {
        
    }
    
    /// This function handles the initialization of actions.
    open func setupActions() {
        
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        
    }
    
}
