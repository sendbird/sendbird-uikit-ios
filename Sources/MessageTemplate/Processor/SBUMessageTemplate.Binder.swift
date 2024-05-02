//
//  SBUMessageTemplate.Binder.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/03/14.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

extension SBUMessageTemplate {
    class Binder {
        static func bind(
            template: TemplateModel,
            children: [String: TemplateModel],
            payload: SBUMessageTemplate.Payload,
            themeMode: String?
        ) -> String? {
            // 1. binding root template.
            guard let rootData = bindDataPayload(
                template: template,
                payload: payload,
                themeMode: themeMode
            ) else { return nil }
            
            if children.isEmpty == true { return rootData }
            
            // 2. create child templates data to bind.
            let childrenData = payload.views.reduce(into: [String: String]()) { result, view in
                result[view.key] = view.value.compactMap { (child: Payload.Child) -> String? in
                    guard let template = children[child.key] else { return nil }
                    return bindDataPayload(
                        template: template,
                        payload: child,
                        themeMode: themeMode
                    )
                }
                .toJsonString()
            }
            
            // 3. binding child templates data
            let result = BindingType.view.replace(
                with: rootData,
                datas: childrenData
            )
            
            return result
        }
    }
}

extension SBUMessageTemplate.Binder {
    fileprivate static func bindDataPayload(
        template: SBUMessageTemplate.TemplateModel,
        payload: MessageTemplatePayload,
        themeMode: String?
    ) -> String? {
        guard let colors = self.themeColorData(
            template: template,
            themeMode: themeMode
        ) else { return nil }
        
        let result = BindingType.data.replace(
            with: template.uiTemplateRemovedEscape,
            datas: payload.datas.merging(colors) { (_, new) in new } // override by colors
        )
        
        return result
    }
    
    fileprivate static func themeColorData(
        template: SBUMessageTemplate.TemplateModel,
        themeMode: String?
    ) -> [String: String]? {
        let variables = template.colorDictionary
        let result = variables.reduce(into: [String: String]()) { result, element in
            let colors = element.value.components(separatedBy: ",")
            var target: String?
            switch (colors.count, SBUTemplateThemeType.type(with: themeMode)) {
            case (1, _): target = colors[0]
            case (2, .light): target = colors[0]
            case (2, .dark): target = colors[1]
            default: target = colors[SBUTheme.colorScheme == .light ? 0 : 1]
            }
            
            if let target = target, target.hasElements {
                result[element.key] = target
            }
        }
        
        if result.count != variables.count { return nil } // 필요한가??
        
        return result
    }
}

extension SBUMessageTemplate.Binder {
    enum BindingType {
        case data
        case view
    }
}

extension SBUMessageTemplate.Binder.BindingType {
    func replace(with json: String, datas: [String: String]) -> String {
        var result = json
        
        for match in self.matches(with: json).reversed() {
            let keyRange = match.range(at: 1)
            let key = (json as NSString).substring(with: keyRange)
            
            if let value = datas[key] {
                let escapedValue = self.replaceEscape(with: value)
                result = result.replacingOccurrences(
                    of: self.key(key),
                    with: escapedValue,
                    options: [],
                    range: Range(match.range, in: result)
                )
            }
        }
        
        return result
    }
}
    
extension SBUMessageTemplate.Binder.BindingType {
    private func key(_ key: String) -> String {
        switch self {
        case .data: return #"{\#(key)}"#
        case .view: return #""{@\#(key)}""#
        }
    }
    
    private var pattern: String {
        switch self {
        case .data: return #"\{([^{}\\"\n]+)\}"# // `{data_key}`
        case .view: return #"\"\{@([^{}\n]+)\}\""# // `"{@view_key}"`
        }
    }
    
    private var regex: NSRegularExpression? {
        try? NSRegularExpression(pattern: self.pattern, options: [])
    }
    
    private func replaceEscape(with value: String) -> String {
        switch self {
        case .data: return value.replacingOccurrences(of: "\"", with: "\\\"")
        case .view: return value
        }
    }
    
    private func matches(with json: String) -> [NSTextCheckingResult] {
        self.regex?.matches(
            in: json,
            options: [],
            range: NSRange(location: 0, length: json.utf16.count)
        ) ?? []
    }
}
