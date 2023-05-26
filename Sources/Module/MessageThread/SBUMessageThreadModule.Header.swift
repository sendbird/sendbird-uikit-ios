//
//  SBUMessageThreadModule.Header.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/01.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// Event methods for the views updates and performing actions from the header component in a message thread.
public protocol SBUMessageThreadModuleHeaderDelegate: SBUBaseChannelModuleHeaderDelegate { }

extension SBUMessageThreadModuleHeaderDelegate {
    public func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?) {}
    public func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {}
}

extension SBUMessageThreadModule {
    /// A module component that represent the header of `SBUMessageThreadModule`.
    @objcMembers open class Header: SBUBaseChannelModule.Header, SBUMessageThreadTitleViewDelegate {
        
        // MARK: - UI properties (Private)
        lazy var defaultMessageThreadTitleView: SBUMessageThreadTitleView = {
            var titleView = SBUMessageThreadTitleView(delegate: self)
            return titleView
        }()
        
        // MARK: - Logic properties (Public)
        /// The object that acts as the delegate of the header component. The delegate must adopt the `SBUMessageThreadModuleHeaderDelegate` protocol.
        public weak var delegate: SBUMessageThreadModuleHeaderDelegate? {
            get { self.baseDelegate as? SBUMessageThreadModuleHeaderDelegate }
            set { self.baseDelegate = newValue }
        }
        
        public private(set) var parentMessage: BaseMessage?
        
        // MARK: - LifeCycle
        
        /// Configures `SBUMessageThreadModule.Header` object with the `delegate` and the `theme`.
        /// - Parameters:
        ///   - delegate: The object that acts as the delegate of the header component. The delegate must adopt the `SBUMessageThreadModuleHeaderDelegate` protocol.
        ///   - theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open func configure(delegate: SBUMessageThreadModuleHeaderDelegate,
                            parentMessage: BaseMessage?,
                            theme: SBUChannelTheme) {
            self.delegate = delegate
            self.theme = theme
            self.parentMessage = parentMessage
            
            self.setupViews()
            self.setupLayouts()
            self.setupStyles()
        }
        
        /// Set values of the views in the header component when it needs.
        open override func setupViews() {
            if self.titleView == nil {
                self.titleView = self.defaultMessageThreadTitleView
            }
            
            if self.leftBarButton == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
            
            if self.rightBarButton == nil {
                self.rightBarButton = self.defaultEmptyBarButton
            }
        }
        
        /// Sets layouts of the views in the header component.
        open override func setupLayouts() {
        }
        
        /// Sets styles of the views in the header component with the `theme`.
        /// - Parameter theme: The object that is used as the theme of the header component. The theme must adopt the `SBUChannelTheme` class.
        open override func setupStyles(theme: SBUChannelTheme? = nil) {
            if let theme = theme {
                self.theme = theme
            }
            
            if let titleView = self.titleView as? SBUMessageThreadTitleView {
                titleView.setupStyles()
            }
            
            self.leftBarButton?.tintColor = self.theme?.leftBarButtonTintColor
        }
        
        // MARK: - Actions
        open func onTapTitleView() {
            if let titleView = self.titleView {
                self.delegate?.baseChannelModule(self, didTapTitleView: titleView)
            }
        }
        
        open override func onTapLeftBarButton() {
            if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        // MARK: - SBUMessageThreadTitleViewDelegate
        open func messageThreadTitleViewDidTap(_ messageThreadTitleView: SBUMessageThreadTitleView) {
            self.onTapTitleView()
        }
    }
}
