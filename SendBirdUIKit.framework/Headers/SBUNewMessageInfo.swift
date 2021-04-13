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
    // MARK: - Properties (Public)
    public lazy var messageInfoButton: UIButton? = {
        let messageInfoButton = UIButton()
        messageInfoButton.layer.masksToBounds = true
        messageInfoButton.tag = DefaultInfoButtonTag
        messageInfoButton.titleLabel?.textAlignment = .center
        return messageInfoButton
    }()
    
    public var actionHandler: SBUNewMessageInfoHandler?
    
    // MARK: - Properties (Private)
    let DefaultInfoButtonTag = 10001
    var type: NewMessageInfoItemType = .tooltip

    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    
    // MARK: - Life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    /// This function Initializes the new message information item.
    /// - Parameter type: Type of new message info item (default: tooltip)
    public init(type: NewMessageInfoItemType = .tooltip) {
        super.init(frame: .zero)
        
        self.type = type
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUNewMessageInfo.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    /// This function handles the initialization of views.
    open func setupViews() {
        if let messageInfoButton = self.messageInfoButton {
            messageInfoButton.addTarget(
                self,
                action:#selector(onClickNewMessageInfo),
                for: .touchUpInside
            )
            self.addSubview(messageInfoButton)
        }
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var infoItemSize = SBUConstant.newMessageInfoSize
        if self.type == .button {
            infoItemSize = SBUConstant.newMessageButtonSize
            self.widthAnchor.constraint(equalToConstant: infoItemSize.width).isActive = true
        }
        /// Note: width for .tooltip is `sizeToFit()`

        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: infoItemSize.height),
        ])
        
        if let messageInfoButton = self.messageInfoButton {
            messageInfoButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                messageInfoButton.leftAnchor.constraint(equalTo: self.leftAnchor),
                messageInfoButton.rightAnchor.constraint(equalTo: self.rightAnchor),
                messageInfoButton.topAnchor.constraint(equalTo: self.topAnchor),
                messageInfoButton.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            ])
        }
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.backgroundColor = .clear
        self.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        
        setupButtonStyle()
        
        if let messageInfoButton = self.messageInfoButton,
            messageInfoButton.tag == DefaultInfoButtonTag {
            
            switch self.type {
            case .tooltip:
                messageInfoButton.titleLabel?.font = theme.newMessageFont
                messageInfoButton.setTitleColor(theme.newMessageTintColor, for: .normal)
                messageInfoButton.setBackgroundImage(
                    UIImage.from(color: theme.newMessageBackground),
                    for: .normal
                )
                messageInfoButton.setBackgroundImage(
                    UIImage.from(color: theme.newMessageHighlighted),
                    for: .highlighted
                )
            case .button:
                messageInfoButton.setImage(
                    SBUIconSetType.iconChevronDown.image(
                        with: theme.newMessageButtonTintColor,
                        to: SBUIconSetType.Metric.defaultIconSizeSmall
                    ),
                    for: .normal
                )
                messageInfoButton.setBackgroundImage(
                    UIImage.from(color: theme.newMessageButtonBackground),
                    for: .normal
                )
                messageInfoButton.setBackgroundImage(
                    UIImage.from(color: theme.newMessageButtonHighlighted),
                    for: .highlighted
                )
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    private func setupButtonStyle() {
        self.messageInfoButton?.layer.cornerRadius = self.frame.height / 2
        self.messageInfoButton?.clipsToBounds = true
    }

    // MARK: - Action
    @objc open func onClickNewMessageInfo() {
        self.actionHandler?()
    }
    
    // MARK: - Count
    /// This function updates the count of new messages and sets the button's action.
    /// - Parameters:
    ///   - count: Message count
    ///   - actionHandler: Button's action handler
    open func updateCount(count: Int, actionHandler: SBUNewMessageInfoHandler?) {
        if let messageInfoButton = self.messageInfoButton {
            messageInfoButton.setTitle(SBUStringSet.Channel_New_Message(count), for: .normal)
            messageInfoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
            messageInfoButton.sizeToFit()
        }
        self.actionHandler = actionHandler
    }
}
