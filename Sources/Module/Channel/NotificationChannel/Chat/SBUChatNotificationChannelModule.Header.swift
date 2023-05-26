//
//  SBUChatNotificationChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2023/03/01.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in a group channel.
protocol SBUChatNotificationChannelModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when the value of  ``SBUChatNotificationChannelModule/Header/titleView`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    )
    
    /// Called when the value of ``SBUChatNotificationChannelModule/Header/leftBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - leftItems: Updated ``SBUChatNotificationChannelModule/Header/leftBarButtons``.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    )
    
    /// Called when the value of ``SBUChatNotificationChannelModule/Header/rightBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - rightItems: Updated ``SBUChatNotificationChannelModule/Header/rightBarButtons``.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    )
    
    /// Called when ``SBUChatNotificationChannelModule/Header/titleView`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - titleView: Selected `titleView` object.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapTitleView titleView: UIView?
    )
    
    /// Called when ``SBUChatNotificationChannelModule/Header/leftBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    )
    
    /// Called when ``SBUChatNotificationChannelModule/Header/rightBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUChatNotificationChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func chatNotificationChannelModule(
        _ headerComponent: SBUChatNotificationChannelModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    )
}

extension SBUChatNotificationChannelModule {
    
    /// A module component that represent the header of `SBUChatNotificationChannelModule`.
    /// - Since: 3.5.0
    @objcMembers
    public class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// Specifies a custom view of the channel title in the center of the navigation bar of the header component.
        /// - NOTE: When the value is updated, ``SBUChatNotificationChannelModuleHeaderDelegate/chatNotificationChannelModule(_:didUpdateTitleView:)`` delegate function is called.
        /// - NOTE: To update title text when you using default title view, please calls ``SBUChatNotificationChannelViewController/updateChannelTitle(_:)`` in ``SBUChatNotificationChannelViewController``
        var titleView: UIView? {
            didSet {
                self.delegate?.chatNotificationChannelModule(
                    self,
                    didUpdateTitleView: self.titleView
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the left side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUChatNotificationChannelModuleHeaderDelegate/chatNotificationChannelModule(_:didUpdateLeftItems:)``  delegate function is called.
        var leftBarButtons: [UIBarButtonItem]? {
            didSet {
                self.delegate?.chatNotificationChannelModule(
                    self,
                    didUpdateLeftItems: self.leftBarButtons
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the right side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUChatNotificationChannelModuleHeaderDelegate/chatNotificationChannelModule(_:didUpdateRightItems:)`` delegate function is called.
        var rightBarButtons: [UIBarButtonItem]? {
            didSet {
                self.delegate?.chatNotificationChannelModule(
                    self,
                    didUpdateRightItems: self.rightBarButtons
                )
            }
        }
        
        /// The object that is used as the theme of the header component. The theme must adopt the ``SBUNotificationTheme.Header`` class.
        var theme: SBUNotificationTheme.Header {
            switch SBUTheme.colorScheme {
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        // MARK: - UI properties (Private)
        private let defaultTitleView: SBUChannelTitleView = {
            var titleView = SBUChannelTitleView()
            titleView.isChatNotificationChannelUsed = true
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
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the ``SBUChatNotificationChannelModuleHeaderDelegate`` protocol.
        weak var delegate: SBUChatNotificationChannelModuleHeaderDelegate?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUChatNotificationChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUChatNotificationChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit { SBULog.info(#function) }
        
        /// Configures ``SBUChatNotificationChannelModule/Header`` object with the ``delegate``.
        /// - Parameters:
        ///    - delegate: The object that acts as the delegate of the header component. The delegate must adopt the ``SBUChatNotificationChannelModuleHeaderDelegate`` protocol.
        func configure(delegate: SBUChatNotificationChannelModuleHeaderDelegate) {
            self.delegate = delegate
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultTitleView
            }
            
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftBarButton]
            }
            
            // NOTO: No `rightBarButton` as a default.
        }
        
        /// Sets layouts of the views in the header component.
        func setupLayouts() {
        }
        
        /// Sets styles of the views in the header component.
        func setupStyles() {
            if let titleView = titleView as? SBUChannelTitleView {
                titleView.setupStyles()
                titleView.titleLabel.font = self.theme.textFont
                titleView.titleLabel.textColor = self.theme.textColor
            }
            
            self.leftBarButtons?
                .forEach { $0.tintColor = self.theme.buttonIconTintColor }
            
            self.rightBarButtons?
                .forEach { $0.tintColor = self.theme.buttonIconTintColor }
        }
        
        /// Updates styles of the views in the header component.
        func updateStyles() {
            self.setupStyles()
        }
        
        // MARK: - Actions
        /// The action of an item in ``leftBarButtons``. It calls ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didTapLeftItem:)`` when it's tapped
        func onTapLeftBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.chatNotificationChannelModule(self, didTapLeftItem: sender)
        }
        
        /// The action of an item in ``rightBarButtons``. It calls ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didtapRightItem:)`` when it's tapped
        func onTapRightBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.chatNotificationChannelModule(self, didTapRightItem: sender)
        }
    }
}
