//
//  MessageTemplateRenderer.Image.swift
//  QuickStart
//
//  Created by Jed Gyeong on 10/17/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import Foundation
import UIKit

extension MessageTemplateRenderer {
    func setImage(
        _ image: UIImage,
        imageSize: CGSize,
        imageView: MessageTemplateImageView,
        item: SBUMessageTemplate.Image,
        isRatioUsed: Bool,
        placeholderConstraints: [NSLayoutConstraint]
    ) {
        _ = image.sbu_with(
            tintColor: tintColor,
            forTemplate: true
        )

        if imageView.needResizeImage {
            imageView.image = image.resizeTopAlignedToFill(newWidth: imageSize.width)
        } else {
            imageView.image = image
        }
        
        imageView.layoutIfNeeded()
        
        self.rendererConstraints.forEach { $0.isActive = false }
        placeholderConstraints.forEach { $0.isActive = false }
        
        if isRatioUsed == true {
            let ratio = imageSize.height / imageSize.width
            
            let heightConst = imageView.heightAnchor.constraint(
                equalTo: imageView.widthAnchor,
                multiplier: ratio
            )
            heightConst.priority = .defaultHigh
            self.rendererConstraints.append(heightConst)
        }
        
        self.rendererConstraints.forEach { $0.isActive = true }
        
        if item.metaData == nil || !isRatioUsed {
            placeholderConstraints.forEach { $0.isActive = true }
            self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
        }
    }
}
