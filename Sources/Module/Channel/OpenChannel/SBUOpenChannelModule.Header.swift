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
    @objc(SBUOpenChannelModuleHeader)
    @objcMembers
    open class Header: SBUBaseChannelModule.Header, SBUChannelInfoHeaderViewDelegate {
        
        /// A view that shows the information of the open channel such as a cover image, a channel name and a description.
        public lazy var channelInfoView: UIView = SBUChannelInfoHeaderView(delegate: self)
        
        /// A property to hide `channelInfoView`.
        public var hidesChannelInfoView: Bool = false {
            willSet { self.channelInfoView.isHidden = newValue }
        }
        
        public var overlaysChannelInfoView: Bool = false {
            willSet { self.overlaysChannelInfoView = newValue }
        }
        
        lazy var defaultRightBarButtons: [UIBarButtonItem] = {
            [self.defaultRightBarButton]
        }()
        
        lazy var defaultParticipantListBarButton = UIBarButtonItem(
            image: SBUIconSetType.iconMembers.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onTapRightBarButton)
        )
        
        lazy var defaultParticipantListBarButtons = [UIBarButtonItem(
            image: SBUIconSetType.iconMembers.image(to: SBUIconSetType.Metric.defaultIconSize),
            style: .plain,
            target: self,
            action: #selector(onTapRightBarButton)
        )]
        
        override public var rightBarButton: UIBarButtonItem? {
            get { self.internalRightBarButton.item ?? nil }
            
            set {
                self.internalRightBarButton = .init(with: newValue, defaultValue: defaultRightBarButton)
                self.internalRightBarButtons = .unused
                
                self.baseDelegate?.baseChannelModule(self, didUpdateRightItem: self.rightBarButton)
            }
        }
        
        /// A view that represents right bar items in navigation bar.
        /// - Since: 3.28.0
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateRightItems:)` delegate function is called.
        override public var rightBarButtons: [UIBarButtonItem]? {
            get { self.internalRightBarButtons.item ?? nil }
            
            set {
                self.internalRightBarButtons = .init(
                    with: newValue,
                    defaultValue: self.defaultRightBarButtons
                )
                self.internalRightBarButton = .unused
                
                self.baseDelegate?.baseChannelModule(self, didUpdateRightItems: self.rightBarButtons)
            }
        }
        
        var internalRightBarButtons: SBUItemUsageState<[UIBarButtonItem]?> = .unused
        
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
        
        // MARK: UI Properties (private)
        override func createDefaultTitleView() -> SBUChannelTitleView {
            SBUModuleSet.OpenChannelModule.HeaderComponent.TitleView.init()
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconInfo.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
        }
        
        // MARK: - LifeCycle
        open override func setupViews() {
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            #endif
            super.setupViews()

            if self.rightBarButton == nil && self.rightBarButtons == nil {
                self.internalRightBarButton = .usingDefault(nil)
            }
            
            if self.rightBarButtons == nil {
                self.internalRightBarButtons = .usingDefault(nil)
            }
            
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
            
            self.leftBarButtons?.forEach({ $0.tintColor = self.theme?.leftBarButtonTintColor })
            self.rightBarButtons?.forEach({ $0.tintColor = self.theme?.rightBarButtonTintColor })
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
        
        /// Updates the right bar button item / items with operator status of the current user.
        open func updateBarButton(isOperator: Bool) {
            /// NOTE:
            /// `internalRightBarButton` should be updated before `internalRightBarButtons` for backward compatibility.
            if internalRightBarButton.isUsingDefault {
                self.rightBarButton = isOperator
                ? self.defaultRightBarButton
                : self.defaultParticipantListBarButton
            }
            
            if internalRightBarButtons.isUsingDefault {
                self.rightBarButtons = isOperator
                ? self.defaultRightBarButtons
                : self.defaultParticipantListBarButtons
            }
            
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
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.baseDelegate?.baseChannelModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            if internalRightBarButtons.isUsingDefault {
                self.delegate?.baseChannelModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
