//
//  SBUNewMessageInfo.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 03/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import QuartzCore

public typealias SBUNewMessageInfoHandler = () -> Void

open class SBUNewMessageInfo: UIView {
    let messageInfoButton = UIButton()
    var completionHandler: SBUNewMessageInfoHandler?
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    // MARK: - Life cycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUChannelTitleView.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// This function handles the initialization of views.
    open func setupViews() {
        self.backgroundColor = .clear
        self.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.2).cgColor
        self.layer.shadowOffset = CGSize(width: 5, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        
        self.messageInfoButton.setTitle(SBUStringSet.Channel_New_Message(0), for: .normal)
        self.messageInfoButton.layer.cornerRadius = 16.0
        self.messageInfoButton.layer.masksToBounds = true
        self.messageInfoButton.semanticContentAttribute = .forceRightToLeft
        self.messageInfoButton.addTarget(self, action: #selector(onClickNewMessageInfo), for: .touchUpInside)
        self.addSubview(self.messageInfoButton)
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: 144.0),
            self.heightAnchor.constraint(equalToConstant: 32.0),
        ])
        
        self.messageInfoButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.messageInfoButton.widthAnchor.constraint(equalToConstant: 144.0),
            self.messageInfoButton.heightAnchor.constraint(equalToConstant: 32.0),
            self.messageInfoButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.messageInfoButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.messageInfoButton.setImage(SBUIconSet.iconChevronDown.with(tintColor: theme.newMessageTintColor), for: .normal)
        self.messageInfoButton.titleLabel?.font = theme.newMessageFont
        self.messageInfoButton.setTitleColor(theme.newMessageTintColor, for: .normal)
        self.messageInfoButton.setBackgroundImage(UIImage.from(color: theme.newMessageBackground), for: .normal)
        self.messageInfoButton.setBackgroundImage(UIImage.from(color: theme.newMessageHighlighted), for: .highlighted)
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }

    // MARK: - Common
    @objc func onClickNewMessageInfo() {
        self.completionHandler?()
    }
    public func updateTitle(count: Int, completionHandler: SBUNewMessageInfoHandler?) {
        self.messageInfoButton.setTitle(SBUStringSet.Channel_New_Message(count), for: .normal)
        self.completionHandler = completionHandler
    }
}
