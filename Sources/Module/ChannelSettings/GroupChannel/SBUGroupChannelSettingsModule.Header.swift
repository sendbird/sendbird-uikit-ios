//
//  SBUGroupChannelSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
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
    
    /// Called when `leftBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelSettingsModule.Header` object
    ///   - leftItem: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUGroupChannelSettingsModule.Header` object
    ///   - rightItem: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
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

extension SBUGroupChannelSettingsModuleHeaderDelegate {
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?) {}
    
    func groupChannelSettingsModule(_ headerComponent: SBUGroupChannelSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
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
// swiftlint:enable type_name

extension SBUGroupChannelSettingsModule {
    
    /// A module component that represent the header of `SBUGroupChannelSettingsModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objc(SBUGroupChannelSettingsModuleHeader)
    @objcMembers
    open class Header: SBUBaseChannelSettingsModule.Header {
        
        // MARK: - UI properties (Private)
        
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
        
        // MARK: - default views
        
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUModuleSet.GroupChannelSettingsModule.HeaderComponent.TitleView.init()
            titleView.configure(title: self.channelName ?? SBUStringSet.ChannelSettings_Header_Title)
            
            return titleView
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.GroupChannelSettingsModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            SBUModuleSet.GroupChannelSettingsModule.HeaderComponent.RightBarButton.init(
                title: SBUStringSet.Edit,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
        }
        
        // MARK: life cycle
        
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
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            // We are not using `...buttons` in SwiftUI
            #endif
            super.setupViews()
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
        public override func didUpdateLeftItems() {
            self.delegate?.groupChannelSettingsModule(self, didUpdateLeftItems: self.leftBarButtons)
        }
        public override func didUpdateRightItems() {
            self.delegate?.groupChannelSettingsModule(self, didUpdateRightItems: self.rightBarButtons)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.delegate?.groupChannelSettingsModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.groupChannelSettingsModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.delegate?.groupChannelSettingsModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.groupChannelSettingsModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
