//
//  SBUCommonItem.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 17/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// SBUCommonItem class
public class SBUCommonItem {
    
    /// Title of the item
    public var title: String?
    
    /// Color of the item
    public var color: UIColor?
    
    /// Image of the item
    public var image: UIImage?
    
    /// Font of the item
    public var font: UIFont?
    
    /// Tint color of the item
    public var tintColor: UIColor?
    
    /// Text alignment of the item
    public var textAlignment: NSTextAlignment
    
    /// Tag of the item
    public var tag: Int?
    
    /// Initializer for the SBUCommonItem class
    public init(title: String? = nil,
                color: UIColor? = SBUColorSet.onlight01,
                image: UIImage? = nil,
                font: UIFont? = nil,
                tintColor: UIColor? = nil,
                textAlignment: NSTextAlignment = .left,
                tag: Int? = nil) {
        
        self.title = title
        self.color = color
        self.image = image
        self.font = font
        self.tintColor = tintColor
        self.textAlignment = textAlignment
        self.tag = tag
    }
}
