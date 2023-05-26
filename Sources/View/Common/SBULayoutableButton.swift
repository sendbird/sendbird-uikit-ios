//
//  SBULayoutableButton.swift
//  SendbirdUIKit
//
//  Created by Tez Park on 2020/07/21.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

// https://gist.github.com/gbitaudeau/6540847de8f5ee9f2e0393a00d2cb11e
public class SBULayoutableButton: UIButton {
    public enum LabelAlignment: Int {
        case right, left, under, top
    }
    
    public enum VerticalAlignment: String {
        case center, top, bottom, unset
    }
    
    public enum HorizontalAlignment: String {
        case center, left, right, unset
    }
    
    public var imageToTitleSpacing: CGFloat = 8.0 {
        didSet { setNeedsLayout() }
    }
    
    public var labelAlignment: LabelAlignment = .right {
        didSet { setNeedsLayout() }
    }
    
    public var imageVerticalAlignment: VerticalAlignment = .unset {
        didSet { setNeedsLayout() }
    }
    
    public var imageHorizontalAlignment: HorizontalAlignment = .unset {
        didSet { setNeedsLayout() }
    }
    
    var extraContentEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    public override var contentEdgeInsets: UIEdgeInsets {
        get {
            super.contentEdgeInsets
        }
        set {
            super.contentEdgeInsets = newValue
            self.extraContentEdgeInsets = newValue
        }
    }
    
    var extraImageEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    public override var imageEdgeInsets: UIEdgeInsets {
        get {
            super.imageEdgeInsets
        }
        set {
            super.imageEdgeInsets = newValue
            self.extraImageEdgeInsets = newValue
        }
    }
    
    var extraTitleEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
    
    public override var titleEdgeInsets: UIEdgeInsets {
        get {
            super.titleEdgeInsets
        }
        set {
            super.titleEdgeInsets = newValue
            self.extraTitleEdgeInsets = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init(gap: CGFloat, labelAlignment: LabelAlignment) {
        self.imageToTitleSpacing = gap
        self.labelAlignment = labelAlignment
        
        switch labelAlignment {
        case .right:
            self.imageVerticalAlignment = .center
            self.imageHorizontalAlignment = .left
        case .left:
            self.imageVerticalAlignment = .center
            self.imageHorizontalAlignment = .right
        case .under:
            self.imageVerticalAlignment = .top
            self.imageHorizontalAlignment = .center
        case .top:
            self.imageVerticalAlignment = .bottom
            self.imageHorizontalAlignment = .center
        }
        
        super.init(frame: .zero)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.imageEdgeInsets = super.imageEdgeInsets
        self.titleEdgeInsets = super.titleEdgeInsets
        self.contentEdgeInsets = super.contentEdgeInsets
    }
    
    public override func layoutSubviews() {
        if let imageSize = self.imageView?.image?.size,
            let font = self.titleLabel?.font,
            let textSize = self.titleLabel?.attributedText?.size()
                ?? self.titleLabel?.text?.size(
                    withAttributes: [NSAttributedString.Key.font: font]
            ) {
            
            var newImageEdgeInsets = UIEdgeInsets.zero
            var newTitleEdgeInsets = UIEdgeInsets.zero
            var newContentEdgeInsets = UIEdgeInsets.zero
            
            let halfImageToTitleSpacing = imageToTitleSpacing / 2.0
            
            switch imageVerticalAlignment {
            case .bottom:
                newImageEdgeInsets.top = (textSize.height + imageToTitleSpacing) / 2.0
                newImageEdgeInsets.bottom = (-textSize.height - imageToTitleSpacing) / 2.0
                newTitleEdgeInsets.top = (-imageSize.height - imageToTitleSpacing) / 2.0
                newTitleEdgeInsets.bottom = (imageSize.height + imageToTitleSpacing) / 2.0
                newContentEdgeInsets.top = (min(imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                newContentEdgeInsets.bottom = (min(imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                contentVerticalAlignment = .center
            case .top:
                newImageEdgeInsets.top = (-textSize.height - imageToTitleSpacing) / 2.0
                newImageEdgeInsets.bottom = (textSize.height + imageToTitleSpacing) / 2.0
                newTitleEdgeInsets.top = (imageSize.height + imageToTitleSpacing) / 2.0
                newTitleEdgeInsets.bottom = (-imageSize.height - imageToTitleSpacing) / 2.0
                newContentEdgeInsets.top = (min(imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                newContentEdgeInsets.bottom = (min(imageSize.height, textSize.height) + imageToTitleSpacing) / 2.0
                contentVerticalAlignment = .center
            case .center:
                contentVerticalAlignment = .center
                break
            case .unset:
                break
            }
            
            switch imageHorizontalAlignment {
            case .left:
                newImageEdgeInsets.left = -halfImageToTitleSpacing
                newImageEdgeInsets.right = halfImageToTitleSpacing
                newTitleEdgeInsets.left = halfImageToTitleSpacing
                newTitleEdgeInsets.right = -halfImageToTitleSpacing
                newContentEdgeInsets.left = halfImageToTitleSpacing
                newContentEdgeInsets.right = halfImageToTitleSpacing
            case .right:
                newImageEdgeInsets.left = textSize.width + halfImageToTitleSpacing
                newImageEdgeInsets.right = -textSize.width - halfImageToTitleSpacing
                newTitleEdgeInsets.left = -imageSize.width - halfImageToTitleSpacing
                newTitleEdgeInsets.right = imageSize.width + halfImageToTitleSpacing
                newContentEdgeInsets.left = halfImageToTitleSpacing
                newContentEdgeInsets.right = halfImageToTitleSpacing
            case .center:
                newImageEdgeInsets.left = textSize.width / 2.0
                newImageEdgeInsets.right = -textSize.width / 2.0
                newTitleEdgeInsets.left = -imageSize.width / 2.0
                newTitleEdgeInsets.right = imageSize.width / 2.0
                newContentEdgeInsets.left = -((imageSize.width + textSize.width) - max(imageSize.width, textSize.width)) / 2.0
                newContentEdgeInsets.right = -((imageSize.width + textSize.width) - max(imageSize.width, textSize.width)) / 2.0
            case .unset:
                break
            }
            
            newContentEdgeInsets.top += extraContentEdgeInsets.top
            newContentEdgeInsets.bottom += extraContentEdgeInsets.bottom
            newContentEdgeInsets.left += extraContentEdgeInsets.left
            newContentEdgeInsets.right += extraContentEdgeInsets.right
            
            newImageEdgeInsets.top += extraImageEdgeInsets.top
            newImageEdgeInsets.bottom += extraImageEdgeInsets.bottom
            newImageEdgeInsets.left += extraImageEdgeInsets.left
            newImageEdgeInsets.right += extraImageEdgeInsets.right
            
            newTitleEdgeInsets.top += extraTitleEdgeInsets.top
            newTitleEdgeInsets.bottom += extraTitleEdgeInsets.bottom
            newTitleEdgeInsets.left += extraTitleEdgeInsets.left
            newTitleEdgeInsets.right += extraTitleEdgeInsets.right
            
            super.imageEdgeInsets = newImageEdgeInsets
            super.titleEdgeInsets = newTitleEdgeInsets
            super.contentEdgeInsets = newContentEdgeInsets
            
        } else {
            super.imageEdgeInsets = extraImageEdgeInsets
            super.titleEdgeInsets = extraTitleEdgeInsets
            super.contentEdgeInsets = extraContentEdgeInsets
        }
        
        super.layoutSubviews()
    }
}
