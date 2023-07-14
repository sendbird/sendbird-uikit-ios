//
//  SBUUserProfileView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/09/03.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUUserProfileViewDelegate: AnyObject {
    /// This delegate function notifies the implemented class when closing the selector.
    func didSelectClose()
    
    /// This delegate function notifies the implemented class when select message button.
    /// - Parameter userId: User ID used in current profile
    func didSelectMessage(userId: String?)
}

/// This protocol is used to create a custom `UserView`.
public protocol SBUUserProfileViewProtocol {
    func setupViews()
    func setupStyles()
    
    /// This function shows selector view.
    func show(baseView: UIView, user: SBUUser?)
    func show(baseView: UIView, user: SBUUser?, isOpenChannel: Bool)

    /// This function dismisses selector view.
    func dismiss()
}

class SBUUserProfileView: UIView, SBUUserProfileViewProtocol {
    
    // MARK: - Property
    weak var delegate: SBUUserProfileViewDelegate?
    var user: SBUUser?
    
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    var theme: SBUUserProfileTheme

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
    
    var isMenuStackViewHidden = false
    
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
        self.menuStackView.isHidden = (self.user?.userId == SBUGlobals.currentUser?.userId) || self.isMenuStackViewHidden
        
        self.contentView.addSubview(self.separatorView)
        self.contentView.addSubview(self.userIdTitleLabel)
        self.contentView.addSubview(self.userIdLabel)
        
        self.addSubview(self.contentView)
        self.baseView.addSubview(self)
        
        self.profileImageView.loadImage(
            urlString: self.user?.profileURL ?? "",
            placeholder: SBUIconSetType.iconUser.image(
                with: self.theme.userPlaceholderTintColor,
                to: SBUIconSetType.Metric.iconUserProfile
            ),
            subPath: SBUCacheManager.PathType.userProfile
        )
        
        // Text
        self.userNameLabel.text = self.user?.refinedNickname()

        self.largeMessageButton.setTitle(SBUStringSet.UserProfile_Message, for: .normal)
        
        self.userIdTitleLabel.text = ""
        self.userIdLabel.text = ""
        
    }
    
    func setupStyles() {
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
    
    func setupLayouts() {
        self.sbu_constraint(equalTo: self.baseView, leading: 0, trailing: 0, top: 0, bottom: 0)
        self.sbu_constraint_equalTo(
            topAnchor: self.safeAreaLayoutGuide.topAnchor,
            top: 0
        )
        self.backgroundCloseButton
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.contentView.sbu_constraint(equalTo: self, leading: 0, trailing: 0, bottom: 0)
        
        self.profileImageView
            .sbu_constraint(equalTo: self.contentView, top: 32, centerX: 0)
            .sbu_constraint(width: kProfileImageSize, height: kProfileImageSize)

        self.largeMessageButton.sbu_constraint(height: kLargeItemSize)
        
        self.menuStackView.translatesAutoresizingMaskIntoConstraints = false
        self.userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.userIdTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.userIdLabel.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.menuStackView.topAnchor.constraint(equalTo: self.userNameLabel.bottomAnchor, constant: 16),
            self.menuStackView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.separatorView.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.userNameLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 8),
            self.userIdTitleLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 24),
            self.userIdTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            self.userIdLabel.topAnchor.constraint(equalTo: self.userIdTitleLabel.bottomAnchor, constant: 2),
            self.userIdLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        NSLayoutConstraint.activate([
            self.menuStackView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.menuStackView.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            self.userNameLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.userNameLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            self.userIdTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.userIdTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            self.userIdLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.userIdLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -24)
        ])
        
        if (self.user?.userId == SBUGlobals.currentUser?.userId) || self.isMenuStackViewHidden {
            self.separatorYAxisAnchor = self.userNameLabel.bottomAnchor
        } else {
            self.separatorYAxisAnchor = self.menuStackView.bottomAnchor
        }
        
        self.separatorTop?.isActive = false
        self.separatorTop = self.separatorView.topAnchor.constraint(
            equalTo: self.separatorYAxisAnchor,
            constant: 24
        )
        self.separatorTop?.isActive = true
        
        let bottomInset = UIApplication.shared.currentWindow?.safeAreaInsets.bottom ?? 0.0
        let bottomMargin: CGFloat = 20 + bottomInset

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
    @objc
    func onClickClose() {
        self.delegate?.didSelectClose()
    }
    
    @objc
    func onClickMessage() {
        self.delegate?.didSelectMessage(userId: self.user?.userId)
    }
    
    // MARK: SBUUserProfileViewProtocol
    func show(baseView: UIView, user: SBUUser?) {
        self.show(baseView: baseView, user: user, isOpenChannel: false)
    }
    
    func show(baseView: UIView, user: SBUUser?, isOpenChannel: Bool) {
        self.baseView = baseView
        self.user = user
        self.isMenuStackViewHidden = isOpenChannel

        self.setupViews()
        self.setupStyles()
        self.setupLayouts()
        
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
