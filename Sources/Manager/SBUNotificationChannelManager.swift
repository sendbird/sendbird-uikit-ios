//
//  SBUNotificationChannelManager.swift
//  QuickStart
//
//  Created by Tez Park on 2023/02/26.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

class SBUNotificationChannelManager: NSObject {
    static var notificationChannelThemeMode: String = {
        SBUCacheManager.NotificationSetting.themeMode
    }()
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
                let responseJson = globalNotificationChannelSetting?.jsonPayload ?? ""

                if let jsonData = responseJson.data(using: .utf8) {
                    do {
                        let settings = try JSONDecoder().decode(
                            GlobalNotificationSettings.self,
                            from: jsonData
                        )
                        
                        SBUCacheManager.NotificationSetting.save(settings: settings)
                        SBUCacheManager.NotificationSetting.lastUpdatedTime = settings.updatedAt
                        
                        loadCompletionHandler(settings.themes)
                    } catch {
                        SBULog.error(error)
                        completionHandler?(false)
                        return
                    }
                }
            }
        } else { // updatedAt 조건 안걸리면 cache 된 templateList 만 로드시켜둠
            let loadedThemes = SBUCacheManager.NotificationSetting.loadAllThemesArray()
            loadCompletionHandler(loadedThemes)
        }
    }
    
    static func setGlobalNotificationChannelTheme(
        with globalTheme: GlobalNotificationSettings.Theme,
        globalThemeMode: String
    ) {
        // TODO: notification - need to improvement
        let lightTheme = SBUNotificationTheme(
            header: SBUNotificationTheme.Header(
                buttonIconTintColor: color(with: globalTheme.header.buttonIconTintColor, themeMode: globalThemeMode, for: .light),
                lineColor: color(with: globalTheme.header.lineColor, themeMode: globalThemeMode, for: .light),
                backgroundColor: color(with: globalTheme.header.backgroundColor, themeMode: globalThemeMode, for: .light),
                textSize: globalTheme.header.textSize,
                textColor: color(with: globalTheme.header.textColor, themeMode: globalThemeMode, for: .light)
            ),
            list: SBUNotificationTheme.List(
                backgroundColor: color(with: globalTheme.list.backgroundColor, themeMode: globalThemeMode, for: .light),
                tooltipBackgroundColor: color(with: globalTheme.list.tooltip.backgroundColor, themeMode: globalThemeMode, for: .light),
                tooltipTextColor: color(with: globalTheme.list.tooltip.textColor, themeMode: globalThemeMode, for: .light),
                timelineBackgroundColor: color(with: globalTheme.list.timeline.backgroundColor, themeMode: globalThemeMode, for: .light),
                timelineTextColor: color(with: globalTheme.list.timeline.textColor, themeMode: globalThemeMode, for: .light)
            ),
            notificationCell: SBUNotificationTheme.NotificationCell(
                radius: globalTheme.notification.radius,
                backgroundColor: color(with: globalTheme.notification.backgroundColor, themeMode: globalThemeMode, for: .light),
                unreadIndicatorColor: color(with: globalTheme.notification.unreadIndicatorColor, themeMode: globalThemeMode, for: .light),
                categoryTextSize: globalTheme.notification.category.textSize,
                categoryTextColor: color(with: globalTheme.notification.category.textColor, themeMode: globalThemeMode, for: .light),
                sentAtTextSize: globalTheme.notification.sentAt.textSize,
                sentAtTextColor: color(with: globalTheme.notification.sentAt.textColor, themeMode: globalThemeMode, for: .light),
                pressedColor: color(with: globalTheme.notification.pressedColor, themeMode: globalThemeMode, for: .light),
                fallbackMessageTitleHexColor: SBUNotificationTheme.NotificationCell.defaultLight.fallbackMessageTitleHexColor,
                fallbackMessageSubtitleHexColor: SBUNotificationTheme.NotificationCell.defaultLight.fallbackMessageSubtitleHexColor
            )
        )
        
        let darkTheme = SBUNotificationTheme(
            header: SBUNotificationTheme.Header(
                buttonIconTintColor: color(with: globalTheme.header.buttonIconTintColor, themeMode: globalThemeMode, for: .dark),
                lineColor: color(with: globalTheme.header.lineColor, themeMode: globalThemeMode, for: .dark),
                backgroundColor: color(with: globalTheme.header.backgroundColor, themeMode: globalThemeMode, for: .dark),
                textSize: globalTheme.header.textSize,
                textColor: color(with: globalTheme.header.textColor, themeMode: globalThemeMode, for: .dark)
            ),
            list: SBUNotificationTheme.List(
                backgroundColor: color(with: globalTheme.list.backgroundColor, themeMode: globalThemeMode, for: .dark),
                tooltipBackgroundColor: color(with: globalTheme.list.tooltip.backgroundColor, themeMode: globalThemeMode, for: .dark),
                tooltipTextColor: color(with: globalTheme.list.tooltip.textColor, themeMode: globalThemeMode, for: .dark),
                timelineBackgroundColor: color(with: globalTheme.list.timeline.backgroundColor, themeMode: globalThemeMode, for: .dark),
                timelineTextColor: color(with: globalTheme.list.timeline.textColor, themeMode: globalThemeMode, for: .dark)
            ),
            notificationCell: SBUNotificationTheme.NotificationCell(
                radius: globalTheme.notification.radius,
                backgroundColor: color(with: globalTheme.notification.backgroundColor, themeMode: globalThemeMode, for: .dark),
                unreadIndicatorColor: color(with: globalTheme.notification.unreadIndicatorColor, themeMode: globalThemeMode, for: .dark),
                categoryTextSize: globalTheme.notification.category.textSize,
                categoryTextColor: color(with: globalTheme.notification.category.textColor, themeMode: globalThemeMode, for: .dark),
                sentAtTextSize: globalTheme.notification.sentAt.textSize,
                sentAtTextColor: color(with: globalTheme.notification.sentAt.textColor, themeMode: globalThemeMode, for: .dark),
                pressedColor: color(with: globalTheme.notification.pressedColor, themeMode: globalThemeMode, for: .dark),
                fallbackMessageTitleHexColor: SBUNotificationTheme.NotificationCell.defaultDark.fallbackMessageTitleHexColor,
                fallbackMessageSubtitleHexColor: SBUNotificationTheme.NotificationCell.defaultDark.fallbackMessageSubtitleHexColor
            )
        )
        
        SBUNotificationTheme.light = lightTheme
        SBUNotificationTheme.dark = darkTheme
    }
}


// MARK: - Template list
extension SBUNotificationChannelManager {
    static func loadTemplateList(completionHandler: ((_ success: Bool) -> Void)?) {
        
        let cachedToken = Int64(SBUCacheManager.Template.lastToken) ?? 0
        let serverToken = Int64(SendbirdChat.getAppInfo()?.notificationInfo?.templateListToken ?? "0") ?? 0
        
        if (cachedToken < serverToken) {
            let params = NotificationTemplateListParams { params in
                params.limit = 100
            }
            
            SendbirdChat.getNotificationTemplateList(
                token: nil,
                params: params
            ) { notificationTemplateList, hasMore, token, error in
                let responseJson = notificationTemplateList?.jsonPayload ?? ""
                
                if let jsonData = responseJson.data(using: .utf8) {
                    let templateList = TemplateList(with: jsonData)
                    
                    SBUCacheManager.Template.save(templates: templateList.templates)
                    SBUCacheManager.Template.lastToken = token ?? ""
                    
                    let _ = SBUCacheManager.Template.loadAllTemplates()
                    
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
    
    static func template(with key: String, completionHandler: (() -> Void)? = nil) -> SBUNotificationChannelManager.TemplateList.Template? {
        if let template = SBUCacheManager.Template.getTemplate(forKey: key) {
            return template
        } else {
            SendbirdChat.getNotificationTemplate(key: key) { notificationTemplate, error in
                if let jsonData = notificationTemplate?.jsonPayload.data(using: .utf8) {
                    do {
                        if let templateDic = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
                           let template = try createTemplate(with: templateDic)
                        {
                            SBUCacheManager.Template.save(templates: [template])
                            let _ = SBUCacheManager.Template.loadAllTemplates()
                            completionHandler?()
                        }
                    } catch {
                        SBULog.error(error.localizedDescription)
                    }
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
    
    static func generateTemplate(with subData: String?, completionHandler: (() -> Void)? = nil) -> String? {
        guard let subData = subData else { return nil }
        
        // data scheme
        var templateVariables : [String: String] = [:]
        var templateKey: String? = nil
        do {
            if let subDataDic = try JSONSerialization.jsonObject(
                with: Data(subData.utf8),
                options: []
            ) as? [String: Any],
               let templateKeyValue = subDataDic["template_key"] as? String
            {
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
              let template = SBUNotificationChannelManager.template(with: templateKey, completionHandler: completionHandler) else {
            return nil
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
                return nil
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
        
        
        // bind
        switch SBUTheme.colorScheme {
        case .light:
            return bind(
                uiTemplate: template.uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForLight
            )
        case .dark:
            return bind(
                uiTemplate: template.uiTemplate,
                templateVariables: templateVariables,
                colorVariable: colorVariablesForDark
            )
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
        let updatedAt: Int64
        let themes: [Theme]
        let themeMode: String
        
        enum CodingKeys: String, CodingKey {
            case updatedAt = "updated_at"
            case themes
            case themeMode = "theme_mode"
        }
        
        struct Theme: Codable {
            let key: String
            let createdAt: Int64
            let updatedAt: Int64
            
            enum CodingKeys: String, CodingKey {
                case key, createdAt = "created_at", updatedAt = "updated_at", notification, list, header
            }
            
            struct Notification: Codable {
                let radius: CGFloat
                let backgroundColor: String
                let unreadIndicatorColor: String

                struct Category: Codable {
                    let textSize: CGFloat
                    let textColor: String
                }
                let category: Category

                struct SentAt: Codable {
                    let textSize: CGFloat
                    let textColor: String
                }
                let sentAt: SentAt

                let pressedColor: String
            }
            let notification: Notification

            struct List: Codable {
                let backgroundColor: String

                struct Tooltip: Codable {
                    let backgroundColor: String
                    let textColor: String
                }
                let tooltip: Tooltip

                struct Timeline: Codable {
                    let backgroundColor: String
                    let textColor: String
                }
                let timeline: Timeline
            }
            let list: List

            struct Header: Codable {
                let textSize: CGFloat
                let textColor: String
                let buttonIconTintColor: String
                let backgroundColor: String
                let lineColor: String
            }
            let header: Header
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
                   let templateList = json["templates"] as? [[String: Any]]
                {
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


// MARK: - MockJson For Test
extension SBUNotificationChannelManager {
    // MARK: - For test
    static let channelSettingsMockJson = {
    """
    {
      "updated_at": 12,
      "themes": [
        {
          "key": "blabla",
          "created_at": 123123,
          "updated_at": 345345,
          "notification": {
            "radius": 8,
            "backgroundColor": "#eeeeee,#2c2c2c",
            "unreadIndicatorColor": "#259c72,#259c72",
            "category": {
              "textSize": 12,
              "textColor": "#80000000,#80ffffff"
            },
            "sentAt": {
              "textSize": 11,
              "textColor": "#61000000,#61ffffff"
            },
            "pressedColor": "#dbd1ff,#491389"
          },
          "list": {
            "backgroundColor": "#ffffff,#161616",
            "tooltip": {
              "backgroundColor": "#742DDD,#C2A9FA",
              "textColor": "#E0FFFFFF,#E0000000"
            },
            "timeline": {
              "backgroundColor": "#52000000,#52000000",
              "textColor": "#e0ffffff,#80ffffff"
            }
          },
          "header": {
            "textSize": 18,
            "textColor": "#e0000000,#e0ffffff",
            "buttonIconTintColor": "#742ddd,#c2a9fa",
            "backgroundColor": "#ffffff,#2c2c2c",
            "lineColor": "#1e000000,#2c2c2c"
          }
        }
      ],
      "theme_mode": "default"
    }
    """
    }()
    
    static let templateListMockJson = {
        """
{
  "templates": [
    {
      "key": "1",
      "name": "blabla",
      "ui_template": {
        "version": 1,
        "body": {
          "items": [
            {
              "type": "box",
              "layout": "column",
              "items": [
                {
                  "type": "image",
                  "imageUrl": "{DATA_IMAGE_KEY1}",
                  "metaData": {
                    "pixelWidth": "{DATA_METADATA_KEY1}",
                    "pixelHeight": "{DATA_METADATA_KEY2}"
                  }
                },
                {
                  "type": "box",
                  "viewStyle": {
                    "padding": {
                      "top": "{DATA_BOX_PADDING_KEY1}",
                      "right": "{DATA_BOX_PADDING_KEY2}",
                      "bottom": "{DATA_BOX_PADDING_KEY3}",
                      "left": "{DATA_BOX_PADDING_KEY4}"
                    }
                  },
                  "layout": "column",
                  "items": [
                    {
                      "type": "box",
                      "layout": "row",
                      "items": [
                        {
                          "type": "box",
                          "layout": "column",
                          "items": [
                            {
                              "type": "text",
                              "text": "{DATA_TEXT_KEY1}",
                              "maxTextLines": "3",
                              "viewStyle": {
                                "padding": {
                                  "top": "0",
                                  "bottom": "6",
                                  "left": "0",
                                  "right": "0"
                                }
                              },
                              "textStyle": {
                                "size": "16",
                                "weight": "bold"
                              }
                            },
                            {
                              "type": "text",
                              "text": "{DATA_TEXT_KEY2}",
                              "maxTextLines": "10",
                              "textStyle": {
                                "size": "14"
                              }
                            }
                          ]
                        },
                        {
                          "type": "imageButton",
                          "action": {
                            "type": "web",
                            "data": "https://naver.com"
                          },
                          "width": {
                            "type": "fixed",
                            "value": "20"
                          },
                          "height": {
                            "type": "fixed",
                            "value": "20"
                          },
                          "metaData": {
                            "pixelWidth": "60",
                            "pixelHeight": "60"
                          },
                          "imageUrl": "https://dxstmhyqfqr1o.cloudfront.net/sendbird-message-builder/icon-more.png",
                            "imageStyle": {
                                "tintColor": "{SBCOLOR_002}",
                            }
                        }
                      ]
                    },
                    {
                      "type": "box",
                      "layout": "column",
                      "items": [
                        {
                          "type": "box",
                          "viewStyle": {
                            "margin": {
                              "top": "16",
                              "bottom": "0",
                              "left": "0",
                              "right": "0"
                            }
                          },
                          "align": {
                            "horizontal": "left",
                            "vertical": "center"
                          },
                          "layout": "row",
                          "items": [
                            {
                              "type": "image",
                              "imageUrl": "https://ca.slack-edge.com/T0ADCTNEL-ULE240VNV-83fd5776e78e-512",
                              "width": {
                                "type": "fixed",
                                "value": "40"
                              },
                              "height": {
                                "type": "fixed",
                                "value": "40"
                              },
                              "metaData": {
                                "pixelWidth": "512",
                                "pixelHeight": "512"
                              },
                              "viewStyle": {
                                "backgroundColor": "#BDBDBD",
                                "radius": "20"
                              },
                              "imageStyle": {
                                "contentMode": "aspectFill"
                              }
                            },
                            {
                              "type": "box",
                              "viewStyle": {
                                "margin": {
                                  "top": "0",
                                  "bottom": "0",
                                  "left": "12",
                                  "right": "0"
                                }
                              },
                              "layout": "column",
                              "items": [
                                {
                                  "type": "text",
                                  "text": "Chongbu",
                                  "maxTextLines": "1",
                                  "textStyle": {
                                    "size": "16",
                                    "weight": "bold",
                                    "color": "{SBCOLOR_001}"
                                  }
                                },
                                {
                                  "type": "text",
                                  "viewStyle": {
                                    "margin": {
                                      "top": "4",
                                      "bottom": "0",
                                      "left": "0",
                                      "right": "0"
                                    }
                                  },
                                  "text": " ",
                                  "maxTextLines": "1",
                                  "textStyle": {
                                    "size": "14"
                                  }
                                }
                              ]
                            }
                          ]
                        },
                        {
                          "type": "box",
                          "viewStyle": {
                            "margin": {
                              "top": "16",
                              "bottom": "0",
                              "left": "0",
                              "right": "0"
                            }
                          },
                          "align": {
                            "horizontal": "left",
                            "vertical": "center"
                          },
                          "layout": "row",
                          "items": [
                            {
                              "type": "image",
                              "imageUrl": "https://ca.slack-edge.com/T0ADCTNEL-U02LA25KY8J-d41a3e8c7554-512",
                              "width": {
                                "type": "fixed",
                                "value": "40"
                              },
                              "height": {
                                "type": "fixed",
                                "value": "40"
                              },
                              "metaData": {
                                "pixelWidth": "512",
                                "pixelHeight": "512"
                              },
                              "viewStyle": {
                                "backgroundColor": "#BDBDBD",
                                "radius": "20"
                              },
                              "imageStyle": {
                                "contentMode": "aspectFill"
                              }
                            },
                            {
                              "type": "box",
                              "viewStyle": {
                                "margin": {
                                  "top": "0",
                                  "bottom": "0",
                                  "left": "12",
                                  "right": "0"
                                }
                              },
                              "layout": "column",
                              "items": [
                                {
                                  "type": "text",
                                  "text": "Amanda",
                                  "maxTextLines": "1",
                                  "textStyle": {
                                    "size": "16",
                                    "weight": "bold"
                                  }
                                },
                                {
                                  "type": "text",
                                  "viewStyle": {
                                    "margin": {
                                      "top": "4",
                                      "bottom": "0",
                                      "left": "0",
                                      "right": "0"
                                    }
                                  },
                                  "text": "This is title message",
                                  "maxTextLines": "1",
                                  "textStyle": {
                                    "size": "14"
                                  }
                                }
                              ]
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            }
          ]
        }
      },
      "color_variables": {
        "SBCOLOR_001": "#5ce1e6,#5d00ff",
        "SBCOLOR_002": "#5ce1e6,#5d00ff"
      },
      "created_at": 123,
      "updated_at": 456
    }
  ]
}
"""
    }()
    
    static let subDataMockJson = {
//        """
//        {
//          "template_key": "feed-system-alert",
//          "channel_type": "feed",
//          "template_variables": {
//              "title": "This is system alert message",
//              "body": "This is system alert body message",
//              "button1.title": "Exit"
//          }
//        }
//        """
        """
        {
            "template_key": "feed-promotion",
            "channel_type": "feed",
            "template_variables": {
                "image.width": "984",
                "image.height": "540",
                "image.url": "https://dxstmhyqfqr1o.cloudfront.net/notifications/feed-example-promotion-bogo.jpg",
                "customer_name": "leo",
                "discount_percentage": "80%"
            }
        }
        """
//        """
//        {
//          "template_key": "feed-order-details",
//          "channel_type": "feed",
//          "template_variables": {
//              "orderNumber": "1090",
//              "product.image.width": "984",
//              "product.image.height": "540",
//              "product.image.url": "https://dxstmhyqfqr1o.cloudfront.net/notifications/feed-example-promotion-bogo.jpg",
//              "product.name": "Beauty Skin Care",
//              "product.summary": "This is summary."
//          }
//        }
//        """
//        """
//        {
//          "template_key": "chat-system-alert",
//          "channel_type": "chat",
//          "template_variables": {
//              "date": "Feb,10",
//              "start_time": "2/15",
//              "end_time": "3/15",
//              "timezone": "US"
//          }
//        }
//        """
//        """
//        {
//          "template_key": "chat-promotion",
//          "channel_type": "chat",
//          "template_variables": {
//              "discount_percentage": "60%",
//              "productName": "Active body control",
//              "image.width": "984",
//              "image.height": "540",
//              "image.url": "https://dxstmhyqfqr1o.cloudfront.net/notifications/feed-example-promotion-bogo.jpg",
//              "button1.title": "ONLINE STORE"
//           }
//        }
//        """
//        """
//        {
//          "template_key": "chat-balance-reminder",
//          "channel_type": "chat",
//          "template_variables": {
//              "account.image.width": "984",
//              "account.image.height": "540",
//              "account.image.url": "https://dxstmhyqfqr1o.cloudfront.net/notifications/feed-example-promotion-bogo.jpg",
//              "account.name": "TEZ",
//              "account.balance": "1,000"
//          }
//        }
//        """
        
    }()
    
    static let templateMockJson = {
        """
{"templates":[{"key":"feed-order-details","name":"Feed - Order Details","status":"active","enable_push":true,"push_template":{"title":"Your order has been processed.","body":"Click to track your order status."},"fallback_message":"Your order #{orderNumber} has been processed.","category":"Order Details","created_at":1677733043513,"updated_at":1677910430800,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"padding":{"top":12,"right":12,"bottom":12,"left":12},"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"text","viewStyle":{"margin":{"bottom":6}},"textStyle":{"weight":"bold","size":20,"color":"{SBCOLOR_text}"},"text":"Your order #{orderNumber} has been processed","maxTextLines":3},{"type":"text","viewStyle":{"margin":{"bottom":16}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"Your order has been successfully processed and will be shipped via USPS within the next 24 hours. Click to track your order status.","maxTextLines":6},{"type":"box","layout":"row","align":{"vertical":"center"},"items":[{"type":"image","metaData":{"pixelWidth":"{product.image.width}","pixelHeight":"{product.image.height}"},"width":{"type":"fixed","value":40},"height":{"type":"fixed","value":40},"imageUrl":"{product.image.url}","imageStyle":{"contentMode":"aspectFill"},"viewStyle":{"radius":20}},{"type":"box","layout":"column","width":{"type":"flex","value":0},"viewStyle":{"margin":{"left":12}},"items":[{"type":"text","text":"{product.name}","maxTextLines":1,"textStyle":{"weight":"bold","size":16,"color":"{SBCOLOR_text}"},"viewStyle":{"margin":{"bottom":4}}},{"type":"text","text":"{product.summary}","maxTextLines":1,"textStyle":{"size":14,"color":"{SBCOLOR_text}"}}]}]},{"type":"box","layout":"row","viewStyle":{"margin":{"top":16}},"items":[{"type":"textButton","text":"View Receipt","viewStyle":{"padding":{"top":10,"right":20,"bottom":10,"left":20},"radius":6,"backgroundColor":"{SBCOLOR_bbg}"},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}},{"type":"textButton","text":"Track Order","textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"viewStyle":{"margin":{"left":8},"padding":{"top":10,"right":20,"bottom":10,"left":20},"radius":6,"backgroundColor":"{SBCOLOR_bbg}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}]}},"color_variables":{"SBCOLOR_bg":"#F6EFD8,#2D2928","SBCOLOR_text":"#E0000000,#E0FFFFFF","SBCOLOR_blbl":"#E0FFFFFF,#000000","SBCOLOR_bbg":"#63922A,#ADCC88"}},{"key":"feed-promotion","name":"Feed - Promotion","status":"active","enable_push":true,"push_template":{"title":"BOGO50 - Just for you!","body":"Buy one item, get one {discount_percentage}% off!"},"fallback_message":"BOGO50 - Just for you!","category":"Promotion","created_at":1677733056192,"updated_at":1677910445720,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"image","imageUrl":"{image.url}","metaData":{"pixelWidth":"{image.width}","pixelHeight":"{image.height}"},"imageStyle":{"contentMode":"aspectFill"}},{"type":"box","layout":"column","viewStyle":{"padding":{"top":12,"right":12,"bottom":12,"left":12}},"items":[{"type":"text","viewStyle":{"margin":{"bottom":6}},"textStyle":{"weight":"bold","size":22,"color":"{SBCOLOR_text}"},"text":"BOGO50 - Just for you!","maxTextLines":2},{"type":"text","viewStyle":{"margin":{"bottom":12}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"Hi {customer_name}, we’ve got a limited-time offer just for you! Buy one item, get one {discount_percentage} off! Use code BOGO50 at checkout. Don’t miss out, shop now!","maxTextLines":6},{"type":"textButton","text":"Shop Now ??","width":{"type":"flex","value":1},"height":{"type":"fixed","value":36},"viewStyle":{"padding":{"right":20,"left":20},"radius":18,"backgroundColor":"{SBCOLOR_bbg}"},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}]}},"color_variables":{"SBCOLOR_bg":"#F4F5F6,#242424","SBCOLOR_text":"#333333,#FFFFFF","SBCOLOR_blbl":"#FFFFFF,#000000","SBCOLOR_bbg":"#000000,#FFFFFF"}},{"key":"feed-system-alert","name":"Feed - System Alert","status":"active","enable_push":true,"push_template":{"title":"System Alert","body":"You have a new notification."},"fallback_message":"Please Reset Your Password","category":"System Alert","created_at":1677733068144,"updated_at":1677910460461,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"padding":{"top":12,"bottom":12},"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"text","viewStyle":{"margin":{"right":8,"bottom":6,"left":12}},"textStyle":{"weight":"bold","size":16,"color":"{SBCOLOR_text}"},"text":"{title}","maxTextLines":4},{"type":"text","viewStyle":{"margin":{"right":8,"bottom":12,"left":12}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"{body}","maxTextLines":10},{"type":"textButton","text":"{button1.title}","width":{"type":"flex","value":1},"height":{"type":"fixed","value":36},"viewStyle":{"margin":{"right":12,"left":12},"padding":{"right":20,"left":20},"radius":2,"backgroundColor":"{SBCOLOR_bbg}"},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}},"color_variables":{"SBCOLOR_bg":"#F2F2F7,#2C2C2C","SBCOLOR_text":"#000000,#FFFFFF","SBCOLOR_blbl":"#FFFFFF,#000000","SBCOLOR_bbg":"#010357,#B8B9FF"}},{"key":"chat-system-alert","name":"Chat - System Alert","status":"active","enable_push":true,"push_template":{"title":"System Alert","body":"Server Maintenance Alert"},"fallback_message":"Server Maintenance Alert","category":"System Alert","created_at":1677733027249,"updated_at":1677910486774,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"padding":{"top":12,"bottom":12},"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"text","viewStyle":{"margin":{"right":8,"bottom":6,"left":12}},"textStyle":{"weight":"bold","size":16,"color":"{SBCOLOR_title}"},"text":"Server Maintenance Alert","maxTextLines":4},{"type":"text","viewStyle":{"margin":{"right":28,"bottom":12,"left":12}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"Scheduled server maintenance on {date} from {start_time} to {end_time} {timezone}. You may experience downtime or slower response times. Contact our support team if you have any questions.","maxTextLines":10},{"type":"textButton","text":"Contact Support","width":{"type":"flex","value":1},"height":{"type":"fixed","value":36},"viewStyle":{"margin":{"right":12,"left":12},"padding":{"right":20,"left":20},"radius":6,"backgroundColor":"{SBCOLOR_bbg}"},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}},"color_variables":{"SBCOLOR_bg":"#E7E2E3,#343232","SBCOLOR_title":"#0270F5,#ABD1FF","SBCOLOR_text":"#000000,#FFFFFF","SBCOLOR_blbl":"#FFFFFF,#000000","SBCOLOR_bbg":"#0270F5,#ABD1FF"}},{"key":"chat-promotion","name":"Chat - Promotion","status":"active","enable_push":true,"push_template":{"title":"BOGO50 - Just for you!","body":"Buy one item, get one {discount_percentage}% off!"},"fallback_message":"Get Fit with {productName}!","category":"Promotion","created_at":1677733014779,"updated_at":1677910509538,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"image","imageUrl":"{image.url}","metaData":{"pixelWidth":"{image.width}","pixelHeight":"{image.height}"},"imageStyle":{"contentMode":"aspectFill"}},{"type":"box","layout":"column","viewStyle":{"padding":{"top":12,"bottom":12,"left":12}},"items":[{"type":"text","viewStyle":{"margin":{"right":8,"bottom":6}},"textStyle":{"weight":"bold","size":20,"color":"{SBCOLOR_title}"},"text":"Get Fit with {productName}!","maxTextLines":2},{"type":"text","viewStyle":{"margin":{"right":28,"bottom":12}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"Take your fitness routine to the next level with {productName}! Click below to chat with one of our experts and learn how we can help you reach your fitness goals.","maxTextLines":6},{"type":"box","layout":"row","viewStyle":{"margin":{"right":12}},"items":[{"type":"textButton","text":"{button1.title}","height":{"type":"fixed","value":36},"viewStyle":{"radius":16,"backgroundColor":"{SBCOLOR_bbg}","padding":{"top":0,"right":0,"bottom":0,"left":0}},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}},{"type":"textButton","text":"Start Chat","height":{"type":"fixed","value":36},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"viewStyle":{"margin":{"left":8},"radius":16,"backgroundColor":"{SBCOLOR_bbg}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}]}]}},"color_variables":{"SBCOLOR_bg":"#FFECEB,#EF5962","SBCOLOR_title":"#EF5962,#E0FFFFFF","SBCOLOR_text":"#E0000000,#E0FFFFFF","SBCOLOR_blbl":"#FFFFFF,#EF5962","SBCOLOR_bbg":"#EF5962,#FFFFFF"}},{"key":"chat-balance-reminder","name":"Chat - Balance Reminder","status":"active","enable_push":true,"push_template":{"title":"Account Balance Alert","body":"Your account balance is getting low."},"fallback_message":"Your account balance is getting low. Click below to chat with a support representative to add more funds.","category":"Balance Reminder","created_at":1677732929304,"updated_at":1677910529256,"ui_template":{"version":1,"body":{"items":[{"type":"box","viewStyle":{"padding":{"top":12,"right":12,"bottom":12,"left":12},"backgroundColor":"{SBCOLOR_bg}"},"layout":"column","items":[{"type":"text","viewStyle":{"margin":{"bottom":6}},"textStyle":{"weight":"bold","size":16,"color":"{SBCOLOR_title}"},"text":"Account Balance Alert","maxTextLines":1},{"type":"text","viewStyle":{"margin":{"right":16,"bottom":16}},"textStyle":{"size":14,"color":"{SBCOLOR_text}"},"text":"Your account balance is getting low. Click below to chat with a support representative to add more funds.","maxTextLines":6},{"type":"box","layout":"row","align":{"vertical":"center"},"items":[{"type":"image","imageUrl":"{account.image.url}","metaData":{"pixelWidth":"{account.image.width}","pixelHeight":"{account.image.height}"},"width":{"type":"fixed","value":40},"height":{"type":"fixed","value":40},"imageStyle":{"contentMode":"aspectFill"},"viewStyle":{"radius":20}},{"type":"box","layout":"column","width":{"type":"flex","value":0},"viewStyle":{"margin":{"left":12}},"items":[{"type":"text","text":"{account.name}","maxTextLines":1,"textStyle":{"weight":"bold","size":16,"color":"{SBCOLOR_text}"},"viewStyle":{"margin":{"bottom":4}}},{"type":"text","text":"{account.balance}","maxTextLines":1,"textStyle":{"size":14,"color":"{SBCOLOR_text}"}}]}]},{"type":"box","layout":"row","viewStyle":{"margin":{"top":16}},"items":[{"type":"textButton","text":"View Balance","viewStyle":{"radius":8,"backgroundColor":"{SBCOLOR_bbg}","padding":{"top":0,"right":0,"bottom":0,"left":0}},"textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}},{"type":"textButton","text":"Chat with Us","textStyle":{"weight":"bold","size":14,"color":"{SBCOLOR_blbl}"},"viewStyle":{"margin":{"left":8},"radius":8,"backgroundColor":"{SBCOLOR_bbg}"},"action":{"type":"web","data":"https://sendbird.com/notifications"}}]}]}]}},"color_variables":{"SBCOLOR_bg":"#E7F0FE,#102B92","SBCOLOR_title":"#102B92,#FFFFFF","SBCOLOR_text":"#000000,#FFFFFF","SBCOLOR_blbl":"#FFFFFF,#102B92","SBCOLOR_bbg":"#102B92,#FFFFFF"}}],"next":"1677910529256286","has_more":false}
"""
    }()
}
