//
//  SBUUserNameView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUUserNameView: UIView {
    public var usernameColor: UIColor?
    
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    var button: UIButton = .init()
    var username: String = ""
    var leftMargin: CGFloat = 0
    
    var isOverlay = false
    
    private var buttonLeftConstraint: NSLayoutConstraint!
    
    public init(username: String) {
        self.username = username
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "UserNameView(username:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.addSubview(self.button)
    }
    
    func setupAutolayout() {
        self.button
            .setConstraint(from: self, right: 0, top: 0, bottom: 0)
            .setConstraint(height: 12)
        
        self.buttonLeftConstraint = self.button.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: self.leftMargin
        )
        self.buttonLeftConstraint.isActive = true
    }
    
    func updateAutolayout() {
        self.buttonLeftConstraint.isActive = false
        self.buttonLeftConstraint = self.button.leftAnchor.constraint(
            equalTo: self.leftAnchor,
            constant: self.leftMargin
        )
        self.buttonLeftConstraint.isActive = true
    }
    
    func setupStyles() {
        self.theme = self.isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        
        self.backgroundColor = .clear

        self.button.titleLabel?.font = theme.userNameFont
        self.button.contentHorizontalAlignment = .left

        if let usernameColor = self.usernameColor {
            self.button.setTitleColor(usernameColor, for: .normal)
        } else {
            self.button.setTitleColor(theme.userNameTextColor, for: .normal)
        }
    }
    
    func updateStyles() {
        self.setupStyles()
    }

    func configure(username: String, isOverlay: Bool = false) {
        self.isOverlay = isOverlay
        
        self.theme = self.isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        
        self.username = username
        self.button.setTitle(username, for: .normal)
        self.button.sizeToFit()
        self.updateStyles()
        self.updateAutolayout()
        
        self.setNeedsLayout()
    }
    
    func setUsernameColor(_ color: UIColor) {
        self.usernameColor = color
    }
}
