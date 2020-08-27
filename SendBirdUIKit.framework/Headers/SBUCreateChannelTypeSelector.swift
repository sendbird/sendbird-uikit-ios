//
//  SBUCreateChannelTypeSelector.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/20.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

/// This delegate is used in the class to handle the action.
@objc public protocol SBUCreateChannelTypeSelectorDelegate {
    /// This function notifies the `SBUchannelListViewController` when closing the selector.
    @objc func didSelectCloseSelector()
    
    /// This function notifies the `SBUchannelListViewController` when selecting the create group channel menu.
    @objc func didSelectCreateGroupChannel()
    
    /// This function notifies the `SBUchannelListViewController` when selecting the create super group channel menu.
    @objc func didSelectCreateSuperGroupChannel()
    
    /// This function notifies the `SBUchannelListViewController` when selecting the create broadcast channel menu.
    @objc func didSelectCreateBroadcastChannel()
}


/// This protocol is used to create a custom `CreateChannelTypeSelector`.
@objc public protocol SBUCreateChannelTypeSelectorProtocol {
    /// This function shows selector view.
    @objc func show()
    
    /// This function dismisses selector view.
    @objc func dismiss()
}


class SBUCreateChannelTypeSelector: UIView, SBUCreateChannelTypeSelectorProtocol {
    var delegate: SBUCreateChannelTypeSelectorDelegate? = nil
    
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    lazy var navigationBar = UINavigationBar()
    lazy var contentView = UIView()
    lazy var rightBarButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: SBUIconSet.iconClose,
            style: .plain,
            target: self,
            action: #selector(onClickClose)
        )
    }()
    
    lazy var backgroundCloseButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(onClickClose), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    var selectorStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var createGroupChannelButton: UIButton = {
        return self.createButton(type: .group)
    }()
    
    lazy var createSuperGroupChannelButton: UIButton = {
        return self.createButton(type: .supergroup)
    }()
    
    lazy var createBroadcastChannelButton: UIButton = {
        return self.createButton(type: .broadcast)
    }()
    

    // MARK: - View Lifecycle
    init(delegate: SBUCreateChannelTypeSelectorDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "CreateChannelTypeSelectView.init(delegate:)")
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "CreateChannelTypeSelectView.init(delegate:)")
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setupViews() {
        self.contentView.backgroundColor = theme.overlayColor
        
        let navigationItem = UINavigationItem(title: SBUStringSet.CreateChannel_Header_Title)
        navigationItem.rightBarButtonItem = self.rightBarButton
        navigationItem.rightBarButtonItem?.tintColor = self.theme.closeBarButtonTintColor
        
        self.navigationBar = UINavigationBar()
        self.navigationBar.items = [navigationItem]
        self.navigationBar.titleTextAttributes = [
            .foregroundColor: self.theme.titleColor,
            .font: self.theme.titleFont
        ]
        self.navigationBar.setBackgroundImage(
            UIImage.from(color: self.theme.backgroundColor), for: .default
        )
        self.contentView.addSubview(self.navigationBar)
        self.contentView.addSubview(self.backgroundCloseButton)
        
        self.selectorStackView.addArrangedSubview(self.createGroupChannelButton)
        self.selectorStackView.addArrangedSubview(self.createSuperGroupChannelButton)
        self.selectorStackView.addArrangedSubview(self.createBroadcastChannelButton)
        
        self.contentView.addSubview(self.selectorStackView)
        
        self.addSubview(self.contentView)
    }
    
    func setupStyle() {
        
    }
    
    func setupAutolayout() {
        self.contentView.sbu_constraint(
            equalTo: self,
            leading: 0,
            trailing: 0,
            bottom: 0
        )
        if #available(iOS 11.0, *) {
            self.contentView.sbu_constraint_equalTo(
                topAnchor: self.safeAreaLayoutGuide.topAnchor,
                top: 0
            )
        }
        else {
            self.contentView.sbu_constraint(equalTo: self, top: 0)
        }
        
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    // MARK: - Common
    func show() {
        if !SBUAvailable.isSupportSuperGroupChannel() {
            self.createSuperGroupChannelButton.isHidden = true
        }
        
        if !SBUAvailable.isSupportBroadcastChannel() {
            self.createBroadcastChannelButton.isHidden = true
        }
        
        self.isHidden = false
    }
    
    func dismiss() {
        self.isHidden = true
    }

    // MARK: - Actions
    @objc func onClickClose() {
        self.delegate?.didSelectCloseSelector()
    }
    @objc func onClickCreateGroupChannel() {
        self.delegate?.didSelectCreateGroupChannel()
    }
    @objc func onClickCreateSuperGroupChannel() {
        self.delegate?.didSelectCreateSuperGroupChannel()
    }
    @objc func onClickCreateBroadcastChannel() {
        self.delegate?.didSelectCreateBroadcastChannel()
    }
}


extension SBUCreateChannelTypeSelector {
    func createButton(type: ChannelType) -> SBUBottomLabelButton {
        let button = SBUBottomLabelButton(contentGap: 4)
        let tintColor = theme.channelTypeSelectorItemTintColor
        switch type {
        case .group:
            button.setTitle(SBUStringSet.ChannelType_Group, for: .normal)
            button.setImage(
                SBUIconSet.channelTypeGroup.sbu_with(tintColor: tintColor),
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
                SBUIconSet.channelTypeSupergroup.sbu_with(tintColor: tintColor),
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
                SBUIconSet.channelTypeBroadcast.sbu_with(tintColor: tintColor),
                for: .normal
            )
            button.addTarget(
                self,
                action: #selector(onClickCreateBroadcastChannel),
                for: .touchUpInside
            )
        }
        
        button.setTitleColor(theme.channelTypeSelectorItemTextColor, for: .normal)
        button.titleLabel?.font = theme.channelTypeSelectorItemFont
        button.backgroundColor = self.theme.backgroundColor
        return button
    }
}
