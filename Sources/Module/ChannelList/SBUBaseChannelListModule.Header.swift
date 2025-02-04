//
//  SBUBaseChannelListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in channel list module.
public protocol SBUBaseChannelListModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButtons` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - leftItems: The updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - rightItems: The updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUBaseChannelListModuleHeaderDelegate {
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) {}
    
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
}

extension SBUBaseChannelListModule {
    /// A module component that represents the header of `SBUBaseChannelListModule`.
    @objc(SBUBaseChannelListModuleHeader)
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// The default view type is ``SBUNavigationTitleView``.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.didUpdateTitleView() }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateLeftItem:)` delegate function is called
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                if let leftBarButton = self.leftBarButton {
                    self.leftBarButtons = [leftBarButton]
                } else {
                    self.leftBarButtons = nil
                }
                
                self.didUpdateLeftItem()
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                if let rightBarButton = self.rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                
                self.didUpdateRightItem()
            }
        }
        
        /// A view that represents the left `[UIBarButtonItem]` in the navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateLeftItems:)` delegate function is called.
        /// - Since: 3.28.0
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet { self.didUpdateLeftItems() }
        }
        
        /// A view that represents the right `[UIBarButtonItem]` in the navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateRightItems:)` delegate function is called.
        /// - Since: 3.28.0
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet { self.didUpdateRightItems() }
        }
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUNavigationTitleView = self.createDefaultTitleView()
        lazy var defaultLeftButton: SBUBarButtonItem = self.createDefaultLeftButton()
        lazy var defaultRightBarButton: SBUBarButtonItem = self.createDefaultRightButton()
        
        func createDefaultTitleView() -> SBUNavigationTitleView { SBUNavigationTitleView() }
        func createDefaultLeftButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        func createDefaultRightButton() -> SBUBarButtonItem { SBUBarButtonItem() }
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUBaseChannelListModuleHeaderDelegate`.
        public weak var baseDelegate: SBUBaseChannelListModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            if self.leftBarButton == nil && self.leftBarButtons == nil {
                self.leftBarButton = self.defaultLeftButton
            }
            
            if self.rightBarButton == nil && self.rightBarButtons == nil {
                self.rightBarButton = self.defaultRightBarButton
            }
            
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftButton]
            }
            
            if self.rightBarButtons == nil {
                self.rightBarButtons = [self.defaultRightBarButton]
            }
        }

        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        // MARK: - Attach update delegate on view
        
        /// Called when the `titleView` was updated.
        func didUpdateTitleView() {
            self.baseDelegate?.baseChannelListModule(self, didUpdateTitleView: self.titleView)
        }
        /// Called when the `leftBarButton` was updated.
        func didUpdateLeftItem() {
            self.baseDelegate?.baseChannelListModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        /// Called when the `rightBarButton` was updated.
        func didUpdateRightItem() {
            self.baseDelegate?.baseChannelListModule(self, didUpdateRightItem: self.rightBarButton)
        }
        /// Called when the `leftBarButtons` was updated.
        func didUpdateLeftItems() {
            self.baseDelegate?.baseChannelListModule(self, didUpdateLeftItems: self.leftBarButtons)
        }
        /// Called when the `rightBarButtons` was updated.
        func didUpdateRightItems() {
            self.baseDelegate?.baseChannelListModule(self, didUpdateRightItems: self.rightBarButtons)
        }
        
        // MARK: - Actions
        /// Called when the `leftBarButton` was tapped.
        open func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftButton) {
                self.baseDelegate?.baseChannelListModule(self, didTapLeftItem: self.defaultLeftButton)
            } else if let leftBarButton = self.leftBarButton {
                self.baseDelegate?.baseChannelListModule(self, didTapLeftItem: leftBarButton)
            }
        }
        /// Called when the `rightBarButton` was tapped.
        open func onTapRightBarButton() {
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.baseDelegate?.baseChannelListModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.baseDelegate?.baseChannelListModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
