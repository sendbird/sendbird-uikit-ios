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
    
    /// Called when `leftBarButtons` value has been updated.
    /// - Parameters:
    ///   - headerComponent: `SBURegisterOperatorModule.Header` object
    ///   - leftItems: Updated `leftBarButtons` object.
    /// - Since: 3.28.0
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?)
    
    /// Called when `rightBarButtons` was selected.
    /// - Parameters:
    ///   - headerComponent: `SBURegisterOperatorModule.Header` object
    ///   - rightItems: Updated `rightBarButtons` object.
    /// - Since: 3.28.0
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?)
    
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

extension SBURegisterOperatorModuleHeaderDelegate {
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateLeftItems leftItems: [UIBarButtonItem]?) { }
    
    func registerOperatorModule(_ headerComponent: SBURegisterOperatorModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) { }
}

// swiftlint:disable type_name
public protocol SBURegisterOperatorModuleHeaderDataSource: SBUBaseSelectUserModuleHeaderDataSource { }
// swiftlint:enable type_name

extension SBURegisterOperatorModule {
    
    /// A module component that represent the header of `SBURegisterOperatorModule`.
    /// This class consists of titleView, leftBarButton, and rightBarButton.
    @objc(SBURegisterOperatorModuleHeader)
    @objcMembers
    open class Header: SBUBaseSelectUserModule.Header {
        
        // MARK: - UI properties (Private)
        override func createDefaultTitleView() -> SBUNavigationTitleView {
            let titleView = self.channelType == .group ?
            SBUModuleSet.GroupRegisterOperatorModule.HeaderComponent.TitleView.init() :
            SBUModuleSet.OpenRegisterOperatorModule.HeaderComponent.TitleView.init()
            
            titleView.configure(title: SBUStringSet.InviteChannel_Header_Select_Users)
            return titleView
        }
        
        override func createDefaultLeftBarButton() -> UIBarButtonItem {
            let module = self.channelType == .group
            ? SBUModuleSet.GroupRegisterOperatorModule
            : SBUModuleSet.OpenRegisterOperatorModule
            
            let leftItem = module.HeaderComponent.LeftBarButton.init(
                title: SBUStringSet.Cancel,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
            
            leftItem.setTitleTextAttributes([.font: SBUFontSet.button2], for: .normal)
            return leftItem
        }
        
        override func createDefaultRightBarButton() -> UIBarButtonItem {
            let module = self.channelType == .group
            ? SBUModuleSet.GroupRegisterOperatorModule
            : SBUModuleSet.OpenRegisterOperatorModule
            
            let rightItem = module.HeaderComponent.RightBarButton.init(
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
        
        // MARK: - Logic properties (Private)
        var channelType: ChannelType?
        
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
        
        open override func setupViews() {
            #if SWIFTUI
            switch channelType {
            case .group:
                self.applyViewConverter(.titleView)
                self.applyViewConverter(.leftView)
                self.applyViewConverter(.rightView)
            case .open:
                self.applyViewConverterForOpen(.titleView)
                self.applyViewConverterForOpen(.leftView)
                self.applyViewConverterForOpen(.rightView)
            default:
                break
            }
            // We are not using `...buttons` in SwiftUI
            #endif
            super.setupViews()
        }
        
        // MARK: - Common
        open override func updateRightBarButton() {
            super.updateRightBarButton()
            
            let title = SBUStringSet.InviteChannel_Register(self.selectedUserList?.count ?? 0)
            self.rightBarButton?.title = title
            self.rightBarButtons?.first?.title = title
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
        public override func didUpdateLeftItems() {
            self.delegate?.registerOperatorModule(self, didUpdateLeftItems: self.leftBarButtons)
        }
        public override func didUpdateRightItems() {
            self.delegate?.registerOperatorModule(self, didUpdateRightItems: self.rightBarButtons)
        }
        
        // MARK: - Actions
        public override func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons,
               let defaultLeftBarButton = self.defaultLeftBarButton,
               leftBarButtons.isUsingDefaultButton(defaultLeftBarButton) {
                self.delegate?.registerOperatorModule(self, didTapLeftItem: defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.registerOperatorModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        public override func onTapRightBarButton() {
            if let rightBarButtons = self.rightBarButtons,
               let defaultRightBarButton = self.defaultRightBarButton,
               rightBarButtons.isUsingDefaultButton(defaultRightBarButton) {
                self.delegate?.registerOperatorModule(self, didTapRightItem: defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.registerOperatorModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
