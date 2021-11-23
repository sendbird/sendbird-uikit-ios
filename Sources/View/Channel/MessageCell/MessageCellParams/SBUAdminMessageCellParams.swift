//
//  SBUAdminMessageCellParams.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/19.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import SendBirdSDK

@objcMembers
public class SBUAdminMessageCellParams: SBUBaseMessageCellParams {
    public var adminMessage: SBDAdminMessage? {
        self.message as? SBDAdminMessage
    }
    
    public init(message: SBDAdminMessage, hideDateView: Bool) {
        super.init(
            message: message,
            hideDateView: hideDateView,
            messagePosition: .center,
            groupPosition: .none,
            receiptState: SBUMessageReceiptState.none
        )
    }
}
