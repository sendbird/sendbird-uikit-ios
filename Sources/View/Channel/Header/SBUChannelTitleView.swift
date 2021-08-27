//
//  SBUChannelTitleView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 25/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
class SBUChannelTitleView: UIView {
    // MARK: - Public
    public var channel: SBDBaseChannel?
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    
    // MARK: - Private
    private lazy var contentView = UIView()
    private lazy var coverImage = SBUCoverImageView()
    private lazy var stackView = UIStackView()
    private lazy var titleLabel = UILabel()
    private lazy var statusField = UITextField()
    private lazy var onlineStateIcon = UIView()

    private let kCoverImageSize: CGFloat = 34.0
    
    
    // MARK: - Life cycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUChannelTitleView.init(frame:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func setupViews() {
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(x: 0, y: 0, width: kCoverImageSize, height: kCoverImageSize)
        
        self.titleLabel.textAlignment = .left
        
        self.onlineStateIcon = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 6))
        
        self.statusField.textAlignment = .left
        self.statusField.leftView = self.onlineStateIcon
        self.statusField.leftViewMode = .never
        self.statusField.isUserInteractionEnabled = false
        
        
        self.stackView.alignment = .center
        self.stackView.axis = .vertical
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.statusField)
        
        self.contentView.addSubview(self.coverImage)
        self.contentView.addSubview(self.stackView)
        self.addSubview(self.contentView)
    }
    
    func setupAutolayout() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        let contentHeightConstant = self.contentView.heightAnchor.constraint(
            equalToConstant: self.bounds.height
        )
        contentHeightConstant.priority = .defaultLow
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            self.contentView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
            self.contentView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            contentHeightConstant,
        ])
        
        self.coverImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.coverImage.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 5),
            self.coverImage.widthAnchor.constraint(equalToConstant: kCoverImageSize),
            self.coverImage.heightAnchor.constraint(equalToConstant: kCoverImageSize),
            self.coverImage.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
        ])
        
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.leftAnchor.constraint(
                equalTo: self.coverImage.rightAnchor,
                constant: 8
            ),
            self.stackView.heightAnchor.constraint(
                equalTo: self.coverImage.heightAnchor,
                multiplier: 1.0
            ),
            self.stackView.rightAnchor.constraint(
                equalTo: self.contentView.rightAnchor,
                constant: 5),
            self.stackView.centerYAnchor.constraint(
                equalTo: self.centerYAnchor,
                constant: 0),
        ])
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.statusField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.widthAnchor.constraint(
                equalTo: self.stackView.widthAnchor,
                multiplier: 1.0
            ),
            self.statusField.widthAnchor.constraint(
                equalTo: self.stackView.widthAnchor,
                multiplier: 1.0
            ),
            self.statusField.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
    
    func setupStyles() {
        self.theme = SBUTheme.componentTheme
        
        self.onlineStateIcon.backgroundColor = theme.titleOnlineStateColor
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleColor

        self.statusField.font = theme.titleStatusFont
        self.statusField.textColor = theme.titleStatusColor
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()

        self.onlineStateIcon.layer.cornerRadius = self.onlineStateIcon.frame.width/2
        
        self.coverImage.layer.cornerRadius = kCoverImageSize/2
        self.coverImage.layer.borderColor = UIColor.clear.cgColor
        self.coverImage.layer.borderWidth = 1
        
        self.setupStyles()
    }

    // MARK: - Common
    public func configure(channel: SBDBaseChannel?, title: String?) {
        self.channel = channel
        self.titleLabel.text = ""

        self.loadCoverImage()
        
        guard title == nil else {
            self.titleLabel.text = title
            self.updateChannelStatus(channel: channel)
            return
        }

        if let channelName = channel?.name,
           SBUUtils.isValid(channelName: channelName) {
            self.titleLabel.text = channelName
        } else {
            if let groupChannel = channel as? SBDGroupChannel {
                self.titleLabel.text = SBUUtils.generateChannelName(channel: groupChannel)
            } else if let _ = channel as? SBDOpenChannel {
                self.titleLabel.text = SBUStringSet.Open_Channel_Name_Default
            } else {
                self.titleLabel.text = ""
            }
        }
        
        self.updateChannelStatus(channel: channel)
    }
    
    func loadCoverImage() {
        guard let channel = self.channel else {
            self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 40, height: 40))
            return
        }
        
        if channel is SBDOpenChannel {
            if let coverUrl = channel.coverUrl {
                self.coverImage.setImage(withCoverUrl: coverUrl)
            } else {
                self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 40, height: 40))
            }
        } else if let channel = channel as? SBDGroupChannel {
            if let coverUrl = channel.coverUrl,
               SBUUtils.isValid(coverUrl: coverUrl) {
                self.coverImage.setImage(withCoverUrl: coverUrl)
            } else if channel.isBroadcast == true {
                self.coverImage.setBroadcastIcon()
            } else if let members = channel.members as? [SBDUser] {
                self.coverImage.setImage(withUsers: members)
            } else {
                self.coverImage.setPlaceholderImage(iconSize: CGSize(width: 40, height: 40))
            }
        }
    }
    
    public func updateChannelStatus(channel: SBDBaseChannel?) {
        self.statusField.leftViewMode = .never
        
        if let channel = channel as? SBDGroupChannel {
            if let typingIndicatorString = self.buildTypingIndicatorString(channel: channel) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.statusField.isHidden = false
                    self.statusField.text = typingIndicatorString
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
            } else {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.statusField.isHidden = true
                    self.statusField.text = ""
                    self.updateConstraints()
                    self.layoutIfNeeded()
                }
            }
        } else if let channel = channel as? SBDOpenChannel {
            let count = channel.participantCount
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.statusField.isHidden = false
                self.statusField.text = SBUStringSet.Open_Channel_Participants_Count(count)
                self.updateConstraints()
                self.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Util
    private func buildTypingIndicatorString(channel: SBDGroupChannel) -> String? {
        guard let typingMembers = channel.getTypingUsers(),
            !typingMembers.isEmpty else { return nil }
        return SBUStringSet.Channel_Header_Typing(typingMembers)
    }
    
    override var intrinsicContentSize: CGSize {
        //NOTE: this is under assumption that this view is used in
        //navigation and / or stack view to shrink but keep max width
        return CGSize(width: 100000, height: self.frame.height)
    }
}
