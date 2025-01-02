//
//  SBUMessageTemplate.TemplateType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/19.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

extension SBUMessageTemplate {
    enum TemplateType {
        case notification
        case message
    }
    
    enum ThemeType: String {
        case light
        case dark
        case `default`
    }

}

extension SBUMessageTemplate.TemplateType {
    var cacheKey: String {
        switch self {
        case .notification: return "template" // NOTE: for backward
        case .message: return "message_template"
        }
    }
}

extension SBUMessageTemplate.ThemeType {
    static func type(with themeMode: String?) -> SBUMessageTemplate.ThemeType? {
        SBUMessageTemplate.ThemeType(rawValue: themeMode ?? "")
    }
}

extension SBUMessageTemplate.TemplateType {
    func getRemoteToken() -> Int64 {
        switch self {
        case .notification:
            return Int64(SendbirdChat.getAppInfo()?.notificationInfo?.templateListToken ?? "0") ?? 0

        case .message:
            return Int64(SendbirdChat.getAppInfo()?.messageTemplateInfo?.templateListToken ?? "0") ?? 0
        }
    }
    
    func loadTemplate(
        key: String,
        completionHandler: @escaping (_ payload: String?, _ error: Error?) -> Void
    ) {
        switch self {
        case .notification:
            SendbirdChat.getNotificationTemplate(key: key) { template, error in
                completionHandler(template?.jsonPayload, error)
            }

        case .message:
            SendbirdChat.getMessageTemplate(key: key) { template, error in
                completionHandler(template?.jsonPayload, error)
            }
        }
    }

    func loadTemplateList(
        token: String?,
        completionHandler: @escaping (_ payload: String?, _ token: String?) -> Void
    ) {
        switch self {
        case .notification:
            let params = NotificationTemplateListParams { $0.limit = 100 }
            SendbirdChat.getNotificationTemplateList(token: token, params: params) { templateList, _, token, _ in
                completionHandler(templateList?.jsonPayload, token)
            }
        case .message:
            let params = MessageTemplateListParams { $0.limit = 100 }
            SendbirdChat.getMessageTemplateList(token: token, params: params) { templateList, _, token, _ in
                completionHandler(templateList?.jsonPayload, token)
            }
        }
    }
    
    func loadTemplateList(
        keys: [String],
        completionHandler: @escaping (_ payload: String?, _ token: String?) -> Void
    ) {
        switch self {
        case .notification:
            let params = NotificationTemplateListParams {
                $0.limit = 100
                $0.keys = keys
            }
            SendbirdChat.getNotificationTemplateList(token: nil, params: params) { templateList, _, token, _ in
                completionHandler(templateList?.jsonPayload, token)
            }
        case .message:
            let params = MessageTemplateListParams {
                $0.limit = 100
                $0.keys = keys
            }
            SendbirdChat.getMessageTemplateList(token: nil, params: params) { templateList, _, token, _ in
                completionHandler(templateList?.jsonPayload, token)
            }
        }
    }
}

extension SBUMessageTemplate.TemplateType: MessageTemplateProvider {
#if canImport(SendbirdUIMessageTemplate)
    typealias TemplateModel = SendbirdUIMessageTemplate.MessageTemplate
#else
    typealias TemplateModel = MessageTemplate
#endif
    
    internal func provide(key: String) -> TemplateModel? {
        return SBUCacheManager
            .template(with: self)
            .getTemplate(forKey: key)
    }
}

extension SBUMessageTemplate.TemplateType {
    func payload(from message: BaseMessage) -> SBUMessageTemplate.TemplateType.Payload? {
        switch self {
        case .notification:
            guard let data = message.notifiationData else { return nil }
            return .init(messageId: message.messageId, key: data.templateKey, datas: data.templateVariables, views: [:])
        case .message:
            guard let data = message.templateMessageData else { return nil }
            return .init(messageId: message.messageId, key: data.key, datas: data.variables, views: data.viewVariables)
        }
    }
    
    struct Payload {
        let messageId: Int64
        let key: String
        let datas: [String: Any]
        let views: [String: [SendbirdChatSDK.TemplateMessageData.SimpleTemplateData]]
    }
}
