//
//  SBUCreateChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in channel creating module.
public protocol SBUCreateChannelModuleHeaderDelegate: SBUBaseSelectUserModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateChannelModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateChannelModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateChannelModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateChannelModule.Header` object
    ///   - leftItem: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUCreateChannelModule.Header` object
    ///   - rightItem: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUCreateChannelModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUCreateChannelModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

extension SBUCreateChannelModuleHeaderDelegate {
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) { }
    
    func createChannelModule(_ headerComponent: SBUCreateChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) { }
}

/// Methods to get data source for the header component.
public protocol SBUCreateChannelModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }

extension SBUCreateChannelModule {
    
    /// A module component that represent the header of `SBUCreateChannelModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objc(SBUCreateChannelModuleHeader)
    @objcMembers
    open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUModuleSet.CreateGroupChannelModule.HeaderComponent.TitleView.init()
            titleView.configure(title: SBUStringSet.CreateChannel_Header_Select_Members)
            return titleView
        }
        
        override func createDefaultLeftBarButton() -> SBUBarButtonItem {
            SBUModuleSet.CreateGroupChannelModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightBarButton() -> UIBarButtonItem {
            let createChannelButton =  SBUModuleSet.CreateGroupChannelModule.HeaderComponent.RightBarButton.init(
                title: SBUStringSet.CreateChannel_Create(0),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            
//            UIBarButtonItem(
//                title: SBUStringSet.CreateChannel_Create(0),
//                style: .plain,
//                target: self,
//                action: #selector(onTapRightBarButton)
//            )
            createChannelButton.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return createChannelButton
        }
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUCreateChannelModuleHeaderDelegate` protocol.
        public weak var delegate: SBUCreateChannelModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUCreateChannelModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        /// The object that acts as the data source of the header component. The data source must adopt the `SBUCreateChannelModuleHeaderDataSource`.
        public weak var dataSource: SBUCreateChannelModuleHeaderDataSource? {
            get { self.baseDataSource as? SBUCreateChannelModuleHeaderDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUCreateChannelModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUCreateChannelModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUCreateChannelModuleHeaderDelegate` type listener
        ///   - dataSource: `SBUCreateChannelModuleHeaderDataSource` object
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBUCreateChannelModuleHeaderDelegate,
                            dataSource: SBUCreateChannelModuleHeaderDataSource,
                            theme: SBUUserListTheme) {
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
        
        // MARK: - Common
        open override func updateRightBarButton() {
            super.updateRightBarButton()
            
            let title = SBUStringSet.CreateChannel_Create(self.selectedUserList?.count ?? 0)
            self.rightBarButton?.title = title
            self.rightBarButtons?.first?.title = title
            // TODO: SwiftUI - Update rightView
        }
        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.createChannelModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.createChannelModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.createChannelModule(self, didUpdateRightItem: self.rightBarButton)
        }
        public override func didUpdateLeftItems() {
            self.delegate?.createChannelModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItems() {
            self.delegate?.createChannelModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        // MARK: - Actions
        /// The action of the leftBarButton. It calls `createChannelModule(_:didTapLeftItem:)` delegate method.
        public override func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons,
               let defaultLeftBarButton = self.defaultLeftBarButton,
               leftBarButtons.isUsingDefaultButton(defaultLeftBarButton) {
                self.delegate?.createChannelModule(self, didTapLeftItem: defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.createChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of the rightBarButton. It calls `createChannelModule(_:didTapRightItem:)` delegate method.
        public override func onTapRightBarButton() {
            if let rightBarButtons = self.rightBarButtons,
               let defaultRightBarButton = self.defaultRightBarButton,
               rightBarButtons.isUsingDefaultButton(defaultRightBarButton) {
                self.delegate?.createChannelModule(self, didTapRightItem: defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.createChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
