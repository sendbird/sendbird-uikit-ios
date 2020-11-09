//
//  SBUUserProfileView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/09/03.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objc public protocol SBUUserProfileViewDelegate {
    /// This delegate function notifies the implemented class when closing the selector.
    @objc func didSelectClose()
    
    /// This delegate function notifies the implemented class when select message button.
    /// - Parameter userId: User ID used in current profile
    @objc func didSelectMessage(userId: String?)
}

/// This protocol is used to create a custom `UserView`.
@objc public protocol SBUUserProfileViewProtocol {
    /// This function shows selector view.
    @objc func show(baseView: UIView, user: SBUUser?)

    /// This function dismisses selector view.
    @objc func dismiss()
}

class SBUUserProfileView: UIView, SBUUserProfileViewProtocol {
    
    // MARK: - Property
    weak var delegate: SBUUserProfileViewDelegate? = nil
    var user: SBUUser?

    var theme: SBUUserProfileTheme = SBUTheme.userProfileTheme

    var baseView = UIView()
    var contentView: UIView = {
        let view = UIView()
        view.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        return view
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.roundCorners(corners: .allCorners, radius: kProfileImageSize/2)
        return imageView
    }()
    
    lazy var userNameLabel = UILabel()
    
    lazy var menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()

    lazy var largeMessageButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickMessage), for: .touchUpInside)
        button.layer.cornerRadius = 4.0
        button.setBackgroundImage(
            UIImage.from(color: self.theme.largeItemBackgroundColor),
            for: .normal
        )
        button.setBackgroundImage(
            UIImage.from(color: self.theme.largeItemHighlightedColor),
            for: .highlighted
        )
        return button
    }()
    
    lazy var separatorView = UIView()
    
    lazy var userIdTitleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    lazy var userIdLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .left
        return label
    }()
    
    lazy var backgroundCloseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        return button
    }()
    
    var separatorYAxisAnchor: NSLayoutYAxisAnchor = NSLayoutYAxisAnchor() {
        didSet {
            setNeedsLayout()
        }
    }
    
    var separatorTop: NSLayoutConstraint?
    var contentTopConstraint: NSLayoutConstraint?
    var contentBottomConstraint: NSLayoutConstraint?
    
    let kProfileImageSize: CGFloat = 80
    let kLargeItemSize: CGFloat = 48
    let kItemSize: CGSize = .init(width: 64, height: 68)
    
    
    // MARK: - View Lifecycle
    init(delegate: SBUUserProfileViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
    }
    
    @available(*, unavailable, renamed: "SBUUserProfileView.init(delegate:)")
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUUserProfileView.init(delegate:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        // View
        self.userNameLabel.textAlignment = .center
        
        self.largeMessageButton.layer.borderWidth = 1
        
        // View arrange
        self.addSubview(self.backgroundCloseButton)
        
        self.contentView.addSubview(self.profileImageView)
        
        self.contentView.addSubview(self.userNameLabel)
        
        self.menuStackView.addArrangedSubview(self.largeMessageButton)
        self.contentView.addSubview(self.menuStackView)
        self.menuStackView.isHidden = self.user?.userId == SBUGlobals.CurrentUser?.userId
        
        self.contentView.addSubview(self.separatorView)
        self.contentView.addSubview(self.userIdTitleLabel)
        self.contentView.addSubview(self.userIdLabel)
        
        self.addSubview(self.contentView)
        self.baseView.addSubview(self)
        
        self.profileImageView.loadImage(
            urlString: self.user?.profileUrl ?? "",
            placeholder: SBUIconSet.iconUser.sbu_with(
                tintColor: self.theme.userPlaceholderTintColor
            )
        )
        
        // Text
        self.userNameLabel.text = self.user?.refinedNickname()

        self.largeMessageButton.setTitle(SBUStringSet.UserProfile_Message, for: .normal)
        
        self.userIdTitleLabel.text = ""
        self.userIdLabel.text = ""
        
    }
    
    func setupStyles() {
        self.theme = SBUTheme.userProfileTheme
        
        self.backgroundColor = .clear
        
        self.contentView.backgroundColor = self.theme.backgroundColor

        self.profileImageView.backgroundColor = self.theme.userPlaceholderBackgroundColor
        
        self.userNameLabel.textColor = self.theme.usernameTextColor
        self.userNameLabel.font = self.theme.usernameFont
        
        self.largeMessageButton.tintColor = self.theme.largeItemTintColor
        self.largeMessageButton.setTitleColor(self.theme.largeItemTintColor, for: .normal)
        self.largeMessageButton.titleLabel?.font = self.theme.largeItemFont
        self.largeMessageButton.layer.borderColor = self.theme.largeItemTintColor.cgColor
        
        self.separatorView.backgroundColor = self.theme.separatorColor
        
        self.userIdTitleLabel.font = self.theme.informationTitleFont
        self.userIdTitleLabel.textColor = self.theme.informationTitleColor
        
        self.userIdLabel.font = self.theme.informationDesctiptionFont
        self.userIdLabel.textColor = self.theme.informationDesctiptionColor
    }
    
    func setupAutolayout() {
        self.sbu_constraint(equalTo: self.baseView, leading: 0, trailing: 0, top: 0, bottom: 0)
        if #available(iOS 11.0, *) {
            self.sbu_constraint_equalTo(
                topAnchor: self.safeAreaLayoutGuide.topAnchor,
                top: 0
            )
        }
        else {
            self.sbu_constraint(equalTo: self, top: 0)
        }
        self.backgroundCloseButton
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.contentView.sbu_constraint(equalTo: self, leading: 0, trailing: 0, bottom: 0)
        
        self.profileImageView
            .sbu_constraint(equalTo: self.contentView, top: 32, centerX: 0)
            .sbu_constraint(width: kProfileImageSize, height: kProfileImageSize)

        self.userNameLabel
            .sbu_constraint_equalTo(topAnchor: self.profileImageView.bottomAnchor, top: 8)
            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24)

        self.largeMessageButton.sbu_constraint(height: kLargeItemSize)
        self.menuStackView
            .sbu_constraint_equalTo(topAnchor: self.userNameLabel.bottomAnchor, top: 16)
            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24, centerX: 0)
//            .sbu_constraint(height: kItemSize.height)
        
        if self.user?.userId == SBUGlobals.CurrentUser?.userId {
            self.separatorYAxisAnchor = self.userNameLabel.bottomAnchor
        } else {
            self.separatorYAxisAnchor = self.menuStackView.bottomAnchor
        }
        
        self.separatorView
            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24, centerX: 0)
            .sbu_constraint(height: 1)
        
        self.separatorTop?.isActive = false
        self.separatorTop = self.separatorView.topAnchor.constraint(
            equalTo: self.separatorYAxisAnchor,
            constant: 24
        )
        self.separatorTop?.isActive = true
        
        self.userIdTitleLabel
            .sbu_constraint_equalTo(topAnchor: self.separatorView.bottomAnchor, top: 24)
            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24)
            .sbu_constraint(height: 20)
        
        self.userIdLabel
            .sbu_constraint_equalTo(topAnchor: self.userIdTitleLabel.bottomAnchor, top: 2)
            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24)
            .sbu_constraint(height: 20)
        
        var bottomMargin: CGFloat = 20
        if #available(iOS 11.0, *) {
            let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0.0
            bottomMargin = 20 + bottomInset
        }

        self.userIdLabel.sbu_constraint(equalTo: self.contentView, bottom: bottomMargin)
        
        self.contentBottomConstraint = self.contentView.bottomAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: 0
        )
        self.contentTopConstraint = self.contentView.topAnchor.constraint(
            equalTo: self.bottomAnchor,
            constant: 0
        )
        self.contentBottomConstraint?.isActive = false
        self.contentTopConstraint?.isActive = true
    }
    
    override func draw(_ rect: CGRect) {

    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    // MARK: - Actions
    @objc func onClickClose() {
        self.delegate?.didSelectClose()
    }
    
    @objc func onClickMessage() {
        self.delegate?.didSelectMessage(userId: self.user?.userId)
    }
    
    
    // MARK: SBUUserProfileViewProtocol
    func show(baseView: UIView, user: SBUUser?) {
        self.baseView = baseView
        self.user = user

        self.setupViews()
        self.setupStyles()
        self.setupAutolayout()
        
        self.layoutIfNeeded()
        
        self.contentBottomConstraint?.isActive = true
        self.contentTopConstraint?.isActive = false
        self.userIdTitleLabel.text = ""
        self.userIdLabel.text = ""

        self.layer.backgroundColor = UIColor.clear.cgColor
        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.layer.backgroundColor = self.theme.overlayColor.cgColor
        }) { _ in
            self.userIdTitleLabel.text = SBUStringSet.UserProfile_UserID
            self.userIdLabel.text = self.user?.userId
        }
    }
    
    func dismiss() {
        self.contentBottomConstraint?.isActive = false
        self.contentTopConstraint?.isActive = true
        self.userIdTitleLabel.text = ""
        self.userIdLabel.text = ""

        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            
            self.layer.backgroundColor = UIColor.clear.cgColor
        }) { _ in
            self.contentBottomConstraint?.isActive = false
            self.contentTopConstraint?.isActive = false
            self.removeFromSuperview()
        }
    }
}



// MARK: - TODO
//@objc public protocol SBUUserProfileViewDelegate {
//    @objc func didSelectPromoteToOperator(userId: String?)
//    @objc func didSelectDismissOperator(userId: String?)
//    @objc func didSelectMute(userId: String?)
//    @objc func didSelectUnmute(userId: String?)
//    @objc func didSelectBan(userId: String?)
//}
//
//@objc public protocol SBUUserProfileViewProtocol {
//    @objc func show(baseView: UIView, user: SBUUser?, myRole: SBDRole)
//}
//
//class SBUUserProfileView: UIView, SBUUserProfileViewProtocol {
//    var myRole: SBDRole = .none
//
//    lazy var userRoleLabel = UILabel()
//
//
//    lazy var messageItemButton: SBULayoutableButton = {
//        let button = SBULayoutableButton(gap: 8, labelAlignment: .under)
//        let tintColor = self.theme.itemTintColor
//        button.setImage(
//            SBUIconSet.iconMessage
//                .sbu_with(tintColor: theme.itemTintColor)
//                .resize(with: .init(width: kItemImageSize, height: kItemImageSize))
//                .withBackground(
//                    color: self.theme.itemBackgroundColor,
//                    margin: kItemImageMargin,
//                    circle: true
//            ),
//            for: .normal
//        )
//        button.addTarget(self, action: #selector(onClickMessage), for: .touchUpInside)
//        return button
//    }()
//
//    lazy var promoteItemButton: SBULayoutableButton = {
//    let button = SBULayoutableButton(gap: 8, labelAlignment: .under)
//        let tintColor = self.theme.itemTintColor
//        button.setImage(
//            SBUIconSet
//                .iconOperator
//                .sbu_with(tintColor: tintColor)
//                .resize(with: .init(width: kItemImageSize, height: kItemImageSize))
//                .withBackground(
//                    color: self.theme.itemBackgroundColor,
//                    margin: kItemImageMargin,
//                    circle: true
//            ),
//            for: .normal
//        )
//        button.addTarget(self, action: #selector(onClickPromoteToOperator), for: .touchUpInside)
//        button.imageView?.contentMode = .scaleAspectFit
//        return button
//    }()
//
//    lazy var muteItemButton: SBULayoutableButton = {
//    let button = SBULayoutableButton(gap: 8, labelAlignment: .under)
//        let tintColor = self.theme.itemTintColor
//        button.setImage(
//            SBUIconSet
//                .iconMuted
//                .sbu_with(tintColor: tintColor)
//                .resize(with: .init(width: kItemImageSize, height: kItemImageSize))
//                .withBackground(
//                    color: self.theme.itemBackgroundColor,
//                    margin: kItemImageMargin,
//                    circle: true
//            ),
//            for: .normal
//        )
//        button.addTarget(self, action: #selector(onClickMute), for: .touchUpInside)
//        button.imageView?.contentMode = .scaleAspectFit
//        return button
//    }()
//
//    lazy var banItemButton: SBULayoutableButton = {
//    let button = SBULayoutableButton(gap: 8, labelAlignment: .under)
//        let tintColor = self.theme.itemHighlightedTintColor
//        button.setImage(
//            SBUIconSet
//                .iconBanned
//                .sbu_with(tintColor: tintColor)
//                .resize(with: .init(width: kItemImageSize, height: kItemImageSize))
//                .withBackground(
//                    color: self.theme.itemBackgroundColor,
//                    margin: kItemImageMargin,
//                    circle: true
//            ),
//            for: .normal
//        )
//        button.addTarget(self, action: #selector(onClickBan), for: .touchUpInside)
//        button.imageView?.contentMode = .scaleAspectFit
//        return button
//    }()
//
//    let kItemImageSize: CGFloat = 48
//    let kItemImageMargin: CGFloat = 12
//
//
//    func show(baseView: UIView, user: SBUUser?, myRole: SBDRole) {
//        ...
//        self.myRole = myRole
//
//        ...
//    }
//
//    func setupViews() {
//        // View
//        ...
//        self.userRoleLabel.textAlignment = .center
//        ...
//        self.contentView.addSubview(self.userRoleLabel)
//
//        if self.myRole == .operator {
//            self.menuStackView.addArrangedSubview(self.messageItemButton)
//            self.menuStackView.addArrangedSubview(self.promoteItemButton)
//            self.menuStackView.addArrangedSubview(self.muteItemButton)
//            self.menuStackView.addArrangedSubview(self.banItemButton)
//        } else {
//            self.menuStackView.addArrangedSubview(self.largeMessageButton)
//        }
//        ...
//        // Text
//        ...
//        self.userRoleLabel.text = self.user?.isOperator ?? false
//            ? SBUStringSet.UserProfile_Role_Operator
//            : SBUStringSet.UserProfile_Role_Member
//
//        if self.myRole == .operator {
//            self.messageItemButton.setTitle(SBUStringSet.UserProfile_Message, for: .normal)
//            self.promoteItemButton.setTitle(SBUStringSet.UserProfile_Promote, for: .normal)
//            self.muteItemButton.setTitle(SBUStringSet.UserProfile_Mute, for: .normal)
//            self.banItemButton.setTitle(SBUStringSet.UserProfile_Ban, for: .normal)
//
//        } else {
//            self.largeMessageButton.setTitle(SBUStringSet.UserProfile_Message, for: .normal)
//        }
//        ...
//    }
//
//    func setupStyles() {
//        ...
//
//        self.userRoleLabel.textColor = self.theme.userRoleTextColor
//        self.userRoleLabel.font = self.theme.userRoleFont
//
//        ...
//
//        self.messageItemButton.setTitleColor(theme.itemTintColor, for: .normal)
//        self.messageItemButton.titleLabel?.font = theme.itemFont
//        self.messageItemButton.backgroundColor = self.theme.backgroundColor
//
//        self.promoteItemButton.setTitleColor(theme.itemTintColor, for: .normal)
//        self.promoteItemButton.titleLabel?.font = theme.itemFont
//        self.promoteItemButton.backgroundColor = self.theme.backgroundColor
//
//        self.muteItemButton.setTitleColor(theme.itemTintColor, for: .normal)
//        self.muteItemButton.titleLabel?.font = theme.itemFont
//        self.muteItemButton.backgroundColor = self.theme.backgroundColor
//
//        self.banItemButton.setTitleColor(theme.itemTintColor, for: .normal)
//        self.banItemButton.titleLabel?.font = theme.itemFont
//        self.banItemButton.backgroundColor = self.theme.backgroundColor
//        ...
//    }
//
//    func setupAutolayout() {
//        ...
//
//        self.userRoleLabel
//            .sbu_constraint_equalTo(topAnchor: self.userNameLabel.bottomAnchor, top: 0)
//            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24)
//
//        ...
//
//        self.messageItemButton.sbu_constraint(height: kItemSize.height)
//        self.promoteItemButton.sbu_constraint(height: kItemSize.height)
//        self.muteItemButton.sbu_constraint(height: kItemSize.height)
//        self.banItemButton.sbu_constraint(height: kItemSize.height)
//        self.menuStackView
//            .sbu_constraint_equalTo(topAnchor: self.userRoleLabel.bottomAnchor, top: 16)
//            .sbu_constraint(equalTo: self.contentView, leading: 24, trailing: -24, centerX: 0)
//            .sbu_constraint(height: kItemSize.height)
//        ...
//    }
//
//    @objc func onClickPromoteToOperator() {
//        self.delegate?.didSelectPromoteToOperator(userId: self.user?.userId)
//    }
//
//    @objc func onClickDismissOperator() {
//        self.delegate?.didSelectDismissOperator(userId: self.user?.userId)
//    }
//
//    @objc func onClickMute() {
//        self.delegate?.didSelectMute(userId: self.user?.userId)
//    }
//
//    @objc func onClickUnmute() {
//        self.delegate?.didSelectUnmute(userId: self.user?.userId)
//    }
//
//    @objc func onClickBan() {
//        self.delegate?.didSelectBan(userId: self.user?.userId)
//    }
//}

