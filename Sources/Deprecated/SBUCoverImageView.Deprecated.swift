//
//  SBUCoverImageView.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2022/10/05.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

extension SBUCoverImageView {
    /// This function sets placeholder image with icon size.
    /// - Parameter iconSize: icon size
    @available(*, deprecated, message: "renamed to 'setPlaceholder(type: .iconUSer)'", renamed: "setPlaceholder(type:iconSize:)") // 3.2.0
    public func setPlaceholderImage(iconSize: CGSize) {
        self.setIconImage(
            type: .iconUser,
            tintColor: theme.userPlaceholderTintColor,
            backgroundColor: theme.userPlaceholderBackgroundColor
        )
    }
}
