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

/// Event methods for the views updates and performing actions from the header component in group channel list module.
public protocol SBUGroupChannelListModuleHeaderDelegate: SBUBaseChannelListModuleHeaderDelegate {}

extension SBUGroupChannelListModule {
    /// A module component that represents the header of `SBUGroupChannelListModule`.
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
            SBUModuleSet.GroupChannelListModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
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
