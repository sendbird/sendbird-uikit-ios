//
//  SBUUserListModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in user list module.
public protocol SBUUserListModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUUserListModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUUserListModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUUserListModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUUserListModule.Header` object
    ///   - leftItems: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUUserListModule.Header` object
    ///   - rightItems: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUUserListModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func userListModule(_ headerComponent: SBUUserListModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUUserListModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func userListModule(_ headerComponent: SBUUserListModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUUserListModuleHeaderDelegate {
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) { }
    func userListModule(_ headerComponent: SBUUserListModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
}

extension SBUUserListModule {
    
    /// A module component that represent the header of `SBUUserListModule`.
    @objc(SBUUserListModuleHeader)
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// The default view type is ``SBUNavigationTitleView``.
        /// - NOTE: When the value is updated, `userListModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.delegate?.userListModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `userListModule(_:didUpdateLeftItem:)` delegate function is called.
        /// and when the value is tapped, `userListModule(_:didTapLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                if let leftBarButton = leftBarButton {
                    self.leftBarButtons = [leftBarButton]
                } else {
                    self.leftBarButtons = nil
                }
                
                self.delegate?.userListModule(self, didUpdateLeftItem: self.leftBarButton)
            }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `userListModule(_:didUpdateRightItem:)` delegate function is called.
        /// and when the value is tapped, `userListModule(_:didTapRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                if let rightBarButton = rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                
                self.delegate?.userListModule(self, didUpdateRightItem: self.rightBarButton)
            }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `userListModule(_:didUpdateLeftItems:)` delegate function is called.
        /// and when the value is tapped, `userListModule(_:didTapLeftItem:)` delegate function is called.
        /// - Since: 3.28.0
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet { self.delegate?.userListModule(self, didUpdateLeftItems: self.leftBarButtons) }
        }
        
        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `userListModule(_:didUpdateRightItems:)` delegate function is called.
        /// and when the value is tapped, `userListModule(_:didTapRightItem:)` delegate function is called.
        /// - Since: 3.28.0
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet { self.delegate?.userListModule(self, didUpdateRightItems: self.rightBarButtons) }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        public var theme: SBUUserListTheme?
        
        /// The object that is used as the component theme of the header component. The theme must adopt the `SBUUserListTheme` class.
        public var componentTheme: SBUComponentTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUNavigationTitleView = {
            var title = ""
            switch self.userListType {
            case .members:
                title = SBUStringSet.UserList_Title_Members
            case .operators:
                title = SBUStringSet.UserList_Title_Operators
            case .muted:
                title = (channelType == .group)
                ? SBUStringSet.UserList_Title_Muted_Members
                : SBUStringSet.UserList_Title_Muted_Participants
            case .banned:
                title = SBUStringSet.UserList_Title_Banned_Users
            case .participants:
                title = SBUStringSet.UserList_Title_Participants
            default:
                break
            }
            
            let titleView = SBUModuleSet.GroupUserListModule.HeaderComponent.TitleView.init()
            titleView.configure(title: title)
            return titleView
        }()
        
        lazy var defaultLeftBarButton: SBUBarButtonItem = {
            let module = self.channelType == .group
            ? SBUModuleSet.GroupUserListModule
            : SBUModuleSet.OpenUserListModule
            
            return module.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }()
        
        lazy var defaultRightBarButton: SBUBarButtonItem = {
            guard self.userListType == .members ||
                    self.userListType == .operators else { return SBUBarButtonItem() }
            
            let module = self.channelType == .group
           ? SBUModuleSet.GroupUserListModule
           : SBUModuleSet.OpenUserListModule

            return module.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconPlus.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
           )
        }()
        
        // MARK: - Logic properties (Public)

        /// The object that acts as the delegate of the header component.
        ///
        /// The delegate must adopt the `SBUUserListModuleHeaderDelegate`.
        public weak var delegate: SBUUserListModuleHeaderDelegate?
        
        /// - Since: 3.1.0
        public var channelType: ChannelType = .group
        
        /// The object that the type of user list.
        public private(set) var userListType: ChannelUserListType = .none
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUUserListModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUUserListModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUUserListModuleHeaderDelegate` type listener
        ///   - userListType: UserList Type
        ///   - channelType: Channel type
        ///   - theme: `SBUUserListTheme` object
        ///   - componentTheme: `SBUComponentTheme` object
        open func configure(delegate: SBUUserListModuleHeaderDelegate,
                            userListType: ChannelUserListType,
                            channelType: ChannelType = .group,
                            theme: SBUUserListTheme,
                            componentTheme: SBUComponentTheme) {
            self.delegate = delegate
            
            self.userListType = userListType
            self.channelType = channelType
            
            self.theme = theme
            self.componentTheme = componentTheme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles(theme: theme, componentTheme: componentTheme)
        }
        
        /// Set values of the views in the header component when it needs.
        open func setupViews() {
            #if SWIFTUI
            self.setupViewsForSwiftUI()
            #endif
            
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
                if let componentTheme = componentTheme {
                    titleView.theme = componentTheme
                }
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = theme?.leftBarButtonTintColor
            self.rightBarButton?.tintColor = theme?.rightBarButtonSelectedTintColor
            
            self.leftBarButtons?.forEach { $0.tintColor = theme?.leftBarButtonTintColor }
            self.rightBarButtons?.forEach { $0.tintColor = theme?.rightBarButtonSelectedTintColor }
        }
        
        // MARK: - Actions
        
        /// The action of `leftBarButton`. It calls `userListModule(_:didTapLeftItem:)` when it's tapped
        public func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.delegate?.userListModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.userListModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of `rightBarButton`. It calls `userListModule(_:didTapRightItem:)` when it's tapped
        public func onTapRightBarButton() {
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.delegate?.userListModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.userListModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}

#if SWIFTUI
extension SBUUserListModule.Header {
    func setupViewsForSwiftUI() {
        switch self.userListType {
        case .none:
            break
        case .members:
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
        case .operators:
            if channelType == .open {
                self.applyViewConverterForOpenOperators(.titleView)
                self.applyViewConverterForOpenOperators(.leftView)
                self.applyViewConverterForOpenOperators(.rightView)
            } else {
                self.applyViewConverterForOperators(.titleView)
                self.applyViewConverterForOperators(.leftView)
                self.applyViewConverterForOperators(.rightView)
            }
        case .muted:
            if channelType == .open {
                self.applyViewConverterForOpenMutedParticipant(.titleView)
                self.applyViewConverterForOpenMutedParticipant(.leftView)
                self.applyViewConverterForOpenMutedParticipant(.rightView)
            } else {
                self.applyViewConverterForMutedMember(.titleView)
                self.applyViewConverterForMutedMember(.leftView)
                self.applyViewConverterForMutedMember(.rightView)
            }
        case .banned:
            if channelType == .open {
                self.applyViewConverterForOpenBannedUser(.titleView)
                self.applyViewConverterForOpenBannedUser(.leftView)
                self.applyViewConverterForOpenBannedUser(.rightView)
            } else {
                self.applyViewConverterForBannedUser(.titleView)
                self.applyViewConverterForBannedUser(.leftView)
                self.applyViewConverterForBannedUser(.rightView)
            }
        case .participants:
            self.applyViewConverterForOpen(.titleView)
            self.applyViewConverterForOpen(.leftView)
            self.applyViewConverterForOpen(.rightView)
        }
    }
}
#endif
