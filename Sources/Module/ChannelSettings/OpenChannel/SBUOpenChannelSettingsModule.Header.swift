//
//  SBUOpenChannelSettingsModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

// swiftlint:disable type_name
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
    
    /// Called when `rightBarButton` was updated.
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
    
    /// Called when `leftBarButtons` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUOpenChannelSettingsModule.Header` object
    ///   - leftItems: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was updated.
    /// - Parameters:
    ///   - headerComponent: `SBUOpenChannelSettingsModule.Header` object
    ///   - rightItems: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
}

extension SBUOpenChannelSettingsModuleHeaderDelegate {
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) {}
    
    func openChannelSettingsModule(_ headerComponent: SBUOpenChannelSettingsModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
}
// swiftlint:enable type_name

extension SBUOpenChannelSettingsModule {
    
    /// A module component that represent the header of `SBUOpenChannelSettingsModule`.
    /// - This class consists of titleView, leftBarButton, and rightBarButton.
    @objc(SBUOpenChannelSettingsModuleHeader)
    @objcMembers
    open class Header: SBUBaseChannelSettingsModule.Header {
        
        // MARK: - UI properties (Private)
    
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUOpenChannelSettingsModuleHeaderDelegate` protocol
        public weak var delegate: SBUOpenChannelSettingsModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUOpenChannelSettingsModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        // MARK: - default views
        
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUModuleSet.OpenChannelSettingsModule.HeaderComponent.TitleView.init()
            titleView.text = SBUStringSet.ChannelSettings_Header_Title
            titleView.textAlignment = .center
            
            return titleView
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelSettingsModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            SBUModuleSet.OpenChannelSettingsModule.HeaderComponent.RightBarButton.init(
                title: SBUStringSet.Edit,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
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
            self.delegate?.openChannelSettingsModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.openChannelSettingsModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.openChannelSettingsModule(self, didUpdateRightItem: self.rightBarButton)
        }
        public override func didUpdateLeftItems() {
            self.delegate?.openChannelSettingsModule(self, didUpdateLeftItems: self.leftBarButtons)
        }
        public override func didUpdateRightItems() {
            self.delegate?.openChannelSettingsModule(self, didUpdateRightItems: self.rightBarButtons)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.delegate?.openChannelSettingsModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.openChannelSettingsModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.delegate?.openChannelSettingsModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.openChannelSettingsModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
