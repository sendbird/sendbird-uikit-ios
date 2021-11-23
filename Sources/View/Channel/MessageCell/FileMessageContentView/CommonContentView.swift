//
//  CommonContentView.swift
//  SendBirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class CommonContentView: BaseFileContentView {
    var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    var fileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    var fileNameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    override func setupViews() {
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.fileImageView.layer.cornerRadius = 8
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1
        
        self.addSubview(self.stackView)
        
        self.stackView.addArrangedSubview(self.fileImageView)
        self.stackView.addArrangedSubview(self.fileNameLabel)
    }
    
    override func setupAutolayout() {
        self.sbu_constraint(height: 44)
        self.stackView.setConstraint(from: self,
                                     left: 12,
                                     right: 12,
                                     top: 8,
                                     bottom: 8)
        self.fileImageView.setConstraint(width: 28, height: 28)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        switch position {
        case .left: self.backgroundColor = theme.leftBackgroundColor
        case .right: self.backgroundColor = theme.rightBackgroundColor
        default: break
        }
        self.fileImageView.backgroundColor = theme.fileIconBackgroundColor
    }
    
    func configure(message: SBDFileMessage,
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
                to: SBUIconSetType.Metric.defaultIconSize
            )
        case .image, .video, .pdf, .etc:
            image = SBUIconSetType.iconFileDocument.image(
                with: theme.fileIconColor,
                to: SBUIconSetType.Metric.defaultIconSize
            )
        }
        
        self.fileImageView.image = image
        
        var attributes: [NSAttributedString.Key : Any]
        var highlightTextColor: UIColor
        
        switch position {
        case .left:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageLeftTextColor,
                .foregroundColor: theme.fileMessageLeftTextColor
            ]
            highlightTextColor = theme.messageLeftHighlightTextColor
        case .right:
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.fileMessageNameFont,
                .underlineColor: theme.fileMessageRightTextColor,
                .foregroundColor: theme.fileMessageRightTextColor
            ]
            highlightTextColor = theme.messageRightHighlightTextColor
        default:
            attributes = [:]
            highlightTextColor = theme.messageRightHighlightTextColor
        }
        
        if highlight {
            attributes[.backgroundColor] = SBUColorSet.highlight
            attributes[.foregroundColor] = highlightTextColor
        }
        
        let attributedText = NSAttributedString(string: self.message.name, attributes: attributes)
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
}
