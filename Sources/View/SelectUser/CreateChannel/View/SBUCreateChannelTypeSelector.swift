//
//  SBUCreateChannelTypeSelector.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This delegate is used in the class to handle the action.
public protocol SBUCreateChannelTypeSelectorDelegate: AnyObject {
    /// This delegate function notifies when closing the selector.
    func didSelectCloseSelector()
    
    /// This delegate function notifies when selecting the create group channel menu.
    func didSelectCreateGroupChannel()
    
    /// This delegate function notifies when selecting the create super group channel menu.
    func didSelectCreateSuperGroupChannel()
    
    /// This delegate function notifies when selecting the create broadcast channel menu.
    func didSelectCreateBroadcastChannel()
}

/// This protocol is used to create a custom `CreateChannelTypeSelector`.
public protocol SBUCreateChannelTypeSelectorProtocol {
    /// This function shows selector view.
    func show()
    
    /// This function dismisses selector view.
    func dismiss()
}

/// This class is used to select the channel type
/// - Since: 3.0.0
open class SBUCreateChannelTypeSelector: SBUView, SBUCreateChannelTypeSelectorProtocol {
    
    // MARK: - UI properties (Public)
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme

    public lazy var navigationBar = UINavigationBar()
    public lazy var navigationItem = UINavigationItem()
    public lazy var contentView = UIView()
    public lazy var rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSetType.iconClose.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onClickClose)
        )
    }()
    
    public lazy var backgroundCloseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    public var selectorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public lazy var createGroupChannelButton: UIButton = {
        return self.createButton(type: .group)
    }()
    
    public lazy var createSuperGroupChannelButton: UIButton = {
        return self.createButton(type: .supergroup)
    }()
    
    public lazy var createBroadcastChannelButton: UIButton = {
        return self.createButton(type: .broadcast)
    }()
    
    // MARK: - UI properties (Private)
    private weak var delegate: SBUCreateChannelTypeSelectorDelegate?

    // MARK: - View Lifecycle
    @available(*, unavailable, renamed: "CreateChannelTypeSelectView.init(delegate:)")
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "CreateChannelTypeSelectView.init(delegate:)")
    required public init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    public init(delegate: SBUCreateChannelTypeSelectorDelegate?) {
        self.delegate = delegate
        
        super.init()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.navigationItem = UINavigationItem(title: SBUStringSet.CreateChannel_Header_Title)
        self.navigationItem.rightBarButtonItem = self.rightBarButton
        
        self.navigationBar = UINavigationBar()
        self.navigationBar.items = [navigationItem]
        self.contentView.addSubview(self.navigationBar)
        self.contentView.addSubview(self.backgroundCloseButton)
        
        self.selectorStackView.addArrangedSubview(self.createGroupChannelButton)
        self.selectorStackView.addArrangedSubview(self.createSuperGroupChannelButton)
        self.selectorStackView.addArrangedSubview(self.createBroadcastChannelButton)
        
        self.contentView.addSubview(self.selectorStackView)
        
        self.addSubview(self.contentView)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.contentView.backgroundColor = theme.overlayColor
        self.navigationBar.titleTextAttributes = [
            .foregroundColor: self.theme.titleColor,
            .font: self.theme.titleFont
        ]
        self.navigationBar.setBackgroundImage(
            UIImage.from(color: self.theme.backgroundColor), for: .default
        )
        
        self.navigationItem.rightBarButtonItem?.tintColor = self.theme.closeBarButtonTintColor
        
        self.updateButton(type: .group)
        self.updateButton(type: .supergroup)
        self.updateButton(type: .broadcast)
    }
    
    open override func updateStyles() {
        super.updateStyles()
        
        self.setupStyles()
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.contentView.sbu_constraint(
            equalTo: self,
            leading: 0,
            trailing: 0,
            bottom: 0
        )
        self.contentView.sbu_constraint_equalTo(
            topAnchor: self.safeAreaLayoutGuide.topAnchor,
            top: 0
        )
        
        self.navigationBar.sbu_constraint(
            equalTo: self.contentView,
            leading: 0,
            trailing: 0,
            top: 0
        )
        
        self.backgroundCloseButton.sbu_constraint(
            equalTo: self.contentView,
            leading: 0,
            trailing: 0,
            top: 0,
            bottom: 0
        )
        
        self.selectorStackView
            .sbu_constraint(height: 80)
            .sbu_constraint_equalTo(
                leadingAnchor: self.leadingAnchor,
                leading: 0,
                trailingAnchor: self.trailingAnchor,
                trailing: 0,
                topAnchor: self.navigationBar.bottomAnchor,
                top: 0
        )

        self.createGroupChannelButton.sbu_constraint(height: 80)
        self.createSuperGroupChannelButton.sbu_constraint(height: 80)
        self.createBroadcastChannelButton.sbu_constraint(height: 80)
    }

    // MARK: - SBUCreateChannelTypeSelectorProtocol
    open func show() {
        self.updateStyles() 
        
        if !SBUAvailable.isSupportSuperGroupChannel() {
            self.createSuperGroupChannelButton.isHidden = true
        }
        
        if !SBUAvailable.isSupportBroadcastChannel() {
            self.createBroadcastChannelButton.isHidden = true
        }
        
        self.isHidden = false
    }
    
    open func dismiss() {
        self.isHidden = true
    }

    // MARK: - Actions
    @objc open func onClickClose() {
        self.delegate?.didSelectCloseSelector()
    }
    
    @objc open func onClickCreateGroupChannel() {
        self.delegate?.didSelectCreateGroupChannel()
    }
    
    @objc open func onClickCreateSuperGroupChannel() {
        self.delegate?.didSelectCreateSuperGroupChannel()
    }
    
    @objc open func onClickCreateBroadcastChannel() {
        self.delegate?.didSelectCreateBroadcastChannel()
    }
    
    open func createButton(type: ChannelCreationType) -> SBULayoutableButton {
        let button = SBULayoutableButton(gap: 4, labelAlignment: .under)
        let tintColor = theme.channelTypeSelectorItemTintColor
        switch type {
        case .group:
            button.setTitle(SBUStringSet.ChannelType_Group, for: .normal)
            button.setImage(
                SBUIconSetType.iconChat.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
            button.addTarget(
                self,
                action: #selector(onClickCreateGroupChannel),
                for: .touchUpInside
            )
        case .supergroup:
            button.setTitle(SBUStringSet.ChannelType_SuperGroup, for: .normal)
            button.setImage(
                SBUIconSetType.iconSupergroup.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
            button.addTarget(
                self,
                action: #selector(onClickCreateSuperGroupChannel),
                for: .touchUpInside
            )
        case .broadcast:
            button.setTitle(SBUStringSet.ChannelType_Broadcast, for: .normal)
            button.setImage(
                SBUIconSetType.iconBroadcast.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
            button.addTarget(
                self,
                action: #selector(onClickCreateBroadcastChannel),
                for: .touchUpInside
            )
        default:
            break
        }

        button.tag = type.rawValue+10
        button.setTitleColor(theme.channelTypeSelectorItemTextColor, for: .normal)
        button.titleLabel?.font = theme.channelTypeSelectorItemFont
        button.backgroundColor = self.theme.backgroundColor
        return button
    }
    
    open func updateButton(type: ChannelCreationType) {
        guard let button = self.viewWithTag(type.rawValue+10) as? UIButton else { return }
        let tintColor = theme.channelTypeSelectorItemTintColor
        switch type {
        case .group:
            button.setImage(
                SBUIconSetType.iconChat.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
        case .supergroup:
            button.setImage(
                SBUIconSetType.iconSupergroup.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
        case .broadcast:
            button.setImage(
                SBUIconSetType.iconBroadcast.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                for: .normal
            )
        default:
            break
        }
        
        button.setTitleColor(theme.channelTypeSelectorItemTextColor, for: .normal)
        button.backgroundColor = self.theme.backgroundColor
    }
}
