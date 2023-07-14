//
//  SBUCommonContentView.swift
//  SendbirdUIKit
//
//  Created by Hoon Sung on 2021/03/18.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class SBUCommonContentView: SBUBaseFileContentView {
    public var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    public var fileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .center
        return imageView
    }()
    public var fileNameLabel: UILabel = {
        let label = UILabel()
        label.lineBreakMode = .byTruncatingMiddle
        return label
    }()

    open override func setupViews() {
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
    
    open override func setupLayouts() {
        self.sbu_constraint(height: 44)
        self.stackView.setConstraint(from: self,
                                     left: 12,
                                     right: 12,
                                     top: 8,
                                     bottom: 8)
        self.fileImageView.setConstraint(width: 28, height: 28)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        switch position {
        case .left: self.backgroundColor = theme.leftBackgroundColor
        case .right: self.backgroundColor = theme.rightBackgroundColor
        default: break
        }
        self.fileImageView.backgroundColor = theme.fileIconBackgroundColor
    }
    
    open func configure(
        message: FileMessage,
        position: MessagePosition,
        highlightKeyword: String?
    ) {
        super.configure(message: message, position: position)
        
        if self.message?.requestId != message.requestId ||
            !message.isRequestIdValid ||
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
        case .voice:
            // The flow does not come here. (will be handled on `SBUVoiceContentView` class)
            image = UIImage()
            break
        }
        
        self.fileImageView.image = image
        
        var attributes: [NSAttributedString.Key: Any]
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
        
        let attributedText = NSMutableAttributedString(string: self.message.name, attributes: attributes)
        if let keyword = highlightKeyword {
            self.addHighlight(
                keyword: keyword,
                toAttributedString: attributedText,
                highlightTextColor: highlightTextColor
            )
        }
        self.fileNameLabel.attributedText = attributedText
        self.fileNameLabel.sizeToFit()
        
        self.setupStyles()
        
        self.layoutIfNeeded()
    }
    
    public func addHighlight(keyword: String, toAttributedString attributedString: NSMutableAttributedString, highlightTextColor: UIColor) {
        let highlightAll = keyword.isEmpty
        if highlightAll {
            let range = NSRange(location: 0, length: attributedString.length)
            attributedString.addAttributes(
                [
                    .backgroundColor: SBUColorSet.highlight,
                    .foregroundColor: highlightTextColor
                ],
                range: range
            )
        } else {
            var baseRange = NSRange(location: 0, length: attributedString.length)
            var ranges: [NSRange] = []
            // Loop until no more keyword found.
            while baseRange.location != NSNotFound {
                baseRange = (attributedString.string as NSString)
                    .range(
                        of: keyword,
                        options: .caseInsensitive,
                        range: baseRange
                    )
                ranges.append(baseRange)
                
                if baseRange.location != NSNotFound {
                    baseRange = NSRange(
                        location: NSMaxRange(baseRange),
                        length: attributedString.length - NSMaxRange(baseRange)
                    )
                }
            }
            ranges.forEach { (range) in
                attributedString.addAttributes(
                    [
                        .backgroundColor: SBUColorSet.highlight,
                        .foregroundColor: highlightTextColor
                    ],
                    range: range
                )
            }
        }
    }
}
