//
//  SBUOpenChannelCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUOpenChannelCell: SBUBaseChannelCell {
    
    // MARK: - property
    /// The image view that shows the channel cover image.
    public lazy var coverImage = SBUCoverImageView()
    /// The label that represents the channel name.
    public lazy var titleLabel = UILabel()
    /// The image view that shows the participant icon.
    public lazy var participantIcon = UIImageView()
    /// The label that represents the number of members in the channel.
    public lazy var participantCountLabel = UILabel()
    /// The image view that indicates the freezing state of the channel.
    public lazy var freezeState = UIImageView()
    /// A view that is used as a separator between the channel cells.
    public lazy var separatorLine = UIView()
    /// A spacer used in `titleStackView` to provide spacing between `titleLabel` and `lastUpdatedTimeLabel`.
    public let titleSpacer = UIView()
    public let participantSpacer = UIView()
    
    /// A value used in the size of `coverImage`.
    public let coverImageSize: CGFloat = 56
    /// A value used in the size of icon image views.
    public let infoIconSize: CGFloat = 16
    
    /// A horizontal stack view to configure layouts of the entire view properties.
    public lazy var contentStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 16)
    /// A vertical stack view to configure layouts of labels and icons that represent the channel information.
    public lazy var infoStackView = SBUStackView(axis: .vertical, alignment: .leading, spacing: 2)
    /// A horizontal stack view to configure layouts of the `titleLabel`, `lastUpdatedTimeLabel` and icons.
    public lazy var titleStackView = SBUStackView(axis: .horizontal, alignment: .center, spacing: 4)
    /// A horizontal stack view to configure layouts of the `participantIcon` and the `participantCount`.
    public lazy var participantStackView = SBUStackView(axis: .horizontal, alignment: .top, spacing: 4)
    
    @SBUThemeWrapper(theme: SBUTheme.openChannelCellTheme)
    public var theme: SBUOpenChannelCellTheme
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        super.setupViews()
        
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(
            x: 0,
            y: 0,
            width: coverImageSize,
            height: coverImageSize
        )
        
        self.freezeState.isHidden = true
        
        self.contentView.addSubview(
            self.contentStackView.setHStack([
                self.coverImage,
                self.infoStackView.setVStack([
                    self.titleStackView.setHStack([
                        self.titleLabel,
                        self.freezeState,
                        self.titleSpacer
                    ]),
                    self.participantStackView.setHStack([
                        self.participantIcon,
                        self.participantCountLabel,
                        self.participantSpacer
                    ]),
                ])
            ])
        )
        self.contentView.addSubview(self.separatorLine)
        
        self.titleStackView.setCustomSpacing(0, after: titleSpacer)
        self.participantStackView.setCustomSpacing(0, after: participantSpacer)
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        super.setupActions()
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        super.setupLayouts()
        
        // content stack view
        self.contentStackView
            .sbu_constraint(equalTo: self.contentView, leading: 16, trailing: -16, top: 10, bottom: 10)
        
        self.coverImage
            .sbu_constraint(width: coverImageSize, height: coverImageSize)
        
        // title stack view
        self.titleStackView
            .sbu_constraint(equalTo: self.contentStackView, trailing: 0)
            .sbu_constraint(height: 22)
        
        self.freezeState
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        self.titleLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // participant stack view
        self.participantStackView
            .sbu_constraint(equalTo: self.contentStackView, trailing: 0)
            .sbu_constraint_greaterThan(height: 20)
        
        self.participantIcon
            .sbu_constraint(width: infoIconSize, height: infoIconSize)
        
        // speprator
        self.separatorLine
            .sbu_constraint(equalTo: self.contentView, trailing: 0, bottom: 0.5)
            .sbu_constraint(equalTo: self.infoStackView, leading: 0)
            .sbu_constraint(height: 0.5)
        
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleTextColor
        
        self.participantIcon.image = SBUIconSetType.iconMembers.image(
            with: theme.participantMarkTint,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        
        self.participantCountLabel.font = theme.participantCountFont
        self.participantCountLabel.textColor = theme.participantCountTextColor
        
        self.freezeState.image = SBUIconSetType.iconFreeze.image(
            with: theme.freezeStateTintColor,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        
        self.separatorLine.backgroundColor = theme.separatorLineColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = coverImageSize / 2
    }
    
    deinit {
        SBULog.info("")
    }
    
    /// This function configure a cell using `OpenChannel` information.
    /// - Parameter channel: `OpenChannel` object
    open override func configure(channel: BaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? OpenChannel else { return }

        // Cover image
        if let url = channel.coverURL {
            self.coverImage.setImage(withCoverURL: url)
        } else {
            self.coverImage.setPlaceholder(type: .iconChannels, iconSize: SBUIconSetType.Metric.defaultIconSize)
        }
        
        // Title
        if channel.name.isEmpty {
            self.titleLabel.text = SBUStringSet.Open_Channel_Name_Default
        } else {
            self.titleLabel.text = channel.name
        }
        
        // Member cound. If 1:1 channel, not set
        self.participantCountLabel.text = channel.participantCount.unitFormattedString
        
        // Channel frozen state. If isFrozen is false, this property will hidden.
        self.freezeState.isHidden = channel.isFrozen == false
    }
}
