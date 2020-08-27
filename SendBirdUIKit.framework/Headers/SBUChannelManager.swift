//
//  SBUChannelManager.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/06/18.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

class SBUChannelManager: NSObject {
    
    /// This function can check whether my role is an operator in the channel.
    /// - Parameters:
    ///   - channel: GroupChannel object
    /// - Returns: Returns `true` if it is an operator.
    /// - Since: 1.0.10
    static func isOperator(channel: SBDGroupChannel?) -> Bool {
        guard let channel = channel else { return false }
        
        if channel.myRole == .operator {
            return true
        }
        else {
            return false
        }
    }
}
