//
//  SBUGroupChannelSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in group channel settings module.
public protocol SBUGroupChannelSettingsModuleHeaderDelegate: SBUBaseChannelSettingsModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelSettingsModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelSettingsModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelSettingsModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUBaseChannelSettingsModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUBaseChannelSettingsModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

/// Methods to get data source for header component in a group channel setting.
public protocol SBUGroupChannelSettingsModuleHeaderDataSource: SBUBaseChannelSettingsModuleHeaderDataSource {
    /// Ask the data source to return the channel name.
    /// - Parameters:
    ///    - headerComponent: `SBUGroupChannelSettingsModule.Header` object.
    ///    - titleView: `UIView` object for titleView
    /// - Returns: The `String` object.
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, channelNameForTitleView titleView: UIView?) -> String?
}

extension SBUGroupChannelSettingsModule {
    
    /// A module component that represent the header of `SBUGroupChannelSettingsModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseChannelSettingsModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.textAlignment = .left
            return titleView
        }
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelSettingsModuleHeaderDelegate` protocol
        public weak var delegate: SBUGroupChannelSettingsModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUGroupChannelSettingsModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// The object that acts as the base data source of the header component. The base data source must adopt the `SBUGroupChannelSettingsModuleHeaderDataSource`.
        public weak var dataSource: SBUGroupChannelSettingsModuleHeaderDataSource? {
            get { self.baseDataSource as? SBUGroupChannelSettingsModuleHeaderDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - Logic properties (Private)
        private var channelName: String? {
            self.dataSource?.groupChannelSettingsModule(self, channelNameForTitleView: self.titleView)
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUGroupChannelSettingsModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUGroupChannelSettingsModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUGroupChannelSettingsModuleHeaderDelegate` type listener
        ///   - dataSource: `SBUGroupChannelSettingsModuleHeaderDataSource` object
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUGroupChannelSettingsModuleHeaderDelegate,
                            dataSource: SBUGroupChannelSettingsModuleHeaderDataSource,
                            theme: SBUChannelSettingsTheme) {
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        open override func setupViews() {
            super.setupViews()
            
            if let titleView = self.titleView as? SBUNavigationTitleView {
                titleView.text = self.channelName ?? SBUStringSet.ChannelSettings_Header_Title
            }
        }
        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.groupChannelSettingsModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.groupChannelSettingsModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.groupChannelSettingsModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            
            if let leftBarButton = self.leftBarButton {
                self.delegate?.groupChannelSettingsModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            
            if let rightBarButton = self.rightBarButton {
                self.delegate?.groupChannelSettingsModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
