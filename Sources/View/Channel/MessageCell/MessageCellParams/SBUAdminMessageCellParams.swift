//
//  SBUAdminMessageCellParams.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendbirdChatSDK

public class SBUAdminMessageCellParams: SBUBaseMessageCellParams {
    public var adminMessage: AdminMessage? {
        self.message as? AdminMessage
    }
    
    public init(message: AdminMessage, hideDateView: Bool) {
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: .center,
            groupPosition: .none,
            receiptState: SBUMessageReceiptState.none
        )
    }
}
