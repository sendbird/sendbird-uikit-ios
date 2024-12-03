//
//  SBUChannelStateBanner.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 5/16/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SwiftUI

/// Banner to show channel state
/// - Since: 3.28.0
open class SBUChannelStateBanner: SBULabel {
    var isThreadMessage: Bool = false
    
    public required override init() {
        super.init(frame: .zero)
    }
    
    public required init(isThreadMessage: Bool) {
        self.isThreadMessage = isThreadMessage
        super.init(frame: .zero)
   }
    
    open override func setupViews() {
        #if SWIFTUI
        if self.isThreadMessage == false {
            if self.applyViewConverter(.entireContent) {
                return
            }
        } else {
            if self.applyViewConverterForMessageThread(.entireContent) {
                return
            }
        }
        #endif
        super.setupViews()
        self.text = SBUStringSet.Channel_State_Banner_Frozen
    }
    
    open func setupStyles(theme: SBUChannelTheme? = nil) {
        super.setupStyles()
        
        self.textAlignment = .center
        
        self.layer.masksToBounds = true
        self.layer.cornerRadius = 5
        
        self.textColor = theme?.channelStateBannerTextColor
        self.font = theme?.channelStateBannerFont
        self.backgroundColor = theme?.channelStateBannerBackgroundColor

        #if SWIFTUI
        if self.isThreadMessage == false {
            if self.viewConverter.entireContent != nil {
                self.backgroundColor = .clear
            }
        } else {
            if self.viewConverterForMessageThread.entireContent != nil {
                self.backgroundColor = .clear
            }
        }
        #endif
    }
}

extension SBUChannelStateBanner {
    static func createDefault(
        _ viewType: SBUChannelStateBanner.Type,
        isThreadMessage: Bool,
        isHidden: Bool = true
    ) -> SBUChannelStateBanner {
        let view = viewType.init(isThreadMessage: isThreadMessage)
        view.isHidden = true
        return view
    }
}
