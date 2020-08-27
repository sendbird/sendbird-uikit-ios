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

    // MARK: - Properties (Private)
    var theme: SBUComponentTheme = SBUTheme.componentTheme
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 28
        stackView.axis = .vertical
        stackView.alignment = .center
        return stackView
    }()
    
    lazy var retryButton: UIButton = {
       let retryButton = UIButton()
        retryButton.setImage(
            SBUIconSet.iconRefresh.sbu_with(tintColor: theme.emptyViewRetryButtonTintColor),
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
        self.backgroundColor = theme.emptyViewBackgroundColor
        
        self.statusLabel.font = theme.emptyViewStatusFont
        self.statusLabel.textColor = theme.emptyViewStatusTintColor
         
        self.retryButton.setTitleColor(theme.emptyViewRetryButtonTintColor, for: .normal)
        self.retryButton.titleLabel?.font = theme.emptyViewRetryButtonFont
        self.retryButton.tintColor = theme.emptyViewRetryButtonTintColor
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        self.setupStyles()
    }
    
    
    // MARK: - Common
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
            self.statusImageView.image = SBUIconSet.iconChat
                .sbu_with(tintColor: theme.emptyViewStatusTintColor)
        case .noMessages:
            self.statusLabel.text = SBUStringSet.Empty_No_Messages
            self.statusImageView.image = SBUIconSet.iconMessage
                .sbu_with(tintColor: theme.emptyViewStatusTintColor)
        case .noMutedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Muted_Members
            self.statusImageView.image = SBUIconSet.iconMuted
                .sbu_with(tintColor: theme.emptyViewStatusTintColor)
        case .noBannedMembers:
            self.statusLabel.text = SBUStringSet.Empty_No_Banned_Members
            self.statusImageView.image = SBUIconSet.iconBanned
                .sbu_with(tintColor: theme.emptyViewStatusTintColor)
        case .error:
            self.statusLabel.text = SBUStringSet.Empty_Wrong
            self.statusImageView.image = SBUIconSet.iconError
                .sbu_with(tintColor: theme.emptyViewStatusTintColor)
        }
    }
    
    
    // MARK: - Action
    @objc open func onClickRetry(_ sender: Any) {
        self.delegate?.didSelectRetry()
    }
}
