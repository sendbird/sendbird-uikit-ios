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
open class SBUUserMessageCell: SBUBaseMessageCell {

    // MARK: - Public property
    public lazy var messageTextView: UIView = _messageTextView
    public lazy var userNameStackView: UIStackView = _userNameStackView
    public lazy var contentsStackView: UIStackView = _contentsStackView
    public lazy var userNameView: UIView = _userNameView
    public lazy var profileView: UIView = _profileView
    public lazy var stateView: UIView = _stateView

    public var userMessage: SBDUserMessage? {
        return self.message as? SBDUserMessage
    }
    
    // MARK: - Private property
    private lazy var _messageTextView: SBUUserMessageTextView = {
        let messageView = SBUUserMessageTextView()
        return messageView
    }()

    private var _userNameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private var _userNameView: UserNameView = {
        let userNameView = UserNameView()
        return userNameView
    }()

    private var _contentsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .bottom
        return stackView
    }()

    private var _profileView: MessageProfileView = {
        let profileView = MessageProfileView()
        return profileView
    }()

    private var _stateView: MessageStateView = {
        let stateView = MessageStateView()
        return stateView
    }()

    private var mainContainerView: SBUSelectableStackView = {
        let mainView = SBUSelectableStackView()
        mainView.layer.cornerRadius = 16
        mainView.layer.borderColor = UIColor.clear.cgColor
        mainView.layer.borderWidth = 1
        mainView.clipsToBounds = true
        return mainView
    }()

    private var additionContainerView: SBUSelectableStackView = {
        let view = SBUSelectableStackView()
        return view
    }()
    
    private var reactionView: SBUMessageReactionView = {
        let reactionView = SBUMessageReactionView()
        return reactionView
    }()
    
    private var webView: SBUMessageWebView = {
        let webView = SBUMessageWebView()
        return webView
    }()

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.userNameView.isHidden = true
        self.profileView.isHidden = true
        
        self.messageContentView.addSubview(self.userNameStackView) 
        
        self.userNameStackView.addArrangedSubview(self.userNameView)
        self.userNameStackView.addArrangedSubview(self.contentsStackView)
        
        self.contentsStackView.addArrangedSubview(self.profileView)
        self.contentsStackView.addArrangedSubview(self.mainContainerView)
        self.contentsStackView.addArrangedSubview(self.stateView)

        self.mainContainerView.addArrangedSubview(self.messageTextView)
        self.mainContainerView.addArrangedSubview(self.additionContainerView)
        self.additionContainerView.addArrangedSubview(self.reactionView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()

        self.userNameStackView
            .setConstraint(from: self.messageContentView, left: 0, right: 12, bottom: 0)
            .setConstraint(from: self.messageContentView, top: 0, priority: .defaultLow)
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

        self.stateView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:)))
        )
        
        self.messageTextView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:))
        ))

        self.webView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapWebview(sender:))
        ))
        
        self.profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapProfileImageView(sender:)))
        )

        self.reactionView.emojiTapHandler = { [weak self] emojiKey in
            self?.emojiTapHandler?(emojiKey)
        }

        self.reactionView.emojiLongPressHandler = { [weak self] emojiKey in
            self?.emojiLongPressHandler?(emojiKey)
        }

        self.reactionView.moreEmojiTapHandler = { [weak self] in
            self?.moreEmojiTapHandler?()
        }
    }

    open override func setupStyles() {
        super.setupStyles()
        
        self.mainContainerView.leftBackgroundColor = self.theme.leftBackgroundColor
        self.mainContainerView.leftPressedBackgroundColor = self.theme.leftPressedBackgroundColor
        self.mainContainerView.rightBackgroundColor = self.theme.rightBackgroundColor
        self.mainContainerView.rightPressedBackgroundColor = self.theme.rightPressedBackgroundColor
        
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
                          receiptState: SBUMessageReceiptState) {
        self.configure(
            message,
            hideDateView: hideDateView,
            receiptState: receiptState,
            withTextView: true
        )
    }
    
    public func configure(_ message: SBDBaseMessage,
                          hideDateView: Bool,
                          receiptState: SBUMessageReceiptState,
                          withTextView: Bool) {
        
        let position = SBUGlobals.CurrentUser?.userId == message.sender?.userId ?
            MessagePosition.right :
            MessagePosition.left
        
        super.configure(
            message: message,
            position: position,
            hideDateView: hideDateView,
            receiptState: receiptState
        )

        self.mainContainerView.position = position
        self.mainContainerView.isSelected = false
        self.additionContainerView.position = position
        self.additionContainerView.isSelected = false
        
        if let messageTextView = messageTextView as? SBUUserMessageTextView, withTextView {
            messageTextView.configure(
                model: SBUUserMessageCellModel(message: message, position: position)
            )
        }
        
        if let userNameView = self.userNameView as? UserNameView {
            var username = ""
            if let sender = message.sender {
                username = SBUUser(user: sender).refinedNickname()
            }
            userNameView.configure(username: username)
        }
        
        if let profileView = self.profileView as? MessageProfileView {
            let urlString = message.sender?.profileUrl ?? ""
            profileView.configure(urlString: urlString)
        }
        
        if let stateView = self.stateView as? MessageStateView {
            stateView.configure(
                timestamp: message.createdAt,
                sendingState: message.sendingStatus,
                receiptState: receiptState,
                position: position
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
        self.mainContainerView.isSelected = selected
        self.additionContainerView.isSelected = selected
    }

    @objc open func onLongPressContentView(sender: UILongPressGestureRecognizer?) {
        if let sender = sender {
            if sender.state == .began {
                self.longPressHandlerToContent?()
            }
        } else {
            self.longPressHandlerToContent?()
        }
    }
    
    @objc open func onTapProfileImageView(sender: UITapGestureRecognizer) {
        self.tapHandlerToProfileImage?()
    }
    
    @objc open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
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
