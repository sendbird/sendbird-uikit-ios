//
//  SBUUser.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 26/02/2020.
//  Copyright © 2020 Tez Park. All rights reserved.
//

import UIKit
import SendBirdSDK

@objcMembers
public class SBUUser: NSObject {
    var userId: String
    var nickname: String?
    var profileUrl: String?
    
    public init(userId: String, nickname: String? = nil, profileUrl: String? = nil) {
        self.userId = userId
        self.nickname = nickname ?? userId
        self.profileUrl = profileUrl
    }
    
    public init(user: SBDUser) {
        self.userId = user.userId
        self.nickname = user.nickname
        self.profileUrl = user.profileUrl
    }
}
