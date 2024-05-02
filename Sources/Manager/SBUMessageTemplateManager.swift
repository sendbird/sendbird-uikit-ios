//
//  SBUMessageTemplateManager.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/02/17.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUMessageTemplateManager: NSObject {
    
    /// Resets notification template cache
    /// - Since: 3.21.0
    public static func resetNotificationTemplateCache() {
        SBUCacheManager.template(with: .notification).resetCache()
    }
    
    /// Resets message template cache
    /// - Since: 3.21.0
    public static func resetMessageTemplateCache() {
        SBUCacheManager.template(with: .group).resetCache()
    }
    
    static let exeucuteQueue = DispatchQueue(label: "com.sendbird.message_template.images")
}

// MARK: - Template list
extension SBUMessageTemplateManager {
    
    // original
    static func generateTemplate(
        type: SBUTemplateType,
        subData: String?,
        themeMode: String? = nil,
        newTemplateResponseHandler: ((_ success: Bool) -> Void)? = nil
    ) -> (String?, Bool) { // bindedTemplate, isNewTemplate
        guard let subData = subData else { return (nil, false) }
        
        // data scheme
        var templateVariables: [String: String] = [:]
        var templateKey: String?
        do {
            if let subDataDic = try JSONSerialization.jsonObject(
                with: Data(subData.utf8),
                options: []
            ) as? [String: Any],
               let templateKeyValue = subDataDic[type.templateKey] as? String {
                let templateVariablesDic = subDataDic[type.dataVariable] as? [String: Any] ?? [:]
                for key in templateVariablesDic.keys {
                    templateVariables[key] = "\(templateVariablesDic[key] ?? "")"
                }
                
                templateKey = templateKeyValue
            }
        } catch {
            SBULog.error(error.localizedDescription)
        }
        
        guard let templateKey = templateKey,
              let template = SBUMessageTemplateManager.template(
                type: type,
                templateKey: templateKey,
                newTemplateResponseHandler: newTemplateResponseHandler
              ) else {
            return (nil, true) // request NewTemplate
        }
        
        // color variabled
        var colorVariables: [String: String] = [:]
        do {
            if let colorVariablesDic = try JSONSerialization.jsonObject(
                with: Data(template.colorVariables.utf8),
                options: []
            ) as? [String: Any] {
                
                for key in colorVariablesDic.keys {
                    colorVariables[key] = "\(colorVariablesDic[key] ?? "")"
                }
            }
            
        } catch {
            SBULog.error(error.localizedDescription)
        }
        
        var colorVariablesForLight: [String: String] = [:]
        var colorVariablesForDark: [String: String] = [:]
        for (key, value) in colorVariables {
            let colorStrings = value.components(separatedBy: ",")
            if colorStrings.count > 1, let first = colorStrings.first, first.isEmpty {
                return (nil, false)
            }
            
            var lightIdx = 0
            var darkIdx = (colorStrings.count == 1) ? 0 : 1
            
            switch SBUTemplateThemeType.type(with: themeMode) {
            case .light: darkIdx = lightIdx
            case .dark: lightIdx = darkIdx
            case .`default`: break
            default: break
            }
            
            colorVariablesForLight[key] = colorStrings[lightIdx]
            colorVariablesForDark[key] = colorStrings[darkIdx]
        }
        
        var uiTemplate = template.uiTemplate
        uiTemplate = uiTemplate.replacingOccurrences(of: "\\n", with: "\n")
        
        // bind
        switch SBUTheme.colorScheme {
        case .light:
            let result = bind(
                uiTemplate: uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForLight
            )
            return (result, false)
        case .dark:
            let result = bind(
                uiTemplate: uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForDark
            )
            return (result, false)
        }
    }
    
    // original
    static func template(
        type: SBUTemplateType,
        templateKey: String,
        newTemplateResponseHandler: ((_ success: Bool) -> Void)? = nil
    ) -> SBUMessageTemplate.TemplateModel? {
        let cache = SBUCacheManager.template(with: type)

        if let template = cache.getTemplate(forKey: templateKey) {
            return template
        } else {
            type.loadTemplate(key: templateKey) { jsonPayload, error in
                guard let jsonPayload = jsonPayload, let jsonData = jsonPayload.data(using: .utf8) else {
                    newTemplateResponseHandler?(false)
                    return
                }

                do {
                    if let templateDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                       let template = try SBUMessageTemplate.TemplateModel.createTemplate(with: templateDic) {
                        cache.save(templates: [template])
                        _ = cache.loadAllTemplates()
                        newTemplateResponseHandler?(true)
                    }
                } catch {
                    newTemplateResponseHandler?(false)
                    SBULog.error(error.localizedDescription)
                }
            }
            return nil
        }
    }
    
    // original
    fileprivate static func bind(
        uiTemplate: String,
        templateVariables: [String: String],
        colorVariable: [String: String]
    ) -> String? {
//        {([^{}\n]+)}
//        \\{([^{}\\\"\\n]+)\\}
        guard let regex = try? NSRegularExpression(
            pattern: "\\{([^{}\\\"\\n]+)\\}",
            options: []
        ) else { return nil }
        let dictionary = templateVariables.merging(colorVariable) { (_, new) in new }
        var resultTemplate = uiTemplate

        let matches = regex.matches(
            in: uiTemplate,
            options: [],
            range: NSRange(location: 0, length: uiTemplate.utf16.count)
        )
        for match in matches.reversed() {
            let keyRange = match.range(at: 1)
            let key = (uiTemplate as NSString).substring(with: keyRange)
            if let value = dictionary[key] {
                let escapedValue = value.replacingOccurrences(of: "\"", with: "\\\"")
                resultTemplate = resultTemplate.replacingOccurrences(
                    of: "{\(key)}",
                    with: escapedValue,
                    options: [],
                    range: Range(match.range, in: resultTemplate)
                )
            }
        }
        
        return resultTemplate
    }
   
}

// for view model
extension SBUMessageTemplateManager {
    static func loadTemplateList(
        type: SBUTemplateType,
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let cache = SBUCacheManager.template(with: type)
        
        let cachedToken = Int64(cache.lastToken) ?? 0
        let serverToken = type.getRemoteToken()
        
        guard cachedToken < serverToken else {
            let success = cache.loadAllTemplates() != nil
            completionHandler?(success)
            return
        }
        
        type.loadTemplateList(token: cache.lastToken) { jsonPayload, token in
            let responseJson = jsonPayload ?? ""
            
            guard let jsonData = responseJson.data(using: .utf8) else {
                completionHandler?(false)
                return
            }
            
            let templateList = SBUMessageTemplate.TemplateList(with: jsonData)
            
            cache.save(templates: templateList.templates)
            cache.lastToken = token ?? ""
            cache.loadAllTemplates()
            
            completionHandler?(true)           
        }
    }
    
    static func loadTemplateImages(
        type: SBUTemplateType,
        cacheData: [String: String],
        completionHandler: ((_ success: Bool) -> Void)?
    ) {
        let dispatchGroup = DispatchGroup()
        var loadCount = 0
        
        exeucuteQueue.async {
            for (_, url) in cacheData {
                dispatchGroup.enter()
                
                let fileName = SBUCacheManager.Image.createCacheFileName(
                    urlString: url,
                    cacheKey: nil
                )
                
                if SBUCacheManager.Image.get(
                    fileName: fileName,
                    subPath: SBUCacheManager.PathType.template
                ) != nil {
                    loadCount += 1
                    dispatchGroup.leave()
                    return
                }
                
                UIImageView.getOriginalImage(
                    urlString: url,
                    subPath: SBUCacheManager.PathType.template
                ) { image, _ in
                    if image != nil {
                        loadCount += 1
                    }
                    dispatchGroup.leave()
                }
            }
            
            let result = dispatchGroup.wait(timeout: .now() + .seconds(10)) // timeout: 10 second
        
            Thread.executeOnMain {
                switch result {
                case .success:
                    completionHandler?(cacheData.count == loadCount)
                case .timedOut:
                    completionHandler?(false)
                }
            }
        }
    }
}

extension Array where Element == String {
    func toJsonString() -> String? { "[\(self.joined(separator: ","))]" }
}
