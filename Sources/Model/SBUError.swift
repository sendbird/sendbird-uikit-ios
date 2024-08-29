//
//  SBUError.swift
//  SendbirdUIKit
//
//  Created by Celine Moon on 8/27/24.
//

import SendbirdChatSDK

struct SBUError {
    var domain: String?
    var code: SBUErrorCode
    var userInfo: [String: Any]?
    
    func asSBError() -> SBError {
        SBError(
            domain: self.domain ?? self.code.message,
            code: self.code.rawValue,
            userInfo: self.userInfo
        )
    }
}

enum SBUErrorCode: Int {
    case emojiUnsupported = 10100
    
    var message: String {
        switch self {
        case .emojiUnsupported:
            return "The selected emoji is unsupported."
        }
    }
}
