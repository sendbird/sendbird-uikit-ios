//
//  SBUGroupChannelModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in a group channel.
public protocol SBUGroupChannelModuleHeaderDelegate: SBUBaseChannelModuleHeaderDelegate {}

extension SBUGroupChannelModule {
    
    /// A module component that represent the header of `SBUGroupChannelModule`.
    @objcMembers
    open class Header: SBUBaseChannelModule.Header {
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelModuleHeaderDelegate` protocol.
        public weak var delegate: SBUGroupChannelModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUGroupChannelModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        override func createDefaultTitleView() -> SBUChannelTitleView {
            SBUModuleSet.GroupChannelModule.HeaderComponent.TitleView.init()
        }
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.GroupChannelModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
        override func createDefaultRightButton() -> SBUBarButtonItem {
            SBUModuleSet.GroupChannelModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconInfo.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapRightBarButton)
            )
        }
        
        /// Configures `SBUGroupChannelModule.Header` object with the `delegate` and the `theme`.
        /// - Parameters:
        ///   - delegate: The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelModuleHeaderDelegate` protocol.
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func configure(
            delegate: SBUGroupChannelModuleHeaderDelegate,
            theme: SBUChannelTheme
        ) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        open override func setupViews() {
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            #endif
            super.setupViews()
            
            if self.rightBarButton == nil && self.rightBarButtons == nil {
                self.rightBarButton = self.defaultRightBarButton
            }
            
            if self.rightBarButtons == nil {
                self.rightBarButtons = [self.defaultRightBarButton]
            }
        }
        
        // MARK: - Actions
        
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            
            if let leftBarButtons = self.leftBarButtons,
               leftBarButtons.isUsingDefaultButton(self.defaultLeftBarButton) {
                self.delegate?.baseChannelModule(self, didTapLeftItem: self.defaultLeftBarButton)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            
            if let rightBarButtons = self.rightBarButtons,
               rightBarButtons.isUsingDefaultButton(self.defaultRightBarButton) {
                self.delegate?.baseChannelModule(self, didTapRightItem: self.defaultRightBarButton)
            } else if let rightBarButton = self.rightBarButton {
                self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
            }
            
//            self.delegate?.baseChannelModule(self, didTapRightItem: self.rightBarButtons!.first!)
        }
    }
}
