//
//  SBUTypingIndicatorMessageCell.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 11/13/23.
//  Copyright © 2023 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK
import UIKit

/// A message cell that displays a typing indicator message. (``SBUTypingIndicatorMessage``).
/// - Since: 3.12.0
open class SBUTypingIndicatorMessageCell: SBUContentBaseMessageCell {
    // MARK: - Public UI properties
    open lazy var typingBubbleView: UIView = {
        let typingBubble = SBUTypingIndicatorBubbleView(frame: CGRect(x: 0, y: 0, width: 60, height: 34))
        return typingBubble
    }()
    
    // MARK: - Public logic properties
    public var typingMessage: SBUTypingIndicatorMessage? {
        self.message as? SBUTypingIndicatorMessage
    }
    
    // MARK: - View Lifecycle
    open override func setupViews() {
        super.setupViews()

        mainContainerView.setStack([
            typingBubbleView
        ])
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
    }
    
    open override func setupActions() {
        super.setupActions()
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        #if SWIFTUI
        if self.viewConverter.typingMessage.entireContent != nil {
            self.mainContainerView.setTransparentBackgroundColor()
        }
        #endif
    }
    
    // MARK: - Common
    open override func configure(with configuration: SBUBaseMessageCellParams) {
        guard let configuration = configuration as? SBUTypingIndicatorMessageCellParams else { return }
        
        // Configure Content base message cell
        super.configure(with: configuration)
        self.stateView.removeFromSuperview()
        
        // Typing bubble view.
        #if SWIFTUI
        if self.applyViewConverter(.typingMessage) {
            return
        }
        #endif
        if let typingBubbleView = self.typingBubbleView as? SBUTypingIndicatorBubbleView,
           configuration.shouldRedrawTypingBubble {
            typingBubbleView.configure()
        }
        
        self.layoutIfNeeded()
    }
    
    public override func resetMainContainerViewLayer() {
        #if SWIFTUI
        if self.viewConverter.typingMessage.entireContent != nil {
            return
        }
        #endif
        super.resetMainContainerViewLayer()
    }
}
