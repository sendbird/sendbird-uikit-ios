//
//  SBUMemberListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


/// Event methods for the views updates and performing actions from the header component in member list module.
public protocol SBUMemberListModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUMemberListModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func memberListModule(_ headerComponent: SBUMemberListModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUMemberListModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func memberListModule(_ headerComponent: SBUMemberListModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUMemberListModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func memberListModule(_ headerComponent: SBUMemberListModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUMemberListModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func memberListModule(_ headerComponent: SBUMemberListModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUMemberListModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func memberListModule(_ headerComponent: SBUMemberListModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}


extension SBUMemberListModule {
    
    /// A module component that represent the header of `SBUMemberListModule`.
    @objcMembers open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// - NOTE: When the value is updated, `memberListModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? = nil {
            didSet { self.delegate?.memberListModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `memberListModule(_:didUpdateLeftItem:)` delegate function is called.
        /// and when the value is tapped, `memberListModule(_:didTapLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? = nil {
            didSet { self.delegate?.memberListModule(self, didUpdateLeftItem: self.leftBarButton) }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `memberListModule(_:didUpdateRightItem:)` delegate function is called.
        /// and when the value is tapped, `memberListModule(_:didTapRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? = nil {
            didSet { self.delegate?.memberListModule(self, didUpdateRightItem: self.rightBarButton) }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        public var theme: SBUUserListTheme? = nil
        
        /// The object that is used as the component theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        public var componentTheme: SBUComponentTheme? = nil
        
        
        // MARK: - UI properties (Private)
        private func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            switch self.memberListType {
            case .channelMembers:
                titleView.text = SBUStringSet.MemberList_Title_Members
            case .operators:
                titleView.text = SBUStringSet.MemberList_Title_Operators
            case .mutedMembers:
                titleView.text = SBUStringSet.MemberList_Title_Muted_Members
            case .bannedMembers:
                titleView.text = SBUStringSet.MemberList_Title_Banned_Members
            case .participants:
                titleView.text = SBUStringSet.MemberList_Title_Participants
            default:
                break
            }
            
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
            guard self.memberListType == .channelMembers ||
                    self.memberListType == .operators else { return UIBarButtonItem() }
            
            let addButton = UIBarButtonItem(
                image: SBUIconSetType.iconPlus.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            return addButton
        }
        
        
        // MARK: - Logic properties (Public)

        /// The object that acts as the delegate of the header component.
        ///
        /// The delegate must adopt the `SBUMemberListModuleHeaderDelegate`.
        public weak var delegate: SBUMemberListModuleHeaderDelegate? = nil
        
        /// The object that the type of member list.
        public private(set) var memberListType: ChannelMemberListType = .none
        
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUMemberListModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUMemberListModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUMemberListModuleHeaderDelegate` type listener
        ///   - memberListType: MemberList Type
        ///   - theme: `SBUUserListTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func configure(delegate: SBUMemberListModuleHeaderDelegate,
                            memberListType: ChannelMemberListType,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
            self.delegate = delegate
            
            self.memberListType = memberListType
            
            self.theme = theme
            self.componentTheme = componentTheme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
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
        
        /// Sets styles of the views in the header component with the `theme` and `componentTheme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        ///   - componentTheme: The object that is used as the component theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        open func setupStyles(theme: SBUUserListTheme? = nil,
                              componentTheme: SBUComponentTheme? = nil) {
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
            self.rightBarButton?.tintColor = theme?.rightBarButtonSelectedTintColor
        }
        
        
        // MARK: - Actions
        
        /// The action of `leftBarButton`. It calls `memberListModule(_:didTapLeftItem:)` when it's tapped
        @objc public func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.memberListModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of `rightBarButton`. It calls `memberListModule(_:didTapRightItem:)` when it's tapped
        @objc public func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.memberListModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
