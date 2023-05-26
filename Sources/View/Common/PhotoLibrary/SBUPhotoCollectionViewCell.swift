//
//  SBUPhotoCollectionViewCell.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/03/28.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import Photos

/// The collection view cell for `SBUSelectablePhotoViewController`.
open class SBUPhotoCollectionViewCell: UICollectionViewCell, SBUViewLifeCycle {
    
    // MARK: - View properties
    
    /// The image view that shows photos or the video thumbnails
    public var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    /// The image view that shows the icon to indicate the media type of the item.
    public var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .center
        return imageView
    }()

    /// The object that is used as a theme. The theme inherits from `SBUMessageCellTheme`.
    @SBUThemeWrapper(theme: SBUTheme.messageCellTheme)
    public var theme: SBUMessageCellTheme

    // MARK: - UIKit Life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupLayouts()
        self.setupActions()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        self.setupStyles()
    }

    // MARK: - Sendbird Life cycle (Set up)
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.addSubview(imageView)
        self.addSubview(self.iconImageView)
    }

    /// This function handles the initialization of auto layouts.
    open func setupLayouts() {
        imageView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)

        self.iconImageView
            .sbu_constraint(equalTo: self, centerX: 0, centerY: 0)
            .sbu_constraint(width: 48, height: 48)
            .layoutIfNeeded()
    }

    /// Configures the cell with image and the media type of the asset.
    open func configure(image: UIImage?, forMediaType mediaType: PHAssetMediaType) {
        self.imageView.image = image
        switch mediaType {
        case .video:
            self.iconImageView.image = SBUIconSetType.iconPlay.image(
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

    /// This function handles the initialization of styles.
    open func setupStyles() { }
    
    /// This function handles the initialization of actions.
    open func setupActions() { }
    
    // MARK: - Sendbird Life cycle (Update)

    /// This function updates layouts.
    open func updateLayouts() { }
    
    /// This function updates styles.
    open func updateStyles() { }
}
