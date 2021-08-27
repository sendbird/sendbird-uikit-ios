//
//  CustomSampleEnums.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/03.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

// MARK: - Enums for Manager
enum GlobalCustomType: Int {
    case colorSet
    case fontSet
    case iconSet
    case stringSet
    case theme
}

enum ChannelListCustomType: Int {
    case uiComponent
    case customCell
    case listQuery
    case functionOverriding
}

enum ChannelCustomType: Int {
    case uiComponent
    case customCell
    case messageListParams
    case messageParams
    case functionOverriding
}

enum ChannelSettingsCustomType: Int {
    case uiComponent
    case functionOverriding
}

enum CreateChannelCustomType: Int {
    case uiComponent
    case customCell
    case userList
}

enum InviteUserCustomType: Int {
    case uiComponent
    case customCell
    case userList
}

enum MemberListCustomType: Int {
    case uiComponent
    case customCell
    case functionOverriding
}



// MARK: - Enum for CustomBaseViewController
enum CustomSection: Int, CaseIterable {
    case Default = 0
    case Global
    case ChannelList
    case Channel
    case ChannelSettings
    case CreateChannel
    case InviteUser
    case MemberList
    
    var title: String { return String(describing: self) }
    var index: Int { return self.rawValue }
    static func customItems(section: Int) -> [String] {
        let sectionIdx = CustomSection(rawValue: section)
        switch sectionIdx {
        case .Default:
            return ["Default"]
        case .Global:
            return ["Color set",
                    "Font set",
                    "Icon set",
                    "String set",
                    "Theme"]
        case .ChannelList:
            return ["UI Component",
                    "Custom cell",
                    "ChannelListQuery",
                    "Function Overriding"]
        case .Channel:
            return ["UI Component",
                    "Custom cell",
                    "MessageListParams",
                    "MessageParams",
                    "Function Overriding"]
        case .ChannelSettings:
            return ["UI Component",
                    "Function Overriding"]
        case .CreateChannel:
            return ["UI Component",
                    "Custom cell",
                    "User list"]
        case .InviteUser:
            return ["UI Component",
                    "Custom cell",
                    "User list"]
        case .MemberList:
            return ["UI Component",
                    "Custom cell",
                    "Function Overriding"]
        case .none:
            return []
        }
    }
    
    static func customItemDescriptions(section: Int) -> [String] {
        let sectionIdx = CustomSection(rawValue: section)
        switch sectionIdx {
        case .Default:
            return [""]
        case .Global:
            return ["[GlobalSetCustomManager setCustomGlobalColorSet()]",
                    "[GlobalSetCustomManager setCustomGlobalFontSet()]",
                    "[GlobalSetCustomManager setCustomGlobalIconSet()]",
                    "[GlobalSetCustomManager setCustomGlobalStringSet()]",
                    "[GlobalSetCustomManager setCustomGlobalTheme()]"]
        case .ChannelList:
            return ["[ChannelListCustomManager uiComponentCustom()]",
                    "[ChannelListCustomManager cellCustom()]",
                    "[ChannelListCustomManager listQueryCustom()]",
                    "ChannelListVC_Overriding.swift"]
        case .Channel:
            return ["[ChannelCustomManager uiComponentCustom()]",
                    "[ChannelCustomManager cellCustom()]",
                    "[ChannelCustomManager messageListParamsCustom()]",
                    "[ChannelCustomManager messageParamsCustom()]",
                    "ChannelVC_MessageParam.swift"]
        case .ChannelSettings:
            return ["[ChannelSettingsCustomManager uiComponentCustom()]",
                    "ChannelSettingsVC_Overriding.swift"]
        case .CreateChannel:
            return ["[CreateChannelCustomManager uiComponentCustom()]",
                    "[CreateChannelCustomManager cellCustom()]",
                    "CreateChannelVC_UserList.swift"]
        case .InviteUser:
            return ["[InviteUserCustomManager uiComponentCustom()]",
                    "[InviteUserCustomManager cellCustom()]",
                    "InviteUserVC_UserList.swift"]
        case .MemberList:
            return ["[MemberListCustomManager uiComponentCustom()]",
                    "[MemberListCustomManager cellCustom()]",
                    "MemberListVC_Overriding.swift"]
        case .none:
            return []
        }
    }
}
