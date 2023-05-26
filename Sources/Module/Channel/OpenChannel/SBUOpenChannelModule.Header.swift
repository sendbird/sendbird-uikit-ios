//
//  SBUOpenChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in a open channel.
public protocol SBUOpenChannelModuleHeaderDelegate: SBUBaseChannelModuleHeaderDelegate {
    
}

extension SBUOpenChannelModule {
    
    /// A module component that represent the header of `SBUOpenChannelModule`.
    @objcMembers open class Header: SBUBaseChannelModule.Header, SBUChannelInfoHeaderViewDelegate {
        
        /// A view that shows the information of the open channel such as a cover image, a channel name and a description.
        public lazy var channelInfoView: UIView = SBUChannelInfoHeaderView(delegate: self)
        
        /// A property to hide `channelInfoView`.
        public var hidesChannelInfoView: Bool = false {
            willSet { self.channelInfoView.isHidden = newValue }
        }
        
        public var overlaysChannelInfoView: Bool = false {
            willSet { self.overlaysChannelInfoView = newValue }
        }
        
        private lazy var defaultParticipantListBarButton = UIBarButtonItem(
            image: SBUIconSetType.iconMembers.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onTapRightBarButton)
        )
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUOpenChannelModuleHeaderDelegate` protocol
        public weak var delegate: SBUOpenChannelModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUOpenChannelModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// Configures `SBUOpenChannelModule.Header` object with the `delegate` and the `theme`.
        /// - Parameters:
        ///   - delegate: The object that acts as the delegate of the header component. The delegate must adopt the `SBUOpenChannelModuleHeaderDelegate` protocol.
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func configure(
            delegate: SBUOpenChannelModuleHeaderDelegate,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        open override func setupViews() {
            super.setupViews()
            
            self.addSubview(self.channelInfoView)
        }
        
        open override func setupLayouts() {
            super.setupLayouts()
            
            self.channelInfoView
                .sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
        }
        
        open override func setupStyles(theme: SBUChannelTheme? = nil) {
            super.setupStyles(theme: theme)
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = self.theme?.rightBarButtonTintColor
        }
        
        open override func updateStyles(theme: SBUChannelTheme? = nil) {
            super.updateStyles(theme: theme)
            
            if let channelInfoView = self.channelInfoView as? SBUChannelInfoHeaderView {
                channelInfoView.setupStyles()
            }
        }
        
        /// Updates styles of the views in the header component with the theme.
        /// - Parameter overlaid: When the it's on overlaying mode, assign `true` for this parameter. The default value is `false`.
        open func updateStyles(overlaid: Bool = false) {
            // Set up overlay status before calling `updateStyles(theme:)`
            if let channelInfoView = self.channelInfoView as? SBUChannelInfoHeaderView {
                channelInfoView.isOverlay = overlaid
            }
            
            self.updateStyles(theme: nil)
        }
        
        // MARK: - Right bar button
        
        /// Updates the right bar button item with operator status of the current user.
        open func updateBarButton(isOperator: Bool) {
            self.rightBarButton = isOperator
            ? self.defaultRightBarButton
            : self.defaultParticipantListBarButton
            
            self.updateStyles(theme: nil)
        }
        
        // MARK: - SBUChannelInfoHeaderViewDelegate
        open func didSelectChannelInfo() {
            SBULog.info("didSelectChannelInfo")
            guard let rightBarButton = self.rightBarButton else { return }
            self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
        }
        
        open func didSelectChannelParticipants() {
            SBULog.info("didSelectChannelParticipants")
            guard let rightBarButton = self.rightBarButton else { return }
            self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            if let rightBarButton = self.rightBarButton {
                self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
