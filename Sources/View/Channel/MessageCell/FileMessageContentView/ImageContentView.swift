//
//  ImageContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class ImageContentView: BaseFileContentView {
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
        
        self.setupSizeContraint()
        
        self.iconImageView
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 48, height: 48)
        self.iconImageView.layoutIfNeeded()
    }
    
    func setupSizeContraint() {
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
        
        let thumbnailSize = message.channelType == CHANNEL_TYPE_GROUP ?
            SBUConstant.thumbnailSize : SBUConstant.openChannelThumbnailSize

        self.resizeImageView(by: thumbnailSize)
        self.loadImageSession = self.imageView.loadImage(urlString: urlString,
                                                         option: imageOption,
                                                         thumbnailSize: thumbnailSize) { [weak self] _ in
            DispatchQueue.main.async {
                self?.setFileIcon()
            }
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
            self.iconImageView.image = SBUIconSetType.iconPlay.image(
                with: theme.fileImageIconColor,
                to: SBUIconSetType.Metric.iconGifPlay
            )
            
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
        self.widthConstraint.constant = min(size.width,
                                            SBUConstant.thumbnailSize.width)
        self.heightConstraint.constant = min(size.height,
                                             SBUConstant.thumbnailSize.height)
    }
}
