//
//  StreamingChannelCell.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/11/15.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class StreamingChannelCell: SBUBaseChannelCell {
    
    // MARK: - property
    lazy var videoThumbnail = UIImageView()
    lazy var coverImage = SBUCoverImageView()
    
    lazy var titleHStack: UIStackView = {
        let titleHStack = UIStackView()
        titleHStack.alignment = .center
        titleHStack.spacing = 8.0
        titleHStack.axis = .horizontal
        return titleHStack
    }()
    lazy var channelInfoVStack: UIStackView = {
        let channelInfoVStack = UIStackView()
        channelInfoVStack.alignment = .leading
        channelInfoVStack.spacing = 4.0
        channelInfoVStack.axis = .vertical
        return channelInfoVStack
    }()
    lazy var liveInfoHStack: UIStackView = {
        let liveInfoHStack = UIStackView()
        liveInfoHStack.spacing = 4.0
        liveInfoHStack.axis = .horizontal
        return liveInfoHStack
    }()
    
    lazy var translucentView = UIView()
    lazy var channelNameLabel = UILabel()
    lazy var creatorProfileImage = SBUCoverImageView()
    lazy var creatorNameLabel = UILabel()
    lazy var tagsLabel = PaddingLabel(4, 5)
    
    lazy var activeIndicator = UIView()
    lazy var participantCountLabel = UILabel()
    lazy var freezeState = UIImageView()
    
    let coverImageWidth: CGFloat = 120
    let coverImageHeight: CGFloat = 72
    let leadingPadding: CGFloat = 16
    let activeIndicatorSize: CGFloat = 10
    let iconSize: CGFloat = 22
    let tagsHeight: CGFloat = 20
    
    
    // MARK: - View Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // MARK: While SBUCaseCell initialized
    /// Handles the initialization of views.
    override func setupViews() {
        super.setupViews()
        
        self.coverImage.frame = CGRect(x: 0,
                                       y: 0,
                                       width: coverImageWidth,
                                       height: coverImageHeight)
        
        self.creatorProfileImage.frame = CGRect(x: 0, y: 0, width: iconSize, height: iconSize)
        
        self.coverImage.clipsToBounds = true
        self.creatorProfileImage.clipsToBounds = true
        self.tagsLabel.clipsToBounds = true
        self.activeIndicator.clipsToBounds = true
        
        self.titleHStack.addArrangedSubview(self.creatorProfileImage)
        self.titleHStack.addArrangedSubview(self.channelNameLabel)
        
        self.channelInfoVStack.addArrangedSubview(self.titleHStack)
        self.channelInfoVStack.addArrangedSubview(self.creatorProfileImage)
        self.channelInfoVStack.addArrangedSubview(self.creatorNameLabel)
        self.channelInfoVStack.addArrangedSubview(self.tagsLabel)
        self.channelInfoVStack.addArrangedSubview(self.freezeState)
        
        self.liveInfoHStack.addArrangedSubview(self.participantCountLabel)
        self.contentView.addSubview(self.translucentView)
        self.contentView.addSubview(self.coverImage)
        self.contentView.addSubview(self.channelInfoVStack)
        self.contentView.addSubview(self.activeIndicator)
        self.contentView.addSubview(self.liveInfoHStack)
    }
    
    /// Handles the initialization of actions.
    override func setupActions() {
        super.setupActions()
    }
    
    /// Handles the initialization of autolayouts.
    override func setupAutolayout() {
        super.setupAutolayout()
        
        self.coverImage
            .sbu_constraint(equalTo: self.contentView,
                            left: leadingPadding,
                            top: 12,
                            bottom: 12)
            .sbu_constraint(width: coverImageWidth,
                            height: coverImageHeight)
        
        self.translucentView
            .sbu_constraint(equalTo: self.coverImage,
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0)
        
        self.channelInfoVStack
            .sbu_constraint(equalTo: self.contentView,
                            right: 16,
                            top: 10)
            .sbu_constraint(height: 72)
            .sbu_constraint_equalTo(leadingAnchor: self.coverImage.trailingAnchor,
                                    leading: leadingPadding)
        
        self.activeIndicator
            .sbu_constraint_equalTo(leadingAnchor: self.coverImage.leadingAnchor,
                                    leading: 4)
            .sbu_constraint(equalTo: self.liveInfoHStack, centerY: 0)
            .sbu_constraint(width: activeIndicatorSize,
                            height: activeIndicatorSize)
        
        self.liveInfoHStack
            .sbu_constraint_equalTo(leadingAnchor: self.activeIndicator.trailingAnchor,
                                    leading: 4)
            .sbu_constraint_equalTo(trailingAnchor: self.coverImage.trailingAnchor,
                                    trailing: -4)
            .sbu_constraint_equalTo(bottomAnchor: self.coverImage.bottomAnchor,
                                    bottom: 4)
            .sbu_constraint(height: 12)
            
        self.creatorProfileImage
            .sbu_constraint(width: iconSize,
                            height: iconSize)
        
        self.channelNameLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        self.tagsLabel.sbu_constraint(height: tagsHeight)
        
        self.participantCountLabel
            .sbu_constraint(height: 22)
    }
    
    // MARK: While cell layout subviews
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    /// Handles the initialization of styles.
    override func setupStyles() {
        super.setupStyles()
        
        self.theme = SBUTheme.channelCellTheme
        
        // When you change `theme.backgroundColor` This might be always `false`
        let isDarkMode = theme.backgroundColor == SBUColorSet.background600
        
        self.backgroundColor = theme.backgroundColor
        self.translucentView.backgroundColor = SBUColorSet.ondark04
        
        self.channelNameLabel.font = theme.titleFont
        self.channelNameLabel.textColor = theme.titleTextColor
        
        self.creatorNameLabel.font = theme.messageFont
        self.creatorNameLabel.textColor = theme.messageTextColor
        
        self.tagsLabel.font = theme.memberCountFont
        self.tagsLabel.textColor = theme.memberCountTextColor
        self.tagsLabel.backgroundColor = isDarkMode
            ? SBUColorSet.background400
            : SBUColorSet.background200
        self.tagsLabel.layer.cornerRadius = self.tagsHeight / 2
        
        self.activeIndicator.backgroundColor = .red
        self.activeIndicator.layer.cornerRadius = self.activeIndicatorSize / 2
        
        self.participantCountLabel.font = theme.memberCountFont
        self.participantCountLabel.textColor = SBUColorSet.ondark01
    }
    
    /// This function configure a cell using channel information.
    override func configure(channel: SBDBaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? SBDOpenChannel else { return }
        guard let streaming = channel.toStreamChannel() else { return }
        
        // Cover image
        self.coverImage.setImage(with: streaming.liveChannelURL, makeCircle: false)
        self.creatorProfileImage.setImage(with: streaming.thumbnailURL)
        
        // Title
        self.channelNameLabel.text = streaming.name
        self.creatorNameLabel.text = streaming.creatorInfo.name
        
        self.tagsLabel.text = streaming.tags.joined(separator: ", ")
        
        self.participantCountLabel.text = "\(channel.participantCount)"
        
        self.creatorProfileImage.isHidden = false
        
        // Channel frozen state. If isFrozen is false, this property will hidden.
        self.freezeState.isHidden = self.channel?.isFrozen == false
    }
}
