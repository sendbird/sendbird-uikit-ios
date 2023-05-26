//
//  SBUFeedNotificationChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/12/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Event methods for the views updates and performing actions from the header component in a notification channel.
protocol SBUFeedNotificationChannelModuleHeaderDelegate: SBUCommonDelegate {
    /// Called when the value of  ``SBUFeedNotificationChannelModule/Header/titleView`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateTitleView titleView: UIView?
    )
    
    /// Called when the value of ``SBUFeedNotificationChannelModule/Header/leftBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - leftItems: Updated ``SBUFeedNotificationChannelModule/Header/leftBarButtons``.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateLeftItems leftItems: [UIBarButtonItem]?
    )
    
    /// Called when the value of ``SBUFeedNotificationChannelModule/Header/rightBarButtons`` has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - rightItems: Updated ``SBUFeedNotificationChannelModule/Header/rightBarButtons``.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didUpdateRightItems rightItems: [UIBarButtonItem]?
    )
    
    /// Called when ``SBUFeedNotificationChannelModule/Header/titleView`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - titleView: Selected `titleView` object.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapTitleView titleView: UIView?
    )
    
    /// Called when ``SBUFeedNotificationChannelModule/Header/leftBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapLeftItem leftItem: UIBarButtonItem
    )
    
    /// Called when ``SBUFeedNotificationChannelModule/Header/rightBarButtons`` is selected.
    /// - Parameters:
    ///   - headerComponent: `SBUFeedNotificationChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        didTapRightItem rightItem: UIBarButtonItem
    )
}

/// Methods to get data source for header component in a feed channel.
protocol SBUFeedNotificationChannelModuleHeaderDataSource: AnyObject {
    /// Ask the data source to return the channel name.
    /// - Parameters:
    ///    - headerComponent: `SBUFeedNotificationChannelModule.Header` object.
    ///    - titleView: `UIView` object for titleView
    /// - Returns: The `String` object.
    func feedNotificationChannelModule(
        _ headerComponent: SBUFeedNotificationChannelModule.Header,
        channelNameForTitleView titleView: UIView?
    ) -> String?
}

extension SBUFeedNotificationChannelModule {
    /// A module component that represent the header of ``SBUFeedNotificationChannelModule``
    /// - Since: 3.5.0
    @objcMembers
    public class Header: UIView {
        
        // MARK: - UI properties (Public)
        
        /// Specifies a custom view of the channel title in the center of the navigation bar of the header component.
        /// - NOTE: When the value is updated, ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didUpdateTitleView:)`` delegate function is called.
        /// - NOTE: To update title text when you using default title view, please calls ``SBUFeedNotificationChannelViewController/updateChannelTitle(_:)`` in ``SBUFeedNotificationChannelViewController``
        var titleView: UIView? {
            didSet {
                self.delegate?.feedNotificationChannelModule(
                    self,
                    didUpdateTitleView: self.titleView
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the left side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didUpdateLeftItems:)``  delegate function is called.
        var leftBarButtons: [UIBarButtonItem]? {
            didSet {
                self.delegate?.feedNotificationChannelModule(
                    self,
                    didUpdateLeftItems: self.leftBarButtons
                )
            }
        }
        
        /// Specifies an array of  `UIBarButtonItem` that is used as a button on the right side of the navigation bar.
        /// - NOTE: When the value is updated, ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didUpdateRightItems:)`` delegate function is called.
        var rightBarButtons: [UIBarButtonItem]? {
            didSet {
                self.delegate?.feedNotificationChannelModule(
                    self,
                    didUpdateRightItems: self.rightBarButtons
                )
            }
        }
        
        var titleSpacer = UIView()
        
        /// The object that is used as the theme of the header component. The theme must adopt the ``SBUNotificationTheme.Header`` class.
        var theme: SBUNotificationTheme.Header {
            switch SBUTheme.colorScheme {
            case .light: return .light
            case .dark: return .dark
            }
        }
        
        // MARK: - UI properties (Private)
        private let defaultTitleView: SBUNotificationNavigationTitleView = {
            var titleView = SBUNotificationNavigationTitleView()
            titleView.textAlignment = .left
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
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the ``SBUFeedNotificationChannelModuleHeaderDelegate`` protocol.
        weak var delegate: SBUFeedNotificationChannelModuleHeaderDelegate?
        
        weak var dataSource: SBUFeedNotificationChannelModuleHeaderDataSource?
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUFeedNotificationChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUFeedNotificationChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit { SBULog.info(#function) }
        
        /// Configures ``SBUFeedNotificationChannelModule/Header`` object with the ``delegate`` and the ``SBUNotificationTheme/Header``.
        /// - Parameters:
        ///    - delegate: The object that acts as the delegate of the header component. The delegate must adopt the ``SBUFeedNotificationChannelModuleHeaderDelegate`` protocol.
        ///    - dataSource: The object that acts as the base data source of the header component. The base data source must adopt the `SBUFeedNotificationChannelModuleHeaderDataSource`.
        func configure(
            delegate: SBUFeedNotificationChannelModuleHeaderDelegate,
            dataSource: SBUFeedNotificationChannelModuleHeaderDataSource
        ) {
            self.delegate = delegate
            self.dataSource = dataSource
            
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
            let bounds = UIApplication.shared.currentWindow?.bounds ?? .zero
            self.titleSpacer.sbu_constraint_greaterThan(
                width: max(bounds.width, bounds.height),
                priority: .defaultLow
            )
        }
        
        /// Sets styles of the views in the header component.
        func setupStyles() {
            if let titleView = titleView as? SBUNotificationNavigationTitleView {
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
        
        /// The action of an item in ``leftBarButtons``. It calls ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didTapLeftItem:)`` when it's tapped
        func onTapLeftBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.feedNotificationChannelModule(self, didTapLeftItem: sender)
        }
        
        /// The action of an item in ``rightBarButtons``. It calls ``SBUFeedNotificationChannelModuleHeaderDelegate/feedNotificationChannelModule(_:didtapRightItem:)`` when it's tapped
        func onTapRightBarButton(_ sender: UIBarButtonItem) {
            self.delegate?.feedNotificationChannelModule(self, didTapRightItem: sender)
        }
    }
}
