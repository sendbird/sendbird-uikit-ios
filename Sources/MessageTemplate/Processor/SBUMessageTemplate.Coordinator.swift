//
//  SBUMessageTemplate.Coordinator.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import Foundation
import SendbirdChatSDK

extension SBUMessageTemplate.Coordinator {
    enum ResultType {
        case reload(ReloadType)
        case template(key: String, template: SBUMessageTemplate.Syntax.TemplateView)
        case failed
        
        enum ReloadType {
            case download(DownloadType)
        }
        
        enum DownloadType {
            case template(keys: [String])
            case images(cacheData: [String: String])
        }
        
        var template: SBUMessageTemplate.Syntax.TemplateView? {
            switch self {
            case .template(_, let template): return template
            default: return nil
            }
        }
    }
}

extension SBUMessageTemplate {
    class Coordinator {
        static func execute(
            type: SBUTemplateType,
            message: BaseMessage,
            payloadJson: String?,
            themeMode: String? = nil,
            imageRetryStatus: SBUTemplateMessageRetryStatus
        ) -> SBUMessageTemplate.Coordinator.ResultType? {
            guard let payload = SBUMessageTemplate.Payload.generate(type: type, json: payloadJson) else {
                return .failed
            }
            
            // main template.
            guard let template = SBUCacheManager.template(with: type).getTemplate(forKey: payload.key) else {
                return .reload(.download(.template(keys: [payload.key])))
            }
            
            // child templates from view data. (can be empty)
            guard let children = SBUCacheManager.template(with: type).getTemplateList(forKeys: payload.viewKeys) else {
                return .reload(.download(.template(keys: payload.viewKeys)))
            }
            
            // data mapping
            guard let result = SBUMessageTemplate.Binder.bind(
                template: template,
                children: children,
                payload: payload,
                themeMode: themeMode
            ) else {
                return .failed
            }
            
            // child views mapping
            guard let template = SBUMessageTemplate.Syntax.TemplateView.generate(
                json: result,
                messageId: message.messageId
            ) else {
                return .failed
            }
            
            // download cache image size
//            if let noHitData = template.identifierFactory.getUncachedData(), noHitData.hasElements {
//                if imageRetryStatus.isRetry {
//                    return .reload(.download(.images(cacheData: [:])))
//                }
//                return .reload(.download(.images(cacheData: noHitData)))
//            }
            
            return .template(key: payload.key, template: template)
        }
    }
}
