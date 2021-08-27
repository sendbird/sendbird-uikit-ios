//
//  CustomChannelListCell.swift
//  SendBirdUIKit-Sample
//
//  Created by Tez Park on 2020/07/02.
//  Copyright © 2020 SendBird, Inc. All rights reserved.
//

import UIKit
import SendBirdSDK

class CustomChannelListCell: SBUBaseChannelCell {

    // MARK: - Properties
    @SBUAutoLayout var coverImage = UIImageView()
    @SBUAutoLayout var separatorLine = UIView()
    @SBUAutoLayout var titleLabel = UILabel()
    @SBUAutoLayout var titleStackView: UIStackView = {
        let titleStackView = UIStackView()
        titleStackView.alignment = .center
        titleStackView.spacing = 4.0
        titleStackView.axis = .horizontal
        return titleStackView
    }()
    
    let kCoverImageSize: CGFloat = 40
    
    // MARK: -
    override func setupViews() {
        super.setupViews()

        self.coverImage.clipsToBounds = true
        self.coverImage.frame = CGRect(x: 0, y: 0, width: kCoverImageSize, height: kCoverImageSize)
        self.contentView.addSubview(self.coverImage)
        
        self.titleStackView.addArrangedSubview(self.titleLabel)
        self.contentView.addSubview(titleStackView)

        self.contentView.addSubview(self.separatorLine)
    }
    
    override func setupAutolayout() {
        super.setupAutolayout()
        
        NSLayoutConstraint.activate([
            self.coverImage.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: 10
            ),
            self.coverImage.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -10
            ),
            self.coverImage.leadingAnchor.constraint(
                equalTo: self.contentView.leadingAnchor,
                constant: 16
            ),
            self.coverImage.widthAnchor.constraint(equalToConstant: kCoverImageSize),
            self.coverImage.heightAnchor.constraint(equalToConstant: kCoverImageSize),
        ])

        NSLayoutConstraint.activate([
            self.titleStackView.topAnchor.constraint(
                equalTo: self.contentView.topAnchor,
                constant: 10
            ),
            self.titleStackView.bottomAnchor.constraint(
                equalTo: self.contentView.bottomAnchor,
                constant: -10
            ),
            self.titleStackView.leadingAnchor.constraint(
                equalTo: self.coverImage.trailingAnchor,
                constant: 16
            ),
            self.titleStackView.rightAnchor.constraint(
                equalTo: self.contentView.rightAnchor,
                constant: -16),
        ])
        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        NSLayoutConstraint.activate([
            self.separatorLine.topAnchor.constraint(
                equalTo: self.coverImage.bottomAnchor,
                constant: -0.5
            ),
            self.separatorLine.leadingAnchor.constraint(
                equalTo: self.titleStackView.leadingAnchor,
                constant: 0
            ),
            self.separatorLine.trailingAnchor.constraint(
                equalTo: self.contentView.trailingAnchor,
                constant: -16
            ),
            self.separatorLine.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }

    override func setupStyles() {
        super.setupStyles()
        
        self.titleLabel.font = SBUTheme.channelCellTheme.titleFont
        self.titleLabel.textColor = SBUTheme.channelCellTheme.titleTextColor
        self.separatorLine.backgroundColor = SBUTheme.channelCellTheme.separatorLineColor
    }

    override func configure(channel: SBDBaseChannel) {
        super.configure(channel: channel)
        
        self.titleLabel.text = channel.name.count > 0 ? channel.name : "Empty channel"
        self.coverImage.image = UIImage(named: "img_default_profile_image_\(Int.random(in: 1 ... 4))")
        self.coverImage.layer.cornerRadius = kCoverImageSize/2
        self.coverImage.layer.masksToBounds = true
    }
}
