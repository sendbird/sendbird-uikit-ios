//
//  QuotedFileCommonContentView.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2021/07/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class QuotedFileCommonContentView: SBUView {
    var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    var position: MessagePosition = .center
    var fileURL: String = ""
    
    // + ------------- + ------------- +
    // | fileImageView | fileNameLabel |
    // + ------------- + ------------- +
    var stackView: SBUStackView = SBUStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: 8
    )
    
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
        super.setupViews()
        
        self.addSubview(self.stackView)
        
        // + ------------- + ------------- +
        // | fileImageView | fileNameLabel |
        // + ------------- + ------------- +
        
        self.stackView.setHStack([
            self.fileImageView,
            self.fileNameLabel
        ])
    }
    
    override func setupAutolayout() {
        super.setupAutolayout()
        
        self.sbu_constraint(height: 34)
        
        self.stackView
            .setConstraint(from: self, left: 12, right: 12, top: 6, bottom: 12)
        
        self.fileImageView
            .setConstraint(width: 16, height: 16)
    }
    
    override func setupStyles() {
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.fileImageView.layer.cornerRadius = 8
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1
        
        super.setupStyles()
        
        switch position {
            case .left: self.backgroundColor = theme.leftBackgroundColor
            case .right: self.backgroundColor = theme.rightBackgroundColor
            default: break
        }
        self.fileImageView.backgroundColor = .clear
    }
    
    func configure(with fileType: String, fileName: String, position: MessagePosition, highlight: Bool) {
        let image: UIImage
        let fileType = SBUUtils.getFileType(by: fileType)
        
        // Icon image
        switch fileType {
            case .audio:
                image = SBUIconSetType.iconFileAudio.image(
                    with: theme.quotedFileMessageThumbnailColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
            case .image, .video, .pdf, .etc:
                image = SBUIconSetType.iconFileDocument.image(
                    with: theme.quotedFileMessageThumbnailColor,
                    to: SBUIconSetType.Metric.defaultIconSizeSmall
                )
        }
        
        self.fileImageView.image = image
        
        // File name
        var attributes: [NSAttributedString.Key : Any]
        var highlightTextColor: UIColor
        
        attributes = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .font: theme.quotedMessageTextFont,
            .underlineColor: theme.quotedMessageTextColor,
            .foregroundColor: theme.quotedMessageTextColor
        ]
        highlightTextColor = theme.messageLeftHighlightTextColor
        
        if highlight {
            attributes[.backgroundColor] = SBUColorSet.highlight
            attributes[.foregroundColor] = highlightTextColor
        }
        
        let attributedText = NSAttributedString(
            string: fileName,
            attributes: attributes
        )
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
}
