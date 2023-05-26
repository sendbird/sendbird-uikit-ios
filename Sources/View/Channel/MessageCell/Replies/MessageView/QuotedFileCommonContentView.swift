//
//  QuotedFileCommonContentView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2021/07/30.
//  Copyright © 2021 Sendbird, Inc. All rights reserved.
//

import UIKit
import SendbirdChatSDK

open class QuotedFileCommonContentView: SBUView {
    public var theme: SBUMessageCellTheme = SBUTheme.messageCellTheme
    public var position: MessagePosition = .center
    public internal(set) var fileURL: String = ""
    
    // + ------------- + ------------- +
    // | fileImageView | fileNameLabel |
    // + ------------- + ------------- +
    public var stackView: SBUStackView = SBUStackView(
        axis: .horizontal,
        alignment: .center,
        spacing: 8
    )
    
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
    
    open override func setupLayouts() {
        super.setupLayouts()
        
        self.sbu_constraint(height: 34)
        
        self.stackView
            .setConstraint(from: self, left: 12, right: 12, top: 6, bottom: 12)
        
        self.fileImageView
            .setConstraint(width: 16, height: 16)
    }
    
    open override func setupStyles() {
        self.layer.cornerRadius = 8
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 1
        self.clipsToBounds = true
        
        self.fileImageView.layer.cornerRadius = 8
        self.fileImageView.layer.borderColor = UIColor.clear.cgColor
        self.fileImageView.layer.borderWidth = 1
        
        super.setupStyles()
        
        self.fileImageView.backgroundColor = .clear
    }
    
    open func configure(
        with fileType: String,
        fileName: String,
        position: MessagePosition,
        highlightKeyword: String?
    ) {
        let fileType = SBUUtils.getFileType(by: fileType)
        
        self.configure(
            with: fileType,
            fileName: fileName,
            position: position,
            highlightKeyword: highlightKeyword
        )
    }
    
    /// Configures quoted file common content view with parameters.
    /// - Parameters:
    ///   - messageFileType: `SBUMessageFileType`enum
    ///   - fileName: File name
    ///   - position:`MessagePosition` enum
    ///   - highlightKeyword: (opt) highlight keyword
    ///
    /// - Since: 3.4.0
    open func configure(
        with messageFileType: SBUMessageFileType,
        fileName: String,
        position: MessagePosition,
        highlightKeyword: String?
    ) {
        let image: UIImage
        var fileName = fileName
        
        self.position = position
        
        self.fileImageView.isHidden = false
        
        // Icon image
        switch messageFileType {
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
        case .voice:
            image = UIImage()
            self.fileImageView.isHidden = true
            fileName = SBUStringSet.VoiceMessage.Preview.quotedMessage
        }
        
        self.fileImageView.image = image
        
        // File name
        var attributes: [NSAttributedString.Key: Any]
        var highlightTextColor: UIColor
        
        if messageFileType == .voice {
            attributes = [
                .font: theme.quotedMessageTextFont,
                .foregroundColor: theme.quotedMessageTextColor
            ]
        } else {
            attributes = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: theme.quotedMessageTextFont,
                .underlineColor: theme.quotedMessageTextColor,
                .foregroundColor: theme.quotedMessageTextColor
            ]
        }
        highlightTextColor = theme.messageLeftHighlightTextColor
        
        let attributedText = NSMutableAttributedString(
            string: fileName,
            attributes: attributes
        )
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
    
    open func addHighlight(keyword: String, toAttributedString attributedString: NSMutableAttributedString, highlightTextColor: UIColor) {
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
