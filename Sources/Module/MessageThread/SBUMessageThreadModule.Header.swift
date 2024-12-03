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
    // swiftlint:disable missing_docs
    public func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItem rightItem: UIBarButtonItem?) {}
    public func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didTapRightItem rightItem: UIBarButtonItem) {}
    public func baseChannelModule(_ headerComponent: SBUBaseChannelModule.Header, didUpdateRightItems rightItems: [UIBarButtonItem]?) {}
    
    // swiftlint:enable missing_docs
}

extension SBUMessageThreadModule {
    /// A module component that represent the header of `SBUMessageThreadModule`.
    @objcMembers
    open class Header: SBUBaseChannelModule.Header, SBUMessageThreadTitleViewDelegate {
        
        // MARK: - UI properties (Private)
        lazy var defaultMessageThreadTitleView: SBUMessageThreadTitleView = {
            let titleView = SBUModuleSet.MessageThreadModule.HeaderComponent.TitleView.init()
            titleView.delegate = self
            return titleView
        }()
        
        lazy var defaultEmptyBarButton: SBUBarButtonItem = {
            let emptyButton = SBUModuleSet.MessageThreadModule.HeaderComponent.RightBarButton.init(
                image: SBUIconSetType.iconEmpty.image(
                    to: SBUIconSetType.Metric.defaultIconSize
                ),
                style: .plain,
                target: self,
                action: nil
            )
            return emptyButton
        }()
        
        // MARK: - default views
        
        override func createDefaultLeftButton() -> SBUBarButtonItem {
            SBUModuleSet.MessageThreadModule.HeaderComponent.LeftBarButton.init(
                image: SBUIconSetType.iconBack.image(to: SBUIconSetType.Metric.defaultIconSize),
                landscapeImagePhone: nil,
                style: .plain,
                target: self,
                action: #selector(onTapLeftBarButton)
            )
        }
        
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
            #if SWIFTUI
            self.applyViewConverter(.titleView)
            self.applyViewConverter(.leftView)
            self.applyViewConverter(.rightView)
            // We are not using `...buttons` in SwiftUI
            #endif
            
            if self.titleView == nil {
                self.titleView = self.defaultMessageThreadTitleView
            }
            
            if self.leftBarButton == nil && self.leftBarButtons == nil {
                self.leftBarButton = self.defaultLeftBarButton
            }
            
            if self.rightBarButton == nil, self.rightBarButtons == nil {
                self.rightBarButton = self.defaultEmptyBarButton
            }
            
            if self.leftBarButtons == nil {
                self.leftBarButtons = [self.defaultLeftBarButton]
            }
            
            if self.rightBarButtons == nil {
                self.rightBarButtons = [self.defaultEmptyBarButton]
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
            self.leftBarButtons?.forEach { $0.tintColor = self.theme?.leftBarButtonTintColor }
            
            self.rightBarButton?.tintColor = self.theme?.rightBarButtonTintColor
            self.rightBarButtons?.forEach { $0.tintColor = self.theme?.rightBarButtonTintColor }
        }
        
        // MARK: - Actions
        open func onTapTitleView() {
            if let titleView = self.titleView {
                self.delegate?.baseChannelModule(self, didTapTitleView: titleView)
            }
        }
        
        open override func onTapLeftBarButton() {
            if let leftBarButtons = self.leftBarButtons, let button = leftBarButtons.first {
                self.delegate?.baseChannelModule(self, didTapLeftItem: button)
            } else if let leftBarButton = self.leftBarButton {
                self.delegate?.baseChannelModule(self, didTapLeftItem: leftBarButton)
            }
        }
        
        // MARK: - SBUMessageThreadTitleViewDelegate
        open func messageThreadTitleViewDidTap(_ messageThreadTitleView: SBUMessageThreadTitleView) {
            self.onTapTitleView()
        }
    }
}
