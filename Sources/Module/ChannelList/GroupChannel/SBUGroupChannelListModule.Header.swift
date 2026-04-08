//
//  SBUGroupChannelListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/08/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SwiftUI
import SendbirdChatSDK

/// Represents the type of group channel to create from the channel list.
/// - Since: 3.34.0
public enum SBUCreateGroupChannelType {
    /// A standard group channel.
    case group
    /// A super group channel that supports a large number of members.
    case superGroup
    /// A broadcast channel where only operators can send messages.
    case broadcast
}

/// Event methods for the views updates and performing actions from the header component in group channel list module.
public protocol SBUGroupChannelListModuleHeaderDelegate: SBUBaseChannelListModuleHeaderDelegate {
    /// Method that gets called when user selects a channel type from the create channel context menu.
    /// - Parameters:
    ///   - headerComponent: The header component where the selection was made.
    ///   - type: The type of channel to create.
    /// - Since: 3.34.0
    func groupChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didSelectCreateChannelType type: SBUCreateGroupChannelType
    )
}

extension SBUGroupChannelListModuleHeaderDelegate {
    func groupChannelListModule(
        _ headerComponent: SBUBaseChannelListModule.Header,
        didSelectCreateChannelType type: SBUCreateGroupChannelType
    ) { }
}

extension SBUGroupChannelListModule {
    /// A module component that represents the header of `SBUGroupChannelListModule`.
    @objc(SBUGroupChannelListModuleHeader)
    @objcMembers
    open class Header: SBUBaseChannelListModule.Header {
        
        // MARK: - UI properties (Public)
        /// The object that is used as the theme of the header  component. The theme must adopt the `SBUGroupChannelListTheme` class.
        public var theme: SBUGroupChannelListTheme?
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelListModuleHeaderDelegate`.
        public weak var delegate: SBUGroupChannelListModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUGroupChannelListModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        // MARK: - Methods (Private)
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUModuleSet.GroupChannelListModule.HeaderComponent.TitleView.init()
            titleView.configure(title: SBUStringSet.ChannelList_Header_Title)
            return titleView
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.GroupChannelListModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            let buttonAction: Selector?
            if SendbirdUI.config.common.shouldApplyLiquidGlass {
                buttonAction = nil
            } else {
                buttonAction = #selector(onTapRightBarButton)
            }
            
            return SBUModuleSet.GroupChannelListModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: buttonAction
            )
        }
        
        /// - Since: 3.34.0
        @available(iOS 26, *)
        func makeCreateChannelTypeContextMenu() -> UIMenu? {
            let tintColor = theme?.channelTypeSelectorItemTintColor

            let group = UIAction(
                title: SBUStringSet.ChannelType_GroupChannel,
                image: SBUIconSetType.iconChat.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            ) { _ in
                self.delegate?.groupChannelListModule(self, didSelectCreateChannelType: .group)
            }
            let superGroup = UIAction(
                title: SBUStringSet.ChannelType_SuperGroupChannel,
                image: SBUIconSetType.iconSupergroup.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            ) { _ in
                self.delegate?.groupChannelListModule(self, didSelectCreateChannelType: .superGroup)
            }
            let broadcast = UIAction(
                title: SBUStringSet.ChannelType_BroadcastChannel,
                image: SBUIconSetType.iconBroadcast.image(
                    with: tintColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            ) { _ in
                self.delegate?.groupChannelListModule(self, didSelectCreateChannelType: .broadcast)
            }

            return UIMenu(title: "Channel type", children: [group, superGroup, broadcast])
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUGroupChannelListModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUGroupChannelListModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelListModuleHeaderDelegate` type listener
        ///   - theme: `SBUGroupChannelListTheme` object
        open func configure(delegate: SBUGroupChannelListModuleHeaderDelegate,
                            theme: SBUGroupChannelListTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        open override func setupViews() {
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            // We are not using `...buttons` in SwiftUI
            #endif
            
            // uikit
            super.setupViews()

            if #available(iOS 26, *), SendbirdUI.config.common.shouldApplyLiquidGlass {
                rightBarButton?.menu = self.makeCreateChannelTypeContextMenu()
            }
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUGroupChannelListTheme` object
        open func setupStyles(theme: SBUGroupChannelListTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = self.theme?.rightBarButtonTintColor
            
            self.leftBarButtons?.forEach({ $0.tintColor = self.theme?.leftBarButtonTintColor })
            
            self.rightBarButtons?.forEach({ $0.tintColor = self.theme?.rightBarButtonTintColor })
        }
    }
}
