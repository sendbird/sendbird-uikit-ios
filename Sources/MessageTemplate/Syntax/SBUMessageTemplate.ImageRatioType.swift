//
//  SBUMessageTemplate.ImageRatioType.swift
//  SendbirdUIKit
//
//  Created by Damon Park on 2024/04/24.
//  Copyright © 2024 Sendbird, Inc. All rights reserved.
//

import UIKit

protocol MessageTemplateImageRatioType where Self: SBUMessageTemplate.Syntax.View {
    var identifier: SBUMessageTemplate.Syntax.Identifier { get }
    
    var imageUrl: String { get }
    
    var width: SBUMessageTemplate.Syntax.SizeSpec { get }
    var height: SBUMessageTemplate.Syntax.SizeSpec { get }
    
    var imageStyle: SBUMessageTemplate.Syntax.ImageStyle { get }
    var metaData: SBUMessageTemplate.Syntax.MetaData? { get }
}

extension MessageTemplateImageRatioType {
    var isImageView: Bool { self is SBUMessageTemplate.Syntax.Image }
    var isImageButton: Bool { self is SBUMessageTemplate.Syntax.ImageButton }
    
    var isForDownloadingTemplate: Bool {
        self.imageUrl == SBUMessageTemplate.urlForTemplateDownload
    }
    
    var isRatioUsed: Bool { self.imageRatioType.isRatioUsed }
    
    var imageRatioType: SBUMessageTemplate.Syntax.ImageRatioType {
        // [VALID_CASE](https://sendbird.atlassian.net/wiki/spaces/UK/pages/2008220608/Message+template+-+Image+policy#Valid-cases)
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
}

// MARK: - placeholder constraints
extension MessageTemplateImageRatioType {
    
    func ratioPlaceholderConstraints(view: UIView) -> [NSLayoutConstraint] {
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
    
    func minimumWrapPlaceholderConstraints(view: UIView) -> [NSLayoutConstraint] {
        view.sbu_constraint_greaterThan_v2(width: 1, height: 1, priority: .defaultLow)
    }
    
    func fixedHeightPlaceholderConstraints(view: UIView) -> [NSLayoutConstraint] {
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
            return self.minimumWrapPlaceholderConstraints(view: view)
        case .ratio:
            return self.ratioPlaceholderConstraints(view: view)
        case .fixedHeightRatio:
            return self.fixedHeightPlaceholderConstraints(view: view)
        case .unknown:
            return []
        }
    }
}

extension MessageTemplateImageRatioType {
    var expectedImageSize: CGSize? {
        guard let size = SBUCacheManager.TemplateImage.load(
            messageId: self.identifier.messageId,
            viewIndex: self.identifier.index
        ), size.width > 0 else { return nil }
        return size
    }
    
    var needResizeImage: Bool {
        if self.isForDownloadingTemplate { return false }
        
        switch (width.internalSizeType, height.internalSizeType) {
        case (.fixed, .wrapContent): return true
        case (.fillParent, .wrapContent): return true
        default: return false
        }
    }
    
    func imageViewContentMode(with align: SBUMessageTemplate.Syntax.ItemsAlign) -> UIView.ContentMode {
        if self.needResizeImage == false { return imageStyle.contentMode }
        return align.imageViewContentMode ?? imageStyle.contentMode
    }
    
    func ratioConstraintsBySize(_ size: CGSize, view: UIView) -> [NSLayoutConstraint] {
        guard self.isRatioUsed == true else { return [] }
        
        // NOTE: Added defensive code for crash when image size is zero.
        guard size.width > 0, size.height > 0 else { return [] }
        
        let ratio = size.height / size.width
        
        let heightConstraint = view.heightAnchor.constraint(
            equalTo: view.widthAnchor,
            multiplier: ratio
        )
        heightConstraint.priority = .defaultHigh
        
        return [heightConstraint]
    }
    
    func haveToUseRatio() -> Bool {
        // If size is not available due to lack of meta-data.
        if self.metaData?.isValid == true { return false }
        
        // Failure to calculate the image ratio (using ratio = not being able to predict the image size in advance).
        if self.isRatioUsed == false { return false }
        
        if self.expectedImageSize != nil { return false }
        
        return true
    }
}
