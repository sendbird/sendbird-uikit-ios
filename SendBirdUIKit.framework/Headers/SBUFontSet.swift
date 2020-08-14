//
//  SBUFontSet.swift
//  SendBirdUIKit
//
//  Created by Harry Kim on 2020/02/05.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit

@objcMembers
public class SBUFontSet: NSObject {
    // MARK: - H
    /// Medium, 18pt
    public static var h1 = UIFont.systemFont(ofSize: 18.0, weight: .medium)
    /// Bold, 16pt
    public static var h2 = UIFont.systemFont(ofSize: 16.0, weight: .bold)
    static var h2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.h2.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 16.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.h2,
            .kern: -0.2,
            .paragraphStyle: style
        ]
    }()

    // MARK: - Body
    /// Regular, 14pt, Line height: 20pt
    public static var body1 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    static var body1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body1.pointSize
        let defaultLineHeight = 20.f
        let defaultFontSize = 14.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body1,
            .paragraphStyle: style
        ]
    }()
    
    /// Regular, 14pt, Line height: 16pt
    public static var body2 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
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
    
    public static var body3 = UIFont.systemFont(ofSize: 14.0, weight: .semibold)
    static var body3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.body3.pointSize
        let defaultLineHeight = 16.f
        let defaultFontSize = 46.f
        style.minimumLineHeight = defaultLineHeight * pointSize / defaultFontSize
        return [
            .font: SBUFontSet.body3,
            .paragraphStyle: style
        ]
    }()
    
    // MARK: - Button
    /// Semibold, 20pt
    public static var button1 = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    static var button1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        let pointSize = SBUFontSet.button1.pointSize
        let defaultLineHeight = 24.f
        let defaultFontSize = 20.f
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
    
    // MARK: - Caption
    /// Bold, 12pt
    public static var caption1 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
    static var caption1Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        return [
            .font: SBUFontSet.caption1,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 12pt
    public static var caption2 = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    static var caption2Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        return [
            .font: SBUFontSet.caption2,
            .paragraphStyle: style
        ]
    }()
    /// Regular, 11pt
    public static var caption3 = UIFont.systemFont(ofSize: 11.0, weight: .regular)
    static var caption3Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
        return [
            .font: SBUFontSet.caption3,
            .paragraphStyle: style
        ]
    }()
    
    public static var caption4 = UIFont.systemFont(ofSize: 11.0, weight: .bold)
    static var caption4Attributes: [NSAttributedString.Key: Any] = {
        let style = NSMutableParagraphStyle()
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
     
}
 
