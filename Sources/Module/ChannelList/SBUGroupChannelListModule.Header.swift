//
//  SBUGroupChannelListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/08/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK


/// Event methods for the views updates and performing actions from the header component in group channel list module.
public protocol SBUGroupChannelListModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelListModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelListModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelListModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelListModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelListModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func channelListModule(_ headerComponent: SBUGroupChannelListModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}


extension SBUGroupChannelListModule {
    /// A module component that represents the header of `SBUGroupChannelListModule`.
    @objcMembers open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? = nil {
            didSet { self.delegate?.channelListModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateLeftItem:)` delegate function is called
        public var leftBarButton: UIBarButtonItem? = nil {
            didSet { self.delegate?.channelListModule(self, didUpdateLeftItem: self.leftBarButton) }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? = nil {
            didSet { self.delegate?.channelListModule(self, didUpdateRightItem: self.rightBarButton) }
        }
        
        /// The object that is used as the theme of the header  component. The theme must adopt the `SBUChannelListTheme` class.
        public var theme: SBUChannelListTheme? = nil
        
        
        // MARK: - UI properties (Private)
        private func defaultTitleView() ->  SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.ChannelList_Header_Title
            titleView.textAlignment = .center
            return titleView
        }
        
        private func defaultLeftButton() -> UIBarButtonItem {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }
        
        private func defaultRightButton() -> UIBarButtonItem {
            let createChannelButton = UIBarButtonItem(
                image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            return createChannelButton
        }
        
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelListModuleHeaderDelegate`.
        public weak var delegate: SBUGroupChannelListModuleHeaderDelegate? = nil
        
        
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
        ///   - theme: `SBUChannelListTheme` object
        open func configure(delegate: SBUGroupChannelListModuleHeaderDelegate,
                            theme: SBUChannelListTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView()
            }
            if self.leftBarButton == nil {
                self.leftBarButton = self.defaultLeftButton()
            }
            if self.rightBarButton == nil {
                self.rightBarButton = self.defaultRightButton()
            }
        }

        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets up style with theme. If the `theme` is `nil`, it uses the stored theme.
        /// - Parameter theme: `SBUChannelListTheme` object
        open func setupStyles(theme: SBUChannelListTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = self.theme?.rightBarButtonTintColor
        }
        
        
        // MARK: - Actions
        /// The action of `leftBarButton`. It calls `channelListModule(_:didTapLeftItem:)` when it's tapped
        @objc open func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.channelListModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of `rightBarButton`. It calls `channelListModule(_:didTapRightItem:)` when it's tapped
        @objc open func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.channelListModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
