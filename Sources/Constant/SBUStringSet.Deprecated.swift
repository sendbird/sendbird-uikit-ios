//
//  SBUStringSet.Deprecated.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2022/07/06.
//  Copyright © 2022 Sendbird, Inc. All rights reserved.
//

extension SBUStringSet {
    
    // MARK: - 3.0.0
    
    @available(*, deprecated, renamed: "ChannelSettings_Banned_Users") // 3.0.0
    public static var ChannelSettings_Banned_Members: String {
        get { SBUStringSet.ChannelSettings_Banned_Users }
        set { SBUStringSet.ChannelSettings_Banned_Users = newValue }
    }
    
    @available(*, deprecated, renamed: "Empty_No_Banned_Users") // 3.0.0
    public static var Empty_No_Banned_Members: String {
        get { SBUStringSet.Empty_No_Banned_Users }
        set { SBUStringSet.Empty_No_Banned_Users = newValue }
    }
    
    @available(*, deprecated, renamed: "InviteChannel_Header_Select_Users") // 3.0.0
    public static var InviteChannel_Header_Select_Members: String {
        get { SBUStringSet.InviteChannel_Header_Select_Users }
        set { SBUStringSet.InviteChannel_Header_Select_Users = newValue }
    }
    
    @available(*, unavailable) // 3.0.0
    public static var MemberList_Header_Title: String { "" }
    @available(*, deprecated, renamed: "UserList_Me") // 3.0.0
    public static var MemberList_Me: String {
        get { SBUStringSet.UserList_Me }
        set { SBUStringSet.UserList_Me = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Ban") // 3.0.0
    public static var MemberList_Ban: String {
        get { SBUStringSet.UserList_Ban }
        set { SBUStringSet.UserList_Ban = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Unban") // 3.0.0
    public static var MemberList_Unban: String {
        get { SBUStringSet.UserList_Unban }
        set { SBUStringSet.UserList_Unban = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Mute") // 3.0.0
    public static var MemberList_Mute: String {
        get { SBUStringSet.UserList_Mute }
        set { SBUStringSet.UserList_Mute = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Unmute") // 3.0.0
    public static var MemberList_Unmute: String {
        get { SBUStringSet.UserList_Unmute }
        set { SBUStringSet.UserList_Unmute = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Unregister_Operator") // 3.0.0
    public static var MemberList_Dismiss_Operator: String {
        get { SBUStringSet.UserList_Unregister_Operator }
        set { SBUStringSet.UserList_Unregister_Operator = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Register_Operator") // 3.0.0
    public static var MemberList_Promote_Operator: String {
        get { SBUStringSet.UserList_Register_Operator }
        set { SBUStringSet.UserList_Register_Operator = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Title_Members") // 3.0.0
    public static var MemberList_Title_Members: String {
        get { SBUStringSet.UserList_Title_Members }
        set { SBUStringSet.UserList_Title_Members = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Title_Operators") // 3.0.0
    public static var MemberList_Title_Operators: String {
        get { SBUStringSet.UserList_Title_Operators }
        set { SBUStringSet.UserList_Title_Operators = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Title_Muted_Members") // 3.0.0
    public static var MemberList_Title_Muted_Members: String {
        get { SBUStringSet.UserList_Title_Muted_Members }
        set { SBUStringSet.UserList_Title_Muted_Members = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Title_Banned_Users") // 3.0.0
    public static var MemberList_Title_Banned_Members: String {
        get { SBUStringSet.UserList_Title_Banned_Users }
        set { SBUStringSet.UserList_Title_Banned_Users = newValue }
    }
    @available(*, deprecated, renamed: "UserList_Title_Participants") // 3.0.0
    public static var MemberList_Title_Participants: String {
        get { SBUStringSet.UserList_Title_Participants }
        set { SBUStringSet.UserList_Title_Participants = newValue }
    }
    
    @available(*, deprecated, renamed: "UserProfile_Register") // 3.0.0
    public static var UserProfile_Promote: String {
        get { SBUStringSet.UserProfile_Register }
        set { SBUStringSet.UserProfile_Register = newValue }
    }
    @available(*, deprecated, renamed: "UserProfile_Unregister") // 3.0.0
    public static var UserProfile_Dismiss: String {
        get { SBUStringSet.UserProfile_Unregister }
        set { SBUStringSet.UserProfile_Unregister = newValue }
    }
}
