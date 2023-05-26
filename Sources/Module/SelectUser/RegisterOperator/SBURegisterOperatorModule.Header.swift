//
//  SBURegisterOperatorModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBURegisterOperatorModuleHeaderDelegate: SBUBaseSelectUserModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBURegisterOperatorModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBURegisterOperatorModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBURegisterOperatorModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

public protocol SBURegisterOperatorModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }

extension SBURegisterOperatorModule {
    
    /// A module component that represent the header of `SBURegisterOperatorModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.InviteChannel_Header_Select_Users
            titleView.textAlignment = .center
            return titleView
        }
        
        override func defaultLeftBarButton() -> UIBarButtonItem {
            let leftItem =  UIBarButtonItem(
                title: SBUStringSet.Cancel,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
            leftItem.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return leftItem
        }
        
        override func defaultRightBarButton() -> UIBarButtonItem {
            let rightItem =  UIBarButtonItem(
                title: SBUStringSet.InviteChannel_Register(0),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            rightItem.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return rightItem
        }
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBURegisterOperatorModuleHeaderDelegate? {
            get { self.baseDelegate as? SBURegisterOperatorModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBURegisterOperatorModuleHeaderDataSource? {
            get { self.baseDataSource as? SBURegisterOperatorModuleHeaderDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBURegisterOperatorModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBURegisterOperatorModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBURegisterOperatorModuleHeaderDelegate` type listener
        ///   - dataSource: `SBURegisterOperatorModuleHeaderDataSource` object
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBURegisterOperatorModuleHeaderDelegate,
                            dataSource: SBURegisterOperatorModuleHeaderDataSource,
                            theme: SBUUserListTheme) {
            self.delegate = delegate
            self.dataSource = dataSource
            
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles(theme: theme)
        }
        
        // MARK: - Common
        open override func updateRightBarButton() {
            super.updateRightBarButton()
            
            self.rightBarButton?.title = SBUStringSet.InviteChannel_Register(self.selectedUserList?.count ?? 0)
        }
        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.registerOperatorModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.registerOperatorModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.registerOperatorModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        // MARK: - Actions
        public override func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.registerOperatorModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        public override func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.registerOperatorModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
