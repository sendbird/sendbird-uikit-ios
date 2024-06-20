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
    static var notificationChannelThemeMode: String {
        SBUCacheManager.NotificationSetting.themeMode
    }
    
    /// Resets template cache
    /// - Since: 3.6.0
    @available(*, deprecated, renamed: "SBUMessageTemplateManager.resetNotificationTemplateCache") // 3.21.0
    public static func resetTemplateCache() {
        SBUCacheManager.template(with: .notification).resetCache()
    }
    
    /// Resets notification setting cache
    /// - Since: 3.6.0
    public static func resetNotificationSettingCache() {
        SBUCacheManager.NotificationSetting.resetCache()
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
                
                struct Label: Codable { // 3.9.0
                    let textSize: CGFloat
                    let fontWeight: SBUFontWeightType?
                    let textColor: String
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
                
                struct CategoryFilter: Codable { // 3.9.0
                    let radius: CGFloat
                    let textColor: String
                    let fontWeight: SBUFontWeightType?
                    let selectedBackgroundColor: String
                    let textSize: CGFloat
                    let backgroundColor: String
                    let selectedTextColor: String
                }

                let backgroundColor: String
                let tooltip: Tooltip
                let timeline: Timeline
                let category: CategoryFilter // 3.9.0
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
        with globalTheme: SBUNotificationChannelManager.GlobalNotificationSettings.Theme,
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
            ),
            categoryFilter: SBUNotificationTheme.CategoryFilter(
                radius: globalTheme.list.category.radius,
                backgroundColor: color(with: globalTheme.list.backgroundColor, themeMode: globalThemeMode, for: colorScheme),
                unselectedTextColor: color(
                    with: globalTheme.list.category.textColor,
                    themeMode: globalThemeMode,
                    for: colorScheme
                ),
                fontWeight: globalTheme.list.category.fontWeight ?? .normal,
                selectedCellBackgroundColor: color(
                    with: globalTheme.list.category.selectedBackgroundColor,
                    themeMode: globalThemeMode,
                    for: colorScheme
                ),
                textSize: globalTheme.list.category.textSize,
                unselectedBackgroundColor: color(
                    with: globalTheme.list.category.backgroundColor,
                    themeMode: globalThemeMode,
                    for: colorScheme
                ),
                selectedTextColor: color(
                    with: globalTheme.list.category.selectedTextColor,
                    themeMode: globalThemeMode,
                    for: colorScheme
                )
            )
        )
        return theme
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
