//
//  SBUMessageWebView.swift
//  SendbirdUIKit
//
//  Created by Wooyoung Chung on 7/9/20.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A view shows preview of web link on the message.
open class SBUMessageWebView: UIStackView, SBUViewLifeCycle {
    public struct Metric {
        public static var imageHeight = 136.f
        public static var textTopMargin = 8.f
        public static var textSideMargin = 12.f
        public static var titleBottomMargin = 4.f
        public static var descBottomMargin = 8.f
        public static var maxWidth = SBUConstant.messageCellMaxWidth
        public static var stackSpacing = 8.f
        /// Read-only.
        public static let textMaxPrefWidth = Metric.maxWidth - Metric.textSideMargin * 2
    }
    
    /// An image view that represents the web link.
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    public let detailStackView = SBUStackView(axis: .vertical)
    
    /// A label that represents a title of the web link
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 10
        label.preferredMaxLayoutWidth = Metric.textMaxPrefWidth
        return label
    }()
    
    /// A label that shows a description of the web link
    public let descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    /// A label that shows the URL
    public let urlLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    public var imageHeightConstraint: NSLayoutConstraint?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupViews()
        self.setupLayouts()
    }
    
    public required init(coder: NSCoder) {
        super.init(coder: coder)
        self.setupViews()
        self.setupLayouts()
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.setupStyles()
    }
    
    open func setupViews() {
        self.axis = .vertical
        self.setVStack([
            self.imageView,
            self.detailStackView.setVStack([
                self.titleLabel,
                self.descriptionLabel,
                self.urlLabel
            ])
        ])
    }
    
    open func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        let imageHeightConstraint = self.imageView.heightAnchor
            .constraint(equalToConstant: Metric.imageHeight)
        imageHeightConstraint.isActive = true
        self.imageHeightConstraint = imageHeightConstraint
        
        self.imageView.widthAnchor
            .constraint(lessThanOrEqualToConstant: Metric.maxWidth).isActive = true
        
        self.detailStackView.translatesAutoresizingMaskIntoConstraints = false
        self.detailStackView.isLayoutMarginsRelativeArrangement = true
        
        self.detailStackView.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: Metric.textTopMargin,
            leading: Metric.textSideMargin,
            bottom: Metric.textSideMargin,
            trailing: Metric.textSideMargin
        )
        
        self.detailStackView.setCustomSpacing(
            Metric.titleBottomMargin,
            after: self.titleLabel
        )
        self.detailStackView.setCustomSpacing(
            Metric.descBottomMargin,
            after: self.descriptionLabel
        )
    }
    
    open func updateLayouts() { }
    
    open func setupStyles() { }
    
    open func updateStyles() { }
    
    open func setupActions() { }

    open func configure(model: SBUMessageWebViewModel) {
        if let imageURL = model.imageURL {
            self.imageView.loadImage(
                urlString: imageURL,
                placeholder: model.placeHolderImage,
                errorImage: model.errorImage,
                option: .imageToThumbnail,
                subPath: SBUCacheManager.PathType.web
            ) { success in
                DispatchQueue.main.async { [weak self] in
                    self?.imageView.contentMode = !success ? .center : .scaleAspectFill
                }
            }
            self.imageView.isHidden = false
            self.imageHeightConstraint?.isActive = true
        } else {
            self.imageView.isHidden = true
            self.imageHeightConstraint?.isActive = false
        }
        
        if let titleText = model.titleAttributedText {
            self.titleLabel.attributedText = titleText
            self.titleLabel.isHidden = false
        } else {
            self.titleLabel.isHidden = true
        }
        
        if let descText = model.descAttributedText {
            self.descriptionLabel.attributedText = descText
            self.descriptionLabel.isHidden = false
        } else {
            self.descriptionLabel.isHidden = true
        }
        
        if let urlText = model.urlAttributedText {
            self.urlLabel.attributedText = urlText
            self.urlLabel.isHidden = false
        } else {
            self.urlLabel.isHidden = true
        }
    }
}
