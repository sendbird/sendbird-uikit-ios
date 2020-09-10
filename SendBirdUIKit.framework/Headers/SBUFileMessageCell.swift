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
    

    private lazy var contentLongPressRecognizer: UILongPressGestureRecognizer = {
        return .init(target: self, action: #selector(self.onLongPressContentView(sender:)))
    }()
    
    private lazy var contentTapRecognizer: UITapGestureRecognizer = {
        return .init(target: self, action: #selector(self.onTapContentView(sender:)))
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
    }
    
    
    // MARK: - Common
    public func configure(_ message: SBDFileMessage,
                          hideDateView: Bool,
                          groupPosition: MessageGroupPosition,
                          receiptState: SBUMessageReceiptState) {

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

        self.reactionView.configure(
            maxWidth: SBUConstant.imageSize.width,
            reactions: message.reactions
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

        // Remove ArrangedSubviews
        self.contentsStackView.arrangedSubviews.forEach(
            self.contentsStackView.removeArrangedSubview(_:)
        )
        
        switch position {
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
    
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let imageContentView = self?.baseFileContentView as? ImageContentView else { return }
            imageContentView.setImage(image, size: size)
            imageContentView.setNeedsLayout()
        }
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
            equalToConstant: self.minWidth
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: self.minHeight
        )

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
        self.setupStyles()
    }
    
    override func configure(message: SBDFileMessage, position: MessagePosition) {
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

        self.resizeImageView(by: thumbnail?.realSize ?? SBUConstant.thumbnailSize)

        self.imageView.loadImage(urlString: urlString, option: imageOption) { [weak self] _ in
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
            self.iconImageView.image = SBUIconSet.iconPlay
            
        case .image where message.type.hasPrefix("image/gif"):
            let isThumbnailAnimated = self.imageView.image?.isAnimatedImage() == true
            self.iconImageView.image = isThumbnailAnimated ? nil : SBUIconSet.iconGif
            
        default:

            switch self.message.sendingStatus {
            case .canceled, .failed:
                self.iconImageView.image = SBUIconSet.iconNoThumbnailLight
                    .sbu_with(tintColor: theme.fileMessagePlaceholderColor)
            default:
                if self.imageView.image == nil {
                    self.iconImageView.image = SBUIconSet.iconThumbnailLight
                        .sbu_with(tintColor: theme.fileMessagePlaceholderColor)
                } else {
                    self.iconImageView.image = nil
                }
            }
        }
    }
    
    func resizeImageView(by size: CGSize) {
        let width = size.width
        let height = size.height
        self.widthConstraint.constant = width < self.minWidth
            ? self.minWidth
            : min(width, self.maxWidth)
        self.heightConstraint.constant = height < self.minHeight
            ?self.minHeight
            : min(height, self.maxHeight)
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
        self.layer.cornerRadius = 16
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.fileImageView.layer.cornerRadius = 10
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1
        
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
        switch position {
        case .left:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageLeftTextColor,
                .foregroundColor: theme.fileMessageLeftTextColor
            ]
            
        case .right:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageRightTextColor,
                .foregroundColor: theme.fileMessageRightTextColor
            ]
        default:
            attributes = [:]
        }
        
        let attributedText = NSAttributedString(string: self.message.name, attributes: attributes)
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.layoutIfNeeded()
    }
}
