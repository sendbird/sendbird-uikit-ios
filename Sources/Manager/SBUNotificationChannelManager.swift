//
//  SBUNotificationChannelManager.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/26.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUNotificationChannelManager: NSObject {
    static var notificationChannelThemeMode: String = {
        SBUCacheManager.NotificationSetting.themeMode
    }()
    
    /// Resets template cache
    /// - Since: 3.6.0
    public static func resetTemplateCache() {
        SBUCacheManager.Template.resetCache()
    }
    
    /// Resets notification setting cache
    /// - Since: 3.6.0
    public static func resetNotificationSettingCache() {
        SBUCacheManager.NotificationSetting.resetCache()
    }
}

// MARK: - Notification Channel Global Settings
extension SBUNotificationChannelManager {
    static func loadGlobalNotificationChannelSettings(completionHandler: ((_ success: Bool) -> Void)?) {
        let cachedUpdatedAt = SBUCacheManager.NotificationSetting.lastUpdatedTime
        let serverUpdatedAt = SendbirdChat.getAppInfo()?.notificationInfo?.settingsUpdatedAt ?? 0
        
        let loadCompletionHandler: (
            ([SBUNotificationChannelManager.GlobalNotificationSettings.Theme]?) -> Void
        ) = { loadedTheme in
            guard let loadedThemes = loadedTheme else {
                completionHandler?(false)
                return
            }
            
            let themeMode = SBUCacheManager.NotificationSetting.themeMode
            
            if loadedThemes.count > 0 {
                let notificationTheme = loadedThemes[0]
                // INFO: Currently only one theme is used. Structured with the theme array for further expansion.
                self.setGlobalNotificationChannelTheme(
                    with: notificationTheme,
                    globalThemeMode: themeMode
                )
            }
            
            completionHandler?(true)
        }
        
        if cachedUpdatedAt < serverUpdatedAt {
            SendbirdChat.getGlobalNotificationChannelSetting { globalNotificationChannelSetting, error in
                guard error == nil else {
                    SBULog.error(error)
                    completionHandler?(false)
                    return
                }
                
                let responseJson = globalNotificationChannelSetting?.jsonPayload ?? ""

                if let settings = self.parseNotificationChannelSettings(responseJson) {
                    SBUCacheManager.NotificationSetting.save(settings: settings)
                    SBUCacheManager.NotificationSetting.lastUpdatedTime = settings.updatedAt
                    
                    loadCompletionHandler(settings.themes)
                } else {
                    completionHandler?(false)
                }
            }
        } else { // updatedAt 조건 안걸리면 cache 된 templateList 만 로드시켜둠
            let loadedThemes = SBUCacheManager.NotificationSetting.loadAllThemesArray()
            loadCompletionHandler(loadedThemes)
        }
    }
    
    static func parseNotificationChannelSettings(_ json: String) -> GlobalNotificationSettings? {
        if let jsonData = json.data(using: .utf8) {
            do {
                let settings = try JSONDecoder().decode(
                    GlobalNotificationSettings.self,
                    from: jsonData
                )
                
                return settings
            } catch {
                SBULog.error(error)
                return nil
            }
        }
        return nil
    }
    
    static func setGlobalNotificationChannelTheme(
        with globalTheme: GlobalNotificationSettings.Theme,
        globalThemeMode: String
    ) {
        SBUNotificationTheme.light = self.makeGlobalNotificationChannelTheme(
            with: globalTheme,
            globalThemeMode: globalThemeMode,
            colorScheme: .light
        )
        SBUNotificationTheme.dark = self.makeGlobalNotificationChannelTheme(
            with: globalTheme,
            globalThemeMode: globalThemeMode,
            colorScheme: .dark
        )
    }
    
    static func makeGlobalNotificationChannelTheme(
        with globalTheme: GlobalNotificationSettings.Theme,
        globalThemeMode: String,
        colorScheme: SBUThemeColorScheme
    ) -> SBUNotificationTheme {
        
        let fallbackMessageDefaultTheme = colorScheme == .light
        ? SBUNotificationTheme.NotificationCell.defaultLight
        : SBUNotificationTheme.NotificationCell.defaultDark
        
        let theme = SBUNotificationTheme(
            header: SBUNotificationTheme.Header(
                buttonIconTintColor: color(with: globalTheme.header.buttonIconTintColor, themeMode: globalThemeMode, for: colorScheme),
                lineColor: color(with: globalTheme.header.lineColor, themeMode: globalThemeMode, for: colorScheme),
                backgroundColor: color(with: globalTheme.header.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                textSize: globalTheme.header.textSize,
                textColor: color(with: globalTheme.header.textColor, themeMode: globalThemeMode, for: colorScheme),
                fontWeight: globalTheme.header.fontWeight ?? .bold
            ),
            list: SBUNotificationTheme.List(
                backgroundColor: color(with: globalTheme.list.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                tooltipBackgroundColor: color(with: globalTheme.list.tooltip.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                tooltipTextColor: color(with: globalTheme.list.tooltip.textColor, themeMode: globalThemeMode, for: colorScheme),
                tooltipTextSize: globalTheme.list.tooltip.textSize ?? 14.0,
                tooltipFontWeight: globalTheme.list.tooltip.fontWeight ?? .bold,
                timelineBackgroundColor: color(with: globalTheme.list.timeline.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                timelineTextColor: color(with: globalTheme.list.timeline.textColor, themeMode: globalThemeMode, for: colorScheme),
                timelineTextSize: globalTheme.list.timeline.textSize ?? 12.0,
                timelineFontWeight: globalTheme.list.timeline.fontWeight ?? .bold
            ),
            notificationCell: SBUNotificationTheme.NotificationCell(
                radius: globalTheme.notification.radius,
                backgroundColor: color(with: globalTheme.notification.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                unreadIndicatorColor: color(with: globalTheme.notification.unreadIndicatorColor, themeMode: globalThemeMode, for: colorScheme),
                categoryTextSize: globalTheme.notification.category.textSize,
                categoryFontWeight: globalTheme.notification.category.fontWeight ?? .bold,
                categoryTextColor: color(with: globalTheme.notification.category.textColor, themeMode: globalThemeMode, for: colorScheme),
                sentAtTextSize: globalTheme.notification.sentAt.textSize,
                sentAtFontWeight: globalTheme.notification.sentAt.fontWeight ?? .normal,
                sentAtTextColor: color(with: globalTheme.notification.sentAt.textColor, themeMode: globalThemeMode, for: colorScheme),
                pressedColor: color(with: globalTheme.notification.pressedColor, themeMode: globalThemeMode, for: colorScheme),
                fallbackMessageTitleHexColor: fallbackMessageDefaultTheme.fallbackMessageTitleHexColor,
                fallbackMessageSubtitleHexColor: fallbackMessageDefaultTheme.fallbackMessageSubtitleHexColor
            )
        )
        return theme
    }
}

// MARK: - Template list
extension SBUNotificationChannelManager {
    static func loadTemplateList(completionHandler: ((_ success: Bool) -> Void)?) {
        
        let cachedToken = Int64(SBUCacheManager.Template.lastToken) ?? 0
        let serverToken = Int64(SendbirdChat.getAppInfo()?.notificationInfo?.templateListToken ?? "0") ?? 0
        
        if cachedToken < serverToken {
            let params = NotificationTemplateListParams { params in
                params.limit = 100
            }
            
            SendbirdChat.getNotificationTemplateList(
                token: SBUCacheManager.Template.lastToken,
                params: params
            ) { notificationTemplateList, _, token, _ in
                let responseJson = notificationTemplateList?.jsonPayload ?? ""
                
                if let jsonData = responseJson.data(using: .utf8) {
                    let templateList = TemplateList(with: jsonData)
                    
                    SBUCacheManager.Template.save(templates: templateList.templates)
                    SBUCacheManager.Template.lastToken = token ?? ""
                    
                    SBUCacheManager.Template.loadAllTemplates()
                    
                    completionHandler?(true)
                } else {
                    completionHandler?(false)
                }
            }
        } else { // updatedAt 조건 안걸리면 cache 된 templateList 만 로드시켜둠
            if SBUCacheManager.Template.loadAllTemplates() != nil {
                completionHandler?(true)
                return
            }
            
            completionHandler?(false)
        }
    }
    
    static func template(
        with key: String,
        newTemplateResponseHandler: ((_ success: Bool) -> Void)? = nil
    ) -> SBUNotificationChannelManager.TemplateList.Template? {
        if let template = SBUCacheManager.Template.getTemplate(forKey: key) {
            return template
        } else {
            SendbirdChat.getNotificationTemplate(key: key) { notificationTemplate, error in
                if let jsonData = notificationTemplate?.jsonPayload.data(using: .utf8) {
                    do {
                        if let templateDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let template = try createTemplate(with: templateDic) {
                            SBUCacheManager.Template.save(templates: [template])
                            _ = SBUCacheManager.Template.loadAllTemplates()
                            newTemplateResponseHandler?(true)
                        }
                    } catch {
                        newTemplateResponseHandler?(false)
                        SBULog.error(error.localizedDescription)
                    }
                } else {
                    newTemplateResponseHandler?(false)
                }
            }
            return nil
        }
    }
    
    static func createTemplate(with templateDic: [String: Any]) throws -> TemplateList.Template? {
        if let key = templateDic["key"] as? String,
           let name = templateDic["name"] as? String,
           let createdAt = templateDic["created_at"] as? Int64,
           let updatedAt = templateDic["updated_at"] as? Int64 {

            let uiTemplate = templateDic["ui_template"] as? [String: Any] ?? [:]
            let colorVariables = templateDic["color_variables"] as? [String: Any] ?? [:]
            
            let uiTemplateJson = try JSONSerialization.data(withJSONObject: uiTemplate, options: [])
            let uiTemplateJsonStr = String(data: uiTemplateJson, encoding: .utf8)

            let colorVariablesJson = try JSONSerialization.data(withJSONObject: colorVariables, options: [])
            let colorVariablesJsonStr = String(data: colorVariablesJson, encoding: .utf8)
            
            let template = TemplateList.Template(
                key: key,
                name: name,
                uiTemplate: uiTemplateJsonStr ?? "",
                colorVariables: colorVariablesJsonStr ?? "",
                createdAt: createdAt,
                updatedAt: updatedAt
            )
            
            return template
        }
        return nil
    }
    
    static func generateTemplate(
        with subData: String?,
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
               let templateKeyValue = subDataDic["template_key"] as? String {
                let templateVariablesDic = subDataDic["template_variables"] as? [String: Any] ?? [:]
                for key in templateVariablesDic.keys {
                    templateVariables[key] = "\(templateVariablesDic[key] ?? "")"
                }
                
                templateKey = templateKeyValue
            }
        } catch {
            SBULog.error(error.localizedDescription)
        }
        
        guard let templateKey = templateKey,
              let template = SBUNotificationChannelManager.template(
                with: templateKey,
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
        
        let themeMode = self.notificationChannelThemeMode
        
        var colorVariablesForLight: [String: String] = [:]
        var colorVariablesForDark: [String: String] = [:]
        for (key, value) in colorVariables {
            let colorStrings = value.components(separatedBy: ",")
            if colorStrings.count > 1, let first = colorStrings.first, first.isEmpty {
                return (nil, false)
            }
            
            var lightIdx = 0
            var darkIdx = (colorStrings.count == 1) ? 0 : 1
            
            switch themeMode {
            case "light": darkIdx = lightIdx
            case "dark": lightIdx = darkIdx
            case "default": break
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
            return (bind(
                uiTemplate: uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForLight
            ), false)
        case .dark:
            return (bind(
                uiTemplate: uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForDark
            ), false)
        }
    }
    
    static func bind(
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
                resultTemplate = resultTemplate.replacingOccurrences(
                    of: "{\(key)}",
                    with: value,
                    options: [],
                    range: Range(match.range, in: resultTemplate)
                )
            }
        }
        
        return resultTemplate
    }
}

// MARK: - Common
extension SBUNotificationChannelManager {
    static func color(
        with colors: String, // hexColors: "#000000,#ffffff"
        themeMode: String,   // light, dark, default
        for themeColorScheme: SBUThemeColorScheme
    ) -> UIColor {
        let colorStrings = colors.components(separatedBy: ",")
        let colorArray: [UIColor]
        
        let lightIdx = 0
        let darkIdx = (colorStrings.count == 1) ? 0 : 1
        
        switch themeMode {
        case "light":
            colorArray = [
                UIColor(hexString: colorStrings[lightIdx]),
                UIColor(hexString: colorStrings[lightIdx])
            ]
        case "dark":
            colorArray = [
                UIColor(hexString: colorStrings[darkIdx]),
                UIColor(hexString: colorStrings[darkIdx])
            ]
        case "default":
            colorArray = [
                UIColor(hexString: colorStrings[lightIdx]),
                UIColor(hexString: colorStrings[darkIdx])
            ]
        default:
            colorArray = [
                UIColor(hexString: colorStrings[lightIdx]),
                UIColor(hexString: colorStrings[darkIdx])
            ]
        }
        
        switch themeColorScheme {
        case .light:
            return colorArray[0]
        case .dark:
            return colorArray[1]
        }
    }
}

// MARK: - GlobalNotificationSettings object
extension SBUNotificationChannelManager {
    struct GlobalNotificationSettings: Codable {
        struct Theme: Codable {
            struct Notification: Codable {
                struct Category: Codable {
                    let textColor: String
                    let textSize: CGFloat
                    let fontWeight: SBUFontWeightType? // 3.5.8
                }
                
                struct SentAt: Codable {
                    let textColor: String
                    let textSize: CGFloat
                    let fontWeight: SBUFontWeightType? // 3.5.8
                }

                let radius: CGFloat
                let backgroundColor: String
                let unreadIndicatorColor: String
                let pressedColor: String
                let category: Category
                let sentAt: SentAt
            }
            
            struct List: Codable {
                struct Tooltip: Codable {
                    let backgroundColor: String
                    let textColor: String
                    let textSize: CGFloat? // 3.5.8
                    let fontWeight: SBUFontWeightType? // 3.5.8
                }

                struct Timeline: Codable {
                    let backgroundColor: String
                    let textColor: String
                    let textSize: CGFloat? // 3.5.8
                    let fontWeight: SBUFontWeightType? // 3.5.8
                }

                let backgroundColor: String
                let tooltip: Tooltip
                let timeline: Timeline
            }

            struct Header: Codable {
                let textColor: String
                let textSize: CGFloat
                let fontWeight: SBUFontWeightType? // 3.5.8
                let buttonIconTintColor: String
                let backgroundColor: String
                let lineColor: String
            }

            let key: String
            let createdAt: Int64
            let updatedAt: Int64
            
            let notification: Notification
            let list: List
            let header: Header
            
            enum CodingKeys: String, CodingKey {
                case key, createdAt = "created_at", updatedAt = "updated_at", notification, list, header
            }
        }
        
        let updatedAt: Int64
        let themes: [Theme]
        let themeMode: String
        
        enum CodingKeys: String, CodingKey {
            case updatedAt = "updated_at"
            case themes
            case themeMode = "theme_mode"
        }
    }
}

// MARK: - TemplateList object
extension SBUNotificationChannelManager {
    struct TemplateList {
        var templates: [Template] = []

        init(with jsonData: Data) {
            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                   let templateList = json["templates"] as? [[String: Any]] {
                    for templateDic in templateList {
                        if let template = try createTemplate(with: templateDic) {
                            self.templates.append(template)
                        }
                    }
                }
            } catch {
                SBULog.error(error.localizedDescription)
            }
        }

        struct Template: Codable {
            let key: String // unique
            let name: String
            let uiTemplate: String // JSON_OBJECT
            let colorVariables: String // JSON_OBJECT
            let createdAt: Int64
            let updatedAt: Int64
        }
    }
}
