//
//  SBUNavigationTitleView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 21/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUNavigationTitleView: UIView {
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    public var text: String? = ""
    public var textAlignment: NSTextAlignment = .center
    
    private var titleLabel = UILabel()
     
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUNavigationTitleView.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setupViews() {
        self.titleLabel.textAlignment = self.textAlignment

        self.addSubview(self.titleLabel)
    }
    
    public func setupAutolayout() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    public func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleColor
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        self.titleLabel.frame = self.bounds
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.titleLabel.text = self.text
        
        self.backgroundColor = .clear
        
        self.setupStyles()
    }
}
