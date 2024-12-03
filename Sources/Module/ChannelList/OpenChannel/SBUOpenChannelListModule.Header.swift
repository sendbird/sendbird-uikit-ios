//
//  SBUOpenChannelListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in open channel list module.
public protocol SBUOpenChannelListModuleHeaderDelegate: SBUBaseChannelListModuleHeaderDelegate {}

extension SBUOpenChannelListModule {
    /// A module component that represents the header of `SBUOpenChannelListModule`.
    @objcMembers
    open class Header: SBUBaseChannelListModule.Header {
        
        // MARK: - UI properties (Public)
        /// The object that is used as the theme of the header  component. The theme must adopt the `SBUOpenChannelListTheme` class.
        public var theme: SBUOpenChannelListTheme?
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUOpenChannelListModuleHeaderDelegate`.
        public weak var delegate: SBUOpenChannelListModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUOpenChannelListModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        // MARK: - Methods (Private)
        
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUModuleSet.OpenChannelListModule.HeaderComponent.TitleView.init()
            titleView.configure(title: SBUStringSet.ChannelList_Header_Title)
            return titleView
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelListModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelListModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUOpenChannelListModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUOpenChannelListModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelListModuleHeaderDelegate` type listener
        ///   - theme: `SBUOpenChannelListTheme` object
        open func configure(delegate: SBUOpenChannelListModuleHeaderDelegate,
                            theme: SBUOpenChannelListTheme) {
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
            super.setupViews()
        }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUOpenChannelListTheme` object
        open func setupStyles(theme: SBUOpenChannelListTheme? = nil) {
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
