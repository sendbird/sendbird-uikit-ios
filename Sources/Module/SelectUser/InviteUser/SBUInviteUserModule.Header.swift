//
//  SBUInviteUserModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public protocol SBUInviteUserModuleHeaderDelegate: SBUBaseSelectUserModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUInviteUserModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUInviteUserModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUInviteUserModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func inviteUserModule(_ headerComponent: SBUInviteUserModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}

public protocol SBUInviteUserModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }

extension SBUInviteUserModule {
    
    /// A module component that represent the header of `SBUInviteUserModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.InviteChannel_Header_Title
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
                title: SBUStringSet.InviteChannel_Invite(0),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            rightItem.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return rightItem
        }
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUInviteUserModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUInviteUserModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBUInviteUserModuleHeaderDataSource? {
            get { self.baseDataSource as? SBUInviteUserModuleHeaderDataSource }
            set { self.baseDataSource = newValue }
        }
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUInviteUserModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUInviteUserModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUInviteUserModuleHeaderDelegate` type listener
        ///   - dataSource: `SBUInviteUserModuleHeaderDataSource` object
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBUInviteUserModuleHeaderDelegate,
                            dataSource: SBUInviteUserModuleHeaderDataSource,
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
            
            self.rightBarButton?.title = SBUStringSet.InviteChannel_Invite(self.selectedUserList?.count ?? 0)
        }
        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.inviteUserModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.inviteUserModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.inviteUserModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        // MARK: - Actions
        open override func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.inviteUserModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.inviteUserModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
