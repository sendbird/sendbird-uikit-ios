//
//  SBUStringSet.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 05/03/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUStringSet {
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
    public static var PhotoVideoLibrary = "Photo library"
    public static var Document = "Files"
    public static var Loading = "Loading..."
    public static var Invite = "Invite"
    public static var TakePhoto = "Take photo"
    public static var ChoosePhoto = "Choose photo"
    public static var RemovePhoto = "Remove photo"
    public static var ViewLibrary = "View library"
    public static var Search = "Search"
    public static var Settings = "Settings"
    public static var Reply = "Reply"
    public static var Submit = "Submit" // 3.11.0
    
    // MARK: - Alert
    public static var Alert_Delete = "Are you sure you want to delete?"
    public static var Alert_Delete_MultipleFilesMessage: (Int) -> String = {
        return  "Do you want to delete all \($0) photos?"
    }
    public static var Alert_Allow_Camera_Access = "Please allow camera usage from settings"
    public static var Alert_Allow_PhotoLibrary_Access = "Please Allow PhotoLibrary Access"
    public static var Alert_Allow_PhotoLibrary_Access_Message = "PhotoLibrary access required to get your photos and videos"
    /// A text used to ask the user permission for microphone usage.
    public static var Alert_Allow_Microphone_Access = "Please allow microphone usage from settings"

    // MARK: - Date Format
    public static var Date_Yesterday = "Yesterday"
    public static var Date_Year: (Int) -> String = { interval in
        return String(format: "%lld%@", interval, (interval>1) ? "years" : "year")
    }
    public static var Date_Day: (Int) -> String = { interval in
        return String(format: "%lld%@", interval, (interval>1) ? "days" : "day")
    }
    public static var Date_Month: (Int) -> String = { interval in
        return String(format: "%lldmonth", interval)
    }
    public static var Date_Hour: (Int) -> String = { interval in
        return String(format: "%lldh", interval)
    }
    public static var Date_Min: (Int) -> String = { interval in
        return String(format: "%lldm", interval)
    }
    public static var Date_Ago = "ago"
    public static var Date_On = "on"

    // MARK: - Channel List
    public static var ChannelList_Header_Title = "Channels"
    public static var ChannelList_Last_File_Message = "uploaded a file."

    // MARK: - Channel
    public static var Channel_Name_Default = "Group Channel"
    public static var Channel_Name_No_Members = "(No members)"
    public static var Channel_Header_LastSeen = "Last seen"
    
    @available(*, deprecated, renamed: "Channel_Typing") // 3.0.0
    public static var Channel_Header_Typing: ([User]) -> String {
        { Channel_Typing($0) }
    }
    
    public static var Channel_Typing: ([User]) -> String = { members in
        switch members.count {
        case 1:
            let nickname = !members[0].nickname.isEmpty ? members[0].nickname : "Member"
            return String(format: "%@ is typing...", nickname)
        case 2:
            let nickname1 = !members[0].nickname.isEmpty ? members[0].nickname : "Member"
            let nickname2 = !members[1].nickname.isEmpty ? members[1].nickname : "Member"
            return String(format: "%@ and %@ are typing...", nickname1, nickname2)
        default:
            return "Several people are typing..."
        }
    }
    public static var Channel_Success_Download_file = "File saved."
    public static var Channel_Failure_Download_file = "Couldn’t download file."
    public static var Channel_Failure_Open_file = "Couldn’t open file."
    public static var Channel_New_Message_File = "uploaded a file"
    public static var Channel_New_Message: (Int) -> String = { count in
        switch count {
        case 1:
            return "1 new message"
        case 2...99:
            return "\(count) new messages"
        case 100...:
            return "99+ new messages"
        default:
            return ""
        }
    }
    public static var Channel_State_Banner_Frozen = "Channel frozen"
    
    // MARK: - Open Channel
    public static var Open_Channel_Name_Default = "Open Channel"
    public static var Open_Channel_Participants = "Participants"
    public static var Open_Channel_Participants_Count: (Int) -> String = { count in
        switch count {
        case 1:
            return "1 participant"
        default:
            return "\(count) participants"
        }
    }

    // MARK: - Notification Channel
    /// Custom type of the notification channel: `"SENDBIRD_NOTIFICATION_CHANNEL_NOTIFICATION"`
    public static let Notification_Channel_CustomType = "SENDBIRD_NOTIFICATION_CHANNEL_NOTIFICATION"
    
    /// Specifies the URL of the notification channel in a string form that belongs to the user with the specified `userId`: `"SENDBIRD_NOTIFICATION_CHANNEL_NOTIFICATION_{userId}"`
    public static var Notification_Channel_URL: (_ userId: String) -> String = { userId in
        return "\(SBUStringSet.Notification_Channel_CustomType)_\(userId)"
    }
    
    /// The default name of the notification channel: `"Notifications"`
    public static var Notification_Channel_Name_Default = "Notifications"

    // MARK: - Channel Setting
    public static var ChannelSettings_Header_Title = "Channel information"
    public static var ChannelSettings_Change_Name = "Change name"
    public static var ChannelSettings_Change_Image = "Change channel image"
    public static var ChannelSettings_Enter_New_Name = "Enter name"
    public static var ChannelSettings_Enter_New_Channel_Name = "Enter channel name"
    public static var ChannelSettings_Notifications = "Notifications"
    public static var ChannelSettings_Notifications_On = "On"
    public static var ChannelSettings_Notifications_Off = "Off"
    public static var ChannelSettings_Notifications_Mentiones_Only = "Mentions only"
    
    public static var ChannelSettings_Members_Title = "Members"
    public static var ChannelSettings_Participants_Title = "Participants"
    public static var ChannelSettings_Members: (UInt) -> String = { count in
        switch count {
        case 0:
            return "members"
        default:
            return "\(count) members"
        }
    }
    public static var ChannelSettings_Leave = "Leave channel"
    public static var ChannelSettings_Delete = "Delete channel"
    public static var ChannelSettings_Delete_Question_Mark = "Delete channel?"
    public static var ChannelSettings_Delete_Description = "Once deleted, this channel can't be restored."
    public static var ChannelSettings_Search = "Search in channel"
    
    public static var ChannelSettings_Moderations = "Moderations"
    public static var ChannelSettings_Operators = "Operators"
    public static var ChannelSettings_Muted_Members = "Muted members"
    public static var ChannelSettings_Muted_Participants = "Muted participants" // 3.0.0
    public static var ChannelSettings_Banned_Users = "Banned users"
    public static var ChannelSettings_Freeze_Channel = "Freeze channel"
    
    public static var ChannelSettings_URL = "URL"
    
    // MARK: Channel push settings
    public static var ChannelPushSettings_Header_Title = "Notifications"
    public static var ChannelPushSettings_Notification_Title = "Notifications"
    public static var ChannelPushSettings_Item_All = "All new messages"
    public static var ChannelPushSettings_Item_Mentions_Only = "Mentions only"
    public static var ChannelPushSettings_Notification_Description = "Turn on push notifications if you wish to be notified when messages are delivered to this channel."

    // MARK: - Message Input
    public static var MessageInput_Text_Placeholder = "Enter message"
    public static var MessageInput_Text_Unavailable = "Chat is unavailable in this channel"
    public static var MessageInput_Text_Muted = "You are muted"
    public static var MessageInput_Text_Reply = "Reply to message"
    public static var MessageInput_Reply_To: (String) -> String = { quotedMessageNickname in
        return "Reply to \(quotedMessageNickname)"
    }
    public static var MessageInput_Quote_Message_Photo = "Photo"
    public static var MessageInput_Quote_Message_GIF = "GIF"
    public static var MessageInput_Quote_Message_Video = "Video"

    // MARK: - Message
    public static var Message_Edited = "(edited)"
    public static var Message_System = "System message"
    public static var Message_Unknown_Title = "(Unknown message type)"
    public static var Message_Unknown_Description = "Can't read this message."
    public static var Message_Replied_To: (String, String) -> String = { replierNickname, quotedMessageNickname in
        return "\(replierNickname) replied to \(quotedMessageNickname)"
    }
    public static var Message_You = "You"
    
    /// - Since: 3.3.0
    public static var Message_Replied_Users_Count: (Int, Bool) -> String = { repliedUsersCount, countLimit in
        switch repliedUsersCount {
        case 1:
            return "1 reply"
        case 2...99:
            return "\(repliedUsersCount) replies"
        case 100...:
            return countLimit ? "99+ replies" : "\(repliedUsersCount) replies"
        default:
            return ""
        }
    }
    
    /// - Since: 3.3.0
    public static var Message_Reply_Cannot_Found_Original = "Couldn't find the original message for this reply."
    
    /// - Since: 3.3.0
    public static var Message_Unavailable = "Message unavailable"
    
    /// - Since: 3.12.0
    public static var Message_Typers_Count: (Int) -> String = { numberOfTypers in
        switch numberOfTypers {
        case 1...SBUConstant.maxNumberOfTypers:
            let remainingTypersCount = numberOfTypers - SBUConstant.maxNumberOfProfileImages
            return "+\(remainingTypersCount)"
        case (SBUConstant.maxNumberOfTypers + 1)...:
            return "+99"
        default:
            return ""
        }
    }
    
    /// - Since: 3.5.0
    public static var Notification_Template_Error_Title = "(Template error)"
    public static var Notification_Template_Error_Subtitle = "Can't read this notification."

    // MARK: - Empty
    public static var Empty_No_Channels = "No channels"
    public static var Empty_No_Messages = "No messages"
    public static var Empty_No_Notifications = "No notifications"
    public static var Empty_No_Users = "No users"
    public static var Empty_No_Muted_Members = "No muted members"
    public static var Empty_No_Muted_Participants = "No muted participants"
    public static var Empty_No_Banned_Users = "No banned users"
    public static var Empty_Search_Result = "No results found"
    public static var Empty_Wrong = "Something went wrong"

    // MARK: - Create Channel
    public static var CreateChannel_Create: (Int) -> String = { count in
        switch count {
        case 0:
            return "Create"
        default:
            return "Create \(count)"
        }
    }
    public static var CreateChannel_Header_Title = "New Channel"
    public static var CreateChannel_Header_Select_Members = "Select members"
    public static var CreateChannel_Header_Title_Profile = "New channel profile"
    
    // MARK: - Create Open Channel
    public static var CreateOpenChannel_Create = "Create"
    public static var CreateOpenChannel_Header_Title = "New channel"
    public static var CreateOpenChannel_ProfileInput_Placeholder = "Enter channel name"

    // MARK: - Invite Channel
    public static var InviteChannel_Header_Title = "Invite users"
    public static var InviteChannel_Header_Select_Users = "Select users"
    public static var InviteChannel_Invite: (Int) -> String = { count in
        switch count {
        case 0:
            return "Invite"
        default:
            return "Invite \(count)"
        }
    }
    public static var InviteChannel_Register: (Int) -> String = { count in
        switch count {
        case 0:
            return "Register"
        default:
            return "Register \(count)"
        }
    }

    // MARK: - User List
    public static var UserList_Me = "(You)"
    public static var UserList_Ban = "Ban"
    public static var UserList_Unban = "Unban"
    public static var UserList_Mute = "Mute"
    public static var UserList_Unmute = "Unmute"
    public static var UserList_Unregister_Operator = "Unregister operator"
    public static var UserList_Register_Operator = "Register as operator"
    public static var UserList_Title_Members = "Members"
    public static var UserList_Title_Operators = "Operators"
    public static var UserList_Title_Muted_Members = "Muted members"
    public static var UserList_Title_Muted_Participants = "Muted Participants" // 3.0.0
    public static var UserList_Title_Banned_Users = "Banned users"
    public static var UserList_Title_Participants = "Participants"
    
    // MARK: - User
    public static var User_No_Name = "(No name)"
    public static var User_Operator = "Operator"
    
    // MARK: - User profile
    public static var UserProfile_Role_Operator = "Operator"
    public static var UserProfile_Role_Member = "Member"
    public static var UserProfile_UserID = "User ID"
    public static var UserProfile_Message = "Message"
    public static var UserProfile_Register = "Register"
    public static var UserProfile_Unregister = "Unregister"
    public static var UserProfile_Mute = "Mute"
    public static var UserProfile_Unmute = "Unmute"
    public static var UserProfile_Ban = "Ban"
    
    // MARK: - Channel type
    public static var ChannelType_Group = "Group"
    public static var ChannelType_SuperGroup = "Super group"
    public static var ChannelType_Broadcast = "Broadcast"
    
    // MARK: - form type
    public static var FormType_Optional = "(optional)" // 3.11.0
    public static var FormType_Error_Default = "Please check the value" // 3.11.0
    
    // MARK: - Feedback
    public static var Feedback_Comment_Title = "Provide additional feedback (optional)" // 3.15.0
    public static var Feedback_Comment_Placeholder = "Leave a comment" // 3.15.0
    public static var Feedback_Edit_Comment = "Edit comment" // 3.15.0
    public static var Feedback_Remove = "Remove feedback" // 3.15.0
    public static var Feedback_Update_Done = "Successfully changed" // 3.15.0
    
    public class Mention {
        /// "@"
        public static let Trigger_Key: String = "@"
        
        /// e.g., "You can mention up to 10 times at a time."
        public static var Limit_Guide = "You can mention up to \(SBUGlobals.userMentionConfig?.mentionLimit ?? 10) times per message. "
    }
    
    // MARK: - MessageThreading
    /// - Since: 3.3.0
    public struct MessageThread {
        public struct Menu {
            public static var replyInThread = "Reply in thread"
        }
        
        public struct MessageInput {
            public static var replyInThread = "Reply in thread"
            public static var replyToThread = "Reply to thread"
        }
        
        public struct Header {
            public static var title = "Thread"
        }
    }
    
    // MARK: - Voice
    public struct VoiceMessage {
        public struct Input {
            /// A text for the cancel button in ``SBUVoiceMessageInputView``.
            public static var cancel = "Cancel"
        }
        
        public struct Alert {
            /// A text for an alert dialog that's displayed when a channel freezes while a user plays a voice message. The default text is `Channel is frozen.`.
            public static var frozen = "Channel is frozen."
            /// A text for an alert dialog that's displayed when a user is muted while playing a voice message. The default text is `You're muted by the operator.`.
            public static var muted = "You're muted by the operator."
        }
        
        public struct Preview {
            /// A text that indicates that a quoted message is a voice message. The default text is `Voice message`.
            public static var quotedMessage = "Voice message"
            /// A text that indicates that a voice message was sent to a group channel and appears in ``SBUGroupChannelCell`` in the group channel list view. The default text is `Voice message`.
            public static var channelList: String {
                get { SBUStringSet.GroupChannel.Preview.voice }
                set { SBUStringSet.GroupChannel.Preview.voice = newValue }
            }
            /// A text that's used in `SBUMessageSearchResultCell` to indicate that a search result is a voice message. The default text is `Voice message`.
            public static var searchResult = "Voice message"
        }
        /// A text that's used in a name of the voice message file.
        public static var fileName = "Voice_message"
    }
    
    // MARK: - GroupChannel
    
    /// Represents a set of strings related to `MultipleFilesMessage`.
    /// - since: 3.10.0
    public struct GroupChannel {
        public struct Preview {
            public static var photo = "Photo"
            public static var gif = "GIF"
            public static var video = "Video"
            public static var audio = "Audio"
            public static var voice = "Voice message"
            public static var file = "File"
            public static var multipleFiles = "Photo"
        }
    }
    
    /// Represents a set of strings related to uploading a file.
    /// - since: 3.10.0
    public struct FileUpload {
        public struct Error {
            public static var exceededSizeLimit = "The maximum size per file is \(SBUAvailable.uploadSizeLimitMB)MB."
        }
    }
}

extension SBUStringSet {
    @available(*, deprecated, renamed: "InviteChannel_Register")
    public static var InviteChannel_Add: (Int) -> String = { count in
        InviteChannel_Register(count)
    }
    
}
