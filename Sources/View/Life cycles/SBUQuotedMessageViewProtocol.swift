//
//  SBUQuotedMessageViewProtocol.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/27.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation

/// The protocol to configure the quoted message views. It conforms to `SBUViewLifeCycle`
///
/// - Since: 2.2.0
public protocol SBUQuotedMessageViewProtocol: SBUViewLifeCycle {
    func configure(with configuration: SBUQuotedBaseMessageViewParams)
}
