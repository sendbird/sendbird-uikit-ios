//
//  UserDefaults+Ext.swift
//  SendbirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

extension UserDefaults {
    enum SampleInfoKeys: String {
        case basicUsagesAppId = "basic_usages_app_id"
        case chatBotAppId = "chat_bot_app_id"
        case customSampleAppId = "custom_sample_app_id"
        case businessMessagingAppId = "business_messaging_app_id"
        
        case basicUsagesUserId = "basic_usages_user_id"
        case chatBotUserId = "chat_bot_user_id"
        case customSampleUserId = "custom_sample_user_id"
        case businessMessagingUserId = "business_messaging_user_id"
        
        case basicUsagesNickname = "basic_usages_nickname"
        case chatBotNickname = "chat_bot_nickname"
        case customSampleNickname = "custom_sample_nickname"
        case businessMessagingNickname = "business_messaging_nickname"
        
        case basicUsagesWs = "basic_usages_wss"
        case chatBotWs = "chat_bot_wss"
        case customSampleWs = "custom_sample_wss"
        case businessMessagingWs = "business_messaging_wss"
        
        case basicUsagesAPI = "basic_usages_api"
        case chatBotAPI = "chat_bot_api"
        case customSampleAPI = "custom_sample_api"
        case businessMessagingAPI = "business_messaging_api"
        
        case basicUsagesRegion = "basic_usages_region"
        case chatBotRegion = "chat_bot_region"
        case customSampleRegion = "custom_sample_region"
        case businessMessagingRegion = "business_messaging_region"
        
        case chatBotBotId = "chat_bot_bot_id"
        
        case signedSampleApp = "signed_sample_app"
        
        case businessMessagingAuthType = "business_messaging_auth_type"
        
        case isLightTheme = "is_light_theme"
    }
    
    static var userDefault = UserDefaults(suiteName: "group.com.sendbird.uikit.sample") ?? UserDefaults.standard
    
    // MARK: Basic Usages
    static func loadAppId(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return userDefault.string(forKey: SampleInfoKeys.basicUsagesAppId.rawValue)
        case .chatBot:
            return userDefault.string(forKey: SampleInfoKeys.chatBotAppId.rawValue)
        case .customSample:
            return userDefault.string(forKey: SampleInfoKeys.customSampleAppId.rawValue)
        case .businessMessagingSample:
            return userDefault.string(forKey: SampleInfoKeys.businessMessagingAppId.rawValue)
        default:
            return nil
        }
    }
    
    static func saveAppId(type: SampleAppType, appId: String) {
        switch type {
        case .basicUsage:
            userDefault.set(appId, forKey: SampleInfoKeys.basicUsagesAppId.rawValue)
        case .chatBot:
            userDefault.set(appId, forKey: SampleInfoKeys.chatBotAppId.rawValue)
        case .customSample:
            userDefault.set(appId, forKey: SampleInfoKeys.customSampleAppId.rawValue)
        case .businessMessagingSample:
            userDefault.set(appId, forKey: SampleInfoKeys.businessMessagingAppId.rawValue)
        default:
            break
        }
    }
    
    static func loadUserId(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return userDefault.string(forKey: SampleInfoKeys.basicUsagesUserId.rawValue)
        case .chatBot:
            return userDefault.string(forKey: SampleInfoKeys.chatBotUserId.rawValue)
        case .customSample:
            return userDefault.string(forKey: SampleInfoKeys.customSampleUserId.rawValue)
        case .businessMessagingSample:
            return userDefault.string(forKey: SampleInfoKeys.businessMessagingUserId.rawValue)
        default:
            return nil
        }
    }
    
    static func saveUserId(type: SampleAppType, userId: String) {
        switch type {
        case .basicUsage:
            userDefault.set(userId, forKey: SampleInfoKeys.basicUsagesUserId.rawValue)
        case .chatBot:
            userDefault.set(userId, forKey: SampleInfoKeys.chatBotUserId.rawValue)
        case .customSample:
            userDefault.set(userId, forKey: SampleInfoKeys.customSampleUserId.rawValue)
        case .businessMessagingSample:
            userDefault.set(userId, forKey: SampleInfoKeys.businessMessagingUserId.rawValue)
        default:
            break
        }
    }
    
    static func loadNickname(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return userDefault.string(forKey: SampleInfoKeys.basicUsagesNickname.rawValue)
        case .chatBot:
            return userDefault.string(forKey: SampleInfoKeys.chatBotNickname.rawValue)
        case .customSample:
            return userDefault.string(forKey: SampleInfoKeys.customSampleNickname.rawValue)
        case .businessMessagingSample:
            return userDefault.string(forKey: SampleInfoKeys.businessMessagingNickname.rawValue)
        default:
            return nil
        }
    }
    
    static func saveNickname(type: SampleAppType, nickname: String) {
        switch type {
        case .basicUsage:
            userDefault.set(nickname, forKey: SampleInfoKeys.basicUsagesNickname.rawValue)
        case .chatBot:
            userDefault.set(nickname, forKey: SampleInfoKeys.chatBotNickname.rawValue)
        case .customSample:
            userDefault.set(nickname, forKey: SampleInfoKeys.customSampleNickname.rawValue)
        case .businessMessagingSample:
            userDefault.set(nickname, forKey: SampleInfoKeys.businessMessagingNickname.rawValue)
        default:
            break
        }
    }
    
    static func loadBotId() -> String? {
        return userDefault.string(forKey: SampleInfoKeys.chatBotBotId.rawValue)
    }
    
    static func saveBotId(botId: String) {
        userDefault.set(botId, forKey: SampleInfoKeys.chatBotBotId.rawValue)
    }
    
    static func saveSignedSampleApp(type: SampleAppType) {
        userDefault.set(type.rawValue, forKey: SampleInfoKeys.signedSampleApp.rawValue)
    }
    
    static func removeSignedSampleApp() {
        userDefault.set(SampleAppType.none.rawValue, forKey: SampleInfoKeys.signedSampleApp.rawValue)
    }
    
    static func loadSignedInSampleApp() -> SampleAppType {
        let type = userDefault.integer(forKey: SampleInfoKeys.signedSampleApp.rawValue)
        return SampleAppType(rawValue: type) ?? .none
    }
    
    static func saveAuthType(type: AuthType) {
        userDefault.set(type.rawValue, forKey: SampleInfoKeys.businessMessagingAuthType.rawValue)
    }
    
    static func loadAuthType() -> AuthType {
        let type = userDefault.integer(forKey: SampleInfoKeys.businessMessagingAuthType.rawValue)
        return AuthType(rawValue: type) ?? .authFeed
    }
    
    static func loadIsLightTheme() -> Bool {
        return userDefault.bool(forKey: SampleInfoKeys.isLightTheme.rawValue)
    }
    static func saveIsLightTheme(_ isLight: Bool) {
        userDefault.set(isLight, forKey: SampleInfoKeys.isLightTheme.rawValue)
    }
}
