//
//  SBUCreateOpenChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/08/24.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in channel creating module.
public protocol SBUCreateOpenChannelModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateOpenChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateOpenChannelModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateOpenChannelModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateOpenChannelModule.Header` object
    ///   - leftItems: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateOpenChannelModule.Header` object
    ///   - rightItems: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUCreateOpenChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUCreateOpenChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUCreateOpenChannelModuleHeaderDelegate {
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) { }
    func createOpenChannelModule(_ headerComponent: SBUCreateOpenChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) { }
}

extension SBUCreateOpenChannelModule {
    
    /// A module component that represent the header of `SBUCreateOpenChannelModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objc(SBUCreateOpenChannelModuleHeader)
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// A view that represents a title in navigation bar.
        /// The default view type is ``SBUNavigationTitleView``.
        /// - NOTE: When the value is updated, `createOpenChannelModule(_:didUpdateTitleView:)` delegate function is called.
        public var titleView: UIView? {
            didSet { self.delegate?.createOpenChannelModule(self, didUpdateTitleView: self.titleView) }
        }
        
        /// A view that represents a left `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `createOpenChannelModule(_:didUpdateLeftItem:)` delegate function is called.
        /// and when the value is tapped, `createOpenChannelModule(_:didTapLeftItem:)` delegate function is called.
        public var leftBarButton: UIBarButtonItem? {
            didSet {
                if let leftBarButton = self.leftBarButton {
                    self.leftBarButtons = [leftBarButton]
                } else {
                    self.leftBarButtons = nil
                }
                self.delegate?.createOpenChannelModule(self, didUpdateLeftItem: self.leftBarButton)
            }
        }

        /// A view that represents a right `UIBarButtonItem` in navigation bar.
        /// - NOTE: When the value is updated, `createOpenChannelModule(_:didUpdateRightItem:)` delegate function is called.
        public var rightBarButton: UIBarButtonItem? {
            didSet {
                if let rightBarButton = self.rightBarButton {
                    self.rightBarButtons = [rightBarButton]
                } else {
                    self.rightBarButtons = nil
                }
                self.delegate?.createOpenChannelModule(self, didUpdateRightItem: self.rightBarButton)
            }
        }
        
        /// A view that represents the left `UIBarButtonItem`s in navigation bar.
        /// - NOTE: When the value is updated, `createOpenChannelModule(_:didUpdateLeftItems:)` delegate function is called.
        /// and when the value is tapped, `createOpenChannelModule(_:didTapLeftItems:)` delegate function is called.
        /// - Since: 3.28.0
        public var leftBarButtons: [UIBarButtonItem]? {
            didSet { self.delegate?.createOpenChannelModule(self, didUpdateLeftItems: self.leftBarButtons) }
        }

        /// A view that represents the right `UIBarButtonItem`s in navigation bar.
        /// - NOTE: When the value is updated, `createOpenChannelModule(_:didUpdateRightItems:)` delegate function is called.
        /// - Since: 3.28.0
        public var rightBarButtons: [UIBarButtonItem]? {
            didSet { self.delegate?.createOpenChannelModule(self, didUpdateRightItems: self.rightBarButtons) }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the `SBUCreateOpenChannelTheme` class.
        public var theme: SBUCreateOpenChannelTheme?
        
        // MARK: - UI properties (Private)
        lazy var defaultTitleView: SBUNavigationTitleView = {
            let titleView = SBUModuleSet.CreateOpenChannelModule.HeaderComponent.TitleView.init()
            titleView.configure(title: SBUStringSet.CreateOpenChannel_Header_Title)
            return titleView
        }()
        
        lazy var defaultLeftBarButton: UIBarButtonItem = {
            SBUModuleSet.CreateOpenChannelModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }()
        
        lazy var defaultRightBarButton: UIBarButtonItem = {
            let createChannelButton = SBUModuleSet.CreateOpenChannelModule.HeaderComponent.RightBarButton.init(
                title: SBUStringSet.CreateOpenChannel_Create,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            createChannelButton.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return createChannelButton
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component.
        /// The delegate must adopt the `SBUCreateOpenChannelModuleHeaderDelegate` protocol.
        public weak var delegate: SBUCreateOpenChannelModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUCreateOpenChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUCreateOpenChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUCreateOpenChannelModuleHeaderDelegate` type listener
        ///   - theme: `SBUCreateOpenChannelTheme` object
        open func configure(delegate: SBUCreateOpenChannelModuleHeaderDelegate,
                            theme: SBUCreateOpenChannelTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        /// - NOTE: If you want to implement `rightBarButton`, set your custom button here.
        open func setupViews() {
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            // We are not using `...buttons` in SwiftUI
            #endif
            
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            if self.leftBarButton == nil && self.leftBarButtons == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
            if self.rightBarButton == nil && self.rightBarButtons == nil {
                self.rightBarButton = self.defaultRightBarButton
                self.rightBarButton?.isEnabled = false
            }
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftBarButton]
            }
            if self.rightBarButtons == nil {
                let button = self.defaultRightBarButton
                button.isEnabled = false
                self.rightBarButtons = [button]
            }
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() { }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameters:
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUCreateOpenChannelTheme` class.
        open func setupStyles(theme: SBUCreateOpenChannelTheme? = nil) {
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
        
        // MARK: - Common
        /// Updates right bar button. The defaults action is updating the title of the button and the tint color with `rightBarButtonTintColor` and `rightBarButtonDisabledTintColor` from the `theme`.
        open func enableRightBarButton(_ enabled: Bool) {
            if let rightBarButtons = self.rightBarButtons, rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.defaultRightBarButton.isEnabled = enabled
            } else {
                self.rightBarButton?.isEnabled = enabled
            }
        }
        
        // MARK: - Actions
        /// The action of the leftBarButton. It calls `createOpenChannelModule(_:didTapLeftItem:)` delegate method.
        public func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.delegate?.createOpenChannelModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.createOpenChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of the rightBarButton. It calls `createOpenChannelModule(_:didTapRightItem:)` delegate method.
        public func onTapRightBarButton() {
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.delegate?.createOpenChannelModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.createOpenChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
