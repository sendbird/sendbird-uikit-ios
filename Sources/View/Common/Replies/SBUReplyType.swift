//
//  SBUReplyType.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/09/09.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendBirdSDK

public enum SBUReplyType: Int {
    case `none`
    case quoteReply
    case thread
    
    public var filterValue: SBDReplyType {
        switch self {
            case .none: return .none
            default: return .all
        }
    }
}
