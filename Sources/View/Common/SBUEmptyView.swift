//
//  SBUEmptyView.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public protocol SBUEmptyViewDelegate: NSObjectProtocol {
    /// Called when the retry button on the empty view was tapped.
    func didSelectRetry()
}

open class SBUEmptyView: SBUView {
    // MARK: - Properties (Public)
    public var type: EmptyViewType = .none
    public weak var delegate: SBUEmptyViewDelegate?
    public lazy var statusImageView = UIImageView()
    public var statusLabel: UILabel = .init()
    
    @SBUThemeWrapper(theme: SBUTheme.componentTheme)
    public var theme: SBUComponentTheme
    @SBUThemeWrapper(theme: SBUTheme.overlayTheme.componentTheme, setToDefault: true)
    public var overlayTheme: SBUComponentTheme
    
    public lazy var retryButton: UIButton = {
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        let retryButton = UIButton()
         retryButton.setImage(
             SBUIconSetType.iconRefresh.image(
                 with: theme.emptyViewRetryButtonTintColor,
                 to: SBUIconSetType.Metric.defaultIconSize
             ),
             for: .normal
         )
         retryButton.setTitle(SBUStringSet.Retry, for: .normal)
         retryButton.addTarget(self, action: #selector(onClickRetry), for: .touchUpInside)
         return retryButton
     }()
    
    public var isOverlay = false
    
    public var emptyViewTopConstraint: NSLayoutConstraint?

    // MARK: - Properties (Private)
    
    lazy var topView = UIView()
    
    lazy var baseStackView: SBUStackView = {
        return SBUStackView(axis: .vertical, alignment: .center)
    }()
    
    lazy var stackView: SBUStackView = {
        return SBUStackView(axis: .vertical, alignment: .center, spacing: 24)
    }()
    
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    @available(*, unavailable, renamed: "SBUEmptyView.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    required public override init() {
        super.init()
    }
    
    open override func setupViews() {
        super.setupViews()
        
        self.baseStackView.setVStack([
            self.topView,
            self.stackView
        ])
        
        self.stackView.setVStack([
            self.statusImageView,
            self.statusLabel,
            self.retryButton
        ])
        self.retryButton.isHidden = true
        
        self.addSubview(self.baseStackView)
        self.isHidden = true
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.emptyViewTopConstraint = self.topView.heightAnchor.constraint(equalToConstant: 0)
        
        self.baseStackView
            .sbu_constraint(equalTo: self, leading: 0, trailing: 0)
            .sbu_constraint(equalTo: self, centerY: 0)
        
        self.statusImageView
            .sbu_constraint(width: 60.0, priority: .defaultLow)
            .sbu_constraint(height: 60.0)
        
        self.updateTopAnchorConstraint(constant: 0)
    }
    
    open func updateTopAnchorConstraint(constant: CGFloat) {
        self.emptyViewTopConstraint?.isActive = false
        self.emptyViewTopConstraint?.constant = constant
        self.emptyViewTopConstraint?.isActive = true
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        
        self.backgroundColor = theme.emptyViewBackgroundColor
        
        self.statusLabel.font = theme.emptyViewStatusFont
        self.statusLabel.textColor = theme.emptyViewStatusTintColor
        self.statusLabel.contentMode = .center
        self.statusLabel.numberOfLines = 0
        self.statusLabel.lineBreakMode = .byWordWrapping

        self.statusImageView.image = self.statusImageView.image?.sbu_with(tintColor: theme.emptyViewStatusTintColor)
         
        self.retryButton.setTitleColor(theme.emptyViewRetryButtonTintColor, for: .normal)
        self.retryButton.titleLabel?.font = theme.emptyViewRetryButtonFont
        self.retryButton.tintColor = theme.emptyViewRetryButtonTintColor
    }
    
    // MARK: - Common
    
    /// This function reloads emptyView.
    /// - Parameter type: Empty view type
    public func reloadData(_ type: EmptyViewType) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.type = type
            
            self.retryButton.isHidden = (self.type != .error)
            
            self.updateViews()
            
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        }
    }
    
    /// Override this function to apply a custom type.
    open func updateViews() {
        var iconSetType: SBUIconSetType?
        switch self.type {
        case .none:
            self.statusLabel.text = ""
            self.statusImageView.image = nil
        case .noChannels:
            self.statusLabel.text = SBUStringSet.Empty_No_Channels
            iconSetType = SBUIconSetType.iconChat
        case .noMessages:
            self.statusLabel.text = SBUStringSet.Empty_No_Messages
            iconSetType = SBUIconSetType.iconMessage
        case .noNotifications:
            self.statusLabel.text = SBUStringSet.Empty_No_Notifications
            iconSetType = SBUIconSetType.iconMessage
        case .noMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Users
            iconSetType = SBUIconSetType.iconMembers
        case .noMutedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Members
            iconSetType = SBUIconSetType.iconMute
        case .noMutedParticipants:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Participants
            iconSetType = SBUIconSetType.iconMute
        case .noBannedUsers:
            self.statusLabel.text = SBUStringSet.Empty_No_Banned_Users
            iconSetType = SBUIconSetType.iconBan
        case .noSearchResults:
            self.statusLabel.text = SBUStringSet.Empty_Search_Result
            iconSetType = SBUIconSetType.iconSearch
        case .error:
            self.statusLabel.text = SBUStringSet.Empty_Wrong
            iconSetType = SBUIconSetType.iconError
        }
        
        let theme = self.isOverlay ? self.overlayTheme : self.theme
        self.statusImageView.image = type.isNone ? nil : iconSetType?.image(
            with: theme.emptyViewStatusTintColor,
            to: SBUIconSetType.Metric.iconEmptyView
        )

        self.isHidden = type.isNone
    }
    
    // MARK: - Action
    
    /// This function actions when the retry button click.
    /// - Parameter sender: sender
    @objc
    open func onClickRetry(_ sender: Any) {
        self.delegate?.didSelectRetry()
    }
}

extension SBUEmptyView {
    static func createDefault(
        _ viewType: SBUEmptyView.Type,
        type: EmptyViewType = .none,
        delegate: SBUEmptyViewDelegate?
    ) -> SBUEmptyView {
        let emptyView = viewType.init()
        emptyView.type = type
        emptyView.delegate = delegate
        return emptyView
    }
}
