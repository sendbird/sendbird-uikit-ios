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

open class SBUParentMessageInfoView: SBUView, SBUUserMessageTextViewDelegate {
    
    // MARK: - UI properties (Public)
    
    /// - Since: 3.10.0
    public struct Constants {
        public static var verticalSideMarginSize: CGFloat = 16.0
    }
    
    /// The view that displays the profile image of sender.
    public var profileView = SBUMessageProfileView()
    public var profileBaseView = UIView()
    
    /// The label that displays the username of sender.
    public var userNameLabel = UILabel()
    /// The label that displays the message sent time.
    public var dateLabel = UILabel()
    /// The button that displays the more menu items.
    public lazy var moreButton: UIButton? = UIButton()
    public var moreButtonBaseView = UIView()
    
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
    
    /// The collection view that displays the multiple files. It's used when the message is `MultipleFilesMessage`.
    /// - Since: 3.10.0
    public lazy var fileCollectionView: SBUMultipleFilesMessageCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumInteritemSpacing = 4
        layout.minimumLineSpacing = 4
        
        let collectionview = SBUMultipleFilesMessageCollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.isScrollEnabled = false
        
        return collectionview
    }()
    
    /// The view that displays the web page preview. Used when the user message type (not used yet).
    public var webView = SBUMessageWebView()
    /// The view that displays the reactions.
    public var reactionView = SBUParentMessageInfoReactionView()
    
    /// ```
    /// + -----------------+------------------+--------------------+
    /// | profileBaseView  | senderVStackView | moreButtonBaseView |
    /// + -----------------+------------------+--------------------+
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
    
    /// This property for backward support
    /// - Since: 3.10.0
    public lazy var contentView: UIView = self
    
    // MARK: - UI properties (Private)
    var replyLabelTopAnchorConstraint: NSLayoutConstraint?
    var bottomSeparateLineTopAnchorConstraint: NSLayoutConstraint?
    var messageTextViewWidthConstraint: NSLayoutConstraint?
    
    var alreadySetupLayouts: Bool = false
    
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
    /// The handler that set the logic to be called when the specific file is selected.
    /// - Since: 3.10.0
    public var fileSelectHandler: ((_ fileInfo: UploadedFileInfo, _ index: Int) -> Void)?
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
    
    var errorHandler: ((_ error: SBError) -> Void)?
    
    // MARK: - LifeCycle
    @available(*, unavailable, renamed: "SBUParentMessageInfoView(frame:)")
    required convenience public init?(coder: NSCoder) {
        fatalError()
    }
    
    required public override init() {
        super.init()
    }
    
    open override func setupViews() {
        #if SWIFTUI
        if self.viewConverter.entireContent != nil {
            return
        }
        #endif
        
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
        
        self.senderVStackView.setVStack([
            self.userNameLabel,
            self.dateLabel
        ])
        
        self.profileBaseView.addSubview(self.profileView)
        if let moreButton = moreButton {
            self.moreButtonBaseView.addSubview(moreButton)
        }
        
        self.userHStackView.setHStack([
            self.profileBaseView,
            self.senderVStackView,
            self.moreButtonBaseView
        ])
        
        self.addSubview(self.userHStackView)
        
        self.messageTextView.delegate = self
        
        self.addSubview(self.contentVStackView)
        
        self.addSubview(self.reactionView)
        self.addSubview(self.replySeparateLine)
        self.addSubview(self.replyLabel)
        self.addSubview(self.bottomSeparateLine)
        
        userHStackView.isHidden = true
        contentVStackView.isHidden = true
        reactionView.isHidden = true
        replySeparateLine.isHidden = true
        replyLabel.isHidden = true
        bottomSeparateLine.isHidden = true
    }
    
    open override func setupLayouts() {
        #if SWIFTUI
        if self.viewConverter.entireContent != nil {
            return
        }
        #endif
        
        guard !alreadySetupLayouts else { return }
        alreadySetupLayouts = true
        
        /// ```
        /// + -----------------+------------------+--------------------+
        /// | profileBaseView  | senderVStackView | moreButtonBaseView |
        /// + -----------------+------------------+--------------------+
        /// ```
        self.userHStackView
            .sbu_constraint(equalTo: self, leading: 16, top: 16)
            .sbu_constraint(equalTo: self, trailing: -16, priority: .defaultHigh)
            .sbu_constraint_equalTo(bottomAnchor: self.contentVStackView.topAnchor, bottom: 8)
        
        self.profileView
            .sbu_constraint(equalTo: self.profileBaseView, leading: 0, trailing: 0, top: 0)
            .sbu_constraint(width: 34, height: 34)
        self.moreButton?
            .sbu_constraint(equalTo: self.moreButtonBaseView, leading: 0, trailing: 0, centerY: 0)
            .sbu_constraint(width: 17, height: 34)
        
        /// ```
        /// + ----------------------------------+
        /// | (message or media or file or web) |
        /// + ----------------------------------+
        /// ```
        self.contentVStackView
            .sbu_constraint(equalTo: self, leading: 16)
            .sbu_constraint(lessThanOrEqualTo: self, trailing: -16, priority: .defaultHigh)
        
        var willApplyReactionViewConverter = false
        #if SWIFTUI
        willApplyReactionViewConverter = self.viewConverter.reactionView.entireContent != nil
        #endif
        if !willApplyReactionViewConverter {
            self.contentVStackView
                .sbu_constraint_equalTo(bottomAnchor: self.reactionView.topAnchor, bottom: 0)
        }
        
        switch message {
        case _ as UserMessage:
            break
            
        case let fileMessage as FileMessage:
            self.contentVStackView.layer.cornerRadius = 16
            self.contentVStackView.clipsToBounds = true
            
            let fileType = SBUUtils.getFileType(by: fileMessage)
            switch fileType {
            case .image, .video:
                self.baseFileContentView.sbu_constraint(width: 240, height: 160)

            case .audio, .pdf, .etc:
                break
            default:
                break
            }
            
        case _ as MultipleFilesMessage:
            break
            
        default:
            break
        }
        
        /// ```
        /// + ------------------------------------------+
        /// | reactionView                              |
        /// + ------------------------------------------+
        /// ```
        self.reactionView
            .sbu_constraint(equalTo: self, leading: 8)
            .sbu_constraint(equalTo: self, trailing: -8, priority: .defaultLow)
            .sbu_constraint_equalTo(bottomAnchor: self.replySeparateLine.topAnchor, bottom: 8)
        
        /// ```
        /// + ------------------------------------------+
        /// | replySeparateLine                         |
        /// + ------------------------------------------+
        /// ```
        self.replySeparateLine
            .sbu_constraint(equalTo: self, leading: 0)
            .sbu_constraint(equalTo: self, trailing: 0, priority: .defaultLow)
            .sbu_constraint(height: 1, priority: .defaultHigh)
//            .sbu_constraint_equalTo(bottomAnchor: self.replyLabel.topAnchor, bottom: 0)
        
        /// ```
        /// + ------------------------------------------+
        /// | replyLabel                                |
        /// + ------------------------------------------+
        /// ```
        self.replyLabel
            .sbu_constraint(equalTo: self, leading: 16)
            .sbu_constraint(equalTo: self, trailing: -16, priority: .defaultLow)
//            .sbu_constraint_equalTo(bottomAnchor: self.bottomSeparateLine.topAnchor, bottom: 8)
        
        var willApplyReplyLabelViewConverter = false
        #if SWIFTUI
        willApplyReplyLabelViewConverter = self.viewConverter.replyLabel.entireContent != nil
        #endif
        
        if !willApplyReplyLabelViewConverter {
            self.replyLabelTopAnchorConstraint = self.replyLabel.sbu_constraint_equalTo_v2(
                topAnchor: self.replySeparateLine.bottomAnchor,
                top: 0
            ).first
        }
        
//        NSLayoutConstraint.sbu_activate(baseView: self.replySeparateLine, constraints: [self.replyLabelTopAnchorConstraint])
        
        /// ```
        /// + ------------------------------------------+
        /// | bottomSeparateLine                        |
        /// + ------------------------------------------+
        /// ```
        self.bottomSeparateLine
            .sbu_constraint(height: 1, priority: .defaultHigh)
            .sbu_constraint(equalTo: self, leading: 0, bottom: 0)
            .sbu_constraint(equalTo: self, trailing: 0, priority: .defaultLow)
        
        if !willApplyReplyLabelViewConverter {
            self.bottomSeparateLineTopAnchorConstraint = bottomSeparateLine.sbu_constraint_equalTo_v2(
                topAnchor: self.replyLabel.bottomAnchor,
                top: 8
            ).first
        }
        
//        NSLayoutConstraint.sbu_activate(baseView: self.replyLabel, constraints: [self.bottomSeparateLineTopAnchorConstraint])
        
        /// 
        
        // not working below logic
        if let superview = self.superview {
            self.sbu_constraint(equalTo: superview, leading: 0, trailing: 0, top: 0)
            self.sbu_constraint(equalTo: superview, centerY: 0)
        }
    }
    
    open override func updateLayouts() {
        #if SWIFTUI
        if self.viewConverter.entireContent != nil {
            return
        }
        #endif
        let activateReply = (message?.threadInfo.replyCount ?? 0) > 0
        
        self.replyLabelTopAnchorConstraint?.constant = activateReply ? 12 : 0
        self.bottomSeparateLineTopAnchorConstraint?.constant = activateReply ? 12 : 8
        
        NSLayoutConstraint.sbu_activate(baseView: replyLabel, constraints: [
            self.replyLabelTopAnchorConstraint
        ])
        
        NSLayoutConstraint.sbu_activate(baseView: bottomSeparateLine, constraints: [
            self.bottomSeparateLineTopAnchorConstraint
        ])
    }
    
    open override func setupStyles() {
        #if SWIFTUI
        if self.viewConverter.entireContent != nil {
            return
        }
        #endif
        
        self.profileView.setupStyles()
        
        self.backgroundColor = self.theme.parentInfoBackgroundColor
        
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
        voiceFileInfo: SBUVoiceFileInfo?,
        enableEmojiLongPress: Bool = true
    ) {
        #if SWIFTUI
        if self.applyViewConverter(.entireContent) {
            return
        }
        #endif
        
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
        
        // profile view
        #if SWIFTUI
        self.applyViewConverter(.profileView)
        #endif
        let urlString = message.sender?.profileURL ?? ""
        self.profileView.configure(urlString: urlString, imageSize: 34)
        
        // userNameLabel
        #if SWIFTUI
        self.applyViewConverter(.userNameLabel)
        #endif
        var username = ""
        if let sender = message.sender {
            username = SBUUser(user: sender).refinedNickname()
        }
        self.userNameLabel.text = username
        
        // dateLabel
        #if SWIFTUI
        self.applyViewConverter(.dateLabel)
        #endif
        self.dateLabel.text = Date.messageCreatedTimeForParentInfo(baseTimestamp: message.createdAt)
        
        // more button
        #if SWIFTUI
        self.applyViewConverter(.moreButton)
        #endif
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
                self.messageTextView
            ])
            
            // Set up WebView with OG meta data
            // TODO: Check - not included in receive data
            if let ogMetaData = userMessage.ogMetaData, SBUAvailable.isSupportOgTag() {
                self.contentVStackView.addArrangedSubview(self.webView)
                self.webView.isHidden = false
                let model = SBUMessageWebViewModel(metaData: ogMetaData)
                
                // og-metadata
                var didApplyWebViewViewConverter = false
                #if SWIFTUI
                didApplyWebViewViewConverter = applyViewConverter(.webView)
                #endif
                if !didApplyWebViewViewConverter {
                    self.webView.configure(model: model)
                }
                
            } else {
                if let superViewWidth = self.superview?.frame.width {
                  self.messageTextViewWidthConstraint?.isActive = false
                    self.messageTextViewWidthConstraint = self.messageTextView.sbu_constraint_lessThan_v2(width: superViewWidth - (Constants.verticalSideMarginSize * 2)).first
                    self.messageTextViewWidthConstraint?.isActive = true
                }
                
                self.webView.isHidden = true
            }
            
            // messsage text view
            var didApplyMessageTextView = false
            #if SWIFTUI
            didApplyMessageTextView = self.applyViewConverter(.messageTextView)
            #endif
            if !didApplyMessageTextView {
                self.messageTextView.configure(
                    model: SBUUserMessageTextViewModel(
                        message: userMessage,
                        position: .left
                    )
                )
            }
            
        case let fileMessage as FileMessage:
            #if SWIFTUI
            if self.applyViewConverter(.fileContentView) { break }
            #endif
            self.contentVStackView.setVStack([
                self.baseFileContentView
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
            }
            
        case _ as MultipleFilesMessage:
            #if SWIFTUI
            if self.applyViewConverter(.multipleFileContentView) { break }
            #endif
            
            self.fileCollectionView.removeFromSuperview()
            
            var fileCollectionViewHeight = self.fileCollectionView.collectionViewLayout.collectionViewContentSize.height
            fileCollectionViewHeight = fileCollectionViewHeight == 0 ? 120 : fileCollectionViewHeight
            
            self.fileCollectionView
                .sbu_constraint(width: SBUConstant.messageCellMaxWidth)
                .sbu_constraint(height: fileCollectionViewHeight, priority: .defaultHigh)
            
            contentVStackView.insertArrangedSubview(self.fileCollectionView, at: 0)
            
            self.fileCollectionView.configure(delegate: self, dataSource: self, cornerRadius: 8)
            
        default:
            break
        }
        
        // MARK: Configure reaction view
        let isReactionEnabled = self.isReactionAvailable && self.enablesReaction
        
        let params = SBUMessageReactionViewParams(
            maxWidth: SBUConstant.imageSize.width,
            useReaction: isReactionEnabled,
            reactions: message.reactions,
            enableEmojiLongPress: enableEmojiLongPress,
            message: message
        )
        self.reactionView.configure(configuration: params)
        
        var didApplyReactionViewViewConverter = false
        #if SWIFTUI
        didApplyReactionViewViewConverter = self.applyViewConverter(.reactionView)
        #endif
        if !didApplyReactionViewViewConverter {
            self.reactionView.configure(
                maxWidth: SBUConstant.imageSize.width,
                useReaction: isReactionEnabled,
                reactions: message.reactions,
                enableEmojiLongPress: enableEmojiLongPress
            )
        }
        
        #if SWIFTUI
        self.applyViewConverter(.replyLabel)
        #endif
        let haveReplyCount = message.threadInfo.replyCount > 0
        self.replyLabel.text = haveReplyCount
        ? SBUStringSet.Message_Replied_Users_Count(message.threadInfo.replyCount, false)
        : nil
        
        self.updateLayouts()
        
        self.configured = true
    }
    
    /// Updates the width constraint property of messageTextView based on size
    /// - Parameter size: Reference size
    ///
    /// - Since: 3.10.0
    open func updateMessageTextWidth(with size: CGSize) {
        var width = 0.0
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            width = min(size.width, size.height)
        case .landscapeLeft, .landscapeRight:
            width = max(size.width, size.height)
        default:
            return
        }
        
        self.messageTextViewWidthConstraint?.constant = width - (Constants.verticalSideMarginSize * 2)
    }
    
    // MARK: - Action
    open override func setupActions() {
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
        
        self.reactionView.errorHandler = { [weak self] error in
            guard let self = self else { return }
            self.errorHandler?(error)
        }
    }
    
    /// Calls the `userProfileTapHandler()` when the user profile is tapped.
    /// - Parameter sender: tapGestureRecognizer
    @objc
    open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }
    
    /// Calls the `tapHandlerToContent()` when the content area is tapped.
    /// - Parameter sender: tapGestureRecognizer
    @objc
    open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
    
    /// Calls the `fileSelectHandler()` when one of thie files is tapped in parent message that is a multiple files message.
    /// - Parameter sender: tapGestureRecognizer
    /// - Since: 3.10.0
    @objc
    open func onSelectFile(sender: UITapGestureRecognizer) {
        if let cell = sender.view as? SBUMultipleFilesMessageCollectionViewCell,
           let fileInfo = cell.uploadedFileInfo,
           let indexPath = fileCollectionView.indexPath(for: cell) {
            
            self.onTapSelectFile(fileInfo, index: indexPath.item)
        }
    }
    
    /// - Since: 3.28.0
    public func onTapSelectFile(_ fileInfo: UploadedFileInfo, index: Int) {
        self.fileSelectHandler?(fileInfo, index)
    }
    
    /// Opens the url when the web page preview area is tapped
    /// - Parameter sender: tapGestureRecognizer
    @objc
    open func onTapWebview(sender: UITapGestureRecognizer) {
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
    @objc
    open func onTapMoreButton(_ sender: Any) {
        self.moreButtonTapHandlerToContent?()
    }
    
    open func userMessageTextView(_ textView: SBUUserMessageTextView, didTapMention user: SBUUser) {
        self.mentionTapHandler?(user)
    }
}

// MARK: - Multiple Files Message
extension SBUParentMessageInfoView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let message = self.message as? MultipleFilesMessage else { return 0 }
        return message.files.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return SBUConstant.parentInfoMultipleFilesThumbnailSize
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let message = self.message as? MultipleFilesMessage,
              let cell = fileCollectionView.dequeueReusableCell(
            withReuseIdentifier: SBUMultipleFilesMessageCollectionViewCell.sbu_className,
            for: indexPath
        ) as? SBUMultipleFilesMessageCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        let index = indexPath[1]
        cell.configure(
            uploadedFileInfo: message.files[index],
            requestId: message.requestId,
            index: indexPath[1],
            imageCornerRadius: 8,
            showOverlay: false
        )
        
        /// Add gesture recognizer instead of using `collectionView didSelectItemAt`
        /// becuase`onTapContentView` consumes the tap instead of triggering the `didSelectItemAt`.
        cell.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onSelectFile(sender:))))
        return cell
    }
}
