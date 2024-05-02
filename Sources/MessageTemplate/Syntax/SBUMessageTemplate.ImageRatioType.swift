//
//  SBUMessageTemplate.ImageRatioType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MessageTemplateImageRatioType {
    var identifier: SBUMessageTemplate.Syntax.Identifier { get }
    
    var width: SBUMessageTemplate.Syntax.SizeSpec { get }
    var height: SBUMessageTemplate.Syntax.SizeSpec { get }
    
    var imageStyle: SBUMessageTemplate.Syntax.ImageStyle { get }
    var metaData: SBUMessageTemplate.Syntax.MetaData? { get }
}

extension MessageTemplateImageRatioType {
    var isImageView: Bool { self is SBUMessageTemplate.Syntax.Image }
    var isImageButton: Bool { self is SBUMessageTemplate.Syntax.ImageButton }
    
    func ratioConstraints(view: UIView) -> [NSLayoutConstraint] {
        guard let metaData = self.metaData else { return [] }
        
        let ratio = metaData.pixelWidth != 0
        ? CGFloat(metaData.pixelHeight) / CGFloat(metaData.pixelWidth)
        : 0
        let constraint = view.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ratio
        )
        
        return [constraint]
    }
    
    func minimumWrapConstraints(view: UIView) -> [NSLayoutConstraint] {
        view.sbu_constraint_greaterThan_v2(width: 1, height: 1, priority: .defaultLow)
    }
    
    func fixedHeightConstraints(view: UIView) -> [NSLayoutConstraint] {
        guard let metaData = self.metaData else { return [] }
        
        var ratio: CGFloat = 1
        
        if metaData.pixelHeight > metaData.pixelWidth, metaData.pixelWidth != 0 {
            ratio = CGFloat(metaData.pixelHeight) / CGFloat(metaData.pixelWidth)
        }
        if metaData.pixelWidth > metaData.pixelHeight, metaData.pixelHeight != 0 {
            ratio = CGFloat(metaData.pixelWidth) / CGFloat(metaData.pixelHeight)
        }
        
        let constraint = view.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ratio
        )
        
        return [constraint]
    }
    
    var imageRatioType: SBUMessageTemplate.Syntax.ImageRatioType {
        switch (self.width.internalSizeType, self.height.internalSizeType) {
        case (.fixed, .fixed): return .minimumWrap(cached: isImageView)
        case (.fixed, .fillParent):
            switch self.imageStyle.contentMode {
            case .scaleAspectFit: return .ratio
            case .scaleAspectFill: return .ratio
            case .scaleToFill: return isImageButton ? .minimumWrap() : .ratio
            default: break
            }
        case (.fixed, .wrapContent):
            switch self.imageStyle.contentMode {
            case .scaleAspectFit: return .ratio
            case .scaleAspectFill: return .ratio
            case .scaleToFill: return .ratio // QM-2657
            default: break
            }
        case (.fillParent, .fixed): return isImageButton ? .minimumWrap() : .fixedHeightRatio
        case (.fillParent, .fillParent): return .ratio
        case (.fillParent, .wrapContent): return .ratio
        case (.wrapContent, .fixed): return .ratio
        case (.wrapContent, .fillParent): return .minimumWrap()
        case (.wrapContent, .wrapContent): return isImageButton ? .minimumWrap() : .ratio
        default: break
        }
        
        return .unknown
    }
    
    var isRatioUsed: Bool { self.imageRatioType.isRatioUsed }
    
    func imagePlaceholderConstraints(view: UIView, saveCache: Bool) -> [NSLayoutConstraint] {
        switch self.imageRatioType {
        case .minimumWrap(let cached):
            if saveCache && cached {
                let size = CGSize.init(width: self.width.value,
                                       height: self.height.value)
                SBUCacheManager.TemplateImage.save(
                    messageId: self.identifier.messageId,
                    viewIndex: self.identifier.index,
                    size: size
                )
            }
            return self.minimumWrapConstraints(view: view)
        case .ratio:
            return self.ratioConstraints(view: view)
        case .fixedHeightRatio:
            return self.fixedHeightConstraints(view: view)
        case .unknown:
            return []
        }
    }
}
