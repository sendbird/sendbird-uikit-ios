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
    /// This function sets up the views.
    func setupViews()
    /// This function sets up the styles for the view.
    func setupStyles()
    
    /// This function shows the selector view.
    /// - Parameters:
    ///   - baseView: The base view where the selector will be shown.
    func show(baseView: UIView, user: SBUUser?)
    
    /// This function shows the selector view.
    /// - Parameters:
    ///   - baseView: The base view where the selector will be shown.
    ///   - user: The user object that will be used in the selector.
    ///   - isOpenChannel: A boolean value indicating whether the channel is open or not.
    func show(baseView: UIView, user: SBUUser?, isOpenChannel: Bool)

    /// This function dismisses selector view.
    func dismiss()
}

/// Default user profile view
/// - Since: 3.28.0
open class SBUUserProfileView: UIView, SBUUserProfileViewProtocol {
    
    // MARK: - Property
    
    /// View event delegate
    public private(set) weak var delegate: SBUUserProfileViewDelegate?
    
    /// User model used in profile views
    public private(set) var user: SBUUser?
    
    /// user profile theme
    @SBUThemeWrapper(theme: SBUTheme.userProfileTheme)
    public var theme: SBUUserProfileTheme
    
    /// Base view where the selector will be shown
    public var baseView = UIView()
    
    /// Contents view
    public var contentView: UIView = {
        let view = UIView()
        view.roundCorners(corners: [.topLeft, .topRight], radius: 10)
        return view
    }()
    
    /// Profile image view
    public lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.roundCorners(corners: .allCorners, radius: kProfileImageSize/2)
        return imageView
    }()
    
    /// Name label
    public lazy var userNameLabel = UILabel()
    
    /// Stack view in which the menu will be displayed
    public lazy var menuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    /// Message button
    public lazy var largeMessageButton: UIButton = {
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
    
    /// Separator view
    public lazy var separatorView = UIView()
    
    /// User id title label
    public lazy var userIdTitleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    /// User id value label
    public lazy var userIdLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    /// Background close button
    public lazy var backgroundCloseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        return button
    }()
    
    /// Value to indicate whether menu is hidden
    public private(set) var isMenuStackViewHidden = false
    
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
    public required init(delegate: SBUUserProfileViewDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
    }
    
    @available(*, unavailable, renamed: "SBUUserProfileView.init(delegate:)")
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUUserProfileView.init(delegate:)")
    public required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    /// This function handles the initialization of views.
    open func setupViews() {
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
    
    /// This function handles the initialization of styles.
    open func setupStyles() {
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
    
    /// This function handles the initialization of autolayouts.
    open func setupLayouts() {
        self.sbu_constraint(equalTo: self.baseView, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.backgroundCloseButton
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        
        self.contentView.sbu_constraint(equalTo: self, leading: 0, trailing: 0)
        
        self.profileImageView
            .sbu_constraint(equalTo: self.contentView, top: 32, centerX: 0)
            .sbu_constraint(width: kProfileImageSize, height: kProfileImageSize)
        
        self.largeMessageButton
            .sbu_constraint(height: kLargeItemSize, priority: .defaultHigh)
        
        NSLayoutConstraint.sbu_activate(baseView: self.userNameLabel, constraints: [
            self.userNameLabel.topAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 8),
            self.userNameLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            self.userNameLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -21)
        ])
        
        NSLayoutConstraint.sbu_activate(baseView: self.menuStackView, constraints: [
            self.menuStackView.topAnchor.constraint(equalTo: self.userNameLabel.bottomAnchor, constant: 16),
            self.menuStackView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 22),
            self.menuStackView.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -23)
        ])
        
        NSLayoutConstraint.sbu_activate(baseView: self.separatorView, constraints: [
            self.separatorView.heightAnchor.constraint(equalToConstant: 1),
            self.separatorView.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            self.separatorView.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -25)
        ])
        
        NSLayoutConstraint.sbu_activate(baseView: self.userIdTitleLabel, constraints: [
            self.userIdTitleLabel.topAnchor.constraint(equalTo: self.separatorView.bottomAnchor, constant: 26),
            self.userIdTitleLabel.heightAnchor.constraint(equalToConstant: 20),
            self.userIdTitleLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 27),
            self.userIdTitleLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -28)
        ])
        
        NSLayoutConstraint.sbu_activate(baseView: self.userIdLabel, constraints: [
            self.userIdLabel.topAnchor.constraint(equalTo: self.userIdTitleLabel.bottomAnchor, constant: 2),
            self.userIdLabel.heightAnchor.constraint(equalToConstant: 20),
            self.userIdLabel.leadingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.leadingAnchor, constant: 29),
            self.userIdLabel.trailingAnchor.constraint(equalTo: self.contentView.safeAreaLayoutGuide.trailingAnchor, constant: -30)
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
        
        self.userIdLabel.sbu_constraint(equalTo: self.contentView, bottom: bottomMargin, priority: .defaultLow)
        
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
    
    open override func draw(_ rect: CGRect) {
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: - Actions
    /// Methods called when the close button is clicked
    @objc
    open func onClickClose() {
        self.delegate?.didSelectClose()
    }
    
    /// Methods called when last message is clicked
    @objc
    open func onClickMessage() {
        self.delegate?.didSelectMessage(userId: self.user?.userId)
    }

    // MARK: SBUUserProfileViewProtocol
    
    /// This function shows the selector view.
    /// - Parameters:
    ///   - baseView: The base view where the selector will be shown.
    open func show(baseView: UIView, user: SBUUser?) {
        self.show(baseView: baseView, user: user, isOpenChannel: false)
    }
    
    /// This function shows the selector view.
    /// - Parameters:
    ///   - baseView: The base view where the selector will be shown.
    ///   - user: The user object that will be used in the selector.
    ///   - isOpenChannel: A boolean value indicating whether the channel is open or not.
    open func show(baseView: UIView, user: SBUUser?, isOpenChannel: Bool) {
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
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            self.layer.backgroundColor = self.theme.overlayColor.cgColor
        } completion: { _ in
            self.userIdTitleLabel.text = SBUStringSet.UserProfile_UserID
            self.userIdLabel.text = self.user?.userId
        }
    }
    
    /// This function dismisses selector view.
    open func dismiss() {
        self.contentBottomConstraint?.isActive = false
        self.contentTopConstraint?.isActive = true
        self.userIdTitleLabel.text = ""
        self.userIdLabel.text = ""

        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
            
            self.layer.backgroundColor = UIColor.clear.cgColor
        } completion: { _ in
            self.contentBottomConstraint?.isActive = false
            self.contentTopConstraint?.isActive = false
            self.removeFromSuperview()
        }
    }
}

extension SBUUserProfileView {
    static func createDefault(
        _ viewType: SBUUserProfileView.Type,
        delegate: SBUUserProfileViewDelegate?
    ) -> SBUUserProfileView {
        return viewType.init(
            delegate: delegate
        )
    }
}
