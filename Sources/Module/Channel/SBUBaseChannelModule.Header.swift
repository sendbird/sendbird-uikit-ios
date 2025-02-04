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
    
    /// Called when `leftBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - rightItem: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelModule.Header` object
    ///   - rightItem: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
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

extension SBUBaseChannelModuleHeaderDelegate {
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) {}
    
    func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
}

extension SBUBaseChannelModule {
    
    /// A module component that represent the header of `SBUBaseChannelModule`.
    @objc(SBUBaseChannelModuleHeader)
    @objcMembers
    open class Header: UIView {
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// For ``SBUBaseChannelModule.Header`` and its subclasses, the default view type is ``SBUChannelTitleView``.
        /// For ``SBUMessageThreadModule.Header``, the default view type is ``SBUMessageThreadTitleView``.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateTitleView: self.titleView)
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// The default view type is ``UIBarButtonItem``.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                if let leftBarButton = self.leftBarButton {
                    self.leftBarButtons = [leftBarButton]
                } else {
                    self.leftBarButtons = nil
                }
                self.baseDelegate?.baseChannelModule(self, didUpdateLeftItem: self.leftBarButton)
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// For ``SBUOpenChannelModule.Header``, the default view type is ``UIBarButtonItem``.
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                if let rightBarButton = rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                self.baseDelegate?.baseChannelModule(self, didUpdateRightItem: self.rightBarButton)
            }
        }
        
        var internalRightBarButton: SBUItemUsageState<UIBarButtonItem?> = .unused
        
        /// A view that represents left bar items in navigation bar.
        /// - Since: 3.28.0
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateLeftItems:)` delegate function is called.
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateLeftItems: self.leftBarButtons)
            }
        }
        
        /// A view that represents right bar items in navigation bar.
        /// - Since: 3.28.0
        /// - NOTE: When the value is updated, `baseChannelModule(_:didUpdateRightItems:)` delegate function is called.
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet {
                self.baseDelegate?.baseChannelModule(self, didUpdateRightItems: self.rightBarButtons)
            }
        }
        
//        var internalRightBarButtons: SBUItemUsageState<[UIBarButtonItem]?> = .unused
        
        public var titleSpacer = UIView()
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        public var theme: SBUChannelTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUChannelTitleView = self.createDefaultTitleView()
        lazy var defaultLeftBarButton: SBUBarButtonItem = self.createDefaultLeftButton()
        lazy var defaultRightBarButton: SBUBarButtonItem = self.createDefaultRightButton()
        
        func createDefaultTitleView() -> SBUChannelTitleView { SBUChannelTitleView() }
        func createDefaultLeftButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        func createDefaultRightButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        
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
            
            if self.leftBarButton == nil && self.leftBarButtons == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
            
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftBarButton]
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
            
            self.leftBarButtons?.forEach({ $0.tintColor = self.theme?.leftBarButtonTintColor })
            self.rightBarButtons?.forEach({ $0.tintColor = self.theme?.rightBarButtonTintColor })
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
