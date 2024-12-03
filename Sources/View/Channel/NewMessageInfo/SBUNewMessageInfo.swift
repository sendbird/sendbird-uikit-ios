//
//  SBUNewMessageInfo.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 03/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import QuartzCore

/// New message info handler
public typealias SBUNewMessageInfoHandler = () -> Void

open class SBUNewMessageInfo: SBUView {
    static let defaultInfoButtonTag = 10001
    
    // MARK: - Properties (Public)
    public lazy var messageInfoButton: UIButton? = {
        let messageInfoButton = UIButton()
        messageInfoButton.layer.masksToBounds = true
        messageInfoButton.tag = Self.defaultInfoButtonTag
        messageInfoButton.titleLabel?.textAlignment = .center
        return messageInfoButton
    }()
    
    public var actionHandler: SBUNewMessageInfoHandler?
    
    // MARK: - Properties (Private)
    var type: NewMessageInfoItemType = .tooltip
    
    var witdhConstraint: NSLayoutConstraint?
    var heightConstraint: NSLayoutConstraint?

    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    #if SWIFTUI
    /// Stores the number of new messages.
    var count: Int = 0
    #endif
    
    // MARK: - Life cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    /// This function Initializes the new message information item.
    /// - Parameter type: Type of new message info item (default: tooltip)
    public required init(type: NewMessageInfoItemType = .tooltip) {
        super.init(frame: .zero)
        
        self.type = type
    }
    
    @available(*, unavailable, renamed: "SBUNewMessageInfo.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(frame: .zero)
    }

    /// This function handles the initialization of views.
    open override func setupViews() {
        if let messageInfoButton = self.messageInfoButton {
            messageInfoButton.addTarget(
                self,
                action: #selector(onClickNewMessageInfo),
                for: .touchUpInside
            )
            self.addSubview(messageInfoButton)
        }
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        var infoItemSize = SBUConstant.newMessageInfoSize
        if self.type == .button {
            infoItemSize = SBUConstant.newMessageButtonSize
            self.witdhConstraint?.isActive = false
            self.witdhConstraint = self.widthAnchor.constraint(equalToConstant: infoItemSize.width)
            self.witdhConstraint?.isActive = true
        }
        /// Note: width for .tooltip is `sizeToFit()`

        self.heightConstraint?.isActive = false
        self.heightConstraint = self.heightAnchor.constraint(equalToConstant: infoItemSize.height)
        self.heightConstraint?.isActive = true
        
        if let messageInfoButton = self.messageInfoButton {
            messageInfoButton.sbu_constraint()
                .sbu_constraint(equalTo: self, left: 0, right: 0, top: 0, bottom: 0)
        }
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.backgroundColor = .clear
        self.layer.shadowColor = theme.shadowColor.withAlphaComponent(0.5).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 5)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 5
        self.layer.masksToBounds = false
        
        setupButtonStyle()
        
        if let messageInfoButton = self.messageInfoButton,
           messageInfoButton.tag == Self.defaultInfoButtonTag {
            
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
    
    private func setupButtonStyle() {
        self.messageInfoButton?.layer.cornerRadius = self.frame.height / 2
        self.messageInfoButton?.clipsToBounds = true
    }

    // MARK: - Action
    @objc
    open func onClickNewMessageInfo() {
        self.actionHandler?()
    }
    
    // MARK: - Count
    /// This function updates the count of new messages and sets the button's action.
    /// - Parameters:
    ///   - count: Message count
    ///   - actionHandler: Button's action handler
    open func updateCount(count: Int, actionHandler: SBUNewMessageInfoHandler?) {
        var didApplyViewConverter = false
        #if SWIFTUI
        didApplyViewConverter = self.applyViewConverter(.entireContent, count: count)
        #endif
        if !didApplyViewConverter {
            if let messageInfoButton = self.messageInfoButton {
                messageInfoButton.setTitle(SBUStringSet.Channel_New_Message(count), for: .normal)
                messageInfoButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
                messageInfoButton.sizeToFit()
            }
        }
        self.actionHandler = actionHandler
    }
}

extension SBUNewMessageInfo {
    static func createDefault(_ viewType: SBUNewMessageInfo.Type) -> SBUNewMessageInfo {
        return viewType.init()
    }
}
