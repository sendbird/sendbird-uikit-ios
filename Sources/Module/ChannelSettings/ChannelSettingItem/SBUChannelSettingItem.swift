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
    public let title: String
    public let icon: UIImage
    public let subTitle: String?
    public let isRightButtonHidden: Bool
    public let isRightSwitchHidden: Bool
    
    public let tapHandler: (() -> Void)?
    
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
