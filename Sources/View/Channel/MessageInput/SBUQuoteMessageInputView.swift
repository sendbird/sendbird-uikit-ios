//
//  SBUQuoteMessageInputView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/07.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol SBUQuoteMessageInputViewDelegate: AnyObject {
    func didTapClose()
}

@IBDesignable
open class SBUQuoteMessageInputView: SBUView, SBUQuoteMessageInputViewProtocol {
    // MARK: - Models
    
    @SBUThemeWrapper(theme: SBUTheme.messageInputTheme)
    public var theme: SBUMessageInputTheme
    
    // MARK: - Views
    
    // MARK: Controls
    
    /// The UILabel displaying whom user replies to.
    /// e.g. “Reply to Jasmine”
    /// - Since: 2.2.0
    public lazy var replyToLabel: UILabel = {
        return UILabel()
    }()

    /// The UIImageView displaying thumbnail of message that user replies to.
    /// - Since: 2.2.0
    public lazy var fileMessagePreview: UIImageView = {
       let imageView = UIImageView()
        imageView.roundCorners(corners: .allCorners, radius: 8)
        return imageView
    }()
    
    /// The UILabel displaying preview of message text.
    /// - Since: 2.2.0
    public lazy var userMessagePreview: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    /// The button that stops replying.
    /// - Since: 2.2.0
    public lazy var closeReplyButton: UIButton = {
        return UIButton()
    }()
    
    lazy var leadingSpacer: UIView = {
        return UIView()
    }()
    
    lazy var trailingSpacer: UIView = {
        return UIView()
    }()
    
    private lazy var bottomSpacer: UIView = {
        return UIView()
    }()
    
    private lazy var topSpacer: UIView = {
        return UIView()
    }()
    
    // MARK: Layouts
    
    // + ------------------ + ------------------- + ----------- +
    // | fileMessagePreview | replyLabelStackView | closeButton |
    // + ------------------ + ------------------- + ----------- +
    /// The UIStackView contains all components.
    /// - Since: 2.2.0
    public lazy var contentStackView: UIStackView = {
        return SBUStackView(axis: .horizontal, alignment: .center, spacing: 8)
    }()
    
    // + ------------------- +
    // | repliedToLabel        |
    // + ------------------- +
    // | userMessagePreview  |
    // + ------------------- +
    /// The UIStackView contains `replyToLabel` and `userMessagePreview`.
    /// - Since: 2.2.0
    public lazy var replyLabelStackView: UIStackView = {
        return SBUStackView(axis: .vertical, alignment: .leading, spacing: 8)
    }()
    
    // + ------------------ +
    // | topSpacer          |
    // + ------------------ +
    // | paddableHStackView |
    // + ------------------ +
    // | bottomSpacer       |
    // + ------------------ +
    lazy var paddableVStackView: SBUStackView = {
        return SBUStackView(axis: .vertical)
    }()
    
    // + ------------- + ---------------- + -------------- +
    // | leadingSpacer | contentStackView | trailingSpacer |
    // + ------------- + ---------------- + -------------- +
    lazy var paddableHStackView: SBUStackView = {
        return SBUStackView(axis: .horizontal)
    }()
    
    // MARK: - Action Delegate
    weak var delegate: SBUQuoteMessageInputViewDelegate?
    
    // MARK: - SBUView Life cycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override init() {
        super.init()
    }
    
    open override func setupViews() {
        // + -------------------------------------------------------------------------------- +
        // |                                topSpacer                                         |
        // + ------------- + ----------- + ------------------- + ----------- + -------------- +
        // | leadingSpacer | filePreview | repliedToLabel        | closeButton | trailingSpacer |
        // |               |             + ------------------- +             |                |
        // |               |             | userMessagePreview  |             |                |
        // + ------------- + ----------- + ------------------- + ----------- + -------------- +
        // |                               bottomSpacer                                       |
        // + -------------------------------------------------------------------------------- +
        
        self.paddableVStackView.setVStack([
            self.topSpacer,
            self.paddableHStackView.setHStack([
                self.leadingSpacer,
                self.contentStackView.setHStack([
                    self.fileMessagePreview,
                    self.replyLabelStackView.setVStack([
                        self.replyToLabel,
                        self.userMessagePreview
                    ]),
                    self.closeReplyButton
                ]),
                self.trailingSpacer
            ]),
            self.bottomSpacer
        ])
        self.addSubview(self.paddableVStackView)
    }
    
    open override func setupLayouts() {
        self.leadingSpacer
            .setConstraint(width: 18, height: 0)
        
        self.trailingSpacer
            .setConstraint(width: 12, height: 0)
        
        self.bottomSpacer
            .setConstraint(width: 0, height: 0)
        
        self.topSpacer
            .setConstraint(width: 0, height: 0)
        
        self.paddableVStackView
            .setConstraint(from: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.fileMessagePreview
            .setConstraint(width: 32, height: 32)
        
        self.closeReplyButton
            .setConstraint(width: 32, height: 32)
        
    }
    
    open override func setupActions() {
        self.closeReplyButton.addTarget(self, action: #selector(onTapClose), for: .touchUpInside)
    }
    
    open override func setupStyles() {
        self.fileMessagePreview.tintColor = theme.quotedFileMessageThumbnailTintColor
        self.fileMessagePreview.backgroundColor = theme.quotedFileMessageThumbnailBackgroundColor
        
        self.replyToLabel.font = theme.replyToTextFont
        self.replyToLabel.textColor = theme.replyToTextColor
        
        self.userMessagePreview.font = theme.quotedMessageTextFont
        self.userMessagePreview.textColor = theme.quotedMessageTextColor

        self.closeReplyButton.setImage(
            SBUIconSetType.iconClose.image(
                with: theme.closeReplyButtonColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
    }

    open func configure(with configuration: SBUQuoteMessageInputViewParams) {
        self.fileMessagePreview.isHidden = !configuration.isFileType
        if configuration.messageFileType == .voice {
            self.fileMessagePreview.isHidden = true
            self.userMessagePreview.text = SBUStringSet.VoiceMessage.Preview.quotedMessage
        } else {
            self.userMessagePreview.text = configuration.message.message
        }
        
        self.replyToLabel.text = configuration.replyToText
        
        self.setupFilePreview(with: configuration)
        
    }
    
    func setupFilePreview(with configuration: SBUQuoteMessageInputViewParams) {
        guard let fileMessage = configuration.message as? FileMessage else { return }
        guard configuration.isFileType,
              let name = configuration.fileName,
              let messageFileType = configuration.messageFileType
        else { return }
        
        // Set up with file name
        self.userMessagePreview.text = name
        
        var imageOption: UIImageView.ImageOption = .imageToThumbnail
        var fileIcon: UIImage?
        
        switch messageFileType {
            case .image:
                imageOption = .imageToThumbnail
            case .video:
                imageOption = .videoURLToImage
            case .audio:
                fileIcon = SBUIconSetType.iconFileAudio.image(
                    with: theme.quotedFileMessageThumbnailTintColor,
                    to: SBUIconSetType.Metric.quotedMessageIconSize
                )
            case .voice:
                self.userMessagePreview.text = SBUStringSet.VoiceMessage.Preview.quotedMessage
                break
                
            case .pdf, .etc:
                fileIcon = SBUIconSetType.iconFileDocument.image(
                    with: theme.quotedFileMessageThumbnailTintColor,
                    to: SBUIconSetType.Metric.quotedMessageIconSize
                )
        }
        
        if let fileIcon = fileIcon {
            self.fileMessagePreview.contentMode = .center
            self.fileMessagePreview.image = fileIcon
            return
        }
        
        let thumbnailSize = SBUIconSetType.Metric.defaultIconSizeLarge
        self.fileMessagePreview.contentMode = .scaleAspectFill
        self.fileMessagePreview.loadImage(
            urlString: fileMessage.url,
            option: imageOption,
            thumbnailSize: thumbnailSize,
            cacheKey: fileMessage.cacheKey,
            subPath: fileMessage.channelURL
        )
    }
    
    // MARK: - Actions
    @objc
    func onTapClose() {
        self.delegate?.didTapClose()
    }
    
    // public
    func padding(_ edge: Edge, _ spacing: CGFloat) {
        switch edge {
        case .vertical:
            self.paddableVStackView.spacing = spacing
        case .leading:
            self.leadingSpacer.setConstraint(width: spacing)
        case .trailing:
            self.trailingSpacer.setConstraint(width: spacing)
        }
        self.updateConstraintsIfNeeded()
    }
    
    public enum Edge: Int {
        case vertical = 0
        case leading = 1
        case trailing = 2
    }
}
