//
//  SBUParentMessageInfoView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/11.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUParentMessageInfoViewDelegate: AnyObject {
    func parentMessageInfoViewBoundsWillChanged(_ view: SBUParentMessageInfoView)
    func parentMessageInfoViewBoundsDidChanged(_ view: SBUParentMessageInfoView)
}

open class SBUParentMessageInfoView: UITableViewHeaderFooterView, SBUUserMessageTextViewDelegate {
    
    // MARK: - UI properties (Public)

    /// The view that displays the profile image of sender.
    public var profileView = SBUMessageProfileView()
    
    /// The label that displays the username of sender.
    public var userNameLabel = UILabel()
    /// The label that displays the message sent time.
    public var dateLabel = UILabel()
    /// The button that displays the more menu items.
    public lazy var moreButton: UIButton? = UIButton()
    
    /// The view that displays the separate line between contents area and reply area.
    public var replySeparateLine = UIView()
    /// The label that displays the reply count.
    public var replyLabel = UILabel()
    /// The view that displays the bottom line.
    public var bottomSeparateLine = UIView()
    
    /// The view that displays the message. Used when the user message type.
    public var messageTextView = SBUUserMessageTextView(removeMargin: true)
    /// The view that displays the file. Used when the file message type.
    public var baseFileContentView = SBUBaseFileContentView()
    /// The view that displays the web page preview. Used when the user message type (not used yet).
    public var webView = SBUMessageWebView()
    /// The view that displays the reactions.
    public var reactionView = SBUParentMessageInfoReactionView()
    
    /// ```
    /// + --------------------------------+------------+
    /// | profileView  | senderVStackView | moreButton |
    /// + -------------+------------------+------------+
    /// ```
    public lazy var userHStackView = SBUStackView(axis: .horizontal, spacing: 8)
    
    /// ```
    /// +---------------+
    /// | userNameLabel |
    /// +---------------+
    /// | dateLabel     |
    /// +---------------+
    /// ```
    public lazy var senderVStackView = SBUStackView(axis: .vertical, spacing: 2)
    
    /// ```
    /// + ----------------------------------+
    /// | (message or media or file or web) |
    /// + ----------------------------------+
    /// ```
    public lazy var contentVStackView = SBUStackView(axis: .vertical, spacing: 0)
    
    public override var bounds: CGRect {
        willSet { self.delegate?.parentMessageInfoViewBoundsWillChanged(self) }
        didSet { self.delegate?.parentMessageInfoViewBoundsDidChanged(self) }
    }
    
    public override var frame: CGRect {
        willSet { self.delegate?.parentMessageInfoViewBoundsWillChanged(self) }
        didSet { self.delegate?.parentMessageInfoViewBoundsDidChanged(self) }
    }
    
    // MARK: - UI properties (Private)
    var replySeparateLineTopAnchorConstraint: NSLayoutConstraint?
    var replyLabelTopAnchorConstraint: NSLayoutConstraint?
    var contentVStackViewTrailingAnchorConstraint: NSLayoutConstraint?
    var bottomSeparateLineTopAnchorConstraint: NSLayoutConstraint?
    var baseFileContentViewWidthConstraint: NSLayoutConstraint?
    
    // MARK: - State properties (Public)
    /// If is`true`, enables reaction feature and it's available. The defaults value is `true`
    /// - NOTE: if it's `false`, ``reactionView`` doesn't appear on ``SBUMessageThreadViewController``and its ``SBUMessageThreadModule/List`` component even the channel uses reaction.
    /// ```swift
    /// // Disable reactionView in Message thread module
    /// let listCompnonent = SBUModuleSet.messageThreadModule.listComponent
    /// listCompnonent?.parentMessageInfoView.enablesReaction = false
    /// SBUModuleSet.messageThreadModule.listComponent = listCompnonent
    /// ```
    public var enablesReaction: Bool = true
    
    // MARK: - Logic properties (Private)
    weak var delegate: SBUParentMessageInfoViewDelegate?
    var message: BaseMessage?

    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    var theme: SBUMessageCellTheme
    
    var configured: Bool = false
    var voiceFileInfo: SBUVoiceFileInfo?
    var isReactionAvailable = false
    
    // MARK: - Action
    /// The handler that set the logic to be called when a user profile is tapped.
    public var userProfileTapHandler: (() -> Void)?
    /// The handler that set the logic to be called when a content area is tapped.
    public var tapHandlerToContent: (() -> Void)?
    /// The handler that set the logic to be called when a more button is tapped.
    public var moreButtonTapHandlerToContent: (() -> Void)?
    /// The handler that set the logic to be called when emoji is tapped.
    public var emojiTapHandler: ((_ emojiKey: String) -> Void)?
    /// The handler that set the logic to be called when a more emoji is tapped.
    public var moreEmojiTapHandler: (() -> Void)?
    /// The handler that set the logic to be called when a emoji is long tapped.
    public var emojiLongPressHandler: ((_ emojiKey: String) -> Void)?
    /// The handler that set the logic to be called when a mention is tapped.
    public var mentionTapHandler: ((_ user: SBUUser) -> Void)?
    
    // MARK: - LifeCycle
    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupLayouts()
        self.setupStyles()
        self.setupActions()
    }
    
    @available(*, unavailable, renamed: "SBUParentMessageInfoView(frame:)")
    required convenience public init?(coder: NSCoder) {
        fatalError()
    }

    open func setupViews() {
        // + -----------------------------+------------+
        // | profileView  | userNameLabel | moreButton |
        // |              | dateLabel     |            |
        // + -------------+---------------+------------+
        // | (message or media or file or web)         |
        // + ------------------------------------------+
        // | reactionView                              |
        // + ------------------------------------------+
        // | replySeparate                             |
        // + ------------------------------------------+
        // | reply                                     |
        // + ------------------------------------------+
        // | bottomSeparate                            |
        // + ------------------------------------------+
        
        self.userHStackView.setHStack([
            self.profileView,
            self.senderVStackView.setVStack([
                self.userNameLabel,
                self.dateLabel
            ]),
            self.moreButton
        ])
        self.contentView.addSubview(self.userHStackView)
        
        self.messageTextView.delegate = self
        
        self.contentView.addSubview(self.contentVStackView)
        
        self.contentView.addSubview(self.reactionView)
        self.contentView.addSubview(self.replySeparateLine)
        self.contentView.addSubview(self.replyLabel)
        self.contentView.addSubview(self.bottomSeparateLine)
        
        userHStackView.isHidden = true
        contentVStackView.isHidden = true
        reactionView.isHidden = true
        replySeparateLine.isHidden = true
        replyLabel.isHidden = true
        bottomSeparateLine.isHidden = true
        
        self.userHStackView.sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -16, top: 16)

        self.profileView.sbu_constraint(width: 34, height: 34)
        self.moreButton?.sbu_constraint(width: 17, height: 34)
        
        self.dateLabel.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        
        self.contentVStackView
            .sbu_constraint(equalTo: self.contentView, leading: 16)
            .sbu_constraint(lessThanOrEqualTo: self.contentView, trailing: -16, priority: .defaultLow)
            .sbu_constraint_equalTo(topAnchor: self.userHStackView.bottomAnchor, top: 8)
        
        self.reactionView
            .sbu_constraint(equalTo: self.contentView, leading: 8, trailing: -8)
            .sbu_constraint_equalTo(topAnchor: self.contentVStackView.bottomAnchor, top: 0)
        
        self.replySeparateLine
            .sbu_constraint(equalTo: self.contentView, leading: 0, trailing: 0)
            .sbu_constraint(height: 1)

        self.replyLabel
            .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -16)
        
        self.bottomSeparateLine
            .sbu_constraint(equalTo: self.contentView, leading: 0, trailing: 0, bottom: 0)
            .sbu_constraint_equalTo(topAnchor: self.replyLabel.bottomAnchor, top: 12)
            .sbu_constraint(height: 1)
    }
    
    open func setupLayouts() {
        self.contentVStackViewTrailingAnchorConstraint?.isActive = false
        switch message {
        case _ as UserMessage:
            self.contentVStackViewTrailingAnchorConstraint = self.contentVStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: self.contentView.trailingAnchor,
                constant: -16
            )
            
            // TODO: Activate the logic below when supporting url preview
//            if userMessage.ogMetaData != nil {
//                self.webView.widthAnchor.constraint(equalToConstant: 240).isActive = true
//            }
            
            break
            
        case let fileMessage as FileMessage:
            self.contentVStackViewTrailingAnchorConstraint = self.contentVStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: self.contentView.trailingAnchor,
                constant: -16
            )
            self.contentVStackViewTrailingAnchorConstraint?.priority = .defaultLow
            
            self.contentVStackView.layer.cornerRadius = 16
            self.contentVStackView.clipsToBounds = true
            
            self.baseFileContentViewWidthConstraint?.isActive = false
            
            let fileType = SBUUtils.getFileType(by: fileMessage)
            switch fileType {
            case .image, .video:
                self.baseFileContentView .sbu_constraint(height: 160)
                self.baseFileContentViewWidthConstraint =  self.baseFileContentView.widthAnchor.constraint(equalToConstant: 240)
                
            case .audio, .pdf, .etc:
                self.baseFileContentViewWidthConstraint =  self.baseFileContentView
                    .trailingAnchor.constraint(
                        lessThanOrEqualTo: self.contentView.trailingAnchor,
                        constant: -16
                    )
                break
            default:
                break
            }
            self.baseFileContentViewWidthConstraint?.isActive = true
        default:
            self.contentVStackViewTrailingAnchorConstraint = self.contentVStackView.trailingAnchor.constraint(
                lessThanOrEqualTo: self.contentView.trailingAnchor,
                constant: 16
            )
            break
        }
        self.contentVStackViewTrailingAnchorConstraint?.isActive = true
    }
    
    open func updateLayouts() {
        self.setupLayouts()
        
        let activateReply = (message?.threadInfo.replyCount ?? 0) > 0
        
        self.replySeparateLineTopAnchorConstraint?.isActive = false
        self.replySeparateLineTopAnchorConstraint = self.replySeparateLine.topAnchor.constraint(
            equalTo: self.reactionView.bottomAnchor,
            constant: 8
        )
        self.replySeparateLineTopAnchorConstraint?.isActive = true
        
        self.replyLabelTopAnchorConstraint?.isActive = false
        self.replyLabelTopAnchorConstraint = self.replyLabel.topAnchor.constraint(
            equalTo: self.replySeparateLine.bottomAnchor,
            constant: activateReply ? 12 : 0
        )
        self.replyLabelTopAnchorConstraint?.isActive = true
        
        self.bottomSeparateLineTopAnchorConstraint?.isActive = false
        self.bottomSeparateLineTopAnchorConstraint = bottomSeparateLine.topAnchor.constraint(
            equalTo: self.replyLabel.bottomAnchor,
            constant: activateReply ? 12 : 8
        )
        self.bottomSeparateLineTopAnchorConstraint?.isActive = true
    }
    
    open func setupStyles() {
        self.profileView.setupStyles()
        
        self.contentView.backgroundColor = self.theme.parentInfoBackgroundColor
        
        self.userNameLabel.textColor = self.theme.parentInfoUserNameTextColor
        self.userNameLabel.font = self.theme.parentInfoUserNameTextFont
        
        self.dateLabel.textColor = self.theme.parentInfoDateTextColor
        self.dateLabel.font = self.theme.parentInfoDateFont
        
        // TODO: Activate the logic below when supporting url preview
//        self.webView.backgroundColor = {BACKGROUND_COLOR}
        
        self.reactionView.setupStyles()
        
        self.replySeparateLine.backgroundColor = self.theme.parentInfoSeparateBarColor
        self.replyLabel.textColor = self.theme.parentInfoReplyCountTextColor
        self.replyLabel.font = self.theme.parentInfoReplyCountTextFont
        self.bottomSeparateLine.backgroundColor = self.theme.parentInfoSeparateBarColor
    }
    
    open func configure(
        message: BaseMessage?,
        delegate: SBUParentMessageInfoViewDelegate?,
        useReaction: Bool = false,
        voiceFileInfo: SBUVoiceFileInfo?
    ) {
        self.delegate = delegate
        
        self.message = message
        self.voiceFileInfo = voiceFileInfo
        self.isReactionAvailable = useReaction
        
        guard let message = self.message else { return }

        userHStackView.isHidden = !configured
        contentVStackView.isHidden = !configured
        reactionView.isHidden = !configured
        replySeparateLine.isHidden = !configured
        replyLabel.isHidden = !configured
        bottomSeparateLine.isHidden = !configured
        
        let activateReply = message.threadInfo.replyCount > 0
        self.bottomSeparateLine.isHidden = !activateReply
        
        let urlString = message.sender?.profileURL ?? ""
        self.profileView.configure(urlString: urlString, imageSize: 34)
        
        var username = ""
        if let sender = message.sender {
            username = SBUUser(user: sender).refinedNickname()
        }
        self.userNameLabel.text = username
        self.dateLabel.text = Date.messageCreatedTimeForParentInfo(baseTimestamp: message.createdAt)
        
        self.moreButton?.setImage(
            SBUIconSetType.iconMore.image(
                with: self.theme.parentInfoMoreButtonTintColor,
                to: .init(width: 17, height: 17)
            ),
            for: .normal
        )
        
        // Set up SBUUserMessageTextView
        self.contentVStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        switch message {
        case let userMessage as UserMessage:
            self.contentVStackView.setVStack([
                self.messageTextView,
                self.webView
            ])
            
            self.messageTextView.configure(
                model: SBUUserMessageTextViewModel(
                    message: userMessage,
                    position: .left
                )
            )
            
            // Set up WebView with OG meta data
            // TODO: Check - not included in receive data
            if let ogMetaData = userMessage.ogMetaData, SBUAvailable.isSupportOgTag() {
                self.webView.isHidden = false
                let model = SBUMessageWebViewModel(metaData: ogMetaData)
                self.webView.configure(model: model)
            } else {
                self.webView.isHidden = true
            }
            
        case let fileMessage as FileMessage:
            self.contentVStackView.setVStack([
                self.baseFileContentView,
            ])
            
            let fileType = SBUUtils.getFileType(by: fileMessage)
            switch fileType {
            case .image, .video:
                if !(self.baseFileContentView is SBUOpenChannelImageContentView) {
                    self.baseFileContentView.removeFromSuperview()
                    self.baseFileContentView = SBUOpenChannelImageContentView()
                    contentVStackView.insertArrangedSubview(self.baseFileContentView, at: 0)
                }
                self.baseFileContentView.configure(message: fileMessage, position: .left)

            case .audio, .pdf, .etc:
                if !(self.baseFileContentView is SBUOpenChannelCommonContentView) {
                    self.baseFileContentView.removeFromSuperview()
                    self.baseFileContentView = SBUCommonContentView()
                    contentVStackView.insertArrangedSubview(self.baseFileContentView, at: 0)
                }
                if let commonContentView = self.baseFileContentView as? SBUCommonContentView {
                    commonContentView.configure(
                        message: fileMessage,
                        position: .left,
                        highlightKeyword: nil
                    )
                }
            case .voice:
                if !(self.baseFileContentView is SBUVoiceContentView) {
                    self.baseFileContentView.removeFromSuperview()
                    self.baseFileContentView = SBUVoiceContentView()
                    contentVStackView.insertArrangedSubview(self.baseFileContentView, at: 0)
                }
                if let voiceContentView = self.baseFileContentView as? SBUVoiceContentView {
                    let voiceFileInfo = self.voiceFileInfo ?? SBUVoiceFileInfo.createVoiceFileInfo(with: fileMessage)
                    voiceContentView.configure(
                        message: fileMessage,
                        position: .left,
                        voiceFileInfo: voiceFileInfo
                    )
                    voiceContentView.needSetBackgroundColor = true
                }
                break
            }
            
        default:
            break
        }
        
        // MARK: Configure reaction view
        let isReactionEnabled = self.isReactionAvailable && self.enablesReaction
        self.reactionView.configure(
            maxWidth: SBUConstant.imageSize.width,
            useReaction: isReactionEnabled,
            reactions: message.reactions
        )
        
        let haveReplyCount = message.threadInfo.replyCount > 0
        self.replyLabel.text = haveReplyCount
        ? SBUStringSet.Message_Replied_Users_Count(message.threadInfo.replyCount, false)
        : nil
        
        self.updateLayouts()
        
        self.configured = true
    }
    
    // MARK: - Action
    open func setupActions() {
        self.profileView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )
        
        self.moreButton?.addTarget(self, action: #selector(onTapMoreButton(_:)), for: .touchUpInside)
        
        self.contentVStackView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapContentView(sender:)))
        )
        
        self.webView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapWebview(sender:))
        ))
        
        self.reactionView.emojiTapHandler = { [weak self] emojiKey in
            guard let self = self else { return }
            self.emojiTapHandler?(emojiKey)
        }

        self.reactionView.emojiLongPressHandler = { [weak self] emojiKey in
            guard let self = self else { return }
            self.emojiLongPressHandler?(emojiKey)
        }

        self.reactionView.moreEmojiTapHandler = { [weak self] in
            guard let self = self else { return }
            self.moreEmojiTapHandler?()
        }
    }
    
    /// Calls the `userProfileTapHandler()` when the user profile is tapped.
    /// - Parameter sender: tapGestureRecognizer
    @objc open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
    
    /// Calls the `tapHandlerToContent()` when the content area is tapped.
    /// - Parameter sender: tapGestureRecognizer
    @objc open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
    
    /// Opens the url when the web page preview area is tapped
    /// - Parameter sender: tapGestureRecognizer
    @objc open func onTapWebview(sender: UITapGestureRecognizer) {
        guard
            let ogMetaData = self.message?.ogMetaData,
            let urlString = ogMetaData.url,
            let url = URL(string: urlString),
            UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        url.open()
    }
    
    /// Calls the `moreButtonTapHandlerToContent()` when the more button is tapped.
    /// - Parameter sender: Sender
    @objc open func onTapMoreButton(_ sender: Any) {
        self.moreButtonTapHandlerToContent?()
    }
    
    open func userMessageTextView(_ textView: SBUUserMessageTextView, didTapMention user: SBUUser) {
        self.mentionTapHandler?(user)
    }
}
