//
//  SBUUserNameView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

open class SBUUserNameView: SBUView {
    public var usernameColor: UIColor?
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.messageCellTheme, setToDefault: true)
    public var overlayTheme: SBUMessageCellTheme
    
    public var button: UIButton = .init()
    public var username: String = ""
    public var leftMargin: CGFloat = 0
    
    var isOverlay = false
    
    /// Set to `button.leftAnchor.constraint(equalTo:constant:)` from `updateLayouts()` function.
    public private(set) var buttonLeftConstraint: NSLayoutConstraint!
    
    public override init() {
        super.init(frame: .zero)
    }
    
    public init(username: String) {
        self.username = username
        
        super.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "UserNameView(username:)")
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.button)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.button
            .setConstraint(from: self, right: 0, top: 0, bottom: 0)
            .setConstraint(height: 12)
        
        self.buttonLeftConstraint = self.button.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: self.leftMargin
        )
        self.buttonLeftConstraint.isActive = true
    }
    
    open override func updateLayouts() {
        super.updateLayouts()
        
        self.buttonLeftConstraint.isActive = false
        self.buttonLeftConstraint = self.button.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: self.leftMargin
        )
        self.buttonLeftConstraint.isActive = true
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        self.backgroundColor = .clear

        self.button.titleLabel?.font = theme.userNameFont
        self.button.contentHorizontalAlignment = .left

        if let usernameColor = self.usernameColor {
            self.button.setTitleColor(usernameColor, for: .normal)
        } else {
            self.button.setTitleColor(theme.userNameTextColor, for: .normal)
        }
    }
    
    open override func updateStyles() {
        super.updateStyles()
        
        self.setupStyles()
    }

    open func configure(username: String, isOverlay: Bool = false) {
        self.isOverlay = isOverlay
        
        self.username = username
        self.button.setTitle(username, for: .normal)
        self.button.sizeToFit()
        
        self.updateStyles()
        self.updateLayouts()
        
        self.setNeedsLayout()
    }
    
    public func setUsernameColor(_ color: UIColor) {
        self.usernameColor = color
    }
}
