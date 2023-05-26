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

/// Methods to get data source for the header component.
public protocol SBUCreateChannelModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }

extension SBUCreateChannelModule {
    
    /// A module component that represent the header of `SBUCreateChannelModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.CreateChannel_Header_Select_Members
            titleView.textAlignment = .center
            return titleView
        }
        
        override func defaultLeftBarButton() -> UIBarButtonItem {
            let backButton = SBUBarButtonItem.backButton(
                vc: self,
                selector: #selector(onTapLeftBarButton)
            )
            return backButton
        }
        
        override func defaultRightBarButton() -> UIBarButtonItem {
            let createChannelButton =  UIBarButtonItem(
                title: SBUStringSet.CreateChannel_Create(0),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
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
        
        // MARK: - Common
        open override func updateRightBarButton() {
            super.updateRightBarButton()
            
            self.rightBarButton?.title = SBUStringSet.CreateChannel_Create(self.selectedUserList?.count ?? 0)
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
        
        // MARK: - Actions
        /// The action of the leftBarButton. It calls `createChannelModule(_:didTapLeftItem:)` delegate method.
        public override func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.createChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        /// The action of the rightBarButton. It calls `createChannelModule(_:didTapRightItem:)` delegate method.
        public override func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.createChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
