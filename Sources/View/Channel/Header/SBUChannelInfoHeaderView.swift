//
//  SBUChannelInfoHeaderView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/10/29.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

/// This delegate is used in the class to handle the action.
@objc public protocol SBUChannelInfoHeaderViewDelegate {
    @objc optional func didSelectChannelInfo()
    @objc optional func didSelectChannelMembers()
    @objc optional func didSelectChannelParticipants()
}


@objcMembers
public class SBUChannelInfoHeaderView: UIView {
    // MARK: - Public
    public lazy var coverImage = SBUCoverImageView()
    public lazy var titleLabel = UILabel()
    /// - Note: To update value with *open* channel description, please set `SBUOpenChannelViewController.channelDescription`
    public lazy var descriptionLabel = UILabel()
    public lazy var infoButton: UIButton? = UIButton()
    
    public private(set) var channel: SBDBaseChannel?
    
    weak var delegate: SBUChannelInfoHeaderViewDelegate? = nil
    
    var isOverlay = false
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    // MARK: - Private
    private lazy var stackView = UIStackView()
    private lazy var lineView = UIView()
    
    private let coverImageSize: CGFloat = 34.0
    private let infoButtonSize: CGFloat = 24.0
    
    
    // MARK: - Life cycle
    init(delegate: SBUChannelInfoHeaderViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }

    @available(*, unavailable, renamed: "SBUChannelInfoHeaderView()")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.coverImage.clipsToBounds = true
        
        self.titleLabel.textAlignment = .left
        self.titleLabel.isUserInteractionEnabled = false
        
        self.descriptionLabel.textAlignment = .left
        self.descriptionLabel.isUserInteractionEnabled = false
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.descriptionLabel)
        
        self.addSubview(self.coverImage)
        self.addSubview(self.stackView)
        if let infoButton = self.infoButton {
            self.addSubview(infoButton)
        }
        self.addSubview(self.lineView)
    }
    
    func setupAutolayout() {
        self.coverImage.sbu_constraint(equalTo: self, leading: 12)
        self.coverImage.sbu_constraint(width: coverImageSize, height: coverImageSize)
        self.coverImage.sbu_constraint(equalTo: self, centerY: 0)
        
        self.stackView.sbu_constraint_equalTo(
            leadingAnchor: self.coverImage.trailingAnchor, leading: 8
        )
        self.stackView.sbu_constraint(height: coverImageSize)
        self.stackView.sbu_constraint(equalTo: self, centerY: 0)
        
        self.titleLabel.sbu_constraint(equalTo: self.stackView, leading: 0, trailing: 0)
        self.titleLabel.setContentCompressionResistancePriority(
            UILayoutPriority(rawValue: 751),
            for: .vertical
        )
        
        self.descriptionLabel.sbu_constraint(equalTo: self.stackView, leading: 0, trailing: 0)
        
        self.infoButton?.sbu_constraint(equalTo: self, trailing: -16)
        self.infoButton?.sbu_constraint_greater(leadingAnchor: self.stackView.trailingAnchor, leading: 16)
        self.infoButton?.sbu_constraint(equalTo: self, centerY: 0)
        self.infoButton?.sbu_constraint(height: infoButtonSize)
        
        self.lineView.sbu_constraint(equalTo: self, leading: 0, trailing: 0, bottom: 0.5)
        self.lineView.sbu_constraint(height: 0.5)
    }
    
    func setupStyles() {
        self.theme = self.isOverlay ? SBUTheme.overlayTheme.componentTheme : SBUTheme.componentTheme
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleColor

        self.descriptionLabel.font = theme.titleStatusFont
        self.descriptionLabel.textColor = theme.titleStatusColor
        
        self.lineView.backgroundColor = theme.separatorColor
        
        self.backgroundColor = theme.backgroundColor
        
        self.setupInfoButtonStyle()
    }
    
    func setupInfoButtonStyle() {
        if let channel = self.channel as? SBDOpenChannel {
            guard let userId = SBUGlobals.CurrentUser?.userId else { return }
            let isOperator = channel.isOperator(withUserId: userId)
            let iconImage = isOperator
                ? SBUIconSetType.iconInfo.image(
                    with: theme.barItemTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
                : SBUIconSetType.iconMembers.image(
                    with: theme.barItemTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            
            self.infoButton?.setImage(iconImage, for: .normal)
        } else if let channel = self.channel as? SBDGroupChannel {
            let isOperator = channel.myRole == .operator
            let iconImage = isOperator
                ? SBUIconSetType.iconInfo.image(
                    with: theme.barItemTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
                : SBUIconSetType.iconMembers.image(
                    with: theme.barItemTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            
            self.infoButton?.setImage(iconImage, for: .normal)
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        self.coverImage.layer.cornerRadius = coverImageSize/2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
        
        self.setupStyles()
    }

    // MARK: - Common
    public func configure(channel: SBDBaseChannel?, description: String?) {
        self.channel = channel
        guard let channel = self.channel else { return }
        
        self.loadCoverImage()
        
        if SBUUtils.isValid(channelName: channel.name) {
            self.titleLabel.text = channel.name
        } else {
            if let groupChannel = channel as? SBDGroupChannel {
                self.titleLabel.text = SBUUtils.generateChannelName(channel: groupChannel)
            } else {
                self.titleLabel.text = SBUStringSet.Open_Channel_Name_Default
            }
        }

        self.descriptionLabel.text = description
        self.descriptionLabel.isHidden = description == nil
        
        self.setupInfoButtonStyle()
        if let channel = self.channel as? SBDOpenChannel {
            guard let userId = SBUGlobals.CurrentUser?.userId else { return }
            let isOperator = channel.isOperator(withUserId: userId)
            self.infoButton?.addTarget(
                self,
                action: isOperator
                    ? #selector(onClickChannelInfo)
                    : #selector(onClickChannelParticipants),
                for: .touchUpInside
            )
        } else if let channel = self.channel as? SBDGroupChannel {
            let isOperator = channel.myRole == .operator
            self.infoButton?.addTarget(
                self,
                action: isOperator
                    ? #selector(onClickChannelInfo)
                    : #selector(onClickChannelMembers),
                for: .touchUpInside
            )
        }
    }
    
    func loadCoverImage() {
        guard let channel = self.channel else { return }
        
        if let url = channel.coverUrl {
            self.coverImage.setImage(withCoverUrl: url)
        } else if let groupChannel = channel as? SBDGroupChannel {
            if groupChannel.isBroadcast {
                self.coverImage.setBroadcastIcon()
            } else {
                if let members = groupChannel.members as? [SBDUser] {
                    self.coverImage.setImage(withUsers: members)
                } else {
                    self.coverImage.setPlaceholderImage(
                        iconSize: .init(width: coverImageSize,height: coverImageSize)
                    )
                }
            }
        } else {
            self.coverImage.setPlaceholderImage(
                iconSize: .init(width: coverImageSize, height: coverImageSize)
            )
        }
    }
    
    
    // MARK: - Action
    public func onClickChannelInfo() {
        self.delegate?.didSelectChannelInfo?()
    }
    
    public func onClickChannelMembers() {
        self.delegate?.didSelectChannelMembers?()
    }
    
    public func onClickChannelParticipants() {
        self.delegate?.didSelectChannelParticipants?()
    }
}
