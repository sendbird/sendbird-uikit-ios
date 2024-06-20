//
//  SBUColorSet.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/05.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//
// swiftlint:disable missing_docs
import UIKit

public class SBUColorSet {
    // MARK: - Primary
    public static var primaryExtraLight = UIColor(red: 219.0 / 255.0, green: 209.0 / 255.0, blue: 1.0, alpha: 1.0)
    public static var primaryLight = UIColor(red: 194.0 / 255.0, green: 169.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    public static var primaryMain = UIColor(red: 116.0 / 255.0, green: 45.0 / 255.0, blue: 221.0 / 255.0, alpha: 1.0)
    public static var primaryDark = UIColor(red: 98.0 / 255.0, green: 17.0 / 255.0, blue: 200.0 / 255.0, alpha: 1.0)
    public static var primaryExtraDark = UIColor(red: 73.0 / 255.0, green: 19.0 / 255.0, blue: 137.0 / 255.0, alpha: 1.0)
    
    // MARK: - Secondary
    public static var secondaryExtraLight = UIColor(red: 168.0 / 255.0, green: 226.0 / 255.0, blue: 171.0 / 255.0, alpha: 1.0)
    public static var secondaryLight = UIColor(red: 105.0 / 255.0, green: 192.0 / 255.0, blue: 133.0 / 255.0, alpha: 1.0)
    public static var secondaryMain = UIColor(red: 37.0 / 255.0, green: 156.0 / 255.0, blue: 114.0 / 255.0, alpha: 1.0)
    public static var secondaryDark = UIColor(red: 2.0 / 255.0, green: 125.0 / 255.0, blue: 105.0 / 255.0, alpha: 1.0)
    public static var secondaryExtraDark = UIColor(red: 6.0 / 255.0, green: 104.0 / 255.0, blue: 88.0 / 255.0, alpha: 1.0)
    
    // MARK: - Background
    public static var background50 = UIColor(white: 1.0, alpha: 1.0)
    public static var background100 = UIColor(white: 238.0 / 255.0, alpha: 1.0)
    public static var background200 = UIColor(white: 224.0 / 255.0, alpha: 1.0)
    public static var background300 = UIColor(white: 189.0 / 255.0, alpha: 1.0)
    public static var background400 = UIColor(white: 57.0 / 255.0, alpha: 1.0)
    public static var background500 = UIColor(white: 44.0 / 255.0, alpha: 1.0)
    public static var background600 = UIColor(white: 22.0 / 255.0, alpha: 1.0)
    public static var background700 = UIColor(white: 0.0, alpha: 1.0)
    
    // MARK: - Overlay
    public static var overlayDark = UIColor(white: 0.0, alpha: 0.55)
    public static var overlayLight = UIColor(white: 0.0, alpha: 0.32)
    
    // MARK: - On Light
    public static var onLightTextHighEmphasis = UIColor(white: 0.0, alpha: 0.88)
    public static var onLightTextMidEmphasis = UIColor(white: 0.0, alpha: 0.5)
    public static var onLightTextLowEmphasis = UIColor(white: 0.0, alpha: 0.38)
    public static var onLightTextDisabled = UIColor(white: 0.0, alpha: 0.12)
    
    // MARK: - On Dark
    public static var onDarkTextHighEmphasis = UIColor(white: 1.0, alpha: 0.88)
    public static var onDarkTextMidEmphasis = UIColor(white: 1.0, alpha: 0.5)
    public static var onDarkTextLowEmphasis = UIColor(white: 1.0, alpha: 0.38)
    public static var onDarkTextDisabled = UIColor(white: 1.0, alpha: 0.12)
    
    // MARK: - Error
    public static var errorExtraLight = UIColor(red: 253.0 / 255.0, green: 170.0 / 255.0, blue: 170.0 / 255.0, alpha: 1.0)
    public static var errorLight = UIColor(red: 246.0 / 255.0, green: 97.0 / 255.0, blue: 97.0 / 255.0, alpha: 1.0)
    public static var errorMain = UIColor(red: 222.0 / 255.0, green: 54.0 / 255.0, blue: 11.0 / 255.0, alpha: 1.0)
    public static var errorDark = UIColor(red: 191.0 / 255.0, green: 7.0 / 255.0, blue: 17.0 / 255.0, alpha: 1.0)
    public static var errorExtraDark = UIColor(red: 157.0 / 255.0, green: 9.0 / 255.0, blue: 30.0 / 255.0, alpha: 1.0)
    
    // MARK: - Information
    public static var informationExtraDark = UIColor(red: 36.0 / 255.0, green: 19.0 / 255.0, blue: 137.0 / 255.0, alpha: 1.0)
    public static var informationDark = UIColor(red: 54.0 / 255.0, green: 44.0 / 255.0, blue: 169.0 / 255.0, alpha: 1.0)
    public static var informationMain = UIColor(red: 74.0 / 255.0, green: 72.0 / 255.0, blue: 205.0 / 255.0, alpha: 1.0)
    public static var informationLight = UIColor(red: 169.0 / 255.0, green: 187.0 / 255.0, blue: 250.0 / 255.0, alpha: 1.0)
    public static var informationExtraLight = UIColor(red: 209.0 / 255.0, green: 219.0 / 255.0, blue: 255.0 / 255.0, alpha: 1.0)

    // MARK: - Highlight
    public static var highlight = UIColor(red: 1.0, green: 242.0 / 255.0, blue: 182.0 / 255.0, alpha: 1.0)
    
}

// MARK: - Old color set. Deprecated.
public extension SBUColorSet {
    // MARK: Primary
    @available(*, deprecated, renamed: "primaryExtraLight", message: "")
    static var primary100: UIColor {
        get { primaryExtraLight }
        set { primaryExtraLight = newValue }
    }

    @available(*, deprecated, renamed: "primaryLight", message: "")
    static var primary200: UIColor {
        get { primaryLight }
        set { primaryLight = newValue }
    }

    @available(*, deprecated, renamed: "primaryMain", message: "")
    static var primary300: UIColor {
        get { primaryMain }
        set { primaryMain = newValue }
    }

    @available(*, deprecated, renamed: "primaryDark", message: "")
    static var primary400: UIColor {
        get { primaryDark }
        set { primaryDark = newValue }
    }

    @available(*, deprecated, renamed: "primaryExtraDark", message: "")
    static var primary500: UIColor {
        get { primaryExtraDark }
        set { primaryExtraDark = newValue }
    }

    // MARK: Secondary
    @available(*, deprecated, renamed: "secondaryExtraLight", message: "")
    static var secondary100: UIColor {
        get { secondaryExtraLight }
        set { secondaryExtraLight = newValue }
    }

    @available(*, deprecated, renamed: "secondaryLight", message: "")
    static var secondary200: UIColor {
        get { secondaryLight }
        set { secondaryLight = newValue }
    }

    @available(*, deprecated, renamed: "secondaryMain", message: "")
    static var secondary300: UIColor {
        get { secondaryMain }
        set { secondaryMain = newValue }
    }

    @available(*, deprecated, renamed: "secondaryDark", message: "")
    static var secondary400: UIColor {
        get { secondaryDark }
        set { secondaryDark = newValue }
    }

    @available(*, deprecated, renamed: "secondaryExtraDark", message: "")
    static var secondary500: UIColor {
        get { secondaryExtraDark }
        set { secondaryExtraDark = newValue }
    }

    // MARK: - Error
    @available(*, deprecated, renamed: "errorExtraDark", message: "")
    static var error500: UIColor {
        get { errorExtraDark }
        set { errorExtraDark = newValue }
    }

    @available(*, deprecated, renamed: "errorDark", message: "")
    static var error400: UIColor {
        get { errorDark }
        set { errorDark = newValue }
    }

    @available(*, deprecated, renamed: "errorMain", message: "")
    static var error300: UIColor {
        get { errorMain }
        set { errorMain = newValue }
    }

    @available(*, deprecated, renamed: "errorLight", message: "")
    static var error200: UIColor {
        get { errorLight }
        set { errorLight = newValue }
    }
    
    @available(*, deprecated, renamed: "errorExtraLight", message: "")
    static var error100: UIColor {
        get { errorExtraLight }
        set { errorExtraLight = newValue }
    }

    // MARK: - Overlay
    @available(*, deprecated, renamed: "overlayDark", message: "")
    static var overlay01: UIColor {
        get { overlayDark }
        set { overlayDark = newValue }
    }

    @available(*, deprecated, renamed: "overlayLight", message: "")
    static var overlay02: UIColor {
        get { overlayLight }
        set { overlayLight = newValue }
    }

    // MARK: - On light
    @available(*, deprecated, renamed: "onLightTextHighEmphasis", message: "")
    static var onlight01: UIColor {
        get { onLightTextHighEmphasis }
        set { onLightTextHighEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onLightTextMidEmphasis", message: "")
    static var onlight02: UIColor {
        get { onLightTextMidEmphasis }
        set { onLightTextMidEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onLightTextLowEmphasis", message: "")
    static var onlight03: UIColor {
        get { onLightTextLowEmphasis }
        set { onLightTextLowEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onLightTextDisabled", message: "")
    static var onlight04: UIColor {
        get { onLightTextDisabled }
        set { onLightTextDisabled = newValue }
    }

    // MARK: - On dark
    @available(*, deprecated, renamed: "onDarkTextHighEmphasis", message: "")
    static var ondark01: UIColor {
        get { onDarkTextHighEmphasis }
        set { onDarkTextHighEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onDarkTextMidEmphasis", message: "")
    static var ondark02: UIColor {
        get { onDarkTextMidEmphasis }
        set { onDarkTextMidEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onDarkTextLowEmphasis", message: "") 
    static var ondark03: UIColor {
        get { onDarkTextLowEmphasis }
        set { onDarkTextLowEmphasis = newValue }
    }

    @available(*, deprecated, renamed: "onDarkTextDisabled", message: "")
    static var ondark04: UIColor {
        get { onDarkTextDisabled }
        set { onDarkTextDisabled = newValue }
    }

    // MARK: - Information
    @available(*, deprecated, renamed: "informationLight", message: "")
    static var information: UIColor {
        get { informationLight }
        set { informationLight = newValue }
    }
}
// swiftlint:enable missing_docs
