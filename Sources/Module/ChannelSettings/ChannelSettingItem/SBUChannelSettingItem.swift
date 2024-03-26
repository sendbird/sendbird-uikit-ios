//
//  SBUChannelSettingItem.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/06/21.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This is a structure used to handling action and display in `SBUBaseChannelSettingsModule.List` and `SBUBaseChannelSettingCell`.
/// - Since: 3.1.0
public struct SBUChannelSettingItem {
    /// The title of the setting item
    public let title: String
    
    /// The icon of the setting item
    public let icon: UIImage
    
    /// The subtitle of the setting item
    public let subTitle: String?
    
    /// A boolean to determine if the right button is hidden
    public let isRightButtonHidden: Bool
    
    /// A boolean to determine if the right switch is hidden
    public let isRightSwitchHidden: Bool
    
    /// The handler for the tap action
    public let tapHandler: (() -> Void)?
    
    /// Initializer
    public init(title: String,
                subTitle: String? = nil,
                icon: UIImage,
                isRightButtonHidden: Bool = true,
                isRightSwitchHidden: Bool = true,
                tapHandler: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.subTitle = subTitle
        self.isRightButtonHidden = isRightButtonHidden
        self.isRightSwitchHidden = isRightSwitchHidden
        self.tapHandler = tapHandler
    }
}
