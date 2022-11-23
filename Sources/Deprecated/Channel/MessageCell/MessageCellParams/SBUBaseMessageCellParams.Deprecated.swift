//
//  SBUBaseMessageCellParams.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/11/23.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUBaseMessageCellParams {
    // MARK: - 3.3.0

    @available(*, deprecated, renamed: "useQuotedMessage")
    public var usingQuotedMessage: Bool { self.useQuotedMessage }
    
}
