//
//  SBUChannelManager.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/06/18.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class SBUChannelManager: NSObject {
    
    /// This function can check whether a specific UserId is an operator in the channel.
    /// - Parameters:
    ///   - channel: GroupChannel object
    ///   - userId: used to verify that it is an operator
    /// - Returns: Returns `true` if it is an operator.
    /// - Since: 1.0.10
    static func isOperator(channel: SBDGroupChannel?, userId: String?) -> Bool {
        guard let channel = channel, let userId = userId else { return false }
        
        if let role = channel.getMember(userId)?.role, role == .operator {
            return true
        }
        else {
            return false
        }
    }
}
