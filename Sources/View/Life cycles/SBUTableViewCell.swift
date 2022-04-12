//
//  SBUTableViewCell.MessageCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The `UITableViewCell` conforming to `SBUViewLifeCycle`
/// - Since: 2.2.0

@IBDesignable
@objcMembers open class SBUTableViewCell: UITableViewCell {
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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

extension SBUTableViewCell: SBUViewLifeCycle {
    open func setupViews() { }
    
    open func setupLayouts() { }
    
    open func updateLayouts() { }
    
    open func setupStyles() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }
}
