//
//  CommunityChannelCell.swift
//  SendBirdUIKit-Sample
//
//  Created by Jaesung Lee on 2020/11/18.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class CommunityChannelCell: SBUBaseChannelCell {
    
    // MARK: - property
    public private(set) lazy var channelImage = SBUCoverImageView()
    public private(set) lazy var titleHStack: UIStackView = {
        let titleHStack = UIStackView()
        titleHStack.alignment = .center
        titleHStack.spacing = 8.0
        titleHStack.axis = .horizontal
        return titleHStack
    }()
    public private(set) lazy var channelNameLabel = UILabel()
    public private(set) lazy var freezeIcon = UIImageView()
    public private(set) var separatorLine = UIView()
    
    public let channelImageSize: CGFloat = 32
    public let leadingPadding: CGFloat = 16
    public let freezIconSize: CGFloat = 16
    
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    public override func setupViews() {
        super.setupViews()
        
        self.channelImage.clipsToBounds = true
        self.channelImage.frame = CGRect(x: 0,
                                         y: 0,
                                         width: channelImageSize,
                                         height: channelImageSize)
        
        self.freezeIcon.isHidden = true
        self.titleHStack.addArrangedSubview(self.channelNameLabel)
        self.titleHStack.addArrangedSubview(self.freezeIcon)
        
        self.contentView.addSubview(self.channelImage)
        self.contentView.addSubview(self.titleHStack)
        self.contentView.addSubview(self.separatorLine)
    }
    
    /// This function handles the initialization of actions.
    public override func setupActions() {
        super.setupActions()
    }
    
    /// This function handles the initialization of autolayouts.
    public override func setupAutolayout() {
        super.setupAutolayout()
        
        self.channelImage
            .sbu_constraint(equalTo: self.contentView,
                            left: leadingPadding,
                            top: 10,
                            bottom: 10)
            .sbu_constraint(width: channelImageSize,
                            height: channelImageSize)

        self.titleHStack
            .sbu_constraint(equalTo: self.contentView,
                            right: 16,
                            top: 15)
            .sbu_constraint_equalTo(leadingAnchor: self.channelImage.trailingAnchor,
                                    leading: leadingPadding)
        self.separatorLine
            .sbu_constraint(equalTo: self.contentView, trailing: 0, bottom: 0.5)
            .sbu_constraint(height: 0.5)
            .sbu_constraint(equalTo: self.titleHStack, leading: 0)
        
        self.freezeIcon
            .sbu_constraint(width: freezIconSize,
                            height: freezIconSize)
        
        self.channelNameLabel
            .setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    /// This function handles the initialization of styles.
    public override func setupStyles() {
        super.setupStyles()
        
        self.theme = SBUTheme.channelCellTheme
        
        self.backgroundColor = theme.backgroundColor
        
        self.channelNameLabel.font = theme.titleFont
        self.channelNameLabel.textColor = theme.titleTextColor
        
        self.freezeIcon.image = SBUIconSet.iconFreeze.sbu_with(
            tintColor: theme.freezeStateTintColor
        )
        
        self.separatorLine.backgroundColor = theme.separatorLineColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    deinit { }
    
    /// This function configure a cell using channel information.
    /// - Parameter channel: cell object
    public override func configure(channel: SBDBaseChannel) {
        super.configure(channel: channel)
        
        guard let channel = channel as? SBDOpenChannel else { return }
        
        // Cover image
        if let coverURL = channel.coverUrl {
            self.channelImage.setImage(with: coverURL)
        } else {
            self.channelImage.setPlaceholderImage(iconSize: CGSize(width: 40, height: 40))
        }
        self.channelNameLabel.text = channel.name
        self.freezeIcon.isHidden = self.channel?.isFrozen == false
    }
    
    
    // MARK: - Common
    
    
    // MARK: -
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}
