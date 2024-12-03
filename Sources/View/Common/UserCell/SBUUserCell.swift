//
//  SBUUserCell.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

#if SWIFTUI
protocol SBUUserCellProtocol {
    func configureEntireContentForSwiftUI()
    func configureForSwiftUI()
    func selectUserForSwiftUI(_ selected: Bool)
}
extension SBUUserCellProtocol {
    func configureEntireContentForSwiftUI() {}
    func configureForSwiftUI() {}
    func selectUserForSwiftUI(_ selected: Bool) {}
}
#else
protocol SBUUserCellProtocol {}
#endif

open class SBUUserCell: SBUTableViewCell, SBUUserCellProtocol {
    
    // MARK: - UI properties (Public)
    public lazy var baseStackView: UIStackView = {
        let stackView = SBUStackView(
            axis: .horizontal,
            alignment: .fill,
            spacing: 16.0
        )
        stackView.distribution = .fill
        return stackView
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
        return imageView
    }()
    
    @available(*, deprecated, renamed: "nicknameLabel") // 3.0.0
    public var userNickname: UILabel {
        get { self.nicknameLabel }
        set { self.nicknameLabel = newValue }
    }
    
    public lazy var nicknameLabel = UILabel()
    
    public lazy var userIdLabel = UILabel()
    
    public lazy var operatorLabel: UILabel = {
        let label = UILabel()
         label.isHidden = true
         label.textAlignment = .right
         return label
     }()
    
    public lazy var checkboxButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    public lazy var moreButton: UIButton = {
        let button = UIButton()
        button.isHidden = true
        button.addTarget(self, action: #selector(onClickMoreMenu), for: .touchUpInside)
        return button
    }()
    
    public var separateView = UIView()

    @SBUThemeWrapper(theme: SBUTheme.userCellTheme)
    public var theme: SBUUserCellTheme
    
    // MARK: - Properties (Private)
    private var loadImageSession: URLSessionTask? {
        willSet {
            loadImageSession?.cancel()
        }
    }
    
    // MARK: - Logic properties (Public)
    public private(set) var type: UserListType = .none
    
    // MARK: - Logic properties (Private)
    var user: SBUUser?
    var isChecked: Bool = false
    var hasNickname: Bool = true
    var operatorMode: Bool = false
    
    var channelType: ChannelType = .group
    
    var userProfileTapHandler: (() -> Void)?
    var moreMenuHandler: (() -> Void)?
    
    #if SWIFTUI
    var cellTapHandler: (() -> Void)?
    #endif
    
    internal private(set) var userImageSize: CGFloat = 40
    
    // MARK: - View Lifecycle
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// This function handles the initialization of views.
    open override func setupViews() {
        self.operatorLabel.text = SBUStringSet.User_Operator
        self.userIdLabel.isHidden = true
        self.userImageView.addSubview(self.mutedStateImageView)
        
        self.baseStackView.setHStack([
            self.userImageView,
            self.nicknameLabel,
            self.userIdLabel,
            self.operatorLabel,
            self.moreButton,
            self.checkboxButton,
        ])
        
        if case .suggestedMention = self.type {
            self.baseStackView.setCustomSpacing(6.0, after: self.userIdLabel)
        }
        self.baseStackView.setCustomSpacing(8.0, after: self.operatorLabel)
        
        self.operatorLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        self.contentView.addSubview(self.baseStackView)
        self.contentView.addSubview(self.separateView)
    }
    
    /// This function handles the initialization of actions.
    open override func setupActions() {
        self.userImageView.addGestureRecognizer(UITapGestureRecognizer(
            target: self,
            action: #selector(self.onTapUserProfileView(sender:)))
        )
    }
    
    /// This function handles the initialization of autolayouts.
    open override func setupLayouts() {
        self.baseStackView
            .sbu_constraint(
                equalTo: self.contentView,
                leading: 16,
                trailing: -16,
                top: 8,
                bottom: 8
            )
            .sbu_constraint(height: userImageSize)

        self.userImageView
            .sbu_constraint(width: userImageSize, height: userImageSize)
        
        self.nicknameLabel
            .setContentHuggingPriority(.required, for: .horizontal)
        
        if !self.userIdLabel.isHidden {
            self.userIdLabel
                .sbu_constraint(width: 32, priority: .defaultLow)
                .sbu_constraint_greaterThan(width: 32, priority: .defaultLow)
        }
        
        self.mutedStateImageView
            .sbu_constraint(width: userImageSize, height: userImageSize)
            .sbu_constraint(equalTo: self.userImageView, leading: 0, top: 0)
        
        self.moreButton
            .sbu_constraint(width: 24)
        
        self.checkboxButton
            .sbu_constraint(width: 24)
        
        self.separateView
            .sbu_constraint(equalTo: self.nicknameLabel, leading: 0)
            .sbu_constraint(
                equalTo: self.contentView,
                trailing: -0.5,
                bottom: 0.5
            )
            .sbu_constraint(height: 0.5)
    }
    
    open override func updateLayouts() {
        super.updateLayouts()
        
        self.setupLayouts()
    }
    
    /// This function handles the initialization of styles.
    open override func setupStyles() {
        self.backgroundColor = theme.backgroundColor

        self.userImageView.layer.cornerRadius = userImageSize/2
        self.userImageView.backgroundColor = theme.userPlaceholderBackgroundColor
        
        self.mutedStateImageView.image = SBUIconSetType.iconMute.image(
            with: self.theme.mutedStateIconColor,
            to: SBUIconSetType.Metric.defaultIconSize
        )
        self.mutedStateImageView.layer.cornerRadius = userImageSize/2
        self.mutedStateImageView.backgroundColor = self.theme.mutedStateBackgroundColor
        
        if case .suggestedMention = self.type, hasNickname == false {
            self.nicknameLabel.textColor = theme.nonameTextColor
        } else {
            self.nicknameLabel.textColor = theme.nicknameTextColor
        }
        self.nicknameLabel.font = theme.nicknameTextFont
        
        self.userIdLabel.textColor = theme.userIdTextColor
        self.userIdLabel.font = theme.userIdTextFont
        
        self.operatorLabel.font = theme.subInfoFont
        self.operatorLabel.textColor = theme.subInfoTextColor
        
        self.separateView.backgroundColor = theme.separateColor
        
        self.checkboxButton.setImage(
            SBUIconSetType.iconCheckboxUnchecked.image(
                with: theme.checkboxOffColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
        self.checkboxButton.setImage(
            SBUIconSetType.iconCheckboxChecked.image(
                with: theme.checkboxOnColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .selected
        )
        
        self.moreButton.setImage(
            SBUIconSetType.iconMore.image(
                with: theme.moreButtonColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .normal
        )
        self.moreButton.setImage(
            SBUIconSetType.iconMore.image(
                with: theme.moreButtonDisabledColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            for: .disabled
        )
        
        if self.type == .reaction {
            self.backgroundColor = .clear
        } else {
            self.backgroundColor = theme.backgroundColor
        }
    }
    
    // MARK: - Common
    open func configure(
        type: UserListType,
        user: SBUUser,
        isChecked: Bool = false,
        operatorMode: Bool = false,
        channelType: ChannelType = .group
    ) {
        self.user = user
        self.type = type
        self.isChecked = isChecked
        self.operatorMode = operatorMode
        
        self.channelType = channelType
        
        let isMe = (user.userId == SBUGlobals.currentUser?.userId)
        self.userIdLabel.text = user.userId
        self.nicknameLabel.text = user.refinedNickname()
            + (isMe ? " \(SBUStringSet.UserList_Me)" : "")
        self.hasNickname = user.nickname != nil && user.nickname?.isEmpty == false
        
        #if SWIFTUI
        if self.configureEntireContentForSwiftUI() {
            return
        }
        #endif
        
        let profileURL = user.profileURL ?? ""
        self.loadImageSession = self.userImageView.loadImage(
            urlString: profileURL,
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: SBUIconSetType.Metric.defaultIconSize
            ),
            subPath: SBUCacheManager.PathType.userProfile
        )
        self.userImageView.contentMode = profileURL.count > 0 ? .scaleAspectFill : .center
        
        self.userImageView.backgroundColor = theme.userPlaceholderBackgroundColor
        
        self.mutedStateImageView.isHidden = (type != .muted) ? !user.isMuted : false
        self.operatorLabel.isHidden = type == .operators || !user.isOperator

        self.separateView.isHidden = false
        self.checkboxButton.isHidden = true
        self.moreButton.isHidden = true
        self.moreButton.isEnabled = true
        
        switch type {
        case .createChannel, .invite:
            self.checkboxButton.isHidden = false
            self.checkboxButton.isSelected = self.isChecked
            
        case .members, .participants:
            if operatorMode {
                self.moreButton.isHidden = false
                self.moreButton.isEnabled = !isMe
            }

        case .reaction:
            let profileImageURL = user.profileURL ?? ""
            self.userImageView.loadImage(
                urlString: profileImageURL,
                placeholder: SBUIconSetType.iconUser.image(
                    with: self.theme.userPlaceholderTintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                subPath: SBUCacheManager.PathType.userProfile
            )
        
            self.separateView.isHidden = true
           
        case .operators:
            self.moreButton.isHidden = false
            self.moreButton.isEnabled = !isMe
            
        case .muted, .banned:
            self.moreButton.isHidden = false
            self.moreButton.isEnabled = !isMe

        case .suggestedMention(let showsUserId):
            self.userIdLabel.isHidden = !showsUserId
            self.userImageSize = 28
            self.updateLayouts()
        default:
            break
        }
        
        #if SWIFTUI
        self.configureForSwiftUI()
        #endif
    }
    
    /// This function selects or deselects user.
    /// - Parameter selected: `Bool` object
    public func selectUser(_ selected: Bool) {
        self.isChecked = selected
        self.checkboxButton.isSelected = selected
        #if SWIFTUI
        self.selectUserForSwiftUI(selected)
        #endif
    }
    
    // MARK: - Action
    
    /// This function is used when more menu tap
    @objc
    open func onClickMoreMenu() {
        self.moreMenuHandler?()
    }
    
    /// This function is used when a user profile tap.
    /// - Parameter sender: sender
    @objc
    open func onTapUserProfileView(sender: UITapGestureRecognizer) {
        self.userProfileTapHandler?()
    }

    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
    }
}

#if SWIFTUI
extension SBUUserCell {
    @objc
    public func onTapContentView(sender: UITapGestureRecognizer) {
        self.isChecked = !self.isChecked
        self.cellTapHandler?()
    }
    
    @objc
    public func onTapCheckBox(sender: UITapGestureRecognizer) {
        self.isChecked = !self.isChecked
    }
    
    @objc
    public func onTapUserProfileView() {
        self.userProfileTapHandler?()
    }
}

extension SBUUserCell {
    func configureEntireContentForSwiftUI() -> Bool {
        switch type {
        case .none:
            break
        case .createChannel:
            return self.applyViewConverter(.entireContent)
        case .members:
            return self.applyViewConverterForMembers(.entireContent)
        case .invite:
            return self.applyViewConverterForInvite(.entireContent)
        case .reaction:
            break
        case .operators:
            if channelType == .open {
                return self.applyViewConverterForOpenOperators(.entireContent)
            } else {
                return self.applyViewConverterForOperators(.entireContent)
            }
        case .muted:
            if channelType == .open {
                return self.applyViewConverterForOpenMutedParticipant(.entireContent)
            } else {
                return self.applyViewConverterForMutedMember(.entireContent)
            }
        case .banned:
            if channelType == .open {
                return self.applyViewConverterForOpenBannedUser(.entireContent)
            } else {
                return self.applyViewConverterForBannedUser(.entireContent)
            }
        case .participants:
            return self.applyViewConverterForParticipants(.entireContent)
        case .suggestedMention(_):
            break
        }
        return false
    }
    
    func configureForSwiftUI() {
        switch type {
        case .none:
            break
        case .createChannel:
            self.applyViewConverter(.profileImage)
            self.applyViewConverter(.userNameLabel)
            self.applyViewConverter(.selectionButton)
        case .members:
            self.applyViewConverterForMembers(.profileImage)
            self.applyViewConverterForMembers(.userNameLabel)
            self.applyViewConverterForMembers(.operatorStateView)
            self.applyViewConverterForMembers(.moreButton)
        case .invite:
            self.applyViewConverterForInvite(.profileImage)
            self.applyViewConverterForInvite(.userNameLabel)
            self.applyViewConverterForInvite(.selectionButton)
        case .reaction:
            break
        case .operators:
            if channelType == .open {
                self.applyViewConverterForOpenOperators(.profileImage)
                self.applyViewConverterForOpenOperators(.userNameLabel)
                self.applyViewConverterForOpenOperators(.moreButton)
            } else {
                self.applyViewConverterForOperators(.profileImage)
                self.applyViewConverterForOperators(.userNameLabel)
                self.applyViewConverterForOperators(.moreButton)
            }
        case .muted:
            if channelType == .open {
                self.applyViewConverterForOpenMutedParticipant(.profileImage)
                self.applyViewConverterForOpenMutedParticipant(.userNameLabel)
                self.applyViewConverterForOpenMutedParticipant(.operatorStateView)
                self.applyViewConverterForOpenMutedParticipant(.moreButton)
            } else {
                self.applyViewConverterForMutedMember(.profileImage)
                self.applyViewConverterForMutedMember(.userNameLabel)
                self.applyViewConverterForMutedMember(.operatorStateView)
                self.applyViewConverterForMutedMember(.moreButton)
            }
        case .banned:
            if channelType == .open {
                self.applyViewConverterForOpenBannedUser(.profileImage)
                self.applyViewConverterForOpenBannedUser(.userNameLabel)
                self.applyViewConverterForOpenBannedUser(.moreButton)
            } else {
                self.applyViewConverterForBannedUser(.profileImage)
                self.applyViewConverterForBannedUser(.userNameLabel)
                self.applyViewConverterForBannedUser(.moreButton)
            }
        case .participants:
            self.applyViewConverterForParticipants(.profileImage)
            self.applyViewConverterForParticipants(.userNameLabel)
            self.applyViewConverterForParticipants(.operatorStateView)
            self.applyViewConverterForParticipants(.moreButton)
        case .suggestedMention(_):
            break
        }
    }
    
    func selectUserForSwiftUI(_ selected: Bool) {
        switch type {
        case .none:
            break
        case .createChannel:
            self.applyViewConverter(.entireContent)
            self.applyViewConverter(.selectionButton)
        case .members:
            break
        case .invite:
            self.applyViewConverterForInvite(.entireContent)
            self.applyViewConverterForInvite(.selectionButton)
        case .reaction:
            break
        case .operators:
            break
        case .muted:
            break
        case .banned:
            break
        case .participants:
            break
        case .suggestedMention(_):
            break
        }
    }
}

#endif
