//
//  SBUChannelInfoHeaderView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/10/29.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// This delegate is used in the class to handle the action.
public protocol SBUChannelInfoHeaderViewDelegate: AnyObject {
    func didSelectChannelInfo()
    func didSelectChannelMembers()
    func didSelectChannelParticipants()
}

extension SBUChannelInfoHeaderViewDelegate {
    public func didSelectChannelInfo() { }
    public func didSelectChannelMembers() { }
    public func didSelectChannelParticipants() { }
}

/// A view contains a channel information such as cover image, channel name and info button.
open class SBUChannelInfoHeaderView: SBUView {
    // MARK: - Public
    
    /// The channel cover image view.
    public lazy var coverImage = SBUCoverImageView()
    
    /// The label represents the channel's name
    public lazy var titleLabel = UILabel()
    
    /// The label that shows a description for the channel
    /// - NOTE: To update value with *open* channel description, please set `SBUOpenChannelViewController.channelDescription`
    public lazy var descriptionLabel = UILabel()
    
    /// The button that shows channel information.
    public lazy var infoButton: UIButton? = UIButton()
    
    /// The channel object.
    public private(set) var channel: BaseChannel?
    
    weak var delegate: SBUChannelInfoHeaderViewDelegate?
    
    var isOverlay = false
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    var theme: SBUComponentTheme
    
    /// The object that is used as theme in overlay mode. The theme is type of `SBUComponentTheme`.
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.componentTheme, setToDefault: true)
    public var overlayTheme: SBUComponentTheme
    
    // MARK: - Private
    private lazy var stackView = UIStackView()
    private lazy var lineView = UIView()
    
    private let coverImageSize: CGFloat = 34.0
    private let infoButtonSize: CGFloat = 24.0
    
    // MARK: - Life cycle
    
    /// Initializes `SBUChannelInfoHeaderView` with the `delegate`.
    /// - Parameter delegate: The object that acts as the delegate of the channel info header view. The delegate must adopt the `SBUChannelInfoHeaderViewDelegate` protocol.
    public init(delegate: SBUChannelInfoHeaderViewDelegate?) {
        self.delegate = delegate

        super.init(frame: .zero)
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable, renamed: "SBUChannelInfoHeaderView()")
    required public init?(coder: NSCoder) {
        fatalError()
    }

    open override func setupViews() {
        super.setupViews()
        
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
    
    open override func setupLayouts() {
        super.setupLayouts()
        
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
    
    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleColor

        self.descriptionLabel.font = theme.titleStatusFont
        self.descriptionLabel.textColor = theme.titleStatusColor
        
        self.lineView.backgroundColor = theme.separatorColor
        
        self.backgroundColor = theme.backgroundColor
        
        self.setupInfoButtonStyle()
    }
    
    public func setupInfoButtonStyle() {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        if let channel = self.channel as? OpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return }
            let isOperator = channel.isOperator(userId: userId)
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
        } else if let channel = self.channel as? GroupChannel {
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
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        self.coverImage.layer.cornerRadius = coverImageSize/2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
    }

    // MARK: - Common
    open func configure(channel: BaseChannel?, description: String?) {
        self.channel = channel
        guard let channel = self.channel else { return }
        
        self.loadCoverImage()
        
        if SBUUtils.isValid(channelName: channel.name) {
            self.titleLabel.text = channel.name
        } else {
            if let groupChannel = channel as? GroupChannel {
                self.titleLabel.text = SBUUtils.generateChannelName(channel: groupChannel)
            } else {
                self.titleLabel.text = SBUStringSet.Open_Channel_Name_Default
            }
        }

        self.descriptionLabel.text = description
        self.descriptionLabel.isHidden = description == nil
        
        self.setupInfoButtonStyle()
        if let channel = self.channel as? OpenChannel {
            guard let userId = SBUGlobals.currentUser?.userId else { return }
            let isOperator = channel.isOperator(userId: userId)
            self.infoButton?.addTarget(
                self,
                action: isOperator
                    ? #selector(onClickChannelInfo)
                    : #selector(onClickChannelParticipants),
                for: .touchUpInside
            )
        } else if let channel = self.channel as? GroupChannel {
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
    
    public func loadCoverImage() {
        guard let channel = self.channel else { return }
        
        if let url = channel.coverURL {
            self.coverImage.setImage(withCoverURL: url)
        } else if let groupChannel = channel as? GroupChannel {
            if groupChannel.isBroadcast {
                self.coverImage.setBroadcastIcon()
            } else {
                if !groupChannel.members.isEmpty {
                    self.coverImage.setImage(withUsers: groupChannel.members)
                } else {
                    self.coverImage.setPlaceholder(
                        type: .iconUser,
                        iconSize: .init(width: coverImageSize, height: coverImageSize)
                    )
                }
            }
        } else {
            self.coverImage.setPlaceholder(
                type: .iconUser,
                iconSize: .init(width: coverImageSize, height: coverImageSize)
            )
        }
    }
    
    // MARK: - Action
    @objc
    public func onClickChannelInfo() {
        self.delegate?.didSelectChannelInfo()
    }
    
    @objc
    public func onClickChannelMembers() {
        self.delegate?.didSelectChannelMembers()
    }
    
    @objc
    public func onClickChannelParticipants() {
        self.delegate?.didSelectChannelParticipants()
    }
}
