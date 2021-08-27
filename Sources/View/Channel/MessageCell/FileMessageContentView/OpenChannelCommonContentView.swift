//
//  OpenChannelCommonContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class OpenChannelCommonContentView: CommonContentView {
    
    override func setupAutolayout() {
        self.sbu_constraint(height: 56)
        self.stackView.setConstraint(from: self,
                                     left: 12,
                                     right: 12,
                                     top: 8,
                                     bottom: 8)
        self.fileImageView.setConstraint(width: 40, height: 40)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        self.backgroundColor = theme.contentBackgroundColor
        self.fileImageView.backgroundColor = theme.fileIconBackgroundColor
    }
    
    override func configure(message: SBDFileMessage,
                   position: MessagePosition,
                   highlight: Bool) {
        super.configure(message: message, position: position)
        
        if self.message?.requestId != message.requestId ||
            self.message?.updatedAt != message.updatedAt {
            self.fileImageView.image = nil
        }
        
        let type = SBUUtils.getFileType(by: message)
        
        let image: UIImage
        switch type {
        case .audio:
            image = SBUIconSetType.iconFileAudio.image(
                with: theme.fileIconColor,
                to: SBUIconSetType.Metric.defaultIconSizeLarge
            )
        case .image, .video, .pdf, .etc:
            image = SBUIconSetType.iconFileDocument.image(
                with: theme.fileIconColor,
                to: SBUIconSetType.Metric.defaultIconSizeLarge
            )
        }
        
        self.fileImageView.image = image
        
        let attributes: [NSAttributedString.Key : Any] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: theme.fileMessageNameFont,
            .underlineColor: theme.fileMessageLeftTextColor,
            .foregroundColor: theme.fileMessageLeftTextColor
        ]
        
        let attributedText = NSAttributedString(string: self.message.name, attributes: attributes)
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
}
