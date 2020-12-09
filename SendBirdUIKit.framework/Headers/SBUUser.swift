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
    public private(set) var userId: String
    public private(set) var nickname: String?
    public private(set) var profileUrl: String?
    
    /// This is an operator state property.
    /// - Since: 1.2.0
    public private(set) var isOperator: Bool = false
    
    /// This is a muted state property.
    /// - Since: 1.2.0
    public private(set) var isMuted: Bool = false
    
    
    // MARK: - User
    /// This function initializes using the userId, nickname, and profileUrl.
    /// - Parameters:
    ///   - userId: userId
    ///   - nickname: nickname (default: nil), If not set this value, sets with userId.
    ///   - profileUrl: profileUrl (default: nil)
    public init(userId: String, nickname: String? = nil, profileUrl: String? = nil) {
        self.userId = userId
        self.nickname = nickname
        self.profileUrl = profileUrl
    }
    
    /// This function initializes using the user object.
    /// - Parameter user: User obejct
    public init(user: SBDUser) {
        self.userId = user.userId
        self.nickname = user.nickname
        self.profileUrl = user.profileUrl
    }
    
    /// This function initializes using the user object, operator state, and muted state.
    /// - Parameters:
    ///   - user: `SBUUser` object
    ///   - isOperator: If the user is the operator, sets the value to `true`.
    ///   - isMuted: If the user is the muted, sets the value to `true`.
    public init(user: SBUUser, isOperator: Bool = false, isMuted: Bool = false) {
        self.userId = user.userId
        self.nickname = user.nickname
        self.profileUrl = user.profileUrl
        self.isOperator = isOperator
        self.isMuted = isMuted
    }
    
    
    // MARK: - Member
    /// This function initializes using the member object.
    /// - Parameter member: `SBDMember` obejct
    public init(member: SBDMember) {
        self.userId = member.userId
        self.nickname = member.nickname
        self.profileUrl = member.profileUrl
        self.isOperator = member.role == .operator
        self.isMuted = member.isMuted
    }
    
    // MARK: - Sender
    /// This function initializes using the sender object.
    /// - Parameter sender: `SBDSender` obejct
    public init(sender: SBDSender) {
        self.userId = sender.userId
        self.nickname = sender.nickname
        self.profileUrl = sender.profileUrl
        self.isOperator = sender.role == .operator
    }
    
    
    // MARK: - Common
    /// This method returns the default value if there is no alias value.
    /// - since: 1.0.1
    public func refinedNickname() -> String {
        if let nickname = self.nickname, nickname.count > 0 {
            return nickname
        } else {
            return SBUStringSet.User_No_Name
        }
    }
    
    public override var description: String {
        return String(
            format: "UserId:%@, Nickname:%@, ProfileUrl:%@, Operator:%d Muted:%d",
            self.userId,
            self.nickname ?? "",
            self.profileUrl ?? "",
            self.isOperator,
            self.isMuted
        )
    }
}
