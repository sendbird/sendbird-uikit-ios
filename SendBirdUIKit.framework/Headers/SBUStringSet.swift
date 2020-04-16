//
//  SBUStringSet.swift
//  SendBirdUIKit
//
//  Created by Tez Park on 05/03/2020.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUStringSet: NSObject {
    // MARK: - Common
    public static var Cancel = "Cancel"
    public static var OK = "OK"
    public static var Retry = "Retry"
    public static var Save = "Save"
    public static var Copy = "Copy"
    public static var Delete = "Delete"
    public static var Edit = "Edit"
    public static var Remove = "Remove"
    public static var Camera = "Camera"
    public static var PhotoVideoLibrary = "Photos and videos"
    public static var Document = "Files"
    public static var Loading = "Loading..."
    public static var Invite = "Invite"

    // MARK: - Alert
    public static var Alert_Delete = "Are you sure you want to delete?"


    // MARK: - Date Format
    public static var Date_Yesterday = "Yesterday"
    public static var Date_Year: (Int) -> String = { interval in
        return String(format :"%lld%@", interval, (interval>1) ? "years" : "year")
    }
    public static var Date_Day: (Int) -> String = { interval in
        return String(format :"%lld%@", interval, (interval>1) ? "days" : "day")
    }
    public static var Date_Month: (Int) -> String = { interval in
        return String(format :"%lldmonth", interval)
    }
    public static var Date_Hour: (Int) -> String = { interval in
        return String(format :"%lldh", interval)
    }
    public static var Date_Min: (Int) -> String = { interval in
        return String(format :"%lldm", interval)
    }
    public static var Date_Ago = "ago"
    public static var Date_On = "on"


    // MARK: - Channel List
    public static var ChannelList_Header_Title = "Channels"
    public static var ChannelList_Last_File_Message = "uploaded a file."


    // MARK: - Channel
    public static var Channel_Name_Default = "Group Channel" // Just for default name checking
    public static var Channel_Name_No_Members = "(No members)"
    public static var Channel_Header_LastSeen = "Last seen"
    public static var Channel_Header_Typing: ([SBDMember]) -> String = { members in

        switch members.count {
        case 1:
            return String(format: "%@ is typing...", members[0].nickname ?? "Member")
        case 2:
            return String(format: "%@ and %@ are typing...", members[0].nickname ?? "Member", members[1].nickname ?? "Member")
        default:
            return "Several people are typing..."
        }
    }
    public static var Channel_Success_Download_file = "File saved."
    public static var Channel_New_Message_File = "uploaded a file"
    public static var Channel_New_Message: (Int) -> String = { count in
        switch count {
        case 1:
            return "1 new message"
        default:
            return "\(count) new messages"
        }
    }


    // MARK: - Channel Setting
    public static var ChannelSettings_Header_Title = "Channel information"
    public static var ChannelSettings_Change_Name = "Change name"
    public static var ChannelSettings_Change_Image = "Change channel image"
    public static var ChannelSettings_Enter_New_Name = "Enter name"
    public static var ChannelSettings_Notifications = "Notifications"
    public static var ChannelSettings_Members: (UInt) -> String = { count in
        switch count {
        case 0:
            return "members"
        default:
            return "\(count) members"
        }
    }
    public static var ChannelSettings_Leave = "Leave channel"


    // MARK: - Message Input
    public static var MessageInput_Text_Placeholder = "Type a message"


    // MARK: - Message
    public static var Message_Edited = "(Edited)"
    public static var Message_System = "System message"


    // MARK: - Empty
    public static var Empty_No_Channels = "No channels"
    public static var Empty_No_Messages = "No messages"
    public static var Empty_No_Users = "No users"
    public static var Empty_Wrong = "Something went wrong"


    // MARK: - Create Channel
    public static var CreateChannel_Create: (Int) -> String = { count in
        switch count {
        case 0:
            return "Create"
        default:
            return "\(count) Create"
        }
    }
    public static var CreateChannel_Header_Title = "New Channel"


    // MARK: - Invite Channel
    public static var InviteChannel_Header_Title = "Invite users"
    public static var InviteChannel_Invite: (Int) -> String = { count in
        switch count {
        case 0:
            return "Invite"
        default:
            return "\(count) Invite"
        }
    }


    // MARK: - Member List
    public static var MemberList_Header_Title = "Members"
    public static var MemberList_Me = "(You)"
    
    
    // MARK: - User
    public static var User_No_Name = "(No name)"
}
