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
    
    // MARK: - Body
    /// Regular, 14pt, Line height: 20pt
    public static var body1 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    /// Regular, 14pt, Line height: 16pt
    public static var body2 = UIFont.systemFont(ofSize: 14.0, weight: .regular)
    
    // MARK: - Button
    /// Semibold, 20pt
    public static var button1 = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
    /// Medium, 16pt, Line hieght 22pt
    public static var button2 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    /// Medium, 14pt
    public static var button3 = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    
    // MARK: - Caption
    /// Bold, 12pt
    public static var caption1 = UIFont.systemFont(ofSize: 12.0, weight: .bold)
    /// Regular, 12pt
    public static var caption2 = UIFont.systemFont(ofSize: 12.0, weight: .regular)
    /// Regular, 11pt
    public static var caption3 = UIFont.systemFont(ofSize: 11.0, weight: .regular)
    
    // MARK: - Subtitle
    /// Medium, 16pt, Line hieght 22pt
    public static var subtitle1 = UIFont.systemFont(ofSize: 16.0, weight: .medium)
    /// Regular, 16pt
    public static var subtitle2 = UIFont.systemFont(ofSize: 16.0, weight: .regular)
     
}
 
