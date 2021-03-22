//
//  SBUEmptyView.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 27/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objc public protocol SBUEmptyViewDelegate: NSObjectProtocol {
    @objc func didSelectRetry()
}

@objcMembers
open class SBUEmptyView: UIView {
    // MARK: - Properties (Public)
    public var type: EmptyViewType = .none
    public weak var delegate: SBUEmptyViewDelegate?
    public lazy var statusImageView = UIImageView()
    public var statusLabel: UILabel = .init()
    public var theme: SBUComponentTheme = SBUTheme.componentTheme
    public lazy var retryButton: UIButton = _retryButton

    // MARK: - Properties (Private)
    var isOverlay = false
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 24
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var _retryButton: UIButton = {
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

    
    // MARK: - Lifecycle
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupViews()
        self.setupAutolayout()
    }
    
    @available(*, unavailable, renamed: "SBUEmptyView.init(frame:)")
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setupViews() {
        self.stackView.alignment = .center
        self.stackView.addArrangedSubview(self.statusImageView)
        self.stackView.addArrangedSubview(self.statusLabel)
        self.stackView.addArrangedSubview(self.retryButton)
        self.retryButton.isHidden = true
        self.addSubview(stackView)
    }
    
    public func setupAutolayout() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            self.stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
        
        self.statusImageView.setConstraint(width: 60.0, height: 60.0)
    }
    
    public func setupStyles() {
        self.theme = self.isOverlay ? SBUTheme.overlayTheme.componentTheme : SBUTheme.componentTheme
        
        self.backgroundColor = theme.emptyViewBackgroundColor
        
        self.statusLabel.font = theme.emptyViewStatusFont
        self.statusLabel.textColor = theme.emptyViewStatusTintColor
        //NOTE: this will cause unexpected image when tint with not desirable
        //image
        //self.statusImageView.image = self.statusImageView.image?.sbu_with(tintColor: theme.emptyViewStatusTintColor)
         
        self.retryButton.setTitleColor(theme.emptyViewRetryButtonTintColor, for: .normal)
        self.retryButton.titleLabel?.font = theme.emptyViewRetryButtonFont
        self.retryButton.tintColor = theme.emptyViewRetryButtonTintColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        self.setupStyles()
    }
    
    
    // MARK: - Common
    
    /// This function reloads emptyView.
    /// - Parameter type: Empty view type
    public func reloadData(_ type: EmptyViewType) {
        self.type = type
        self.retryButton.isHidden = (self.type != .error)

        self.updateViews()
        
        self.layoutIfNeeded()
        self.updateConstraintsIfNeeded()
    }
    
    /// Override this function to apply a custom type.
    open func updateViews() {
        self.isHidden = false
        
        switch self.type {
        case .none:
            self.statusLabel.text = ""
            self.statusImageView.image = nil
            self.isHidden = true
        case .noChannels:
            self.statusLabel.text = SBUStringSet.Empty_No_Channels
            self.statusImageView.image = SBUIconSetType.iconChat.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        case .noMessages:
            self.statusLabel.text = SBUStringSet.Empty_No_Messages
            self.statusImageView.image = SBUIconSetType.iconMessage.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        case .noMutedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Members
            self.statusImageView.image = SBUIconSetType.iconMute.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        case .noBannedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Banned_Members
            self.statusImageView.image = SBUIconSetType.iconBan.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        case .noSearchResults:
            self.statusLabel.text = SBUStringSet.Empty_Search_Result
            self.statusImageView.image = SBUIconSetType.iconSearch.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        case .error:
            self.statusLabel.text = SBUStringSet.Empty_Wrong
            self.statusImageView.image = SBUIconSetType.iconError.image(
                with: theme.emptyViewStatusTintColor,
                to: SBUIconSetType.Metric.iconEmptyView,
                forceResizeCustomized: false
            )
        }
    }
    
    
    // MARK: - Action
    
    /// This function actions when the retry button click.
    /// - Parameter sender: sender
    @objc open func onClickRetry(_ sender: Any) {
        self.delegate?.didSelectRetry()
    }
}
