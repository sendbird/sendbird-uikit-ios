//
//  SBUGroupChannelPushSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/05/22.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

// MARK: - Delegate

/// Event methods for the views updates and performing actions from the header component in notification settings module.
public protocol SBUGroupChannelPushSettingsModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelPushSettingsModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func groupChannelPushSettingsModule(
        _ headerComponent: SBUGroupChannelPushSettingsModule.Header,
        didUpdateTitleView titleView: UIView?
    )
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelPushSettingsModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func groupChannelPushSettingsModule(
        _ headerComponent: SBUGroupChannelPushSettingsModule.Header,
        didUpdateLeftItem leftItem: UIBarButtonItem?
    )
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelPushSettingsModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func groupChannelPushSettingsModule(
        _ headerComponent: SBUGroupChannelPushSettingsModule.Header,
        didUpdateRightItem rightItem: UIBarButtonItem?
    )
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUGroupChannelPushSettingsModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func groupChannelPushSettingsModule(
        _ headerComponent: SBUGroupChannelPushSettingsModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    )
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUGroupChannelPushSettingsModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func groupChannelPushSettingsModule(
        _ headerComponent: SBUGroupChannelPushSettingsModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    )
}

// MARK: - Header

extension SBUGroupChannelPushSettingsModule {
    /// A module component that represent the header of `SBUGroupChannelPushSettingsModule`.
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `groupChannelPushSettingsModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet {
                self.delegate?.groupChannelPushSettingsModule(
                    self,
                    didUpdateTitleView: self.titleView
                )
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `groupChannelPushSettingsModule(_:didUpdateLeftItem:)` delegate function is called.
        /// and when the value is tapped, `groupChannelPushSettingsModule(_:didTapLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                self.delegate?.groupChannelPushSettingsModule(
                    self,
                    didUpdateLeftItem: self.leftBarButton
                )
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `groupChannelPushSettingsModule(_:didUpdateRightItem:)` delegate function is called.
        /// and when the value is tapped, `groupChannelPushSettingsModule(_:didTapRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                self.delegate?.groupChannelPushSettingsModule(
                    self,
                    didUpdateRightItem: self.rightBarButton
                )
            }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        public var theme: SBUChannelSettingsTheme?
        
        /// The object that is used as the component theme of the header component. The theme must adopt the `SBUComponentTheme` class.
        public var componentTheme: SBUComponentTheme?
        
        // MARK: - UI properties (Private)
        private var defaultTitleView: SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.ChannelPushSettings_Header_Title
            titleView.textAlignment = .center
            return titleView
        }
        
        private var defaultLeftBarButton: UIBarButtonItem {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }
        
        // MARK: - Logic properties (Public)
        
        /// The object that acts as the delegate of the header component.
        ///
        /// The delegate must adopt the `SBUGroupChannelPushSettingsModuleHeaderDelegate`.
        public weak var delegate: SBUGroupChannelPushSettingsModuleHeaderDelegate?
        
        // MARK: - Life cycle
        @available(*, unavailable, renamed: "SBUGroupChannelPushSettingsModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUGroupChannelPushSettingsModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelPushSettingsModuleHeaderDelegate` type listener
        ///   - theme: `SBUChannelSettingsTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func configure(
            delegate: SBUGroupChannelPushSettingsModuleHeaderDelegate,
            theme: SBUChannelSettingsTheme,
            componentTheme: SBUComponentTheme
        ) {
            self.delegate = delegate
            self.theme = theme
            self.componentTheme = componentTheme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        /// ```swift
        /// // Override guidance
        /// override func setupViews() {
        ///     self.titleView = myTitleView
        ///     self.leftBarButton = myLeftBarButton
        ///
        ///     super.setupViews()
        /// }
        /// ```
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            if self.leftBarButton == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() {
            
        }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        ///   - componentTheme: The object that is used as the theme of the header component. The theme must adopt the `SBUComponentTheme` class.
        open func setupStyles(
            theme: SBUChannelSettingsTheme? = nil,
            componentTheme: SBUComponentTheme? = nil
        ) {
            if let theme = theme {
                self.theme = theme
            }
            if let componentTheme = componentTheme {
                self.componentTheme = componentTheme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = theme?.rightBarButtonTintColor
        }
        
        // MARK: - Actions
        
        /// The action of `leftBarButton`. It calls `groupChannelPushSettingsModule(_:didTapLeftItem:)` when it's tapped
        public func onTapLeftBarButton() {
            if let leftBarButton = leftBarButton {
                self.delegate?.groupChannelPushSettingsModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of `rightBarButton`. It calls `groupChannelPushSettingsModule(_:didTapRightItem:)` when it's tapped
        public func onTapRightBarButton() {
            if let rightBarButton = rightBarButton {
                self.delegate?.groupChannelPushSettingsModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
