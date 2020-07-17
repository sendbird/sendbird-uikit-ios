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
    private lazy var _messageTextView: UserMessageTextView = {
        let messageView = UserMessageTextView()
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

    private var detailContainerView: MessageDetailContainerView = {
        let detailContainerView = MessageDetailContainerView()
        return detailContainerView
    }()

    private var reactionView: SBUMessageReactionView = {
        let reactionView = SBUMessageReactionView()
        return reactionView
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
        self.contentsStackView.addArrangedSubview(self.detailContainerView)
        self.contentsStackView.addArrangedSubview(self.stateView)

        self.detailContainerView.stackView.addArrangedSubview(self.messageTextView)
        self.detailContainerView.stackView.addArrangedSubview(self.reactionView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.userNameStackView
            .setConstraint(from: self.messageContentView, left: 0, right: 12, bottom: 0)
            .setConstraint(from: self.messageContentView, top: 0, priority: .defaultLow)
    }
    
    open override func setupActions() {
        super.setupActions()
        
        let contentLongPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.onLongPressContentView(sender:)))
        self.messageTextView.addGestureRecognizer(contentLongPressRecognizer)

        let stateTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapContentView(sender:)))
        self.stateView.addGestureRecognizer(stateTapRecognizer)

        let contentTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapContentView(sender:)))

        self.messageTextView.addGestureRecognizer(contentTapRecognizer)
        
        let profileImageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapProfileImageView(sender:)))
        self.profileView.addGestureRecognizer(profileImageTapRecognizer)

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


    // MARK: - Common
    open func configure(_ message: SBDUserMessage, hideDateView: Bool, receiptState: SBUMessageReceiptState) {
        self.configure(message, hideDateView: hideDateView, receiptState: receiptState, withTextView: true)
        self.setNeedsLayout()
    }
    
    open func configure(_ message: SBDBaseMessage, hideDateView: Bool, receiptState: SBUMessageReceiptState, withTextView: Bool) {
        super.configure(message: message,
                        position: SBUGlobals.CurrentUser?.userId == message.sender?.userId ? .right : .left,
                        hideDateView: hideDateView,
                        receiptState: receiptState)

        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(self.contentsStackView.removeArrangedSubview(_:))
        
        switch self.position {
        case .left:
            self.setBackgroundColor(color: theme.leftBackgroundColor)
            
            self.userNameStackView.alignment = .leading
            self.userNameView.isHidden = false
            self.profileView.isHidden = false
            
            self.contentsStackView.addArrangedSubview(self.profileView)
            self.contentsStackView.addArrangedSubview(self.messageTextView)
            self.contentsStackView.addArrangedSubview(self.stateView)
            
        case .right:
            self.setBackgroundColor(color: theme.rightBackgroundColor)
            
            self.userNameStackView.alignment = .trailing
            self.userNameView.isHidden = true
            self.profileView.isHidden = true
            
            self.contentsStackView.addArrangedSubview(self.stateView)
            self.contentsStackView.addArrangedSubview(self.messageTextView)
        case .center:
            break
        }

        if let messageTextView = messageTextView as? UserMessageTextView, withTextView {
            let isEdited = message.updatedAt != 0
            messageTextView.configure(text: message.message,
                                      position: self.position,
                                      isEdited: isEdited)
        }
        
        if let userNameView = self.userNameView as? UserNameView {
            var username = ""
            if let sender = message.sender { username = SBUUser(user: sender).refinedNickname() }
            userNameView.configure(username: username)
        }
        
        if let profileView = self.profileView as? MessageProfileView {
            let urlString = message.sender?.profileUrl ?? ""
            profileView.configure(urlString: urlString)
        }
        
        if let stateView = self.stateView as? MessageStateView {
            stateView.configure(timestamp: self.message.createdAt,
                                sendingState: message.sendingStatus,
                                receiptState: self.receiptState,
                                position: self.position)
        }

        self.detailContainerView.configure(position: self.position, isSelected: false)
        self.reactionView.configure(maxWidth: SBUConstant.messageCellMaxWidth, reactions: message.reactions)

        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(self.contentsStackView.removeArrangedSubview(_:))

        switch self.position {
        case .left:
            self.userNameStackView.alignment = .leading
            self.userNameView.isHidden = false
            self.profileView.isHidden = false

            self.contentsStackView.addArrangedSubview(self.profileView)
            self.contentsStackView.addArrangedSubview(self.detailContainerView)
            self.contentsStackView.addArrangedSubview(self.stateView)

        case .right:
            self.userNameStackView.alignment = .trailing
            self.userNameView.isHidden = true
            self.profileView.isHidden = true

            self.contentsStackView.addArrangedSubview(self.stateView)
            self.contentsStackView.addArrangedSubview(self.detailContainerView)

        case .center:
            break
        }

        self.setNeedsLayout()
    }
    
    open func setBackgroundColor(color: UIColor) {
        self.messageTextView.backgroundColor = color
    }

    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if self.messageTextView is UserMessageTextView {
            if selected {
                switch position {
                case .left  : self.setBackgroundColor(color: theme.leftPressedBackgroundColor)
                case .right : self.setBackgroundColor(color: theme.rightPressedBackgroundColor)
                case .center: break
                }
            } else {
                switch position {
                case .left  : self.setBackgroundColor(color: theme.leftBackgroundColor)
                case .right : self.setBackgroundColor(color: theme.rightBackgroundColor)
                case .center: break
                }
            }
        }

        self.detailContainerView.configure(position: self.position, isSelected: selected)

    }

    @objc open func onLongPressContentView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.longPressHandlerToContent?()
        }
    }
    
    @objc open func onTapProfileImageView(sender: UITapGestureRecognizer) {
        self.tapHandlerToProfileImage?()
    }
    
    @objc open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
}


// MARK: -
class UserMessageTextView: UIView {
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var textLabel: UILabel = UILabel()

    var text: String = ""
    var isEdited: Bool = false
    var position: MessagePosition = .center
    var attributedText = NSMutableAttributedString()

    init() {
        super.init(frame: .zero)
        self.setupViews()
        self.setupAutolayout()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "UserMessageTextView(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.textLabel.preferredMaxLayoutWidth = 220
        self.textLabel.numberOfLines = 0
        self.textLabel.textAlignment = .left
        self.textLabel.lineBreakMode = .byWordWrapping
        
        self.addSubview(self.textLabel)
    }
    
    func setupAutolayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = self.widthAnchor.constraint(lessThanOrEqualToConstant: SBUConstant.messageCellMaxWidth)
        NSLayoutConstraint.activate([widthConstraint])
        
        self.textLabel.setConstraint(from: self, left: 12, right: 12, top: 7, bottom: 7)

        NSLayoutConstraint.activate([self.textLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20)])
    }

    func setupStyles() {
        self.textLabel.font = theme.userMessageFont
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 14
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        
        self.setupStyles()
    }

    func configure(text: String, position: MessagePosition, isEdited: Bool, attributedText: NSMutableAttributedString? = nil) {
        self.text = text
        self.isEdited = isEdited
        self.textLabel.text = text
        self.position = position

        switch position {
        case .center:
            break
        case .left:
            self.textLabel.textColor = theme.userMessageLeftTextColor
            if isEdited {
                self.setEditedString(color: theme.userMessageLeftEditTextColor)
            }
        case .right:
            self.textLabel.textColor = theme.userMessageRightTextColor
            if isEdited {
                self.setEditedString(color: theme.userMessageRightEditTextColor)
            }
        }

        if let attributedText = attributedText {
            self.attributedText = attributedText
            self.textLabel.attributedText = attributedText
        }

        self.layoutIfNeeded()
    }
    
    func setEditedString(color: UIColor) {
        let baseString = NSMutableAttributedString(string: text, attributes: [:])
        let editString = NSAttributedString(string: " " + SBUStringSet.Message_Edited, attributes: [.foregroundColor: color])
        baseString.append(editString)
        self.textLabel.attributedText = baseString
    }
}
