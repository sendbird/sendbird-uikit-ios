//
//  SBUToastView.Item.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 4/17/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// Toast view item for setting data.
/// - Since: 3.15.0
public class SBUToastViewItem: SBUCommonItem {
    /// The position of the toast view.
    /// - Since: 3.28.0
    public var position: Position
    
    /// The duration of the toast view.
    /// - Since: 3.28.0
    public var duration: Double
    
    /// The completion handler of the toast view.
    /// - Since: 3.28.0
    public var completionHandler: SBUToastViewHandler?
    
    /// This function initializes toast view item.
    /// - Parameters:
    ///   - position: Toast position (Screen-based position)
    ///   - duration: Toast duration (default: 1.5 second)
    ///   - image: Item image
    ///   - title: Title text
    ///   - color: Title color
    ///   - font: Title font
    ///   - textAlignment: Title alignment
    ///   - tag: Item tag
    ///   - completionHandler: Item's completion handler
    public init(
        position: Position = .center,
        duration: Double = 1.5,
        title: String? = nil,
        color: UIColor? = nil,
        image: UIImage? = nil,
        font: UIFont? = nil,
        textAlignment: NSTextAlignment = .left,
        tag: Int? = nil
    ) {

        self.position = position
        self.duration = duration
        self.completionHandler = nil
        // FIXME: textAlignment 를 사용하는 곳이 없음
        
        super.init(
            title: title,
            color: color,
            image: image,
            font: font,
            tintColor: nil,
            textAlignment: textAlignment,
            tag: tag
        )
    }
        
    /// Toast View position
    public enum Position {
        case top(padding: CGFloat? = nil)
        case center
        case bottom(padding: CGFloat? = nil)
//        case custom(CGPoint) // TODO
    }
}
