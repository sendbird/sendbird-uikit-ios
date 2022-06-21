//
//  SBUOpenChannelMessageWebView.swift
//  SendbirdUIKit
//
//  Created by Jaesung Lee on 2020/11/30.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

/// A view shows preview of web link on the message in the open channel.
open class SBUOpenChannelMessageWebView: SBUMessageWebView {
    public struct OpenChannelMetric {
        public static var imageHeight: CGFloat = 164
        public static var imageTopMargin: CGFloat = 12
        public static var imageSideMargin: CGFloat = 8
        public static var textSideMargin: CGFloat = 8
        public static var titleBottomMargin: CGFloat = 4
        public static var descBottomMargin: CGFloat = 8
        public static var stackSpacing: CGFloat = 8
    }
    
    open override func setupViews() {
        self.axis = .vertical
        self.addArrangedSubview(self.detailStackView)
        self.addArrangedSubview(self.imageView)
        self.detailStackView.addArrangedSubview(self.urlLabel)
        self.detailStackView.addArrangedSubview(self.titleLabel)
        self.detailStackView.addArrangedSubview(self.descriptionLabel)
    }
    
    open override func setupStyles() {
        super.setupStyles()
        
        self.clipsToBounds = true
        self.imageView.clipsToBounds = true
    }
    
    open override func setupLayouts() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isLayoutMarginsRelativeArrangement = true
        
        self.directionalLayoutMargins = NSDirectionalEdgeInsets(
            top: OpenChannelMetric.textSideMargin,
            leading: OpenChannelMetric.textSideMargin,
            bottom: OpenChannelMetric.textSideMargin,
            trailing: OpenChannelMetric.textSideMargin
        )
        
        let imageHeightConstraint = self.imageView.heightAnchor
            .constraint(equalToConstant: Metric.imageHeight)
        imageHeightConstraint.isActive = true
        self.imageHeightConstraint = imageHeightConstraint
        
        self.setCustomSpacing(OpenChannelMetric.imageTopMargin, after: detailStackView)
        
        self.detailStackView.setCustomSpacing(
            Metric.titleBottomMargin,
            after: self.titleLabel
        )
        self.detailStackView.setCustomSpacing(
            Metric.descBottomMargin,
            after: self.descriptionLabel
        )
    }
    
    open override func configure(model: SBUMessageWebViewModel) {
        self.descriptionLabel.numberOfLines = 2
        self.imageView.layer.cornerRadius = 8
        
        super.configure(model: model)
    }
}
