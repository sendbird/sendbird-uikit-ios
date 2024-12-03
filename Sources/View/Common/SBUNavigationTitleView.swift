//
//  SBUNavigationTitleView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 21/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUNavigationTitleView: SBUView {
    /// - Since: 3.21.0
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    
    public var text: String? = ""
    public var textAlignment: NSTextAlignment = .center
    
    public var titleLabel = UILabel()
     
    required public override init() {
        super.init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUNavigationTitleView.init(frame:)")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func setupViews() {
        self.addSubview(self.titleLabel)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.titleLabel.sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleColor
    }
    
    open override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.titleLabel.frame = self.bounds
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.text = self.text
        self.titleLabel.textAlignment = self.textAlignment
        
        self.setupStyles()
    }
    
    open func configure(title: String?) {
        if let title = title {
            self.text = title
            self.titleLabel.text = title
        }
    }
}
