//
//  SBUOpenChannelUserMessageCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/27.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

@IBDesignable
open class SBUOpenChannelUserMessageCell: SBUOpenChannelContentBaseMessageCell {

    // MARK: - Public property
    public lazy var messageTextView: UIView = SBUUserMessageTextView(channelType: .open)
    
    public var userMessage: UserMessage? {
        self.message as? UserMessage
    }
    
    // MARK: - Private property

    public private(set) var additionContainerView: SBUSelectableStackView = {
        let view = SBUSelectableStackView()
        return view
    }()
    
    /// A ``SBUOpenChannelMessageWebView`` which represents a preview of the web link
    public var webView: SBUOpenChannelMessageWebView = {
        let webView = SBUOpenChannelMessageWebView()
        
        return webView
    }()
    
    /// As a default, the value is the constraint of `messageTextView.trailingAnchor`and  it's activated when the message has no `ogMetaData`.
    public private(set) var messageTypeConstraint: NSLayoutConstraint!
    /// Activated when the message has `ogMetaData`.
    public private(set) var webTypeConstraints: [NSLayoutConstraint] = []
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        self.additionContainerView.clipsToBounds = true
        
        if let mainContainerView = self.mainContainerView as? SBUSelectableStackView {
            mainContainerView.addArrangedSubview(self.messageTextView)
            mainContainerView.addArrangedSubview(self.additionContainerView)
        }
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.messageTypeConstraint = self.messageTextView.trailingAnchor.constraint(
            lessThanOrEqualTo: self.trailingAnchor, constant: -12
        )
        self.messageTypeConstraint.isActive = true
        
        let additionalContainerConstraint = self.additionContainerView.widthAnchor.constraint(
            equalToConstant: 311
        )
        additionalContainerConstraint.priority = .init(rawValue: 750)
        self.webTypeConstraints = [
            self.additionContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 311),
            additionalContainerConstraint
        ]
    }
    
    open override func setupActions() {
        super.setupActions()

        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            messageTextView.longPressHandler = { [weak self] _ in
                guard let self = self else { return }
                self.onLongPressContentView(sender: nil)
            }
        }
        
        self.messageTextView.addGestureRecognizer(self.contentLongPressRecognizer)
        self.messageTextView.addGestureRecognizer(self.contentTapRecognizer)

        self.webView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapWebview(sender:))
        ))
    }

    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        let isWebviewVisible = !self.webView.isHidden
        self.additionContainerView.leftBackgroundColor = isWebviewVisible
            ? theme.contentBackgroundColor
            : theme.leftBackgroundColor
        self.additionContainerView.leftPressedBackgroundColor = isWebviewVisible
            ? theme.pressedContentBackgroundColor
            : theme.leftPressedBackgroundColor

        self.additionContainerView.setupStyles()
        
        self.webView.setupStyles()
        
        self.additionContainerView.layer.cornerRadius = 8
    }
    
    // MARK: - Common
    open func configure(_ message: BaseMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          withTextView: Bool,
                          isOverlay: Bool = false) {

        let position = MessagePosition.left
        
        self.configure(
            message,
            hideDateView: hideDateView,
            groupPosition: groupPosition,
            isOverlay: isOverlay
        )

        self.additionContainerView.position = .left
        self.additionContainerView.isSelected = false
        
        if let ogMetaData = message.ogMetaData, SBUAvailable.isSupportOgTag(channelType: .open) {
            self.additionContainerView.insertArrangedSubview(self.webView, at: 0)
            self.webView.isHidden = false
            let model = SBUMessageWebViewModel(metaData: ogMetaData, isOverlay: isOverlay, isOpenChannel: true)
            self.webView.configure(model: model)
            self.messageTypeConstraint.isActive = false
            self.webTypeConstraints.forEach { $0.isActive = true }
            self.isWebType = true
        } else {
            self.additionContainerView.removeArrangedSubview(self.webView)
            self.webView.isHidden = true
            self.messageTypeConstraint.isActive = true
            self.webTypeConstraints.forEach { $0.isActive = false }
            self.isWebType = false
        }

        if let messageTextView = messageTextView as? SBUUserMessageTextView, withTextView {
            let theme = self.isOverlay ? self.overlayTheme : self.theme
            
            messageTextView.configure(
                model: SBUUserMessageTextViewModel(message: message, position: position, isOverlay: isOverlay)
            )
            if self.isWebType { // Open channel only
                let linkColor = theme.linkColor
                messageTextView.textView.linkTextAttributes = [
                    .foregroundColor: linkColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
            }
            messageTextView.updateSideConstraint()
            messageTextView.sizeToFit()
        }
        
        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(
            self.contentsStackView.removeArrangedSubview(_:)
        )

        self.baseStackView.alignment = .top
        self.profileView.isHidden = false

        self.contentsStackView.addArrangedSubview(self.infoStackView)
        self.contentsStackView.addArrangedSubview(self.mainContainerView)
        self.contentsStackView.addArrangedSubview(self.stateImageView)
    }
   
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.additionContainerView.isSelected = selected
    }

    @objc
    open func onTapWebview(sender: UITapGestureRecognizer) {
        guard
            let ogMetaData = self.userMessage?.ogMetaData,
            let urlString = ogMetaData.url,
            let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        url.open()
    }
}
