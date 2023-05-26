//
//  SBUMessageWebViewModel.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/9/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

public class SBUMessageWebViewModel {
    public var imageURL: String?
    public var titleAttributedText: NSAttributedString?
    public var descAttributedText: NSAttributedString?
    public var urlAttributedText: NSAttributedString?
    public var placeHolderImage: UIImage?
    public var errorImage: UIImage?
    
    public init(metaData: OGMetaData?, isOverlay: Bool = false, isOpenChannel: Bool = false) {
        let theme = isOverlay ? SBUTheme.overlayTheme.messageCellTheme : SBUTheme.messageCellTheme
        let imageData = metaData?.defaultImage
        
        if let title = metaData?.title {
            var attributes = self.applyLinebreak(SBUFontSet.body2Attributes)
            attributes[.foregroundColor] = isOpenChannel
            ? theme.openChannelOGTitleColor
            : theme.ogTitleColor
            attributes[.font] = theme.ogTitleFont
            let attributedString = NSMutableAttributedString(
                string: title,
                attributes: attributes
            )
            self.titleAttributedText = attributedString
        }
        
        if let desc = metaData?.desc {
            var attributes = self.applyLinebreak(SBUFontSet.caption2Attributes)
            attributes[.foregroundColor] = theme.ogDescriptionColor
            attributes[.font] = theme.ogDescriptionFont
            let attributedString = NSMutableAttributedString(
                string: desc,
                attributes: attributes
            )
            self.descAttributedText = attributedString
        }
        
        if let url = metaData?.url {
            var attributes = self.applyLinebreak(SBUFontSet.caption2Attributes)
            attributes[.foregroundColor] = theme.ogURLAddressColor
            attributes[.font] = theme.ogURLAddressFont
            let attributedString = NSMutableAttributedString(
                string: url,
                attributes: attributes
            )
            self.urlAttributedText = attributedString
        }
                
        self.imageURL = imageData?.secureURL ?? imageData?.url
        self.placeHolderImage = SBUIconSetType.iconPhoto.image(
            with: theme.fileMessagePlaceholderColor,
            to: SBUIconSetType.Metric.defaultIconSizeVeryLarge
        )
        self.errorImage = SBUIconSetType.iconThumbnailNone.image(
            with: theme.fileMessagePlaceholderColor,
            to: SBUIconSetType.Metric.defaultIconSizeVeryLarge
        )
    }
    
    private func applyLinebreak(_ attributes: [NSAttributedString.Key: Any]) -> [NSAttributedString.Key: Any] {
        var newAttributes = attributes
        if let paragraphStyle = attributes[.paragraphStyle] as? NSMutableParagraphStyle {
            paragraphStyle.lineBreakMode = .byTruncatingTail
            newAttributes[.paragraphStyle] = paragraphStyle
        } else {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineBreakMode = .byTruncatingTail
            newAttributes[.paragraphStyle] = paragraphStyle
        }
        return newAttributes
    }
}
