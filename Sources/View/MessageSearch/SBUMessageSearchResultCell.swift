//
//  SBUMessageSearchResultCell.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/02/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
open class SBUMessageSearchResultCell: UITableViewCell {
    
    // MARK: - Properties (View)
    public private(set) lazy var coverImage = SBUCoverImageView()
    public private(set) lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    public private(set) lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        
        return label
    }()
    
    public private(set) lazy var fileMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingMiddle
        
        return label
    }()
    
    public private(set) lazy var fileMessageIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = false
        
        return imageView
    }()
    
    public private(set) lazy var fileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        
        return stackView
    }()
    
    public private(set) lazy var createdAtLabel: UILabel = UILabel()
    public private(set) var separatorLine = UIView()
    
    
    // MARK: - Properties
    
    @SBUThemeWrapper(theme: SBUTheme.messageSearchResultCellTheme)
    public var theme: SBUMessageSearchResultCellTheme

    private let coverImageSize: CGSize = CGSize(value: 56)
    private let fileIconSize: CGSize = CGSize(value: 26)
    private var message: SBDBaseMessage? = nil
    
    // MARK: - View Lifecycle
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupAutolayout()
        self.setupActions()
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(origin: .zero, size: self.coverImageSize)
        self.coverImage.layer.cornerRadius = coverImageSize.height / 2
        
        self.fileMessageIcon.frame = CGRect(origin: .zero, size: fileIconSize)
        self.fileStackView.addArrangedSubview(self.fileMessageIcon)
        self.fileStackView.addArrangedSubview(self.fileMessageLabel)
        
        self.contentView.addSubview(self.coverImage)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.createdAtLabel)
        self.contentView.addSubview(self.messageLabel)
        self.contentView.addSubview(self.fileStackView)
        self.contentView.addSubview(self.separatorLine)
    }
    
    /// This function handles the initialization of actions.
    public func setupActions() {
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.coverImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.coverImage.widthAnchor.constraint(equalToConstant: self.coverImageSize.width),
            self.coverImage.heightAnchor.constraint(equalToConstant: self.coverImageSize.height),
            self.coverImage.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            self.coverImage.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ])
        
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.titleLabel.leadingAnchor.constraint(equalTo: self.coverImage.trailingAnchor, constant: 16),
            self.titleLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 10),
            self.titleLabel.trailingAnchor.constraint(equalTo: self.createdAtLabel.leadingAnchor, constant: -4),
            self.titleLabel.bottomAnchor.constraint(equalTo: self.messageLabel.topAnchor, constant: -2)
        ])
        
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.messageLabel.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.messageLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 2),
            self.messageLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            self.messageLabel.bottomAnchor.constraint(lessThanOrEqualTo: self.contentView.bottomAnchor, constant: -10)
        ])
        
        self.fileMessageIcon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.fileMessageIcon.widthAnchor.constraint(equalToConstant: self.fileIconSize.width),
            self.fileMessageIcon.heightAnchor.constraint(equalToConstant: self.fileIconSize.height)
        ])
        
        self.fileStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.fileStackView.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.fileStackView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 6),
            self.fileStackView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
        ])
        
        
        self.createdAtLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.createdAtLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.titleLabel.trailingAnchor, constant: 4),
            self.createdAtLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 12),
            self.createdAtLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16)
        ])
        
        self.separatorLine.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.separatorLine.leadingAnchor.constraint(equalTo: self.coverImage.trailingAnchor, constant: 16),
            self.separatorLine.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor),
            self.separatorLine.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            self.separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
        
        self.titleLabel.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        self.messageLabel.setContentHuggingPriority(.defaultLow, for: .vertical)
        self.createdAtLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.backgroundColor = theme.backgroundColor
        
        self.titleLabel.font = theme.titleFont
        self.titleLabel.textColor = theme.titleTextColor
        
        self.messageLabel.font = theme.descriptionFont
        self.messageLabel.textColor = theme.descriptionTextColor
        
        self.fileMessageLabel.font = theme.fileMessageFont
        self.fileMessageLabel.textColor = theme.fileMessageTextColor
        
        self.createdAtLabel.font = theme.updatedAtFont
        self.createdAtLabel.textColor = theme.updatedAtTextColor
        
        self.separatorLine.backgroundColor = theme.separatorLineColor
        
        self.setupFileIcon()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        self.setupStyles()
    }
    
    deinit {
        SBULog.info("")
    }
    
    /// This function configure a cell using `SBDBaseMessage` information.
    /// - Parameter channel: `SBDBaseMessage` object
    open func configure(message: SBDBaseMessage) {
        self.message = message
        
        self.selectionStyle = .none
        
        if let profileUrl = self.message?.sender?.profileUrl {
            self.coverImage.setImage(with: profileUrl, makeCircle: true)
        } else {
            self.coverImage.setPlaceholderImage(iconSize: SBUIconSetType.Metric.defaultIconSizeLarge)
        }
        
        if let sender = message.sender {
            let username: String = SBUUser(user: sender).refinedNickname()
            self.titleLabel.text = username
        } else {
            self.titleLabel.text = SBUStringSet.User_No_Name
        }
        
        self.messageLabel.isHidden = true
        self.fileStackView.isHidden = true
        
        switch message {
        case let fileMessage as SBDFileMessage:
            self.fileStackView.isHidden = false
            
            self.fileMessageLabel.text = fileMessage.name
            
            let iconType: SBUIconSetType
            switch SBUUtils.getFileType(by: fileMessage) {
            case .image:
                if fileMessage.type.hasPrefix("image/gif") {
                    iconType = SBUIconSetType.iconGif
                } else {
                    iconType = SBUIconSetType.iconPhoto
                }
            case .video:
                iconType = SBUIconSetType.iconPlay
            case .audio:
                iconType = SBUIconSetType.iconFileAudio
            case .pdf:
                iconType = SBUIconSetType.iconPhoto
            case .etc:
                iconType = SBUIconSetType.iconFileDocument
            }
            
            self.fileMessageIcon.image = iconType.image(
                with: self.theme.fileMessageIconTintColor,
                to: SBUIconSetType.Metric.defaultIconSizeMedium
            )
            self.fileMessageIcon.backgroundColor = self.theme.fileMessageIconBackgroundColor
        default:
            self.messageLabel.isHidden = false
            self.messageLabel.text = message.message
        }
        
        let createdAt = Date.lastUpdatedTime(baseTimestamp: message.createdAt)
        self.createdAtLabel.text = createdAt ??
            Date.sbu_from(message.createdAt).sbu_toString(format: .hhmma)
    }
    
    /// Sets file message icon depending on the message's file type using `SBUUtils.getFileType(by: fileMessage)`.
    public func setupFileIcon() {
        guard let fileMessage = self.message as? SBDFileMessage else { return }
        let iconType: SBUIconSetType
        
        switch SBUUtils.getFileType(by: fileMessage) {
        case .image:
            if fileMessage.type.hasPrefix("image/gif") {
                iconType = SBUIconSetType.iconGif
            } else {
                iconType = SBUIconSetType.iconPhoto
            }
        case .video:
            iconType = SBUIconSetType.iconPlay
        case .audio:
            iconType = SBUIconSetType.iconFileAudio
        case .pdf:
            iconType = SBUIconSetType.iconPhoto
        case .etc:
            iconType = SBUIconSetType.iconFileDocument
        }
        
        self.fileMessageIcon.image = iconType.image(
            with: self.theme.fileMessageIconTintColor,
            to: SBUIconSetType.Metric.defaultIconSizeMedium
        )
        self.fileMessageIcon.backgroundColor = self.theme.fileMessageIconBackgroundColor
    }
}
