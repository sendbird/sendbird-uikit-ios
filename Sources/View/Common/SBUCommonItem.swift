//
//  SBUCommonItem.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 17/02/2020.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

public class SBUCommonItem {
    public var title: String?
    public var color: UIColor?
    public var image: UIImage?
    public var font: UIFont?
    public var tintColor: UIColor?
    public var textAlignment: NSTextAlignment
    public var tag: Int?
    
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
