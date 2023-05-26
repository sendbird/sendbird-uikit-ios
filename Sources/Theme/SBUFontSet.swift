//
//  SBUFontSet.swift
//  SendbirdUIKit
//
//  Created by Harry Kim on 2020/02/05.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUFontSet {
    // MARK: - H
    /// Bold, 18pt
    public static var h1 = UIFont.systemFont(ofSize: 18.0, weight: .bold)
    /// Medium, 18pt
    public static var h2 = UIFont.systemFont(ofSize: 18.0, weight: .medium)
    static var h2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.h2.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 18.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.h2,
            .kern: -0.2,
            .paragraphStyle: style
        ]
    }()
    /// Bold, 16pt
    public static var h3 = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    
    // MARK: - Body
    /// Regular, 16pt, Line height: 20pt
    public static var body1 = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    static var body1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body1.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 16.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body1,
            .paragraphStyle: style
        ]
    }()
    /// Semibold, 14pt, Line height: 16pt
    public static var body2 = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    static var body2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body2.pointSize
        let defaultLineHeight = 16.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body2,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 14pt, Line height: 16pt
    public static var body3 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    static var body3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body3.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body3,
            .paragraphStyle: style
        ]
    }()
    /// Bold, 14pt, Line height: 20pt
    public static var body4 = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    static var body4Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body4.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body4,
            .paragraphStyle: style
        ]
    }()
    
    // MARK: - Button
    /// Semibold, 18pt
    public static var button1 = UIFont.systemFont(ofSize: 18.0, weight: .semibold)
    static var button1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.button1.pointSize
        let defaultLineHeight = 24.f
        let defaultFontSize = 18.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.button1,
            .kern: 0.38,
            .paragraphStyle: style
        ]
    }()
    /// Medium, 16pt
    public static var button2 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    static var button2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.button2.pointSize
        let defaultLineHeight = 16.f
        let defaultFontSize = 16.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.button1,
            .kern: -0.4,
            .paragraphStyle: style
        ]
    }()
    /// Medium, 14pt
    public static var button3 = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    static var button3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.button3.pointSize
        let defaultLineHeight = 16.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.button3,
            .paragraphStyle: style
        ]
    }()
    /// Bold, 14pt
    public static var button4 = UIFont.systemFont(ofSize: 14.0, weight: .bold)
    static var button4Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.button3.pointSize
        let defaultLineHeight = 16.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.button3,
            .paragraphStyle: style
        ]
    }()
    
    // MARK: - Caption
    /// Bold, 12pt
    public static var caption1 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
    static var caption1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.caption1.pointSize
        let defaultLineHeight = 12.f
        let defaultFontSize = 12.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.caption1,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 12pt
    public static var caption2 = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    static var caption2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.caption2.pointSize
        let defaultLineHeight = 12.f
        let defaultFontSize = 12.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.caption2,
            .paragraphStyle: style
        ]
    }()
    /// Bold, 11pt
    public static var caption3 = UIFont.systemFont(ofSize: 11.0, weight: .bold)
    static var caption3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.caption3.pointSize
        let defaultLineHeight = 12.f
        let defaultFontSize = 11.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.caption3,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 11pt
    public static var caption4 = UIFont.systemFont(ofSize: 11.0, weight: .regular)
    static var caption4Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.caption4.pointSize
        let defaultLineHeight = 12.f
        let defaultFontSize = 11.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.caption4,
            .paragraphStyle: style
        ]
    }()
    
    // MARK: - Subtitle
    /// Medium, 16pt, Line hieght 22pt
    public static var subtitle1 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    static var subtitle1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.subtitle1.pointSize
        let defaultLineHeight = 22.f
        let defaultFontSize = 16.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.subtitle1,
            .kern: -0.2,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 16pt
    public static var subtitle2 = UIFont.systemFont(ofSize: 16.0, weight: .regular)
    static var subtitle2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.subtitle2.pointSize
        let defaultLineHeight = 24.f
        let defaultFontSize = 16.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.subtitle2,
            .kern: -0.2,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 14pt
    public static var subtitle3 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    static var subtitle3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.subtitle3.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.subtitle3,
            .kern: -0.2,
            .paragraphStyle: style
        ]
    }()
    
    // MARK: - Custom font
    /// Sets custom font with name and size
    /// - Parameters:
    ///   - name: font name string
    ///   - size: font size
    /// - Returns: UIFont object. If `name` is `nil`, it returns the system font.
    /// - Since: 3.5.0
    static func customFont(name: String? = nil, size: CGFloat) -> UIFont {
        // Not used now
        if let name = name,
            let font = UIFont(name: name, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
    }
    
    // MARK: - Notifications font
    /// Returns system font or custom font by checking if there is a set fontFamily value for Notifications.
    /// - Since: 3.5.7
    static func notificationsFont(size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        guard let fontFamily = SBUFontSet.FontFamily.notifications else {
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
        
        let descriptor = UIFontDescriptor(
            fontAttributes: [
                .family: fontFamily,
                .traits: [UIFontDescriptor.TraitKey.weight: weight]
            ]
        )
        let font = UIFont(descriptor: descriptor, size: size)
        return font
    }
}

extension SBUFontSet {

    // MARK: - Font family
    /// It is a class for font family.
    /// - Since: 3.5.7
    public class FontFamily {
        
        /// If this value is set, all of the fonts in Notification are use this fontFamily.
        /// - Since: 3.5.7
        public static var notifications: String?
    }
}
