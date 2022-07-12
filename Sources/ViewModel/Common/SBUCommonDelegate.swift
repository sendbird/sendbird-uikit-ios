//
//  SBUCommonDelegate.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2021/09/02.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//
import SendbirdChatSDK

public protocol SBUCommonDelegate: AnyObject {
    // Error
    func didReceiveError(_ error: SBError?, isBlocker: Bool)
}
