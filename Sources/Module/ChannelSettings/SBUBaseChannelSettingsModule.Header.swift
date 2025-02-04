//
//  SBUBaseChannelSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name

/// Event methods for the views updates and performing actions from the header component in channel settings module.
public protocol SBUBaseChannelSettingsModuleHeaderDelegate: SBUCommonDelegate { }

/// Methods to get data source for header component in a channel setting.
public protocol SBUBaseChannelSettingsModuleHeaderDataSource: AnyObject { }

// swiftlint:enable type_name

extension SBUBaseChannelSettingsModule {
    
    /// A module component that represent the header of `SBUBaseChannelSettingsModule`.
    @objc(SBUBaseChannelSettingsModuleHeader)
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// The default view type is ``SBUNavigationTitleView``. 
        /// - NOTE: When the value is updated, `didUpdateTitleView`is called.
        public var titleView: UIView? {
            didSet { self.didUpdateTitleView() }
        }
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateLeftItem`is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                if let leftBarButton = leftBarButton {
                    self.leftBarButtons = [leftBarButton]
                } else {
                    self.leftBarButtons = nil
                }
                self.didUpdateLeftItem()
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateRightItem`is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                if let rightBarButton = rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                self.didUpdateRightItem()
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateRightItem`is called.
        /// - Since: 3.28.0
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet { self.didUpdateLeftItems() }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateRightItem`is called.
        /// - Since: 3.28.0
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet { self.didUpdateRightItems() }
        }

        /// The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        public var theme: SBUChannelSettingsTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUNavigationTitleView? = self.createDefaultTitleView()
        lazy var defaultLeftBarButton: SBUBarButtonItem = self.createDefaultLeftButton()
        lazy var defaultRightBarButton: SBUBarButtonItem = self.createDefaultRightButton()
        
        func createDefaultTitleView() -> SBUNavigationTitleView? { return nil }
        func createDefaultLeftButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        func createDefaultRightButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        
        // MARK: - Logic properties (Public)
        weak var baseDelegate: SBUBaseChannelSettingsModuleHeaderDelegate?
        weak var baseDataSource: SBUBaseChannelSettingsModuleHeaderDataSource?
        
        // MARK: - LifeCycle
        
        /// Set values of the views in the header component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            if self.leftBarButton == nil && self.leftBarButtons == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
            if self.rightBarButton == nil && self.rightBarButtons == nil {
                self.rightBarButton = self.defaultRightBarButton
            }
            
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftBarButton]
            }
            if self.rightBarButtons == nil {
                self.rightBarButtons = [self.defaultRightBarButton]
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        open func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = theme?.rightBarButtonTintColor
            
            self.leftBarButtons?.forEach { $0.tintColor = theme?.leftBarButtonTintColor }
            self.rightBarButtons?.forEach { $0.tintColor = theme?.rightBarButtonTintColor }
        }
        
        // MARK: - Attach update delegate on view
        
        /// Called when the `titleView` was updated.
        func didUpdateTitleView() { }
        /// Called when the `leftBarButton` was updated.
        func didUpdateLeftItem() { }
        /// Called when the `rightBarButton` was updated.
        func didUpdateRightItem() { }
        /// Called when the `leftBarButtons` was updated.
        func didUpdateLeftItems() { }
        /// Called when the `rightBarButtons` was updated.
        func didUpdateRightItems() { }
        
        // MARK: - Actions
        /// Called when the `leftBarButton` was tapped.
        open func onTapLeftBarButton() { }
        /// Called when the `rightBarButton` was tapped.
        open func onTapRightBarButton() { }
    }
}
