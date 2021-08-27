//
//  SBUOpenChannelMessageWebView.swift
//  SendBirdUIKit
//
//  Created by Jaesung Lee on 2020/11/30.
//  Copyright © 2020 Sendbird, Inc. All rights reserved.
//

import UIKit

class SBUOpenChannelMessageWebView: SBUMessageWebView {
    struct OpenChannelMetric {
        static let imageHeight: CGFloat = 164
        static let imageTopMargin: CGFloat = 12
        static let imageSideMargin: CGFloat = 8
        static let textSideMargin: CGFloat = 8
        static let titleBottomMargin: CGFloat = 4
        static let descBottomMargin: CGFloat = 8
        static let stackSpacing: CGFloat = 8
    }
    
    override func setupViews() {
        self.axis = .vertical
        self.addArrangedSubview(self.detailStackView)
        self.addArrangedSubview(self.imageView)
        self.detailStackView.addArrangedSubview(self.urlLabel)
        self.detailStackView.addArrangedSubview(self.titleLabel)
        self.detailStackView.addArrangedSubview(self.descriptionLabel)
    }
    
    override func setupStyles() {
        super.setupStyles()
        
        self.clipsToBounds = true
        self.imageView.clipsToBounds = true
    }
    
    override func setupAutolayout() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.isLayoutMarginsRelativeArrangement = true
        
        if #available(iOS 11.0, *) {
            self.directionalLayoutMargins = NSDirectionalEdgeInsets(
                top: OpenChannelMetric.textSideMargin,
                leading: OpenChannelMetric.textSideMargin,
                bottom: OpenChannelMetric.textSideMargin,
                trailing: OpenChannelMetric.textSideMargin
            )
        } else {
            self.layoutMargins = UIEdgeInsets(
                top: OpenChannelMetric.textSideMargin,
                left: OpenChannelMetric.textSideMargin,
                bottom: OpenChannelMetric.textSideMargin,
                right: OpenChannelMetric.textSideMargin
            )
        }
        
        let imageHeightConstraint = self.imageView.heightAnchor
            .constraint(equalToConstant: Metric.imageHeight)
        imageHeightConstraint.isActive = true
        self.imageHeightConstraint = imageHeightConstraint
        
        if #available(iOS 11.0, *) {
            self.setCustomSpacing(OpenChannelMetric.imageTopMargin, after: detailStackView)
        } else {
            self.spacing = OpenChannelMetric.imageTopMargin
        }
        
        if #available(iOS 11.0, *) {
            self.detailStackView.setCustomSpacing(
                Metric.titleBottomMargin,
                after: self.titleLabel
            )
            self.detailStackView.setCustomSpacing(
                Metric.descBottomMargin,
                after: self.descriptionLabel
            )
        } else {
            self.detailStackView.spacing = Metric.stackSpacing
        }
    }
    
    override func configure(model: SBUMessageWebViewModel) {
        self.descriptionLabel.numberOfLines = 2
        self.imageView.layer.cornerRadius = 8
        
        super.configure(model: model)
    }
}
