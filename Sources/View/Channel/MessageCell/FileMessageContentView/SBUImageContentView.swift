//
//  SBUImageContentView.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUImageContentView: SBUBaseFileContentView {
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()
    
    public var widthConstraint: NSLayoutConstraint!
    public var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    open override func setupViews() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.addSubview(self.imageView)
        self.addSubview(self.iconImageView)
    }
    
    open override func setupLayouts() {
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
    
    open func setupSizeContraint() {
        self.widthConstraint = self.imageView.widthAnchor.constraint(
            equalToConstant: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.height
        )

        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
    }
    
    open override func configure(message: FileMessage, position: MessagePosition) {
        if self.message?.requestId != message.requestId ||
            !message.isRequestIdValid ||
            self.message?.updatedAt != message.updatedAt {
            self.imageView.image = nil
        }
        
        super.configure(message: message, position: position)
        let thumbnail = message.thumbnails?.first

        let imageOption: UIImageView.ImageOption
        let urlString: String
        
        let isGifImage = message.type.hasPrefix("image/gif")
        
        if let thumbnailURL = thumbnail?.url, !thumbnailURL.isEmpty, !isGifImage {
            imageOption = .original
            urlString = thumbnailURL
        } else {
            switch SBUUtils.getFileType(by: message) {
            case .image where message.sendingStatus == .succeeded:
                urlString = message.url
                imageOption = .imageToThumbnail

            case .video where message.sendingStatus == .succeeded:
                urlString = message.url
                imageOption = .videoURLToImage

            default:
                imageOption = .imageToThumbnail
                urlString = ""
            }
        }
        
        let thumbnailSize = message.channelType == .group
        ? SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize
        : SBUGlobals.messageCellConfiguration.openChannel.thumbnailSize

        self.resizeImageView(by: thumbnailSize)
        self.loadImageSession = self.imageView.loadImage(
            urlString: urlString,
            option: imageOption,
            thumbnailSize: thumbnailSize,
            cacheKey: message.cacheKey,
            subPath: message.channelURL
        ) { [weak self] _ in
            DispatchQueue.main.async {
                self?.setFileIcon()
            }
        }
        self.setFileIcon()
    }
    
    public func setImage(_ image: UIImage?, size: CGSize? = nil) {
        if let size = size {
            self.resizeImageView(by: size)
        }

        self.imageView.image = image
        self.setFileIcon()
    }
    
    public func setFileIcon() {
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
                    to: SBUIconSetType.Metric.defaultIconSizeVeryLarge
                )
            default:
                if self.imageView.image == nil {
                    self.iconImageView.image = SBUIconSetType.iconPhoto.image(
                        with: theme.fileMessagePlaceholderColor,
                        to: SBUIconSetType.Metric.defaultIconSizeVeryLarge
                    )
                } else {
                    self.iconImageView.image = nil
                }
            }
        }
    }
    
    open func resizeImageView(by size: CGSize) {
        self.widthConstraint.constant = min(
            size.width,
            SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.width
        )
        self.heightConstraint.constant = min(
            size.height,
            SBUGlobals.messageCellConfiguration.groupChannel.thumbnailSize.height
        )
    }
}
