//
//  SBUTheme+MessageTemplate.swift
//  SendbirdUIKitCommon
//
//  Created by Damon Park on 10/21/24.
//

import Foundation

import UIKit
#if canImport(SendbirdUIMessageTemplate)
import SendbirdUIMessageTemplate
#endif

@available(*, deprecated, renamed: "SendbirdUIMessageTemplate.TemplateTheme")
extension SBUMessageTemplateTheme {
#if canImport(SendbirdUIMessageTemplate)
    static var internal_light: SBUMessageTemplateTheme {
        get {
            let theme = SendbirdUIMessageTemplate.TemplateTheme.light
            return SBUMessageTemplateTheme(
                textFont: theme.textFont,
                textColor: theme.textColor,
                textButtonFont: theme.textButtonFont,
                textButtonTitleColor: theme.textButtonTitleColor,
                textButtonBackgroundColor: theme.textButtonBackgroundColor,
                viewBackgroundColor: theme.viewBackgroundColor
            )
        }
        set {
            SendbirdUIMessageTemplate.TemplateTheme.light = SendbirdUIMessageTemplate.TemplateTheme(
                textFont: newValue.textFont,
                textColor: newValue.textColor,
                textButtonFont: newValue.textButtonFont,
                textButtonTitleColor: newValue.textButtonTitleColor,
                textButtonBackgroundColor: newValue.textButtonBackgroundColor,
                viewBackgroundColor: newValue.viewBackgroundColor
            )
        }
    }
    
    static var internal_dark: SBUMessageTemplateTheme {
        get {
            let theme = SendbirdUIMessageTemplate.TemplateTheme.dark
            return SBUMessageTemplateTheme(
                textFont: theme.textFont,
                textColor: theme.textColor,
                textButtonFont: theme.textButtonFont,
                textButtonTitleColor: theme.textButtonTitleColor,
                textButtonBackgroundColor: theme.textButtonBackgroundColor,
                viewBackgroundColor: theme.viewBackgroundColor
            )
        }
        set {
            SendbirdUIMessageTemplate.TemplateTheme.dark = SendbirdUIMessageTemplate.TemplateTheme(
                textFont: newValue.textFont,
                textColor: newValue.textColor,
                textButtonFont: newValue.textButtonFont,
                textButtonTitleColor: newValue.textButtonTitleColor,
                textButtonBackgroundColor: newValue.textButtonBackgroundColor,
                viewBackgroundColor: newValue.viewBackgroundColor
            )
        }
    }
    
    static var internal_defaultLight: SBUMessageTemplateTheme {
        let theme = SBUMessageTemplateTheme()
        
        let light = SendbirdUIMessageTemplate.TemplateTheme.defaultLight
        theme.textFont = light.textFont
        theme.textColor = light.textColor
        theme.textButtonFont = light.textButtonFont
        theme.textButtonTitleColor = light.textButtonTitleColor
        theme.textButtonBackgroundColor = light.textButtonBackgroundColor
        theme.viewBackgroundColor = light.viewBackgroundColor
        return theme
    }
    
    static var internal_defaultDark: SBUMessageTemplateTheme {
        let theme = SBUMessageTemplateTheme()
        let dark = SendbirdUIMessageTemplate.TemplateTheme.defaultDark
        theme.textFont = dark.textFont
        theme.textColor = dark.textColor
        theme.textButtonFont = dark.textButtonFont
        theme.textButtonTitleColor = dark.textButtonTitleColor
        theme.textButtonBackgroundColor = dark.textButtonBackgroundColor
        theme.viewBackgroundColor = dark.viewBackgroundColor
        
        return theme
    }
    
    static func internal_setTheme(
        light: SBUMessageTemplateTheme? = nil,
        dark: SBUMessageTemplateTheme? = nil
    ) {
        if let light = light {
            let theme = SendbirdUIMessageTemplate.TemplateTheme()
            theme.textFont = light.textFont
            theme.textColor = light.textColor
            theme.textButtonFont = light.textButtonFont
            theme.textButtonTitleColor = light.textButtonTitleColor
            theme.textButtonBackgroundColor = light.textButtonBackgroundColor
            theme.viewBackgroundColor = light.viewBackgroundColor
            SendbirdUIMessageTemplate.TemplateTheme.light = theme
        }
        if let dark = dark {
            let theme = SendbirdUIMessageTemplate.TemplateTheme()
            theme.textFont = dark.textFont
            theme.textColor = dark.textColor
            theme.textButtonFont = dark.textButtonFont
            theme.textButtonTitleColor = dark.textButtonTitleColor
            theme.textButtonBackgroundColor = dark.textButtonBackgroundColor
            theme.viewBackgroundColor = dark.viewBackgroundColor

            SendbirdUIMessageTemplate.TemplateTheme.dark = theme
        }
    }
    
    static func internal_factory(
        textFont: UIFont? = nil,
        textColor: UIColor? = nil,
        textButtonFont: UIFont? = nil,
        textButtonTitleColor: UIColor? = nil,
        textButtonBackgroundColor: UIColor? = nil,
        viewBackgroundColor: UIColor? = nil
    ) -> SBUMessageTemplateTheme {
        let theme = SBUMessageTemplateTheme()
        theme.textFont = TemplateTheme.defaultLight.textFont
        theme.textColor = TemplateTheme.defaultLight.textColor
        theme.textButtonFont = TemplateTheme.defaultLight.textButtonFont
        theme.textButtonTitleColor = TemplateTheme.defaultLight.textButtonTitleColor
        theme.textButtonBackgroundColor = TemplateTheme.defaultLight.textButtonBackgroundColor
        theme.viewBackgroundColor = TemplateTheme.defaultLight.viewBackgroundColor
        return theme
    }
#endif
}
