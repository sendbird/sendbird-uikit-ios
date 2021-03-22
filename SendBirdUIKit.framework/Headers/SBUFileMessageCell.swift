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
open class SBUFileMessageCell: SBUContentBaseMessageCell {
    
    // MARK: - Public property
    public var fileMessage: SBDFileMessage? {
        return self.message as? SBDFileMessage
    }
    
    // MARK: - Private property
    private lazy var baseFileContentView: BaseFileContentView = {
        let fileView = BaseFileContentView()
        return fileView
    }()
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        self.mainContainerView.addArrangedSubview(self.baseFileContentView)
        self.mainContainerView.addArrangedSubview(self.reactionView)
    }

    open override func setupAutolayout() {
        super.setupAutolayout()
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.baseFileContentView.setupStyles()
    }
    
    // MARK: - Common
    open func configure(_ message: SBDFileMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          receiptState: SBUMessageReceiptState?) {

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
        
        switch SBUUtils.getFileType(by: message) {
        case .image, .video:
            if !(self.baseFileContentView is ImageContentView){
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = ImageContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            self.baseFileContentView.configure(message: message, position: position)

        case .audio, .pdf, .etc:
            if !(self.baseFileContentView is CommonContentView) {
                self.baseFileContentView.removeFromSuperview()
                self.baseFileContentView = CommonContentView()
                self.baseFileContentView.addGestureRecognizer(self.contentLongPressRecognizer)
                self.baseFileContentView.addGestureRecognizer(self.contentTapRecognizer)
                self.mainContainerView.insertArrangedSubview(self.baseFileContentView, at: 0)
            }
            self.baseFileContentView.configure(message: message, position: position)
        }
    }
    
    open func configure(highlightInfo: SBUHighlightMessageInfo?) {
        // Only apply highlight for the given message, that's not edited (updatedAt didn't change)
        guard self.message.messageId == highlightInfo?.messageId,
              self.message.updatedAt == highlightInfo?.updatedAt else { return }
        
        guard let commonContentView = self.baseFileContentView as? CommonContentView,
              let fileMessage = self.fileMessage else { return }
        
        commonContentView.configure(message: fileMessage,
                                    position: self.position,
                                    highlight: true)
    }
    
    /// This method has to be called in main thread
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        guard let imageContentView = self.baseFileContentView as? ImageContentView else { return }
        imageContentView.setImage(image, size: size)
        imageContentView.setNeedsLayout()
    }

    
    // MARK: - Action
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}


// MARK: - File Content View

fileprivate class BaseFileContentView: UIView {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    
    var message: SBDFileMessage!
    var position: MessagePosition = .center

    func setupStyles() {
        self.theme = SBUTheme.messageCellTheme
    }
    
    func configure(message: SBDFileMessage, position: MessagePosition) {
        self.message = message
        self.position = position
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
        imageView.contentMode = .center
        return imageView
    }()
    
    var widthConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    
    var text: String = ""
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }

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
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.addSubview(self.imageView)
        self.addSubview(self.iconImageView)
    }
    
    func setupAutolayout() {
        self.imageView.setConstraint(
            from: self,
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            priority: .defaultLow
        )
        
        self.widthConstraint = self.imageView.widthAnchor.constraint(
            equalToConstant: SBUConstant.thumbnailSize.width
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: SBUConstant.thumbnailSize.height
        )

        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
        
        self.iconImageView
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 48, height: 48)
        self.iconImageView.layoutIfNeeded()
    }

    override func setupStyles() {
        super.setupStyles()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    override func configure(message: SBDFileMessage, position: MessagePosition) {
        if self.message?.requestId != message.requestId ||
            self.message?.updatedAt != message.updatedAt {
            self.imageView.image = nil
        }
        
        super.configure(message: message, position: position)
        let thumbnail = message.thumbnails?.first

        let imageOption: UIImageView.ImageOption
        let urlString: String
        
        if let thumbnailUrl = thumbnail?.url {
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

        self.resizeImageView(by: SBUConstant.thumbnailSize)

        self.loadImageSession = self.imageView.loadImage(urlString: urlString, option: imageOption) { [weak self] _ in
            self?.setFileIcon()
        }

        self.setFileIcon()
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
            self.iconImageView.image = SBUIconSetType.iconPlay.image(with: theme.fileImageIconColor,
                                                                     to: SBUIconSetType.Metric.iconGifPlay)
            
            self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
            self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        case .image where message.type.hasPrefix("image/gif"):
            self.iconImageView.image = SBUIconSetType.iconGif.image(
                with: theme.fileImageIconColor,
                to: SBUIconSetType.Metric.iconGifPlay
            )
            
            self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
            self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
        default:
            self.iconImageView.backgroundColor = nil
            switch self.message.sendingStatus {
            case .canceled, .failed:
                self.iconImageView.image = SBUIconSetType.iconThumbnailNone.image(
                    with: theme.fileMessagePlaceholderColor,
                    to: SBUIconSetType.Metric.defaultIconSizeXLarge
                )
            default:
                if self.imageView.image == nil {
                    self.iconImageView.image = SBUIconSetType.iconPhoto.image(
                        with: theme.fileMessagePlaceholderColor,
                        to: SBUIconSetType.Metric.defaultIconSizeXLarge
                    )
                } else {
                    self.iconImageView.image = nil
                }
            }
        }
    }
    
    func resizeImageView(by size: CGSize) {
        let width = size.width
        let height = size.height
        self.widthConstraint.constant = min(width, SBUConstant.thumbnailSize.width)
        self.heightConstraint.constant = min(height, SBUConstant.thumbnailSize.height)
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
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.fileImageView.layer.cornerRadius = 8
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1
        
        self.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.fileImageView)
        self.stackView.addArrangedSubview(self.fileNameLabel)
    }
    
    func setupAutolayout() {
        self.sbu_constraint(height: 44)
        self.stackView.setConstraint(from: self, left: 12, right: 12, top: 8, bottom: 8)
        self.fileImageView.setConstraint(width: 28, height: 28)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        switch position {
        case .left: self.backgroundColor = theme.leftBackgroundColor
        case .right: self.backgroundColor = theme.rightBackgroundColor
        default: break
        }
        self.fileImageView.backgroundColor = theme.fileIconBackgroundColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }
    
    override func configure(message: SBDFileMessage, position: MessagePosition) {
        self.configure(message: message,
                       position: position,
                       highlight: false)
    }
    
    func configure(message: SBDFileMessage,
                   position: MessagePosition,
                   highlight: Bool) {
        if self.message?.requestId != message.requestId ||
            self.message?.updatedAt != message.updatedAt {
            self.fileImageView.image = nil
        }
        
        super.configure(message: message, position: position)
        
        let type = SBUUtils.getFileType(by: message)
        
        let image: UIImage
        switch type {
        case .audio:
            image = SBUIconSetType.iconFileAudio.image(
                with: theme.fileIconColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
        case .image, .video, .pdf, .etc:
            image = SBUIconSetType.iconFileDocument.image(
                with: theme.fileIconColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
        }
        
        self.fileImageView.image = image
        
        var attributes: [NSAttributedString.Key : Any]
        var highlightTextColor: UIColor
        
        switch position {
        case .left:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageLeftTextColor,
                .foregroundColor: theme.fileMessageLeftTextColor
            ]
            highlightTextColor = theme.messageLeftHighlightTextColor
        case .right:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageRightTextColor,
                .foregroundColor: theme.fileMessageRightTextColor
            ]
            highlightTextColor = theme.messageRightHighlightTextColor
        default:
            attributes = [:]
            highlightTextColor = theme.messageRightHighlightTextColor
        }
        
        if highlight {
            attributes[.backgroundColor] = SBUColorSet.highlight
            attributes[.foregroundColor] = highlightTextColor
        }
        
        let attributedText = NSAttributedString(string: self.message.name, attributes: attributes)
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
}
