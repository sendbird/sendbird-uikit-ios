//
//  SBUMessageTemplate.Payload.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

protocol MessageTemplatePayload {
    var key: String { get }
    var datas: [String: String] { get }
}

extension SBUMessageTemplate {
    struct Payload: MessageTemplatePayload {
        let key: String
        let datas: [String: String]
        let views: [String: [Payload.Child]]
        
        var viewKeys: [String] {
            self.views.reduce(into: [String]()) { result, views in result += views.value.compactMap { $0.key } }
        }
    }
}

extension SBUMessageTemplate.Payload {
    static func generate(
        type: SBUTemplateType,
        json: String?
    ) -> SBUMessageTemplate.Payload? {
        guard let json = json else { return nil }
        
        do {
            guard let dic = try JSONSerialization.jsonObject(with: Data(json.utf8), options: []) as? [String: Any] else { return nil }
            guard let key = dic[type.templateKey] as? String else { return nil }
            
            let datas = (dic[type.dataVariable] as? [String: Any] ?? [:])
                .reduce(into: [String: String]()) { result, element in
                    result[element.key] = "\(element.value)"
                }
            
            let views = (dic[type.viewVariable] as? [String: [Any]] ?? [:])
                .reduce(into: [String: [SBUMessageTemplate.Payload.Child]]()) { result, element in
                    result[element.key] = element.value.compactMap {
                        SBUMessageTemplate.Payload.Child.generate(type: type, data: $0)
                    }
                }
            
            return SBUMessageTemplate.Payload(key: key, datas: datas, views: views)
        } catch {
            SBULog.error(error.localizedDescription)
            return nil
        }
    }
}

extension SBUMessageTemplate.Payload {
    struct Child: MessageTemplatePayload {
        let key: String
        let datas: [String: String]
    }
}

extension SBUMessageTemplate.Payload.Child {
    static func generate(
        type: SBUTemplateType,
        data: Any?
    ) -> SBUMessageTemplate.Payload.Child? {
        guard let data = data else { return nil }
        
        do {
            guard let json = try? JSONSerialization.data(withJSONObject: data, options: []) else { return nil }
            guard let dic = try JSONSerialization.jsonObject(with: json, options: []) as? [String: Any] else { return nil }
            guard let key = dic[type.templateKey] as? String else { return nil }
            
            let datas = (dic[type.dataVariable] as? [String: Any] ?? [:])
                .reduce(into: [String: String]()) { $0[$1.key] = "\($1.value)" }
            
            return SBUMessageTemplate.Payload.Child(key: key, datas: datas)
        } catch {
            SBULog.error(error.localizedDescription)
            return nil
        }
    }
}
