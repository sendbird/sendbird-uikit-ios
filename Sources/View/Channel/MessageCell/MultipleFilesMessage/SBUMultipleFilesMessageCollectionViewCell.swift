//
//  SBUMultipleFilesMessageCollectionViewCell.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 2023/09/07.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
/// CollectionView Cell used in SBUMultipleFilesMessageCollectionView to show the files of a multiple files message.
/// - Since: 3.10.0
open class SBUMultipleFilesMessageCollectionViewCell: SBUCollectionViewCell {
    // swiftlint:enable type_name

    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public var overlayView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    public var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        imageView.isHidden = false
        return imageView
    }()
    
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme
    public var imageCornerRadius: CGFloat = 1
    
    private(set) var uploadableFileInfo: UploadableFileInfo?
    private(set) var uploadedFileInfo: UploadedFileInfo?
    
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    open func configure(
        uploadableFileInfo: UploadableFileInfo? = nil,
        uploadedFileInfo: UploadedFileInfo? = nil,
        requestId: String,
        index: Int,
        imageCornerRadius: CGFloat,
        showOverlay: Bool
    ) {
        self.uploadableFileInfo = uploadableFileInfo
        self.uploadedFileInfo = uploadedFileInfo
        self.imageCornerRadius = imageCornerRadius
        
        setupViews()
        setupStyles()
        setupLayouts()
        
        // Image data setup.
        guard let uploadedFileInfo = uploadedFileInfo else {
            // Set image with local image
            // when message.sendingStatus is pending or failed.
            guard let uploadableFileInfo = uploadableFileInfo,
                  let imageData = uploadableFileInfo.file else {
                SBULog.error("Multiple files message has no files")
                return
            }
            
            DispatchQueue.main.async { [weak self, uploadableFileInfo] in
                guard let self = self else { return }
                self.imageView.image = UIImage(data: imageData)
                self.overlayView.isHidden = !showOverlay
                if let mimeType = uploadableFileInfo.mimeType, mimeType.hasPrefix("image/gif") {
                    self.setGIFIcon()
                } else {
                    self.iconImageView.isHidden = true
                }
            }
            return
        }
        
        // Set image from server URL
        // when message.sendingStatus is succeeded.
        let fileURL = uploadedFileInfo.url
        self.loadImageSession = self.imageView.loadImage(
            urlString: fileURL,
            option: .imageToThumbnail,
            cacheKey: requestId + "_\(index)"
        ) { _ in
            DispatchQueue.main.async { [weak self, uploadedFileInfo] in
                guard let self = self else { return }
                self.overlayView.isHidden = true
                if let mimeType = uploadedFileInfo.mimeType, mimeType.hasPrefix("image/gif") {
                    self.setGIFIcon()
                } else {
                    self.iconImageView.isHidden = true
                }
            }
        }
        
        self.layoutIfNeeded()
    }
    
    override open func setupViews() {
        contentView.addSubview(imageView)
        contentView.addSubview(overlayView)
        contentView.addSubview(iconImageView)
    }
    
    override open func setupStyles() {
        // contentView
        self.contentView.layer.cornerRadius = self.imageCornerRadius
        self.contentView.layer.masksToBounds = true
        
        self.overlayView.backgroundColor = theme.multipleFilesMessageFileOverlayColor
    }
    
    override open func setupLayouts() {
        // imageView
        self.imageView
            .sbu_constraint(
                equalTo: contentView,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        // overlayView
        self.overlayView
            .sbu_constraint(
                equalTo: contentView,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        // iconImageView
        self.iconImageView
            .sbu_constraint(equalTo: contentView, centerX: 0, centerY: 0)
            .sbu_constraint(width: 32, height: 32)
    }
    
    override open func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.overlayView.isHidden = true
        self.iconImageView.isHidden = true
        self.loadImageSession?.cancel()
    }
    
    public func setGIFIcon() {
        self.iconImageView.isHidden = false
        self.iconImageView.image = SBUIconSetType.iconGif.image(
            with: theme.fileImageIconColor,
            to: SBUIconSetType.Metric.iconGifPlay
        )
        
        self.iconImageView.backgroundColor = theme.fileImageBackgroundColor
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.height / 2
    }
}
