//
//  LiveStreamChannelCell.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class LiveStreamChannelCell: SBUOpenChannelCell {
    static let coverImageWidth: CGFloat = 120
    static let coverImageHeight: CGFloat = 72
    static let leadingPadding: CGFloat = 16
    static let activeIndicatorSize: CGFloat = 10
    static let iconSize: CGFloat = 22
    static let tagsHeight: CGFloat = 20
    
    let creatorProfileImage = SBUCoverImageView()
    let translucentView = UIView()
    let creatorNameLabel = UILabel()
    let tagsLabel = PaddingLabel(4, 5)
    let activeIndicator = UIView()
    
    override func setupViews() {
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(
            x: 0,
            y: 0,
            width: Self.coverImageWidth,
            height: Self.coverImageHeight
        )
        
        self.creatorProfileImage.clipsToBounds = true
        self.creatorProfileImage.frame = CGRect(
            x: 0,
            y: 0,
            width: Self.iconSize,
            height: Self.iconSize
        )
        
        self.tagsLabel.clipsToBounds = true
        self.activeIndicator.clipsToBounds = true
        
        self.titleStackView.setHStack([
            self.creatorProfileImage,
            self.titleLabel
        ])
        
        self.infoStackView.setVStack([
            self.titleStackView,
            self.creatorNameLabel,
            self.tagsLabel,
            self.freezeState
        ])
        
        self.participantStackView.tag = 3030
        self.participantStackView.setHStack([
            self.participantCountLabel
        ])
        self.contentView.addSubview(self.translucentView)
        self.contentView.addSubview(self.coverImage)
        self.contentView.addSubview(self.infoStackView)
        self.contentView.addSubview(self.activeIndicator)
        self.contentView.addSubview(self.participantStackView)
    }
    
    override func setupLayouts() {
        self.creatorProfileImage
            .sbu_constraint(width: Self.iconSize, height: Self.iconSize)

        self.titleLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        self.infoStackView
            .sbu_constraint(
                equalTo: self.contentView,
                trailing: 16,
                top: 10
            )
            .sbu_constraint(height: 72)
            .sbu_constraint_equalTo(
                leadingAnchor: self.coverImage.trailingAnchor,
                leading: Self.leadingPadding
            )
        
        self.tagsLabel
            .sbu_constraint(height: Self.tagsHeight)

        self.participantCountLabel
            .sbu_constraint(height: 22, priority: .defaultHigh)
        
        self.coverImage
            .sbu_constraint(
                equalTo: self.contentView,
                leading: Self.leadingPadding,
                top: 12,
                bottom: 12
            )
            .sbu_constraint(
                width: Self.coverImageWidth,
                height: Self.coverImageHeight
            )
        
        self.translucentView
            .sbu_constraint(
                equalTo: self.coverImage,
                leading: 0,
                trailing: 0,
                top: 0,
                bottom: 0
            )
        
        self.activeIndicator
            .sbu_constraint(equalTo: self.participantStackView, centerY: 0)
            .sbu_constraint_equalTo(
                leadingAnchor: self.coverImage.leadingAnchor,
                leading: 4
            )
            .sbu_constraint(
                width: Self.activeIndicatorSize,
                height: Self.activeIndicatorSize
            )

        self.participantStackView
            .sbu_constraint_equalTo(
                leadingAnchor: self.activeIndicator.trailingAnchor,
                leading: 4
            )
            .sbu_constraint_equalTo(
                trailingAnchor: self.coverImage.trailingAnchor,
                trailing: -4
            )
            .sbu_constraint_equalTo(
                bottomAnchor: self.coverImage.bottomAnchor,
                bottom: 4
            )
            .sbu_constraint(height: 12)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.coverImage.layer.cornerRadius = 0
    }
    
    override func setupStyles() {
        self.theme = SBUTheme.openChannelCellTheme

        // When you change `theme.backgroundColor` This might be always `false`
        let isDarkMode = theme.backgroundColor == SBUColorSet.background600

        self.backgroundColor = theme.backgroundColor
        self.translucentView.backgroundColor = SBUColorSet.ondark04

        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleTextColor

        // message font
        self.creatorNameLabel.font = theme.participantCountFont
        self.creatorNameLabel.textColor = theme.participantCountTextColor

        self.tagsLabel.font = theme.participantCountFont
        self.tagsLabel.textColor = theme.participantCountTextColor
        self.tagsLabel.backgroundColor = isDarkMode
            ? SBUColorSet.background400
            : SBUColorSet.background200
        self.tagsLabel.layer.cornerRadius = Self.tagsHeight / 2
        
        self.activeIndicator.backgroundColor = .red
        self.activeIndicator.layer.cornerRadius = Self.activeIndicatorSize / 2

        self.participantCountLabel.font = theme.participantCountFont
        self.participantCountLabel.textColor = SBUColorSet.ondark01
    }
    
    override func configure(channel: BaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? OpenChannel else { return }
        guard let liveStreamData = channel.liveStreamData else { return }
        
        // Cover image
        self.coverImage.setImage(with: liveStreamData.liveChannelURL, makeCircle: false)
        self.creatorProfileImage.setImage(with: liveStreamData.thumbnailURL)
        
        // Title
        self.titleLabel.text = liveStreamData.name
        self.creatorNameLabel.text = liveStreamData.creatorInfo.name
        
        self.tagsLabel.text = liveStreamData.tags.joined(separator: ", ")
        
        self.participantCountLabel.text = "\(channel.participantCount)"
        
        self.creatorProfileImage.isHidden = false
        
        // Channel frozen state. If isFrozen is false, this property will hidden.
        self.freezeState.isHidden = self.channel?.isFrozen == false
    }
}
