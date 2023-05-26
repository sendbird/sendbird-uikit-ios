//
//  SBUOpenChannelSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in open channel settings module.
public protocol SBUOpenChannelSettingsModuleHeaderDelegate: SBUBaseChannelSettingsModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUOpenChannelSettingsModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUOpenChannelSettingsModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUOpenChannelSettingsModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUBaseChannelSettingsModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUBaseChannelSettingsModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUOpenChannelSettingsModule {
    
    /// A module component that represent the header of `SBUOpenChannelSettingsModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseChannelSettingsModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.ChannelSettings_Header_Title
            titleView.textAlignment = .center
            
            return titleView
        }

        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUOpenChannelSettingsModuleHeaderDelegate` protocol
        public weak var delegate: SBUOpenChannelSettingsModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUOpenChannelSettingsModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUOpenChannelSettingsModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUOpenChannelSettingsModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUOpenChannelSettingsModuleHeaderDelegate` type listener
        ///   - theme: `SBUChannelSettingsTheme` object
        open func configure(delegate: SBUOpenChannelSettingsModuleHeaderDelegate,
                            theme: SBUChannelSettingsTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.openChannelSettingsModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.openChannelSettingsModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.openChannelSettingsModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            
            if let leftBarButton = self.leftBarButton {
                self.delegate?.openChannelSettingsModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            
            if let rightBarButton = self.rightBarButton {
                self.delegate?.openChannelSettingsModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
