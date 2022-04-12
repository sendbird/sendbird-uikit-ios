//
//  SBUQuoteMessageInputViewProtocol.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/27.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The protocol to configure the quote message input view. It conforms to `SBUViewLifeCycle`
///
/// - Since: 2.2.0
public protocol SBUQuoteMessageInputViewProtocol: SBUViewLifeCycle {
    /// Configures UI components with `SBUParentMessageInputViewParams`
    /// - Since: 2.2.0
    func configure(with configuration: SBUQuoteMessageInputViewParams)
}
