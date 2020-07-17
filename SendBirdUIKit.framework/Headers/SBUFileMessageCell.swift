//
//  SBUFileMessageCell.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/20.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers @IBDesignable
open class SBUFileMessageCell: SBUBaseMessageCell {
    
    // MARK: - Public property
    public lazy var userNameStackView: UIStackView = _userNameStackView
    public lazy var contentsStackView: UIStackView = _contentsStackView
    public lazy var userNameView: UIView = _userNameView
    public lazy var profileView: UIView = _profileView
    public lazy var stateView: UIView = _stateView

    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()
        
        self.messageContentView.addSubview(self.userNameStackView)
        
        self.userNameStackView.addArrangedSubview(self.userNameView)
        self.userNameStackView.addArrangedSubview(self.contentsStackView)

        self.detailContainerView.stackView.addArrangedSubview(self.baseFileContentView)
        self.detailContainerView.stackView.addArrangedSubview(self.reactionView)

        self.contentsStackView.addArrangedSubview(self.profileView)
        self.contentsStackView.addArrangedSubview(self.detailContainerView)
        self.contentsStackView.addArrangedSubview(self.stateView)
    }
    
    open override func setupAutolayout() {
        super.setupAutolayout()
        
        self.userNameStackView
            .setConstraint(from: self.messageContentView, left: 0, right: 12, bottom: 0)
            .setConstraint(from: self.messageContentView, top: 0, priority: .defaultLow)
    }
    
    open override func setupActions() {
        super.setupActions()

        let stateTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onTapContentView(sender:)))
        self.stateView.addGestureRecognizer(stateTapRecognizer)
        
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
    public func configure(_ message: SBDFileMessage, hideDateView: Bool, receiptState: SBUMessageReceiptState) {

        let oldMessage = self.fileMessage

        super.configure(message: message,
                        position: SBUGlobals.CurrentUser?.userId == message.sender?.userId ? .right : .left,
                        hideDateView: hideDateView,
                        receiptState: receiptState)

        if oldMessage == message,
            oldMessage?.updatedAt == message.updatedAt,
            oldMessage?.sendingStatus == .succeeded, message.sendingStatus == .succeeded {

            if let baseFileContentView = self.baseFileContentView as? ImageContentView, baseFileContentView.imageView.image?.isAnimatedImage() == false {
                self.reactionView.configure(maxWidth: SBUConstant.imageSize.width, reactions: message.reactions)
                return
            }
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
                                receiptState: receiptState,
                                position: self.position)
        }

        self.reactionView.configure(maxWidth: SBUConstant.imageSize.width, reactions: message.reactions)
        self.baseFileContentView.removeGestureRecognizer(self.contentLongPressRecognizer)
        self.baseFileContentView.removeGestureRecognizer(self.contentTapRecognizer)

        switch SBUUtils.getFileType(by: message) {
        case .image, .video:
            self.detailContainerView.stackView.removeArrangedSubview(self.baseFileContentView)
            self.baseFileContentView.removeFromSuperview()
            self.baseFileContentView = ImageContentView()
            self.baseFileContentView.configure(message: message, position: self.position)
            self.detailContainerView.stackView.insertArrangedSubview(self.baseFileContentView, at: 0)

        case .audio, .pdf, .etc:
            self.detailContainerView.stackView.removeArrangedSubview(self.baseFileContentView)
            self.baseFileContentView.removeFromSuperview()
            self.baseFileContentView = CommonContentView()
            self.baseFileContentView.configure(message: message, position: self.position)
            self.detailContainerView.stackView.insertArrangedSubview(self.baseFileContentView, at: 0)
        }

        self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
        self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)

        self.detailContainerView.configure(position: self.position, isSelected: false)

        switch self.position {
        case .left:
            self.userNameStackView.alignment = .leading
            self.profileView.isHidden = false
            self.userNameView.isHidden = false
            self.contentsStackView.removeArrangedSubview(self.stateView)
            self.contentsStackView.addArrangedSubview(self.stateView)
        case .right:
            self.userNameStackView.alignment = .trailing
            self.userNameView.isHidden = true
            self.profileView.isHidden = true
            self.contentsStackView.removeArrangedSubview(self.detailContainerView)
            self.contentsStackView.addArrangedSubview(self.detailContainerView)
        case .center:
            break
        }

        self.setNeedsLayout()
    }
    
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let imageContentView = self?.baseFileContentView as? ImageContentView else { return }
            imageContentView.setImage(image, size: size)
            imageContentView.setNeedsLayout()
        }
    }
    
    public func setBackgroundColor(color: UIColor) {
        self.baseFileContentView.backgroundColor = color
    }

    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.baseFileContentView.setBackground(isSelected: selected)
        self.detailContainerView.configure(position: self.position, isSelected: selected)
    }
    
    @objc open func onLongPressContentView(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            self.longPressHandlerToContent?()
        }
    }
    
    @objc open func onTapContentView(sender: UITapGestureRecognizer) {
        self.tapHandlerToContent?()
    }
    
    @objc open func onTapProfileImageView(sender: UITapGestureRecognizer) {
        self.tapHandlerToProfileImage?()
    }

    // MARK: - Private property
    private var fileMessage: SBDFileMessage? {
        return self.message as? SBDFileMessage
    }

    private lazy var baseFileContentView: BaseFileContentView = {
        let fileView = BaseFileContentView()
        return fileView
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

    private lazy var contentLongPressRecognizer: UILongPressGestureRecognizer = { return .init(target: self, action: #selector(self.onLongPressContentView(sender:)))
    }()

    private lazy var contentTapRecognizer: UITapGestureRecognizer = {
        return .init(target: self, action: #selector(self.onTapContentView(sender:)))
    }()
}


// MARK: - File Content View
fileprivate class BaseFileContentView: UIView {
    
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var message: SBDFileMessage!
    var position: MessagePosition = .center
    
    func configure(message: SBDFileMessage, position: MessagePosition) {
        self.message = message
        self.position = position
        
        switch position {
        case .left  : self.backgroundColor = theme.leftBackgroundColor
        case .right : self.backgroundColor = theme.rightBackgroundColor
        case .center: break
        }
    }
    
    open func setBackground(isSelected: Bool) {
        if isSelected {
            switch position {
            case .left  : self.backgroundColor = theme.leftPressedBackgroundColor
            case .right : self.backgroundColor = theme.rightPressedBackgroundColor
            case .center: break
            }
        } else {
            switch position {
            case .left  : self.backgroundColor = theme.leftBackgroundColor
            case .right : self.backgroundColor = theme.rightBackgroundColor
            case .center: break
            }
        }
    }
}


// MARK: - Image Content View
fileprivate class ImageContentView: BaseFileContentView {

    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    var text: String = ""
    
    var maxWidth: CGFloat = 240
    var minWidth: CGFloat = 100
    
    var maxHeight: CGFloat = 400
    var minHeight: CGFloat = 100

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
    
    @available(*, unavailable, renamed: "ImageContentView(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.iconImageView.contentMode = .center
        
        self.addSubview(self.imageView)
        self.addSubview(self.iconImageView)
    }
    
    func setupAutolayout() {
        self.imageView
            .setConstraint(from: self, left: 0, right: 0, top: 0, bottom: 0, priority: .defaultLow)
        
        self.widthConstraint = self.imageView.widthAnchor.constraint(equalToConstant: self.minWidth)
        self.heightConstraint = self.imageView.heightAnchor.constraint(equalToConstant: self.minHeight)

        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
        
        self.iconImageView
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 48, height: 48)
    }

    func setupStyles() {
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.setupStyles()
    }
    
    override func configure(message: SBDFileMessage, position: MessagePosition) {
        super.configure(message: message, position: position)

        self.resizeImageView(by: SBUConstant.thumbnailSize)

        let imageOption: UIImageView.ImageOption
        let urlString: String

        if let thumbnailUrl = message.thumbnails?.first?.url {
            imageOption = .original
            urlString = thumbnailUrl
        } else {
            switch SBUUtils.getFileType(by: message) {
            case .image where message.sendingStatus == .succeeded:
                urlString = message.url
                imageOption = .imageToThumbnail

            case .video where message.sendingStatus == .succeeded:
                urlString = message.url
                imageOption = .videoUrlToImage

            default:
                imageOption = .imageToThumbnail
                urlString = ""
            }
        }

        self.imageView.loadImage(urlString: urlString, option: imageOption) { [weak self] in
            self?.setFileIcon()
        }

        self.setBackground(isSelected: false)

        self.setFileIcon()
        self.setNeedsLayout()
    }

    func setImage(_ image: UIImage?, size: CGSize? = nil) {
        if let size = size {
            self.resizeImageView(by: size)
        }

        self.imageView.image = image
        self.setFileIcon()
    }
    
    func setFileIcon() {
        switch SBUUtils.getFileType(by: self.message) {
        case .video:
            self.iconImageView.image = SBUIconSet.iconPlay
            
        case .image where message.type.hasPrefix("image/gif"):
            let isThumbnailAnimated = self.imageView.image?.isAnimatedImage() == true
            self.iconImageView.image = isThumbnailAnimated ? nil : SBUIconSet.iconGif
            
        default:

            switch self.message.sendingStatus {
            case .canceled, .failed:
                self.iconImageView.image = SBUIconSet.iconNoThumbnailLight.sbu_with(tintColor: theme.fileMessagePlaceholderColor)

            default:
                if self.imageView.image == nil {
                    self.iconImageView.image = SBUIconSet.iconThumbnailLight.sbu_with(tintColor: theme.fileMessagePlaceholderColor)
                } else {
                    self.iconImageView.image = nil
                }
            }
        }
    }
    
    func resizeImageView(by size: CGSize) {
        let width = size.width
        let height = size.height

        switch width {
        case ...minWidth:
            self.widthConstraint.constant = minWidth
        case minWidth...maxWidth:
            self.widthConstraint.constant = width
        case maxWidth...:
            self.widthConstraint.constant = maxWidth
        default:
            break
        }
        
        switch height {
        case ...minHeight:
            self.heightConstraint.constant = minHeight
        case minHeight...maxHeight:
            self.heightConstraint.constant = height
        case maxHeight...:
            self.heightConstraint.constant = maxHeight
        default:
            break
        }
        self.layoutIfNeeded()
    }
}


// MARK: - Common Content View
fileprivate class CommonContentView: BaseFileContentView {

    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    var fileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    var fileNameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

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
    
    @available(*, unavailable, renamed: "CommonContentView(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.fileImageView)
        self.stackView.addArrangedSubview(self.fileNameLabel)
    }
    
    func setupAutolayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 44),
            self.widthAnchor.constraint(lessThanOrEqualToConstant: 240)
        ])

        self.stackView.setConstraint(from: self, left: 12, right: 12, top: 8, bottom: 8)
        self.fileImageView.setConstraint(width: 28, height: 28)
    }
    
    func setupStyles() {
        self.fileImageView.backgroundColor = theme.fileIconBackgroundColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true

        // File Image
        self.fileImageView.layer.cornerRadius = 10
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1

        self.setupStyles()
    }
    
    override func configure(message: SBDFileMessage, position: MessagePosition) {
        super.configure(message: message, position: position)
        
        let type = SBUUtils.getFileType(by: message)
        
        let image: UIImage
        switch type {
        case .audio: image = SBUIconSet.iconFileAudio.sbu_with(tintColor: theme.fileIconColor)
        case .image: image = SBUIconSet.iconFileDocument.sbu_with(tintColor: theme.fileIconColor)
        case .video: image = SBUIconSet.iconFileDocument.sbu_with(tintColor: theme.fileIconColor)
        case .pdf  : image = SBUIconSet.iconFileDocument.sbu_with(tintColor: theme.fileIconColor)
        case .etc  : image = SBUIconSet.iconFileDocument.sbu_with(tintColor: theme.fileIconColor)
        }
        
        self.fileImageView.image = image
        
        let attributes: [NSAttributedString.Key : Any]
        switch self.position {
        case .left:
            attributes = [ .underlineStyle: NSUnderlineStyle.single.rawValue,
                           .font: theme.fileMessageNameFont,
                           .underlineColor: theme.fileMessageLeftTextColor,
                           .foregroundColor: theme.fileMessageLeftTextColor ]
            
        case .right:
            attributes = [ .underlineStyle: NSUnderlineStyle.single.rawValue,
                           .font: theme.fileMessageNameFont,
                           .underlineColor: theme.fileMessageRightTextColor,
                           .foregroundColor: theme.fileMessageRightTextColor ]
        default:
            attributes = [:]
        }
        
        let attributedText = NSAttributedString(string: self.message.name, attributes: attributes)
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        self.setBackground(isSelected: false)
        
        self.layoutIfNeeded()
    }
}
