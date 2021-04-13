//
//  Array+SBUIKit.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 2020/07/16.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK


public extension Array where Element: SBUUser {
    /// This is a function that extracts the userId array using the `SBUUser` type array.
    /// - Returns: userId `String` type array
    func sbu_getUserIds() -> [String] {
        let userIds: [String] = self.map ({ $0.userId })
        return userIds
    }
    
    /// This is a function that extracts the nickname array using the `SBUUser` type array.
    /// - Returns: nickname `String` type array
    func sbu_getUserNicknames() -> [String] {
        let userNicknames: [String] = self.map ({ $0.refinedNickname() })
        return userNicknames
    }
}

public extension Array where Element: SBDUser {
    /// This is a function that extracts the `SBUUser` array using the `SBDUser` type array.
    /// - Returns: `SBUUser`  type array
    func sbu_convertUserList() -> [SBUUser] {
        let userList = self.map { SBUUser(user: $0) }
        return userList
    }
}

public extension Array where Element: SBDMember {
    /// This is a function that extracts the `SBUUser` array using the `SBDMember` type array.
    /// - Returns: `SBUUser`  type array
    func sbu_convertUserList() -> [SBUUser] {
        let userList = self.map { SBUUser(member: $0) }
        return userList
    }
}


public extension NSArray {
    /// This is a function that extracts the userId array using the `SBUUser` type array.
    /// This is a function used in Objective-C.
    /// - Returns: userId `String` type array
    @objc func sbu_getUserIds() -> [String] {
        guard let users = self as? [SBUUser] else { return [] }
        return users.sbu_getUserIds()
    }
    
    /// This is a function that extracts the nickname array using the `SBUUser` type array.
    /// This is a function used in Objective-C.
    /// - Returns: nickname `String` type array
    @objc func sbu_getUserNicknames() -> [String] {
        guard let users = self as? [SBUUser] else { return [] }
        return users.sbu_getUserNicknames()
    }
    
    /// This is a function that extracts the `SBUUser` array using the `SBDUser` type array.
    /// This is a function used in Objective-C.
    /// - Returns: `SBUUser`  type array
    @objc func sbu_convertUserList() -> [SBUUser] {
        guard let users = self as? [SBDUser] else { return [] }
        return users.sbu_convertUserList()
    }
}
