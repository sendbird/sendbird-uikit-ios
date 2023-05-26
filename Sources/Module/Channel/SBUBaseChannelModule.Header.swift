//
//  SBUBaseChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component.
public protocol SBUBaseChannelModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `titleView` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - titleView: Selected `titleView` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUBaseChannelModule {
    
    /// A module component that represent the header of `SBUBaseChannelModule`.
    @objcMembers open class Header: UIView {
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateTitleView: self.titleView)
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateLeftItem: self.leftBarButton)
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateRightItem: self.rightBarButton)
            }
        }
        
        public var titleSpacer = UIView()
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUChannelTitleView = {
            var titleView = SBUChannelTitleView()
            return titleView
        }()
        
        lazy var defaultLeftBarButton: UIBarButtonItem = {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }()
        
        lazy var defaultRightBarButton: UIBarButtonItem = {
            let settingsButton = UIBarButtonItem(
                image: SBUIconSetType.iconInfo.image(
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            return settingsButton
        }()
        
        lazy var defaultEmptyBarButton: UIBarButtonItem = {
            let backButton = UIBarButtonItem(
                image: SBUIconSetType.iconEmpty.image(
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                style: .plain,
                target: self,
                action: nil
            )
            return backButton
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the base of delegate of the header component. The base delegate must adopt the `SBUBaseChannelModuleHeaderDelegate`.
        public weak var baseDelegate: SBUBaseChannelModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUBaseChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUBaseChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info(#function)
        }
        
        /// Set values of the views in the header component when it needs.
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
            self.titleSpacer.sbu_constraint_greaterThan(
                width: self.bounds.width,
                priority: .defaultLow
            )
        }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUChannelTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = self.theme?.rightBarButtonTintColor
        }
        
        /// Updates styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func updateStyles(theme: SBUChannelTheme? = nil) {
            self.setupStyles(theme: theme)
        }
        
        // MARK: - Actions
        
        /// The action of `leftBarButton`. It calls `baseChannelModule(_:didTapLeftItem:)` when it's tapped
        open func onTapLeftBarButton() { }
        
        /// The action of `rightBarButton`. It calls `baseChannelModule(_:didTapRightItem:)` when it's tapped
        open func onTapRightBarButton() { }
        
    }
}
