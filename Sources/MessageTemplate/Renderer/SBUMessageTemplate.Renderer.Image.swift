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
        imageView: SBUMessageTemplate.Renderer.ImageView,
        imageType: MessageTemplateImageRatioType,
        placeholderConstraints: [NSLayoutConstraint]
    ) {
        let item = imageType as SBUMessageTemplate.Syntax.View
        let image = image.sbu_with(
            tintColor: imageType.imageStyle.tintColorValue,
            forTemplate: true
        )
        imageView.identifier = item.identifier
        imageView.originalImage = image
        
        self.rendererConstraints.forEach { $0.isActive = false }
        placeholderConstraints.forEach { $0.isActive = false }
        
        imageView.setNeedsLayout()
        
        self.rendererConstraints += imageType.ratioConstraintsBySize(image.size, view: imageView)
        self.rendererConstraints.forEach { $0.isActive = true }
        
        if imageType.haveToUseRatio() == true {
            placeholderConstraints.forEach { $0.isActive = true }
            self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
        }
    }
}
    
extension SBUMessageTemplate.Renderer {
    func setImageButton(
        _ button: ImageButton,
        item: SBUMessageTemplate.Syntax.ImageButton,
        placeholderConstraints: [NSLayoutConstraint]
    ) {
        guard let imageView = button.imageView else { return }
        
        let image = imageView.image?.sbu_with(
            tintColor: item.imageStyle.tintColorValue,
            forTemplate: true
        )
        
        button.setImage(image, for: .normal)
        button.setNeedsLayout()
        
        if let size = imageView.image?.size {
            self.rendererConstraints.forEach { $0.isActive = false }
            placeholderConstraints.forEach { $0.isActive = false }
            
            self.rendererConstraints += item.ratioConstraintsBySize(size, view: button)
            self.rendererConstraints.forEach { $0.isActive = true }
            
            if item.haveToUseRatio() == true {
                self.delegate?.messageTemplateRender(self, didFinishLoadingImage: imageView)
            }
        }
    }
}
