//
//  Array+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/16.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit


public extension Array where Element: SBUUser {
    func sbu_getUserIds() -> [String] {
        let userIds: [String] = self.map ({ $0.userId })
        return userIds
    }
    
    func sbu_getUserNicknames() -> [String] {
        let userNicknames: [String] = self.map ({ $0.refinedNickname() })
        return userNicknames
    }
}

public extension Array where Element: SBDUser {
    func sbu_convertUserList() -> [SBUUser] {
        let userList = self.map { SBUUser(user: $0) }
        return userList
    }
}

public extension Array where Element: SBDMember {
    func sbu_convertUserList() -> [SBUUser] {
        let userList = self.map { SBUUser(member: $0) }
        return userList
    }
}


public extension NSArray {
    // For SBUUser type array
    @objc func sbu_getUserIds() -> [String] {
        guard let users = self as? [SBUUser] else { return [] }
        return users.sbu_getUserIds()
    }
    
    @objc func sbu_getUserNicknames() -> [String] {
        guard let users = self as? [SBUUser] else { return [] }
        return users.sbu_getUserNicknames()
    }
    
    // For SBDUser type array
    @objc func sbu_convertUserList() -> [SBUUser] {
        guard let users = self as? [SBDUser] else { return [] }
        return users.sbu_convertUserList()
    }
}
