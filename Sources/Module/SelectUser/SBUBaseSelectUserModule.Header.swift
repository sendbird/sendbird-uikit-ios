//
//  SBUBaseSelectUserModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in user selection module.
public protocol SBUBaseSelectUserModuleHeaderDelegate: SBUCommonDelegate { }

/// Methods to get data source for header component in a user selection.
public protocol SBUBaseSelectUserModuleHeaderDataSource: AnyObject {
    /// Ask to data source to return selected users for `SBUBaseSelectUserModule.Header`
    /// - Returns: The set of selected `SBUUser` objects.
    func selectedUsersForBaseSelectUserModule(_ headerComponent: SBUBaseSelectUserModule.Header) -> Set<SBUUser>?
}

extension SBUBaseSelectUserModule {
    
    /// A module component that represent the header of `SBUBaseSelectUserModule`.
    @objc(SBUBaseSelectUserModuleHeader)
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
                if let leftBarButton = self.leftBarButton {
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
                if let rightBarButton = self.rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                didUpdateRightItem()
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateLeftItem`is called.
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet {
                self.didUpdateLeftItem()
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `didUpdateRightItem`is called.
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet { didUpdateRightItem() }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        public var theme: SBUUserListTheme?
        
        public var componentTheme: SBUComponentTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUNavigationTitleView? = self.createDefaultTitleView()
        func createDefaultTitleView() -> SBUNavigationTitleView? { return nil }
        
        lazy var defaultLeftBarButton: UIBarButtonItem? = self.createDefaultLeftBarButton()
        func createDefaultLeftBarButton() -> UIBarButtonItem? { return nil }
        
        lazy var defaultRightBarButton: UIBarButtonItem? = self.createDefaultRightBarButton()
        func createDefaultRightBarButton() -> UIBarButtonItem? { return nil }
        
        // MARK: - Logic properties (Public)
        public var selectedUserList: Set<SBUUser>? {
            self.baseDataSource?.selectedUsersForBaseSelectUserModule(self)
        }
        
        // MARK: - Logic properties (private)
        weak var baseDelegate: SBUBaseSelectUserModuleHeaderDelegate?
        weak var baseDataSource: SBUBaseSelectUserModuleHeaderDataSource?
        
        // MARK: - Life cycle
        deinit {
            SBULog.info("")
        }
        
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
                if let defaultButton = self.defaultLeftBarButton {
                    self.leftBarButtons = [defaultButton]
                }
            }
            if self.rightBarButtons == nil {
                if let defaultButton = self.defaultRightBarButton {
                    self.rightBarButtons = [defaultButton]
                }
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        open func setupStyles(theme: SBUUserListTheme? = nil, componentTheme: SBUComponentTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let componentTheme = componentTheme {
                self.componentTheme = componentTheme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                if let componentTheme = self.componentTheme {
                    titleView.theme = componentTheme
                }
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
            self.leftBarButtons?.forEach { $0.tintColor = self.theme?.leftBarButtonTintColor }
            
            self.updateRightBarButton()
        }

        // MARK: - Common
        /// Updates right bar button based on `selectedUserList.count`. The defaults action is updating the title of the button and the tint color with `rightBarButtonTintColor` and `rightBarButtonSelectedTintColor` from the `theme`.
        open func updateRightBarButton() {
            let isEnable = (self.selectedUserList?.count ?? 0) > 0
            let tintColor = isEnable
            ? self.theme?.rightBarButtonSelectedTintColor
            : self.theme?.rightBarButtonTintColor
            
            self.rightBarButton?.tintColor = tintColor
            self.rightBarButtons?.forEach { $0.tintColor = tintColor }
        }
        
        // MARK: - Attach update delegate on view
        /// Called when the `titleView` was updated.
        func didUpdateTitleView() { }
        /// Called when the `leftBarButton` was updated.
        func didUpdateLeftItem() { }
        /// Called when the `rightBarButton` was updated.
        func didUpdateRightItem() { }
        /// Called when the `leftBarButtons` was updated.
        /// - Since: 3.28.0
        func didUpdateLeftItems() { }
        /// Called when the `rightBarButtons` was updated.
        /// - Since: 3.28.0
        func didUpdateRightItems() { }
        
        // MARK: - Actions
        /// The action of the `leftBarButton`.
        open func onTapLeftBarButton() { }
        /// The action of the `rightBarButton`.
        open func onTapRightBarButton() { }
    }
}
