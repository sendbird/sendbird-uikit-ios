//
//  SBUActionSheet.Item.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 4/17/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

/// This class represents an item in an action sheet.
public class SBUActionSheetItem: SBUCommonItem {
    /// The completion handler of the action sheet item.
    /// - Since: 3.28.0
    public var completionHandler: SBUActionSheetHandler?
    
    /// This property indicates whether the text alignment is set.
    /// - Since: 3.28.0
    public var isTextAlignmentSet = false
    
    /// initializer
    public override init(
        title: String? = nil,
        color: UIColor? = SBUColorSet.onLightTextHighEmphasis,
        image: UIImage? = nil,
        font: UIFont? = nil,
        tintColor: UIColor? = nil,
        textAlignment: NSTextAlignment? = nil,
        tag: Int? = nil
    ) {
        super.init(
            title: title,
            color: color,
            image: image,
            font: font,
            tintColor: tintColor,
            textAlignment: textAlignment ?? .left,
            tag: tag
        )
        self.isTextAlignmentSet = (textAlignment != nil)
        self.completionHandler = nil
    }
    
    /// This function initializes actionSheet item.
    /// - Parameters:
    ///   - title: Title text
    ///   - color: Title color
    ///   - image: Item image
    ///   - font: Title font
    ///   - textAlignment: Title alignment
    ///   - tag: Item tag
    ///   - completionHandler: Item's completion handler
    public init(title: String? = nil,
                color: UIColor? = nil,
                image: UIImage? = nil,
                font: UIFont? = nil,
                textAlignment: NSTextAlignment? = nil,
                tag: Int? = nil,
                completionHandler: SBUActionSheetHandler?) {
        super.init(
            title: title,
            color: color,
            image: image,
            font: font,
            textAlignment: textAlignment ?? .left,
            tag: tag
        )
        self.isTextAlignmentSet = (textAlignment != nil)
        self.completionHandler = completionHandler
    }
}
