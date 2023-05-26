//
//  SBUModerationsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/01/04.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in moderation module.
public protocol SBUModerationsModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUModerationsModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func moderationsModule(_ headerComponent: SBUModerationsModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUModerationsModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func moderationsModule(_ headerComponent: SBUModerationsModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUModerationsModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func moderationsModule(_ headerComponent: SBUModerationsModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUModerationsModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func moderationsModule(_ headerComponent: SBUModerationsModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
}

extension SBUModerationsModule {
    
    /// A module component that represent the header of `SBUModerationsModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `moderationsModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.delegate?.moderationsModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `moderationsModule(_:didUpdateLeftItem:)` delegate function is called.
        /// and when the value is tapped, `moderationsModule(_:didTapLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet { self.delegate?.moderationsModule(self, didUpdateLeftItem: self.leftBarButton) }
        }

        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `moderationsModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet { self.delegate?.moderationsModule(self, didUpdateRightItem: self.rightBarButton) }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        public var theme: SBUChannelSettingsTheme?
        
        // MARK: - UI properties (Private)
        private func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.ChannelSettings_Moderations
            titleView.textAlignment = .left
            
            return titleView
        }
        
        private func defaultLeftBarButton() -> UIBarButtonItem {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }
        
        // MARK: - Logic properties (Public)
        
        /// The object that acts as the delegate of the header component.
        ///
        /// The delegate must adopt the `SBUModerationsModuleHeaderDelegate`.
        public weak var delegate: SBUModerationsModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUModerationsModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUModerationsModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUModerationsModuleHeaderDelegate` type listener
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUModerationsModuleHeaderDelegate,
                            theme: SBUChannelSettingsTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        /// - NOTE: If you want to implement `rightBarButton`, set your custom button here.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView()
            }
            if self.leftBarButton == nil {
                self.leftBarButton = self.defaultLeftBarButton()
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelSettingsTheme` class.
        open func setupStyles(theme: SBUChannelSettingsTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = theme?.leftBarButtonTintColor
        }
        
        // MARK: - Actions
        
        /// The action of `leftBarButton`. It calls `moderationsModule(_:didTapLeftItem:)` when it's tapped
        public func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.moderationsModule(self, didTapLeftItem: leftBarButton)
            }
        }
    }
}
