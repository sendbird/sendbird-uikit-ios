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
    @objcMembers open class Header: SBUBaseChannelModule.Header {
        
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelModuleHeaderDelegate` protocol.
        public weak var delegate: SBUGroupChannelModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUGroupChannelModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        /// Configures `SBUGroupChannelModule.Header` object with the `delegate` and the `theme`.
        /// - Parameters:
        ///   - delegate: The object that acts as the delegate of the header component. The delegate must adopt the `SBUGroupChannelModuleHeaderDelegate` protocol.
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func configure(delegate: SBUGroupChannelModuleHeaderDelegate,
                              theme: SBUChannelTheme) {
            self.delegate = delegate
            self.theme = theme
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        // MARK: - LifeCycle
        open override func setupViews() {
            super.setupViews()
            
            if self.rightBarButton == nil {
                self.rightBarButton = self.defaultRightBarButton
            }
        }
        
        // MARK: - Actions
        
        open override func onTapLeftBarButton() {
            super.onTapLeftBarButton()
            if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        open override func onTapRightBarButton() {
            super.onTapRightBarButton()
            if let rightBarButton = self.rightBarButton {
                self.delegate?.baseChannelModule(self, didTapRightItem: rightBarButton)
            }
        }
    }
}
