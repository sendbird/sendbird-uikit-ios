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
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUBaseChannelListModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func baseChannelListModule(_ headerComponent: SBUBaseChannelListModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
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

extension SBUBaseChannelListModule {
    /// A module component that represents the header of `SBUBaseChannelListModule`.
    @objcMembers open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.didUpdateTitleView() }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateLeftItem:)` delegate function is called
        public var leftBarButton: UIBarButtonItem? {
            didSet { self.didUpdateLeftItem() }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `channelListModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet { self.didUpdateRightItem() }
        }
        
        // MARK: - UI properties (Private)
        private func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.ChannelList_Header_Title
            titleView.textAlignment = .center
            return titleView
        }
        
        private func defaultLeftBarButton() -> UIBarButtonItem {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }
        
        private func defaultRightBarButton() -> UIBarButtonItem {
            let createChannelButton = UIBarButtonItem(
                image: SBUIconSetType.iconCreate.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            return createChannelButton
        }
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUBaseChannelListModuleHeaderDelegate`.
        public weak var baseDelegate: SBUBaseChannelListModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        
        /// Set values of the views in the list component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView()
            }
            if self.leftBarButton == nil {
                self.leftBarButton = self.defaultLeftBarButton()
            }
            if self.rightBarButton == nil {
                self.rightBarButton = self.defaultRightBarButton()
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
        
        // MARK: - Actions
        /// Called when the `leftBarButton` was tapped.
        open func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.baseDelegate?.baseChannelListModule(self, didTapLeftItem: leftBarButton)
            }
        }
        /// Called when the `rightBarButton` was tapped.
        open func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.baseDelegate?.baseChannelListModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
