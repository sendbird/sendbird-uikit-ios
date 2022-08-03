//
//  SBUMention.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/04/11.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

import UIKit

/// The class that contains the information of a mentioned text.
public class SBUMention: Equatable {
    /// The location of the mention within the attributed string of the `UITextView`
    public var range: NSRange
    
    /// A mentioned user.
    public private(set) var user: SBUUser
    
    public init(range: NSRange, user: SBUUser) {
        self.range = range
        self.user = user
    }
    
    public static func == (lhs: SBUMention, rhs: SBUMention) -> Bool {
        return lhs.range == rhs.range && lhs.user.nickname == rhs.user.nickname
    }
}
