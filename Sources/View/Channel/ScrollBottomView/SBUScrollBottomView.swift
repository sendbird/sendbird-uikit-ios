//
//  SBUScrollBottomView.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 5/16/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

/// ScrollBottomView used in the channel
/// - Since: 3.28.0
open class SBUScrollBottomView: SBUView {
    var channelType: ChannelType = .group
    
    public override required init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public lazy var button = UIButton(frame: CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize))
    
    open override func setupViews() {
        super.setupViews()
        
        self.addSubview(self.button)
    }
    
    open override func setupLayouts() {
        super.setupLayouts()
        self.button.sbu_constraint(equalTo: self, leading: 0, trailing: 0, top: 0, bottom: 0)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = .clear
        
        var hasViewConverter = false
        #if SWIFTUI
        hasViewConverter = (self.viewConverter.entireContent != nil) || (self.viewConverterForOpen.entireContent != nil)
        #endif
        if !hasViewConverter {
            self.layer.shadowColor = self.theme.shadowColor.withAlphaComponent(0.5).cgColor
            self.layer.shadowOffset = CGSize(width: 0, height: 5)
            self.layer.shadowOpacity = 0.5
            self.layer.shadowRadius = 5
            self.layer.masksToBounds = false
            
            self.button.clipsToBounds = true
            self.button.setImage(self.buttomImage, for: .normal )
            self.button.setBackgroundImage(self.buttonBackground, for: .highlighted)
            self.button.backgroundColor = self.theme.scrollBottomButtonBackground
            self.button.layer.cornerRadius = (self.button.frame.height / 2).rounded(.up)
        }
    }
}

extension SBUScrollBottomView {
    /// component theme
    public var theme: SBUComponentTheme { SBUTheme.componentTheme }
    
    private var buttomImage: UIImage {
        SBUIconSetType.iconChevronDown.image(
            with: self.theme.scrollBottomButtonIconColor,
            to: SBUIconSetType.Metric.iconChevronDown
        )
    }
    
    private var buttonBackground: UIImage {
        UIImage.from(
            color: self.theme.scrollBottomButtonHighlighted
        )
    }
    
    fileprivate func addButtonTarget(_ target: Any, action: Selector) {
        self.button.addTarget(target, action: action, for: .touchUpInside)
    }
}

extension SBUScrollBottomView {
    static func createDefault(
        _ viewType: SBUScrollBottomView.Type?,
        channelType: SendbirdChatSDK.ChannelType,
        frame: CGRect = CGRect(origin: .zero, size: SBUConstant.scrollBottomButtonSize),
        target: Any,
        action: Selector
    ) -> SBUScrollBottomView? {
        guard let viewType = viewType else { return nil }
        let view = viewType.init(frame: frame)
        view.channelType = channelType
        
        
        var didApplyViewConverter = false
        #if SWIFTUI
        switch channelType {
        case .group:
            didApplyViewConverter = view.applyViewConverter(.entireContent, target: target, action: action)
        case .open:
            didApplyViewConverter = view.applyViewConverterForOpen(.entireContent, target: target, action: action)
        default:
            break
        }
        #endif
        if !didApplyViewConverter {
            view.addButtonTarget(target, action: action)
        }
        
        return view
    }
}
