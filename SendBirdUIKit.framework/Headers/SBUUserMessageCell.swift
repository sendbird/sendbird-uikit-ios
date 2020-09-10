//
//  SBUUserMessageCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUUserMessageCell: SBUContentBaseMessageCell {

    // MARK: - Public property
    public lazy var messageTextView: UIView = _messageTextView
    
    public var userMessage: SBDUserMessage? {
        return self.message as? SBDUserMessage
    }
    
    // MARK: - Private property
    private lazy var _messageTextView: SBUUserMessageTextView = {
        let messageView = SBUUserMessageTextView()
        return messageView
    }()

    private var additionContainerView: SBUSelectableStackView = {
        let view = SBUSelectableStackView()
        return view
    }()
    
    private var webView: SBUMessageWebView = {
        let webView = SBUMessageWebView()
        return webView
    }()

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        self.mainContainerView.addArrangedSubview(self.messageTextView)
        self.mainContainerView.addArrangedSubview(self.additionContainerView)
        self.additionContainerView.addArrangedSubview(self.reactionView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
    }
    
    open override func setupActions() {
        super.setupActions()

        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            messageTextView.longPressHandler = { [weak self] url in
                self?.onLongPressContentView(sender: nil)
            }
        }
        
        self.mainContainerView.addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(self.onLongPressContentView(sender:)))
        )

        self.messageTextView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:))
        ))

        self.webView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapWebview(sender:))
        ))
    }

    open override func setupStyles() {
        super.setupStyles()
        
        let isWebviewVisible = !self.webView.isHidden
        self.additionContainerView.leftBackgroundColor = isWebviewVisible
            ? self.theme.contentBackgroundColor
            : self.theme.leftBackgroundColor
        self.additionContainerView.leftPressedBackgroundColor = isWebviewVisible
            ? self.theme.pressedContentBackgroundColor
            : self.theme.leftPressedBackgroundColor
        self.additionContainerView.rightBackgroundColor = isWebviewVisible
            ? self.theme.contentBackgroundColor
            : self.theme.rightBackgroundColor
        self.additionContainerView.rightPressedBackgroundColor = isWebviewVisible
            ? self.theme.pressedContentBackgroundColor
            : self.theme.rightPressedBackgroundColor
    }
    
    
    // MARK: - Common
    public func configure(_ message: SBDUserMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          receiptState: SBUMessageReceiptState) {
        self.configure(
            message,
            hideDateView: hideDateView,
            receiptState: receiptState,
            groupPosition: groupPosition,
            withTextView: true
        )
    }
    
    public func configure(_ message: SBDBaseMessage,
                          hideDateView: Bool,
                          receiptState: SBUMessageReceiptState,
                          groupPosition: MessageGroupPosition,
                          withTextView: Bool) {

        let position = SBUGlobals.CurrentUser?.userId == message.sender?.userId ?
            MessagePosition.right :
            MessagePosition.left
        
        self.configure(
            message,
            hideDateView: hideDateView,
            position: position,
            groupPosition: groupPosition,
            receiptState: receiptState
        )

        self.additionContainerView.position = self.position
        self.additionContainerView.isSelected = false
        
        if let messageTextView = messageTextView as? SBUUserMessageTextView, withTextView {
            messageTextView.configure(
                model: SBUUserMessageCellModel(message: message, position: position)
            )
        }
        
        if let ogMetaData = message.ogMetaData {
            self.additionContainerView.insertArrangedSubview(self.webView, at: 0)
            self.webView.isHidden = false
            let model = SBUMessageWebViewModel(metaData: ogMetaData)
            self.webView.configure(model: model)
        } else {
            self.additionContainerView.removeArrangedSubview(self.webView)
            self.webView.isHidden = true
        }
        
        self.reactionView.configure(
            maxWidth: SBUConstant.messageCellMaxWidth,
            reactions: message.reactions
        )

        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(
            self.contentsStackView.removeArrangedSubview(_:)
        )

        switch self.position {
        case .left:
            self.userNameStackView.alignment = .leading
            self.userNameView.isHidden = false
            self.profileView.isHidden = false
           
            self.contentsStackView.addArrangedSubview(self.profileView)
            self.contentsStackView.addArrangedSubview(self.mainContainerView)
            self.contentsStackView.addArrangedSubview(self.stateView)
            
        case .right:
            self.userNameStackView.alignment = .trailing
            self.userNameView.isHidden = true
            self.profileView.isHidden = true
            
            self.contentsStackView.addArrangedSubview(self.stateView)
            self.contentsStackView.addArrangedSubview(self.mainContainerView)
            
        case .center:
            break
        }
    }
    
   
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.additionContainerView.isSelected = selected
    }

    @objc func onTapWebview(sender: UITapGestureRecognizer) {
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
