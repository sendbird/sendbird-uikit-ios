//
//  SBUPromoteMemberModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


public protocol SBUPromoteMemberModuleHeaderDelegate: SBUBaseSelectUserModuleHeaderDelegate {
    /// Called when `titleView` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUPromoteMemberModule.Header` object
    ///   - titleView: Updated `titleView` object.
    func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header, didUpdateTitleView titleView: UIView?)
    
    /// Called when `leftBarButton` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBUPromoteMemberModule.Header` object
    ///   - leftItem: Updated `leftBarButton` object.
    func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header, didUpdateLeftItem leftItem: UIBarButtonItem?)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBUPromoteMemberModule.Header` object
    ///   - rightItem: Updated `rightBarButton` object.
    func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?)
    
    /// Called when `leftBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - leftItem: Selected `leftBarButton` object.
    func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header, didTapLeftItem leftItem: UIBarButtonItem)
    
    /// Called when `rightBarButton` was selected.
    /// - Parameters:
    ///   - component: `SBUInviteUserModule.Header` object
    ///   - rightItem: Selected `rightBarButton` object.
    func promoteMemberModule(_ headerComponent: SBUPromoteMemberModule.Header, didTapRightItem rightItem: UIBarButtonItem)
}


public protocol SBUPromoteMemberModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }


extension SBUPromoteMemberModule {
    
    /// A module component that represent the header of `SBUPromoteMemberModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objcMembers open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func defaultTitleView() -> SBUNavigationTitleView {
            let titleView = SBUNavigationTitleView()
            titleView.text = SBUStringSet.InviteChannel_Header_Select_Members
            titleView.textAlignment = .center
            return titleView
        }
        
        override func defaultLeftButton() -> UIBarButtonItem {
            let leftItem =  UIBarButtonItem(
                title: SBUStringSet.Cancel,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
            leftItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
            return leftItem
        }
        
        override func defaultRightButton() -> UIBarButtonItem {
            let rightItem =  UIBarButtonItem(
                title: SBUStringSet.InviteChannel_Add(0),
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
            rightItem.setTitleTextAttributes([.font : SBUFontSet.button2], for: .normal)
            return rightItem
        }
        
        
        // MARK: - Logic properties (Public)
        public weak var delegate: SBUPromoteMemberModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUPromoteMemberModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        public weak var dataSource: SBUPromoteMemberModuleHeaderDataSource? {
            get { self.baseDataSource as? SBUPromoteMemberModuleHeaderDataSource }
            set { self.baseDataSource = newValue }
        }
        
        
        // MARK: - LifeCycle
        @available(*, unavailable, renamed: "SBUPromoteMemberModule.Header()")
        required public init?(coder: NSCoder) { super.init(coder: coder) }
        
        @available(*, unavailable, renamed: "SBUPromoteMemberModule.Header()")
        public override init(frame: CGRect) { super.init(frame: frame) }
        
        deinit {
            SBULog.info("")
        }
        
        /// Configures header component.
        /// - Parameters:
        ///   - delegate: `SBUPromoteMemberModuleHeaderDelegate` type listener
        ///   - dataSource: `SBUPromoteMemberModuleHeaderDataSource` object
        ///   - theme: `SBUUserListTheme` object
        open func configure(delegate: SBUPromoteMemberModuleHeaderDelegate,
                            dataSource: SBUPromoteMemberModuleHeaderDataSource,
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
            
            self.rightBarButton?.title = SBUStringSet.InviteChannel_Add(self.selectedUserList?.count ?? 0)
        }

        
        // MARK: - Attach update delegate on view
        public override func didUpdateTitleView() {
            self.delegate?.promoteMemberModule(self, didUpdateTitleView: self.titleView)
        }
        public override func didUpdateLeftItem() {
            self.delegate?.promoteMemberModule(self, didUpdateLeftItem: self.leftBarButton)
        }
        public override func didUpdateRightItem() {
            self.delegate?.promoteMemberModule(self, didUpdateRightItem: self.rightBarButton)
        }
        
        
        // MARK: - Actions
        @objc public override func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.promoteMemberModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        @objc public override func onTapRightBarButton() {
            if let rightBarButton = self.rightBarButton {
                self.delegate?.promoteMemberModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
