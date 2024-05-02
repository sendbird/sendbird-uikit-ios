//
//  SBUMessageTemplate.Renderer.Image.swift
//
//  Created by Jed Gyeong on 10/17/23.
//  Copyright © 2023 SendBird, Inc. All rights reserved.
//

import Foundation
import UIKit

extension SBUMessageTemplate.Renderer {
    func setImage(
        _ image: UIImage,
        imageSize: CGSize,
        imageView: SBUMessageTemplate.Renderer.ImageView,
        item: SBUMessageTemplate.Syntax.Image,
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
            // NOTE: Added defensive code for crash when image size is zero.
            if imageSize.width > 0, imageSize.height > 0 {
                let ratio = imageSize.height / imageSize.width

                let heightConst = imageView.heightAnchor.constraint(
                    equalTo: imageView.widthAnchor,
                    multiplier: ratio
                )
                heightConst.priority = .defaultHigh
                self.rendererConstraints.append(heightConst)
            }
        }
        
        self.rendererConstraints.forEach { $0.isActive = true }
        
        if item.metaData == nil || !isRatioUsed {
            placeholderConstraints.forEach { $0.isActive = true }
            self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
        }
    }
}
