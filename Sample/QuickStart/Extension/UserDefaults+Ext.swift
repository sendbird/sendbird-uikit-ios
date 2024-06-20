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
        
        case chatBotBotId = "chat_bot_bot_id"
        
        case signedSampleApp = "signed_sample_app"
        
        case businessMessagingAuthType = "business_messaging_auth_type"
        
        case isLightTheme = "is_light_theme"
    }
    
    // MARK: Basic Usages
    static func loadAppId(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.basicUsagesAppId.rawValue)
        case .chatBot:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotAppId.rawValue)
        case .customSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.customSampleAppId.rawValue)
        case .businessMessagingSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.businessMessagingAppId.rawValue)
        default:
            return nil
        }
    }
    
    static func saveAppId(type: SampleAppType, appId: String) {
        switch type {
        case .basicUsage:
            UserDefaults.standard.set(appId, forKey: SampleInfoKeys.basicUsagesAppId.rawValue)
        case .chatBot:
            UserDefaults.standard.set(appId, forKey: SampleInfoKeys.chatBotAppId.rawValue)
        case .customSample:
            UserDefaults.standard.set(appId, forKey: SampleInfoKeys.customSampleAppId.rawValue)
        case .businessMessagingSample:
            UserDefaults.standard.set(appId, forKey: SampleInfoKeys.businessMessagingAppId.rawValue)
        default:
            break
        }
    }
    
    static func loadUserId(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.basicUsagesUserId.rawValue)
        case .chatBot:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotUserId.rawValue)
        case .customSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.customSampleUserId.rawValue)
        case .businessMessagingSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.businessMessagingUserId.rawValue)
        default:
            return nil
        }
    }
    
    static func saveUserId(type: SampleAppType, userId: String) {
        switch type {
        case .basicUsage:
            UserDefaults.standard.set(userId, forKey: SampleInfoKeys.basicUsagesUserId.rawValue)
        case .chatBot:
            UserDefaults.standard.set(userId, forKey: SampleInfoKeys.chatBotUserId.rawValue)
        case .customSample:
            UserDefaults.standard.set(userId, forKey: SampleInfoKeys.customSampleUserId.rawValue)
        case .businessMessagingSample:
            UserDefaults.standard.set(userId, forKey: SampleInfoKeys.businessMessagingUserId.rawValue)
        default:
            break
        }
    }
    
    static func loadNickname(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.basicUsagesNickname.rawValue)
        case .chatBot:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotNickname.rawValue)
        case .customSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.customSampleNickname.rawValue)
        case .businessMessagingSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.businessMessagingNickname.rawValue)
        default:
            return nil
        }
    }
    
    static func saveNickname(type: SampleAppType, nickname: String) {
        switch type {
        case .basicUsage:
            UserDefaults.standard.set(nickname, forKey: SampleInfoKeys.basicUsagesNickname.rawValue)
        case .chatBot:
            UserDefaults.standard.set(nickname, forKey: SampleInfoKeys.chatBotNickname.rawValue)
        case .customSample:
            UserDefaults.standard.set(nickname, forKey: SampleInfoKeys.customSampleNickname.rawValue)
        case .businessMessagingSample:
            UserDefaults.standard.set(nickname, forKey: SampleInfoKeys.businessMessagingNickname.rawValue)
        default:
            break
        }
    }
    
    static func loadWebsocketHost(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.basicUsagesWs.rawValue)
        case .chatBot:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotWs.rawValue)
        case .customSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.customSampleWs.rawValue)
        case .businessMessagingSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.businessMessagingWs.rawValue)
        default:
            return nil
        }
    }
    
    static func saveWebsocketHost(type: SampleAppType, host: String) {
        switch type {
        case .basicUsage:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.basicUsagesWs.rawValue)
        case .chatBot:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.chatBotWs.rawValue)
        case .customSample:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.customSampleWs.rawValue)
        case .businessMessagingSample:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.businessMessagingWs.rawValue)
        default:
            break
        }
    }
    
    static func loadAPIHost(type: SampleAppType) -> String? {
        switch type {
        case .basicUsage:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.basicUsagesAPI.rawValue)
        case .chatBot:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotAPI.rawValue)
        case .customSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.customSampleAPI.rawValue)
        case .businessMessagingSample:
            return UserDefaults.standard.string(forKey: SampleInfoKeys.businessMessagingAPI.rawValue)
        default:
            return nil
        }
    }
    
    static func saveAPIHost(type: SampleAppType, host: String) {
        switch type {
        case .basicUsage:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.basicUsagesAPI.rawValue)
        case .chatBot:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.chatBotAPI.rawValue)
        case .customSample:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.customSampleAPI.rawValue)
        case .businessMessagingSample:
            UserDefaults.standard.set(host, forKey: SampleInfoKeys.businessMessagingAPI.rawValue)
        default:
            break
        }
    }
    
    static func loadBotId() -> String? {
        return UserDefaults.standard.string(forKey: SampleInfoKeys.chatBotBotId.rawValue)
    }
    
    static func saveBotId(botId: String) {
        UserDefaults.standard.set(botId, forKey: SampleInfoKeys.chatBotBotId.rawValue)
    }
    
    static func saveSignedSampleApp(type: SampleAppType) {
        UserDefaults.standard.set(type.rawValue, forKey: SampleInfoKeys.signedSampleApp.rawValue)
    }
    
    static func removeSignedSampleApp() {
        UserDefaults.standard.set(SampleAppType.none.rawValue, forKey: SampleInfoKeys.signedSampleApp.rawValue)
    }
    
    static func loadSignedInSampleApp() -> SampleAppType {
        let type = UserDefaults.standard.integer(forKey: SampleInfoKeys.signedSampleApp.rawValue)
        return SampleAppType(rawValue: type) ?? .none
    }
    
    static func saveAuthType(type: AuthType) {
        UserDefaults.standard.set(type.rawValue, forKey: SampleInfoKeys.businessMessagingAuthType.rawValue)
    }
    
    static func loadAuthType() -> AuthType {
        let type = UserDefaults.standard.integer(forKey: SampleInfoKeys.businessMessagingAuthType.rawValue)
        return AuthType(rawValue: type) ?? .authFeed
    }
    
    static func loadIsLightTheme() -> Bool {
        return UserDefaults.standard.bool(forKey: SampleInfoKeys.isLightTheme.rawValue)
    }
    static func saveIsLightTheme(_ isLight: Bool) {
        UserDefaults.standard.set(isLight, forKey: SampleInfoKeys.isLightTheme.rawValue)
    }
}
