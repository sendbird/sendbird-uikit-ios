//
//  SBUUserCell.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

open class SBUUserCell: UITableViewCell {
    
    // MARK: - UI properties (Public)
    public lazy var baseStackView: UIStackView = {
        let baseStackView = UIStackView()
        baseStackView.spacing = 16.0
        baseStackView.axis = .horizontal
        return baseStackView
    }()
    
    public lazy var userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public lazy var mutedStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        imageView.contentMode = .center
        
        let image = SBUIconSetType.iconMute.image(
            with: self.theme.mutedStateIconColor,
            to: SBUIconSetType.Metric.defaultIconSize
        ).resize(
            with: .init(width: 24, height: 24)
        )
        
        imageView.image = image
        return imageView
    }()
    
    public var userNameLabel = UILabel()
    
    public lazy var operatorLabel: UILabel = {
        let label = UILabel()
         label.isHidden = true
         label.textAlignment = .right
         return label
     }()
    
    public lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.setImage(
            SBUIconSetType.iconCheckboxUnchecked.image(
                with: self.theme.checkboxOffColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
        button.setImage(
            SBUIconSetType.iconCheckboxChecked.image(
                with: self.theme.checkboxOnColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .selected
        )
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    public lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(
            SBUIconSetType.iconMore.image(
                with: self.theme.moreButtonColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
        button.setImage(
            SBUIconSetType.iconMore.image(
                with: self.theme.moreButtonDisabledColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .disabled
        )
        button.isHidden = true
        button.addTarget(self, action: #selector(onClickMoreMenu), for: .touchUpInside)
        return button
    }()
    
    public var separateView = UIView()

    public var theme: SBUUserCellTheme = SBUTheme.userCellTheme
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    
    // MARK: - Logic properties (Public)
    public private(set) var type: UserListType = .none
    
    
    // MARK: - Logic properties (Private)
    var isChecked: Bool = false
    
    var userProfileTapHandler: (() -> Void)? = nil
    var moreMenuHandler: (() -> Void)? = nil
    
    let kUserImageSize: CGFloat = 40
  
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
    
    /// This function handles the initialization of views.
    open func setupViews() {
        self.operatorLabel.text = SBUStringSet.User_Operator
        
        self.userImageView.addSubview(self.mutedStateImageView)
        
        self.baseStackView.addArrangedSubview(self.userImageView)
        self.baseStackView.addArrangedSubview(self.userNameLabel)
        self.baseStackView.addArrangedSubview(self.operatorLabel)
        if #available(iOS 11.0, *) {
            self.baseStackView.setCustomSpacing(8.0, after: self.operatorLabel)
        }
        self.baseStackView.addArrangedSubview(self.moreButton)
        self.baseStackView.addArrangedSubview(self.checkboxButton)
        
        self.contentView.addSubview(self.baseStackView)
        self.contentView.addSubview(self.separateView)
    }
    
    /// This function handles the initialization of actions.
    func setupActions() {
        self.userImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )
    }
    
    /// This function handles the initialization of autolayouts.
    open func setupAutolayout() {
        self.baseStackView
            .sbu_constraint(equalTo: self.contentView,
                            leading: 16,
                            trailing: -16,
                            top:8,
                            bottom: 8)
            .sbu_constraint(height: kUserImageSize)

        self.userImageView.sbu_constraint(width: kUserImageSize, height: kUserImageSize)
        self.mutedStateImageView
            .sbu_constraint(width: kUserImageSize, height: kUserImageSize)
            .sbu_constraint(equalTo: self.userImageView, leading: 0, top: 0)
        self.moreButton.sbu_constraint(width: 24)
        self.checkboxButton.sbu_constraint(width: 24)
        
        self.separateView
            .sbu_constraint(equalTo: self.contentView,
                            leading: 68,
                            trailing: -0.5,
                            bottom: 0.5)
            .sbu_constraint(height: 0.5)
    }
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
        self.theme = SBUTheme.userCellTheme
        
        self.backgroundColor = theme.backgroundColor

        self.userImageView.layer.cornerRadius = kUserImageSize/2
        self.userImageView.backgroundColor = theme.userPlaceholderBackgroundColor
        
        self.mutedStateImageView.layer.cornerRadius = kUserImageSize/2
        self.mutedStateImageView.backgroundColor = self.theme.mutedStateBackgroundColor
        
        self.userNameLabel.textColor = theme.userNameTextColor
        self.userNameLabel.font = theme.userNameFont
        
        self.operatorLabel.font = theme.subInfoFont
        self.operatorLabel.textColor = theme.subInfoTextColor
        
        self.separateView.backgroundColor = theme.separateColor
        
        if self.type == .reaction {
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = theme.backgroundColor
        }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }

    
    // MARK: - Common
    public func configure(type: UserListType,
                          user: SBUUser,
                          isChecked: Bool = false,
                          operatorMode: Bool = false) {
        self.type = type
        self.isChecked = isChecked
        
        let isMe = (user.userId == SBUGlobals.CurrentUser?.userId)
        self.userNameLabel.text = user.refinedNickname()
            + (isMe ? " \(SBUStringSet.MemberList_Me)" : "")
        
        self.loadImageSession = self.userImageView.loadImage(
            urlString: user.profileUrl ?? "",
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
        )
        
        self.userImageView.backgroundColor = theme.userPlaceholderBackgroundColor
        self.userImageView.contentMode = .scaleAspectFill
        
        self.mutedStateImageView.isHidden = !user.isMuted
        self.operatorLabel.isHidden = type == .operators || !user.isOperator

        self.separateView.isHidden = false
        self.checkboxButton.isHidden = true
        self.moreButton.isHidden = true
        self.moreButton.isEnabled = true
        
        switch type {
        case .createChannel, .inviteUser:
            self.checkboxButton.isHidden = false
            self.checkboxButton.isSelected = self.isChecked
            
        case .channelMembers:
            if operatorMode {
                self.moreButton.isHidden = false
                self.moreButton.isEnabled = !isMe
            }

        case .reaction:
            let profileImageUrl = user.profileUrl ?? ""
            self.userImageView.loadImage(
                urlString: profileImageUrl,
                placeholder: SBUIconSetType.iconUser.image(
                    with: self.theme.userPlaceholderTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                )
            )
        
            self.separateView.isHidden = true
           
        case .operators:
            self.moreButton.isHidden = false
            self.moreButton.isEnabled = !isMe
            
        case .mutedMembers, .bannedMembers:
            self.moreButton.isHidden = false
            self.moreButton.isEnabled = !isMe

        default:
            break
        }
    }
    
    /// This function selects or deselects user.
    /// - Parameter selected: `Bool` object
    public func selectUser(_ selected: Bool) {
        self.isChecked = selected
        self.checkboxButton.isSelected = selected
    }
    
    
    // MARK: - Action
    
    /// This function is used when more menu tap
    @objc open func onClickMoreMenu() {
        self.moreMenuHandler?()
    }
    
    /// This function is used when a user profile tap.
    /// - Parameter sender: sender
    @objc open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}
