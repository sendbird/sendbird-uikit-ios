//
//  SBUNotificationChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Event methods for the views updates and performing actions from the header component in a notification channel.
public protocol SBUNotificationChannelModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when the value of  ``SBUNotificationChannelModule/Header/titleView`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    )
    
    /// Called when the value of ``SBUNotificationChannelModule/Header/leftBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - leftItems: Updated ``SBUNotificationChannelModule/Header/leftBarButtons``.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]
    )
    
    /// Called when the value of ``SBUNotificationChannelModule/Header/rightBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - rightItems: Updated ``SBUNotificationChannelModule/Header/rightBarButtons``.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]
    )
    
    /// Called when ``SBUNotificationChannelModule/Header/titleView`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - titleView: Selected `titleView` object.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didTapTitleView titleView: UIView?
    )
    
    /// Called when ``SBUNotificationChannelModule/Header/leftBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    )
    
    /// Called when ``SBUNotificationChannelModule/Header/rightBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUNotificationChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func notificationChannelModule(
        _ headerComponent: SBUNotificationChannelModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    )
}

extension SBUNotificationChannelModule {
    /// A module component that represent the header of ``SBUNotificationChannelModule``
    @objcMembers
    open class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// Specifies a custom view of the channel title in the center of the navigation bar of the header component.
        /// - NOTE: When the value is updated, ``SBUNotificationChannelModuleHeaderDelegate/notificationChannelModule(_:didUpdateTitleView:)`` delegate function is called.
        /// - NOTE: To update title text when you using default title view, please calls ``SBUNotificationChannelViewController/updateChannelTitle(_:)`` in ``SBUNotificationChannelViewController``
        public var titleView: UIView? = nil {
            didSet {
                self.delegate?.notificationChannelModule(
                    self,
                    didUpdateTitleView: self.titleView
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the left side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUNotificationChannelModuleHeaderDelegate/notificationChannelModule(_:didUpdateLeftItems:)``  delegate function is called.
        public var leftBarButtons: [UIBarButtonItem] = [] {
            didSet {
                self.delegate?.notificationChannelModule(
                    self,
                    didUpdateLeftItems: self.leftBarButtons
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the right side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUNotificationChannelModuleHeaderDelegate/notificationChannelModule(_:didUpdateRightItems:)`` delegate function is called.
        public var rightBarButtons: [UIBarButtonItem] = [] {
            didSet {
                self.delegate?.notificationChannelModule(
                    self,
                    didUpdateRightItems: self.rightBarButtons
                )
            }
        }
        
        public var titleSpacer = UIView()
        
        /// The object that is used as the theme of the header component. The theme must adopt the ``SBUChannelTheme`` class.
        public var theme: SBUChannelTheme? = nil
        
        // MARK: - UI properties (Private)
        private let defaultTitleView: SBUNavigationTitleView = {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.Notification_Channel_Name_Default
            titleView.textAlignment = .center
            return titleView
        }()
        
        /// "Notifications"
        lazy var defaultLeftBarButton: UIBarButtonItem = {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton(_:))
            )
            return backButton
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
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the ``SBUNotificationChannelModuleHeaderDelegate`` protocol.
        public weak var delegate: SBUNotificationChannelModuleHeaderDelegate? = nil
        
        @available(*, unavailable, renamed: "SBUNotificationChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUNotificationChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit { SBULog.info(#function) }
        
        /// Configures ``SBUNotificationChannelModule/Header`` object with the ``delegate`` and the ``SBUBaseChannelModule/Header/theme``.
        /// - Parameters:
        ///    - delegate: The object that acts as the delegate of the header component. The delegate must adopt the ``SBUNotificationChannelModuleHeaderDelegate`` protocol.
        ///    - theme: The object that is used as the theme of the header component. The theme must adopt the ``SBUChannelTheme`` class.
        open func configure(delegate: SBUNotificationChannelModuleHeaderDelegate, theme: SBUChannelTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - Life cycle
        
        /// Set values of the views in the header component when it needs.
        open func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            
            if self.leftBarButtons.isEmpty {
                self.leftBarButtons.append(self.defaultLeftBarButton)
            }
            
            // NOTO: No `rightBarButton` as a default.
        }
        
        /// Sets layouts of the views in the header component.
        open func setupLayouts() {
            self.titleSpacer.sbu_constraint_greaterThan(
                width: self.bounds.width,
                priority: .defaultLow
            )
        }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the ``SBUChannelTheme`` class.
        open func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            (self.titleView as? SBUNavigationTitleView)?
                .setupStyles()
            
            self.leftBarButtons
                .forEach { $0.tintColor = self.theme?.leftBarButtonTintColor }
            
            self.rightBarButtons
                .forEach { $0.tintColor = self.theme?.rightBarButtonTintColor }
        }
        
        /// Updates styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the ``SBUChannelTheme`` class.
        open func updateStyles(theme: SBUChannelTheme? = nil) {
            self.setupStyles(theme: theme)
        }
        
        /// The action of an item in ``leftBarButtons``. It calls ``SBUNotificationChannelModuleHeaderDelegate/notificationChannelModule(_:didTapLeftItem:)`` when it's tapped
        open func onTapLeftBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.notificationChannelModule(self, didTapLeftItem: sender)
        }
        
        /// The action of an item in ``rightBarButtons``. It calls ``SBUNotificationChannelModuleHeaderDelegate/notificationChannelModule(_:didtapRightItem:)`` when it's tapped
        open func onTapRightBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.notificationChannelModule(self, didTapRightItem: sender)
        }
    }
}
