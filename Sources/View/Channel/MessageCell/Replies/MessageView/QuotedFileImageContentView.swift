//
//  QuotedFileImageContentView.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/29.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class QuotedFileImageContentView: SBUView {
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    var position: MessagePosition = .center
    
    var text: String = ""
    var fileURL: String = ""
    var fileType: String = ""
    
    var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.opacity = 0.4
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
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    // MARK: - SBUViewLifeCycle
    override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.imageView)
        self.addSubview(self.iconImageView)
    }
    
    override func setupAutolayout() {
        super.setupAutolayout()
        
        self.imageView
            .setConstraint(
                from: self,
                left: 0, right: 0, top: 0, bottom: 0,
                priority: .defaultLow
            )
        
        self.setupSizeContraint()
        
        self.iconImageView
            .setConstraint(from: self, centerX: true, centerY: true)
            .setConstraint(width: 48, height: 48)
            .layoutIfNeeded()
    }
    
    func setupSizeContraint() {
        self.widthConstraint = self.imageView.widthAnchor.constraint(
            equalToConstant: SBUConstant.quotedMessageThumbnailSize.width
        )
        self.heightConstraint = self.imageView.heightAnchor.constraint(
            equalToConstant: SBUConstant.quotedMessageThumbnailSize.height
        )
        
        NSLayoutConstraint.activate([
            self.widthConstraint,
            self.heightConstraint
        ])
    }
    
    override func setupStyles() {
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        super.setupStyles()
        
        self.theme = SBUTheme.messageCellTheme
    }
    
    // MARK: - Configuration
    func configure(with configuration: SBUQuotedBaseMessageViewParams) {
        let imageOption: UIImageView.ImageOption
        guard let fileType = configuration.fileType else { return }
        guard let fileURL = configuration.urlString else { return }
        self.fileType = fileType
        switch SBUUtils.getFileType(by: fileType) {
            case .image:
                imageOption = .imageToThumbnail
            case .video:
                imageOption = .videoUrlToImage
            default:
                imageOption = .imageToThumbnail
        }
        
        let thumbnailSize = SBUConstant.thumbnailSize
        
        self.resizeImageView(by: thumbnailSize)
        self.loadImageSession = self.imageView.loadImage(
            urlString: fileURL,
            option: imageOption,
            thumbnailSize: thumbnailSize
        ) { _ in
            DispatchQueue.main.async { [weak self] in
                self?.setFileIcon()
            }
        }
        self.fileURL = fileURL
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
        guard !self.fileType.isEmpty else { return }
        
        switch SBUUtils.getFileType(by: self.fileType) {
            case .video:
                self.iconImageView.image = SBUIconSetType.iconPlay.image(
                    with: theme.fileImageIconColor,
                    to: SBUIconSetType.Metric.iconGifPlay
                )
                
                self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
                self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
            case .image where self.fileType.hasPrefix("image/gif"):
                self.iconImageView.image = SBUIconSetType.iconGif.image(
                    with: theme.fileImageIconColor,
                    to: SBUIconSetType.Metric.iconGifPlay
                )
                
                self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
                self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
            default:
                self.iconImageView.backgroundColor = nil
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
    
    func resizeImageView(by size: CGSize) {
        self.widthConstraint.constant = min(
            size.width,
            SBUConstant.quotedMessageThumbnailSize.width
        )
        self.heightConstraint.constant = min(
            size.height,
            SBUConstant.quotedMessageThumbnailSize.height
        )
    }
}
