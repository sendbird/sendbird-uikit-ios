//
//  SBUUserMessageCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUUserMessageCell: SBUContentBaseMessageCell {

    // MARK: - Public property
    public lazy var messageTextView: UIView = SBUUserMessageTextView()
    
    public var userMessage: SBDUserMessage? {
        return self.message as? SBDUserMessage
    }
    
    // MARK: - Private property

    // + ------------ +
    // | reactionView |
    // + ------------ +
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

        // + --------------- +
        // | messageTextView |
        // + --------------- +
        // | reactionView    |
        // + --------------- +
        
        self.mainContainerView.setStack([
            self.messageTextView,
            self.additionContainerView.setStack([
                self.reactionView
            ])
        ])
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
    }
    
    open override func setupActions() {
        super.setupActions()

        if let messageTextView = self.messageTextView as? SBUUserMessageTextView {
            messageTextView.longPressHandler = { [weak self] url in
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

        self.additionContainerView.setupStyles()
        
        self.webView.setupStyles()
        
        self.additionContainerView.layer.cornerRadius = 8
    }
    
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUUserMessageCellParams else { return }
        guard let message = configuration.userMessage else { return }
        // Set using reaction
        self.useReaction = configuration.useReaction
        
        self.usingQuotedMessage = configuration.usingQuotedMessage
        
        // Configure Content base message cell
        super.configure(with: configuration)
        
        // Set up message position of additionContainerView(reactionView)
        self.additionContainerView.position = self.position
        self.additionContainerView.isSelected = false
        
        // Set up SBUUserMessageTextView
        if let messageTextView = messageTextView as? SBUUserMessageTextView, configuration.withTextView {
            messageTextView.configure(
                model: SBUUserMessageTextViewModel(
                    message: message,
                    position: configuration.messagePosition
                )
            )
        }
        // Set up WebView with OG meta data
        if let ogMetaData = configuration.message.ogMetaData {
            self.additionContainerView.insertArrangedSubview(self.webView, at: 0)
            self.webView.isHidden = false
            let model = SBUMessageWebViewModel(metaData: ogMetaData)
            self.webView.configure(model: model)
        } else {
            self.additionContainerView.removeArrangedSubview(self.webView)
            self.webView.isHidden = true
        }
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: SBDUserMessage,
                        hideDateView: Bool,
                        groupPosition: MessageGroupPosition,
                        receiptState: SBUMessageReceiptState?,
                        useReaction: Bool) {
        let configuration = SBUUserMessageCellParams(
            message: message,
            hideDateView: hideDateView,
            useMessagePosition: true,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: false,
            withTextView: true
        )
        self.configure(with: configuration)
    }
    
    @available(*, deprecated, renamed: "configure(with:)") // 2.2.0
    open func configure(_ message: SBDBaseMessage,
                        hideDateView: Bool,
                        receiptState: SBUMessageReceiptState?,
                        groupPosition: MessageGroupPosition,
                        withTextView: Bool) {
        guard let userMessage = message as? SBDUserMessage else {
            // TODO: error
            return
        }

        let configuration = SBUUserMessageCellParams(
            message: userMessage,
            hideDateView: hideDateView,
            useMessagePosition: true,
            groupPosition: groupPosition,
            receiptState: receiptState ?? .none,
            useReaction: self.useReaction,
            withTextView: withTextView
        )
        self.configure(with: configuration)
    }
    
    /// Adds highlight attribute to the message
    open override func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
        guard self.message.messageId == highlightInfo?.messageId,
              self.message.updatedAt == highlightInfo?.updatedAt else { return }

        guard let messageTextView = messageTextView as? SBUUserMessageTextView else { return }

        messageTextView.configure(
            model: SBUUserMessageTextViewModel(
                message: message,
                position: position,
                highlight: true
            )
        )
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
