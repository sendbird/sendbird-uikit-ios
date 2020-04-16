//
//  SBUUser.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 26/02/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
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
    
    /// This method returns the default value if there is no alias value.
    /// - since: 1.0.1
    public func refinedNickname() -> String {
        if let nickname = self.nickname, nickname.count > 0 {
            return nickname
        } else {
            return SBUStringSet.User_No_Name
        }
    }
}
