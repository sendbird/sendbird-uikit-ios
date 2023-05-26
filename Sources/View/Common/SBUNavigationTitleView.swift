//
//  SBUNavigationTitleView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 21/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUNavigationTitleView: SBUView {
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    public var text: String? = ""
    public var textAlignment: NSTextAlignment = .center
    
    var titleLabel = UILabel()
     
    public override init() {
        super.init()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUNavigationTitleView.init(frame:)")
    required public init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func setupViews() {
        self.titleLabel.textAlignment = self.textAlignment

        self.addSubview(self.titleLabel)
    }
    
    public override func setupLayouts() {
        super.setupLayouts()
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
        ])
    }
    
    public override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
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
        
        self.setupStyles()
    }
    
    public func configure(title: String?) {
        if let title = title {
            self.text = title
            self.titleLabel.text = title
        }
    }
}
